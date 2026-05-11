import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class InternalPlayer extends StatefulWidget {
  final String url;
  final Map<String, String>? headers;

  const InternalPlayer({
    super.key,
    required this.url,
    this.headers,
  });

  @override
  State<InternalPlayer> createState() => _InternalPlayerState();
}

class _InternalPlayerState extends State<InternalPlayer> {
  late final Player player;
  late final VideoController controller;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);

    // Configurar headers se fornecidos
    final httpHeaders = widget.headers != null
        ? {
            for (final entry in widget.headers!.entries)
              entry.key: entry.value,
          }
        : <String, String>{};

    // Abrir o stream com headers
    player.open(
      Media(
        widget.url,
        httpHeaders: httpHeaders,
      ),
    );

    // Entrar em tela cheia automaticamente
    player.setPlaylistMode(PlaylistMode.none);
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Botão voltar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Voltar',
                  ),
                  Expanded(
                    child: Text(
                      'Reproduzindo',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Player de vídeo
            Expanded(
              child: Center(
                child: Video(
                  controller: controller,
                  controls: MaterialVideoControls,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
