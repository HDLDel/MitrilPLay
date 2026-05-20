import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mitril_play/backend/sql.dart';
import 'package:mitril_play/models/channel.dart';
import 'package:mitril_play/models/media_type.dart';
import 'package:mitril_play/error.dart';
import 'package:mitril_play/backend/xtream.dart';
import 'package:mitril_play/memory.dart';
import 'package:mitril_play/models/node.dart';
import 'package:mitril_play/models/node_type.dart';
import 'package:mitril_play/internal_player.dart';
import 'package:mitril_play/theme.dart';
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
        widget.channel.mediaType == MediaType.serie ||
        widget.channel.mediaType == MediaType.season) {
      if (widget.channel.mediaType == MediaType.serie &&
          !refreshedSeries.contains(widget.channel.id)) {
        await Error.tryAsync(() async {
          await getEpisodes(widget.channel);
          refreshedSeries.add(widget.channel.id!);
        }, widget.parentContext, null, true, false);
      }
      widget.setNode(Node(
          id: widget.channel.mediaType == MediaType.serie
              ? int.parse(widget.channel.url!)
              : widget.channel.id!,
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
      final channelHeaders = await Sql.getChannelHeaders(widget.channel.id!);
      
      // Converter para Map<String, String>
      final headers = <String, String>{};
      if (channelHeaders != null) {
        if (channelHeaders.referrer != null && channelHeaders.referrer!.isNotEmpty) {
          headers['Referer'] = channelHeaders.referrer!;
        }
        if (channelHeaders.userAgent != null && channelHeaders.userAgent!.isNotEmpty) {
          headers['User-Agent'] = channelHeaders.userAgent!;
        }
        if (channelHeaders.httpOrigin != null && channelHeaders.httpOrigin!.isNotEmpty) {
          headers['Origin'] = channelHeaders.httpOrigin!;
        }
      }

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
      debugPrint('Erro ao abrir player: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao reproduzir: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _openWindowsPlayer(String url, Map<String, String> headers) async {
    // Procurar players na pasta Players (relativa ao executável)
    final executablePath = Platform.resolvedExecutable;
    final executableDir = Directory(executablePath).parent;
    final playersDir = Directory(path.join(executableDir.path, 'Players'));

    final playersDirExists = await playersDir.exists();

    // Tentar encontrar um player externo
    String? foundPlayerPath;
    String? playerName;

    if (playersDirExists) {
      // Tentar MPV primeiro
      final mpvPath = path.join(playersDir.path, 'mpv', 'mpv.exe');
      final mpvAltPath = path.join(playersDir.path, 'mpv.exe');

      if (await File(mpvPath).exists()) {
        foundPlayerPath = mpvPath;
        playerName = 'MPV';
      } else if (await File(mpvAltPath).exists()) {
        foundPlayerPath = mpvAltPath;
        playerName = 'MPV (alternativo)';
      } else {
        // Tentar VLC
        final vlcPath = path.join(playersDir.path, 'vlc', 'vlc.exe');
        final vlcAltPath = path.join(playersDir.path, 'vlc.exe');
        final vlcProgramFiles = r'C:\Program Files\VideoLAN\VLC\vlc.exe';
        final vlcProgramFilesX86 = r'C:\Program Files (x86)\VideoLAN\VLC\vlc.exe';

        final vlcPaths = [vlcPath, vlcAltPath, vlcProgramFiles, vlcProgramFilesX86];

        for (final vPath in vlcPaths) {
          if (await File(vPath).exists()) {
            foundPlayerPath = vPath;
            playerName = 'VLC';
            break;
          }
        }
      }
    } else {
      // Verificar VLC instalado no sistema mesmo sem pasta Players
      final vlcProgramFiles = r'C:\Program Files\VideoLAN\VLC\vlc.exe';
      final vlcProgramFilesX86 = r'C:\Program Files (x86)\VideoLAN\VLC\vlc.exe';
      
      if (await File(vlcProgramFiles).exists()) {
        foundPlayerPath = vlcProgramFiles;
        playerName = 'VLC (sistema)';
      } else if (await File(vlcProgramFilesX86).exists()) {
        foundPlayerPath = vlcProgramFilesX86;
        playerName = 'VLC (sistema)';
      }
    }

    // Se encontrou um player externo, usa-lo
    if (foundPlayerPath != null) {
      debugPrint('Usando $playerName: $foundPlayerPath');
      _playerProcess = await Process.start(
        foundPlayerPath,
        playerName == 'MPV' || playerName == 'MPV (alternativo)'
            ? [url, '--no-terminal']
            : [url],
        runInShell: true,
      );
      _monitorPlayer();
      return;
    }

    // Fallback: usar player interno
    debugPrint('Nenhum player externo encontrado, usando player interno');
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => InternalPlayer(
            url: url,
            headers: headers,
          ),
        ),
      );
    }
  }

  Future<void> _openLinuxPlayer(String url, Map<String, String> headers) async {
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
    final playersDirExists = await playersDir.exists();
    if (playersDirExists) {
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
      final vlcAppImageUpper = path.join(playersDir.path, 'VLC.AppImage');

      if (await File(vlcAppImage).exists()) {
        debugPrint('Usando VLC AppImage: $vlcAppImage');
        _playerProcess = await Process.start(
          vlcAppImage,
          [url],
          runInShell: true,
        );
        _monitorPlayer();
        return;
      } else if (await File(vlcAppImageUpper).exists()) {
        debugPrint('Usando VLC AppImage: $vlcAppImageUpper');
        _playerProcess = await Process.start(
          vlcAppImageUpper,
          [url],
          runInShell: true,
        );
        _monitorPlayer();
        return;
      }
    }

    // Fallback: usar player interno
    debugPrint('Nenhum player externo encontrado, usando player interno');
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => InternalPlayer(
            url: url,
            headers: headers,
          ),
        ),
      );
    }
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
    final isFocused = _focusNode.hasFocus;

    return AnimatedScale(
      scale: isFocused ? 1.02 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      child: Card(
        elevation: isFocused ? 4.0 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isFocused ? AppColors.focusBorder : AppColors.border,
            width: isFocused ? 2 : 1,
          ),
        ),
        color: AppColors.cardBackground,
        child: InkWell(
          focusNode: _focusNode,
          onLongPress: favorite,
          onTap: () async => await play(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do grupo/playlist no topo
                  if (widget.groupName != null && widget.groupName!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        widget.groupName!,
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  // Conteúdo principal (imagem + nome do canal)
                  Expanded(
                    child: Row(
                      children: [
                        // Container branco arredondado para o logo
                        Expanded(
                            flex: 3,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  constraints: const BoxConstraints(
                                    maxWidth: 120,
                                    maxHeight: 80,
                                  ),
                                  child: widget.channel.image != null
                                      ? Image.network(
                                          widget.channel.image!,
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) =>
                                              Image.asset("assets/icon.png", fit: BoxFit.contain),
                                        )
                                      : Image.asset(
                                          "assets/icon.png",
                                          fit: BoxFit.contain,
                                        ),
                                ))),
                        const Expanded(flex: 1, child: SizedBox(width: 8)),
                        // Nome do canal
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
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontFamily: AppTypography.fontFamily,
                                  fontSize: style.fontSize,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: maxLines,
                              );
                            }))
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
