import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mitril_play/backend/sql.dart';
import 'package:mitril_play/models/channel.dart';
import 'package:mitril_play/models/media_type.dart';
import 'package:mitril_play/error.dart';
import 'package:mitril_play/backend/xtream.dart';
import 'package:mitril_play/memory.dart';
import 'package:mitril_play/models/node.dart';
import 'package:mitril_play/models/node_type.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as path;

class ChannelTile extends StatefulWidget {
  final Channel channel;
  final BuildContext parentContext;
  final Function(Node node) setNode;
  final String? groupName;
  const ChannelTile(
      {super.key,
      required this.channel,
      required this.setNode,
      required this.parentContext,
      this.groupName});

  @override
  State<ChannelTile> createState() => _ChannelTileState();
}

class _ChannelTileState extends State<ChannelTile> {
  final FocusNode _focusNode = FocusNode();
  Process? _playerProcess;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _killPlayer();
    super.dispose();
  }

  void _killPlayer() {
    if (_playerProcess != null) {
      try {
        _playerProcess!.kill();
      } catch (e) {
        debugPrint('Erro ao matar player: $e');
      }
      _playerProcess = null;
    }
  }

  Future<void> favorite() async {
    if (widget.channel.mediaType == MediaType.group) return;
    await Error.tryAsyncNoLoading(() async {
      await Sql.favoriteChannel(widget.channel.id!, !widget.channel.favorite);
      setState(() {
        widget.channel.favorite = !widget.channel.favorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Added to favorites"),
        duration: Duration(milliseconds: 500),
      ));
    }, context);
  }

  Future<void> play() async {
    if (widget.channel.mediaType == MediaType.group ||
        widget.channel.mediaType == MediaType.serie) {
      if (widget.channel.mediaType == MediaType.serie &&
          !refreshedSeries.contains(widget.channel.id)) {
        await Error.tryAsync(() async {
          await getEpisodes(widget.channel);
          refreshedSeries.add(widget.channel.id!);
        }, widget.parentContext, null, true, false);
      }
      widget.setNode(Node(
          id: widget.channel.mediaType == MediaType.group
              ? widget.channel.id!
              : int.parse(widget.channel.url!),
          name: widget.channel.name,
          type: fromMediaType(widget.channel.mediaType)));
    } else {
      // Usar player externo
      Sql.addToHistory(widget.channel.id!);
      await _openExternalPlayer();
    }
  }

  Future<void> _openExternalPlayer() async {
    try {
      final url = widget.channel.url;
      if (url == null || url.isEmpty) {
        throw Exception('URL do canal inválida');
      }

      // Obter headers para o player
      final headers = await Sql.getChannelHeaders(widget.channel.id!);
      
      if (Platform.isWindows) {
        await _openWindowsPlayer(url, headers);
      } else if (Platform.isLinux) {
        await _openLinuxPlayer(url, headers);
      } else {
        // Fallback para mobile
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      debugPrint('Erro ao abrir player externo: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao reproduzir: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _openWindowsPlayer(String url, dynamic headers) async {
    // Procurar players na pasta Players (relativa ao executável)
    final executablePath = Platform.resolvedExecutable;
    final executableDir = Directory(executablePath).parent;
    final playersDir = Directory(path.join(executableDir.path, 'Players'));
    
    if (!await playersDir.exists()) {
      throw Exception('Pasta Players não encontrada em: ${playersDir.path}\n\nCrie a pasta Players junto com o executável e coloque mpv.exe ou vlc.exe lá.');
    }

    // Tentar MPV primeiro
    final mpvPath = path.join(playersDir.path, 'mpv', 'mpv.exe');
    final mpvAltPath = path.join(playersDir.path, 'mpv.exe');
    
    if (await File(mpvPath).exists()) {
      debugPrint('Usando MPV: $mpvPath');
      _playerProcess = await Process.start(
        mpvPath,
        [url, '--no-terminal'],
        runInShell: true,
      );
      _monitorPlayer();
      return;
    }
    
    if (await File(mpvAltPath).exists()) {
      debugPrint('Usando MPV (alternativo): $mpvAltPath');
      _playerProcess = await Process.start(
        mpvAltPath,
        [url, '--no-terminal'],
        runInShell: true,
      );
      _monitorPlayer();
      return;
    }

    // Tentar VLC
    final vlcPath = path.join(playersDir.path, 'vlc', 'vlc.exe');
    final vlcAltPath = path.join(playersDir.path, 'vlc.exe');
    final vlcProgramFiles = r'C:\Program Files\VideoLAN\VLC\vlc.exe';
    final vlcProgramFilesX86 = r'C:\Program Files (x86)\VideoLAN\VLC\vlc.exe';
    
    final vlcPaths = [vlcPath, vlcAltPath, vlcProgramFiles, vlcProgramFilesX86];
    
    for (final vlcPath in vlcPaths) {
      if (await File(vlcPath).exists()) {
        debugPrint('Usando VLC: $vlcPath');
        _playerProcess = await Process.start(
          vlcPath,
          [url],
          runInShell: true,
        );
        _monitorPlayer();
        return;
      }
    }

    throw Exception('Nenhum player encontrado.\n\nColoque na pasta Players:\n- mpv.exe\n  ou\n- vlc.exe');
  }

  Future<void> _openLinuxPlayer(String url, dynamic headers) async {
    // Procurar players na pasta Players (relativa ao executável)
    final executablePath = Platform.resolvedExecutable;
    final executableDir = Directory(executablePath).parent;
    final playersDir = Directory(path.join(executableDir.path, 'Players'));

    // Tentar players do sistema PRIMEIRO (mais confiável)
    if (await _commandExists('mpv')) {
      debugPrint('Usando MPV do sistema');
      _playerProcess = await Process.start(
        'mpv',
        [url, '--no-terminal'],
        runInShell: true,
      );
      _monitorPlayer();
      return;
    }

    if (await _commandExists('vlc')) {
      debugPrint('Usando VLC do sistema');
      _playerProcess = await Process.start(
        'vlc',
        [url],
        runInShell: true,
      );
      _monitorPlayer();
      return;
    }

    // Fallback: procurar AppImage na pasta Players
    if (!await playersDir.exists()) {
      throw Exception('Nenhum player encontrado.\n\nInstale mpv ou vlc no sistema:\n  sudo dnf install mpv vlc\n\nOu crie a pasta Players e coloque mpv.AppImage ou vlc.AppImage.');
    }

    // Tentar MPV AppImage
    final mpvAppImage = path.join(playersDir.path, 'mpv.AppImage');

    if (await File(mpvAppImage).exists()) {
      debugPrint('Usando MPV AppImage: $mpvAppImage');
      _playerProcess = await Process.start(
        mpvAppImage,
        [url, '--no-terminal'],
        runInShell: true,
      );
      _monitorPlayer();
      return;
    }

    // Tentar VLC AppImage
    final vlcAppImage = path.join(playersDir.path, 'vlc.AppImage');

    if (await File(vlcAppImage).exists()) {
      debugPrint('Usando VLC AppImage: $vlcAppImage');
      _playerProcess = await Process.start(
        vlcAppImage,
        [url],
        runInShell: true,
      );
      _monitorPlayer();
      return;
    }

    throw Exception('Nenhum player encontrado.\n\nInstale mpv ou vlc no sistema:\n  sudo dnf install mpv vlc\n\nOu crie a pasta Players e coloque mpv.AppImage ou vlc.AppImage.');
  }

  Future<bool> _commandExists(String command) async {
    try {
      final result = await Process.run('which', [command]);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  void _monitorPlayer() {
    if (_playerProcess == null) return;
    
    _playerProcess!.stdout.listen((data) {
      debugPrint('Player: ${String.fromCharCodes(data)}');
    });

    _playerProcess!.stderr.listen((data) {
      debugPrint('Player Error: ${String.fromCharCodes(data)}');
    });

    _playerProcess!.exitCode.then((code) {
      debugPrint('Player fechado com código: $code');
      _playerProcess = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: _focusNode.hasFocus ? 8.0 : 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: widget.channel.favorite
            ? Theme.of(context).colorScheme.surfaceContainerHighest
            : Theme.of(context).colorScheme.surfaceContainer,
        child: InkWell(
          focusNode: _focusNode,
          onLongPress: favorite,
          onTap: () async => await play(),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
              padding: const EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do grupo/playlist no topo
                  if (widget.groupName != null && widget.groupName!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      margin: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        widget.groupName!,
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  // Conteúdo principal (imagem + nome do canal)
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: widget.channel.image != null
                                    ? CachedNetworkImage(
                                        width: 2000,
                                        height: 150,
                                        fit: BoxFit.contain,
                                        errorWidget: (_, __, ___) =>
                                            Image.asset("assets/icon.png"),
                                        imageUrl: widget.channel.image!,
                                      )
                                    : Image.asset(
                                        "assets/icon.png",
                                        fit: BoxFit.contain,
                                      ))),
                        const Expanded(flex: 1, child: SizedBox()),
                        Expanded(
                            flex: 8,
                            child: LayoutBuilder(builder: (context, constraints) {
                              final style = Theme.of(context).textTheme.bodyMedium!;
                              final fontSize = MediaQuery.of(context)
                                  .textScaler
                                  .scale(style.fontSize!);
                              final lineHeight = style.height! * fontSize;
                              final maxLines =
                                  (constraints.maxHeight / lineHeight).floor();
                              return Text(
                                widget.channel.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: maxLines,
                              );
                            }))
                      ],
                    ),
                  ),
                ],
              )),
        ));
  }
}
