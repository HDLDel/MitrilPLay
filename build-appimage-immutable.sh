#!/bin/bash
# ==============================================================================
# build-appimage-immutable.sh - Build exclusivo para Bazzite / Distros Imutáveis
# ==============================================================================
# Este script cria um AppImage do MitrilPlay removendo COMPLETAMENTE as
# dependências do media_kit (que causam erro de compilação por falta do mpv-devel).
# O player interno é desativado e o app dependerá apenas dos AppImages na pasta Players.
# ==============================================================================

set -e

echo "========================================================"
echo "MitrilPlay - Build AppImage para Distros Imutáveis"
echo "========================================================"
echo "Este build removerá o media_kit para evitar erros de C++"
echo "========================================================"
echo ""

if [ "$EUID" -eq 0 ]; then
    echo "❌ Erro: Não execute este script como root (sudo)!"
    exit 1
fi

if ! command -v flutter &> /dev/null; then
    echo "❌ Erro: Flutter não está instalado ou não está no PATH"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🧹 Limpando ambiente..."
flutter clean

# 1. Fazer backup dos arquivos que serão modificados
echo "📦 Fazendo backup dos arquivos originais..."
cp pubspec.yaml pubspec.yaml.bak
cp lib/main.dart lib/main.dart.bak
cp lib/internal_player.dart lib/internal_player.dart.bak

# Função para restaurar backups em caso de erro ou ao final
restore_backups() {
    echo "🔄 Restaurando arquivos originais..."
    mv pubspec.yaml.bak pubspec.yaml
    mv lib/main.dart.bak lib/main.dart
    mv lib/internal_player.dart.bak lib/internal_player.dart
    echo "✅ Arquivos restaurados."
}

# Configurar trap para garantir que os arquivos sejam restaurados mesmo se o script falhar
trap restore_backups EXIT

# 2. Remover media_kit do pubspec.yaml
echo "📝 Removendo media_kit do pubspec.yaml..."
sed -i '/media_kit:/d' pubspec.yaml
sed -i '/media_kit_video:/d' pubspec.yaml
sed -i '/media_kit_libs_video:/d' pubspec.yaml

# 3. Remover media_kit do main.dart
echo "📝 Removendo inicialização do media_kit de main.dart..."
# Remover a linha de import
sed -i "/import 'package:media_kit\/media_kit.dart';/d" lib/main.dart
# Remover o bloco try/catch do MediaKit.ensureInitialized() usando perl
perl -0777 -pi -e 's/try\s*\{\s*MediaKit\.ensureInitialized\(\);\s*\}\s*catch\s*\([^)]*\)\s*\{[^}]*\}//g' lib/main.dart

# 4. Criar um internal_player.dart substituto (Dummy)
echo "📝 Criando player interno alternativo..."
cat > lib/internal_player.dart << 'EOF'
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
EOF

# 5. Obter dependências e buildar
echo "📦 Obtendo dependências..."
flutter pub get

echo "🐧 Habilitando Linux desktop..."
flutter config --enable-linux-desktop

echo "🏗️  Compilando para Linux (sem media_kit)..."
flutter build linux --release

# Nome do executável
EXEC_NAME="mitril_play"
APPDIR="build/appimage/AppDir"

echo "📦 Criando AppDir em: $APPDIR"
rm -rf "$APPDIR"
mkdir -p "$APPDIR"

echo "📦 Copiando arquivos para AppDir..."
cp -r build/linux/x64/release/bundle/* "$APPDIR/"

if [ -f "$APPDIR/open_tv" ] && [ ! -f "$APPDIR/$EXEC_NAME" ]; then
    mv "$APPDIR/open_tv" "$APPDIR/$EXEC_NAME"
fi

echo "📝 Criando AppRun..."
cat > "$APPDIR/AppRun" << EOF
#!/bin/bash
SELF=\$(readlink -f "\$0")
HERE=\${SELF%/*}
export PATH="\${HERE}:\${PATH}"
export LD_LIBRARY_PATH="\${HERE}:\${LD_LIBRARY_PATH}"
exec "\${HERE}/$EXEC_NAME" "\$@"
EOF
chmod +x "$APPDIR/AppRun"

echo "📝 Criando arquivo .desktop..."
cat > "$APPDIR/$EXEC_NAME.desktop" << EOF
[Desktop Entry]
Type=Application
Name=MitrilPlay
Comment=Player de vídeo e streaming
Exec=$EXEC_NAME
Icon=$EXEC_NAME
Categories=AudioVideo;Player;
EOF

echo "📦 Copiando ícone..."
mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"
if [ -f "ASTROFX.png" ]; then
    cp "ASTROFX.png" "$APPDIR/$EXEC_NAME.png"
    cp "ASTROFX.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/$EXEC_NAME.png"
elif [ -f "assets/icon.png" ]; then
    cp "assets/icon.png" "$APPDIR/$EXEC_NAME.png"
    cp "assets/icon.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/$EXEC_NAME.png"
fi

echo "📦 Baixando linuxdeploy..."
LINUXDEPLOY="build/appimage/linuxdeploy-x86_64.AppImage"
if [ ! -f "$LINUXDEPLOY" ]; then
    mkdir -p build/appimage
    curl -L -o "$LINUXDEPLOY" "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
    chmod +x "$LINUXDEPLOY"
fi

echo "🏗️  Gerando AppImage..."
cd build/appimage
./linuxdeploy-x86_64.AppImage --appdir AppDir --executable "AppDir/$EXEC_NAME" --desktop-file "AppDir/$EXEC_NAME.desktop" --icon-file "AppDir/$EXEC_NAME.png" --output appimage || echo "⚠️  Avisos no linuxdeploy..."

cd "$SCRIPT_DIR"

if ls build/appimage/*.AppImage 2>/dev/null | grep -v linuxdeploy; then
    APPIMAGE_FILE=$(ls -t build/appimage/*.AppImage 2>/dev/null | grep -v linuxdeploy | head -1)
    echo "========================================================"
    echo "✅ AppImage Imutável criado com sucesso!"
    echo "========================================================"
    echo "📦 Arquivo: $APPIMAGE_FILE"
else
    echo "⚠️  AppImage pode não ter sido gerado."
fi

# O trap EXIT executará restore_backups automaticamente.
