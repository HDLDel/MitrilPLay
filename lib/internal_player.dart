import 'package:flutter/material.dart';

class InternalPlayer extends StatelessWidget {
  final String url;
  final Map<String, String>? headers;

  const InternalPlayer({
    super.key,
    required this.url,
    this.headers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Aviso de Compatibilidade'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.videocam_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Player Interno Desativado',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Esta versão foi compilada especificamente para distribuições imutáveis e não possui o player interno.\n\nPor favor, utilize os players externos (VLC ou MPV) configurando-os na aba de Ajustes.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
