#!/bin/bash
# ==============================================================================
# build-appimage.sh - Cria um AppImage portátil do MitrilPlay para Linux
# ==============================================================================
# Gera um AppImage único que roda em qualquer distribuição Linux x86_64 sem
# instalação. Ideal para Bazzite/Silverblue/Bluefin (sistemas baseados em ostree).
# Baixa linuxdeploy automaticamente e empacota o build Flutter com dependências.
# ==============================================================================

# Script de compilação para MitrilPlay - AppImage (Linux)
# Gera um AppImage que roda em qualquer distribuição Linux x86_64
# Ideal para Bazzite/Silverblue/Bluefin (sem containers)

set -e

echo "=========================================="
echo "MitrilPlay - Build AppImage"
echo "=========================================="
echo ""

# Impedir execução como root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Erro: Não execute este script como root (sudo)!"
    echo "   O Flutter deve ser executado como usuário normal."
    echo "   Execute apenas: ./build-appimage.sh"
    echo ""
    exit 1
fi

# Verificar se Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Erro: Flutter não está instalado ou não está no PATH"
    echo ""
    echo "📦 Instale via:"
    echo "   brew install flutter"
    echo ""
    exit 1
fi

echo "✅ Flutter encontrado:"
flutter --version
echo ""

echo "🧹 Restaurando o repositório do Flutter para o estado original..."
if [ -d "$HOME/flutter" ]; then
    (cd "$HOME/flutter" && git clean -xfd && git reset --hard HEAD) || echo "⚠️ Aviso: Falha ao limpar o repositório do Flutter."
fi
echo ""

echo "� Verificando a saúde do ambiente (flutter doctor)..."
flutter doctor
echo ""

# Obter diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📁 Diretório do projeto: $SCRIPT_DIR"
echo ""

# Versão do app
VERSION=$(grep '^version:' pubspec.yaml | head -1 | cut -d' ' -f2 | cut -d'+' -f1)
echo "📌 Versão: $VERSION"
echo ""

# Limpar build anterior
echo "🧹 Limpando build anterior..."
flutter clean
rm -rf build/linux/x64/release/bundle
echo ""

# Obter dependências
echo "📦 Obtendo dependências..."
flutter pub get
echo ""

# Habilitar Linux desktop
echo "🐧 Habilitando Linux desktop..."
flutter config --enable-linux-desktop
echo ""

# Build de release
echo "🏗️  Compilando para Linux..."
flutter build linux --release
echo ""

# Nome do executável (baseado no nome do projeto)
EXEC_NAME="mitril_play"

# Criar diretório do AppImage
APPDIR="build/appimage/AppDir"
echo "📦 Criando AppDir em: $APPDIR"
rm -rf "$APPDIR"
mkdir -p "$APPDIR"
echo ""

# Copiar build para AppDir
echo "📦 Copiando arquivos para AppDir..."
cp -r build/linux/x64/release/bundle/* "$APPDIR/"
echo ""

# Renomear executável se necessário
if [ -f "$APPDIR/open_tv" ] && [ ! -f "$APPDIR/$EXEC_NAME" ]; then
    echo "📝 Renomeando executável para $EXEC_NAME..."
    mv "$APPDIR/open_tv" "$APPDIR/$EXEC_NAME"
fi
echo ""

# Criar arquivo AppRun
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
echo ""

# Criar arquivo desktop
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
echo ""

# Copiar ícone
echo "📦 Copiando ícone..."
mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"

if [ -f "ASTROFX.png" ]; then
    cp "ASTROFX.png" "$APPDIR/$EXEC_NAME.png"
    cp "ASTROFX.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/$EXEC_NAME.png"
    echo "✅ Usando ASTROFX.png como ícone"
elif [ -f "assets/icon.png" ]; then
    cp "assets/icon.png" "$APPDIR/$EXEC_NAME.png"
    cp "assets/icon.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/$EXEC_NAME.png"
    echo "✅ Usando assets/icon.png como ícone"
else
    echo "⚠️  Nenhum ícone encontrado, criando placeholder..."
    # Criar ícone simples se ImageMagick estiver disponível
    if command -v convert &> /dev/null; then
        convert -size 256x256 xc:#6366F1 "$APPDIR/$EXEC_NAME.png"
        cp "$APPDIR/$EXEC_NAME.png" "$APPDIR/usr/share/icons/hicolor/256x256/apps/$EXEC_NAME.png"
    fi
fi
echo ""

# Download do linuxdeploy
echo "📦 Baixando linuxdeploy..."
LINUXDEPLOY_URL="https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
LINUXDEPLOY="build/appimage/linuxdeploy-x86_64.AppImage"

if [ ! -f "$LINUXDEPLOY" ]; then
    mkdir -p build/appimage
    curl -L -o "$LINUXDEPLOY" "$LINUXDEPLOY_URL"
    chmod +x "$LINUXDEPLOY"
fi
echo ""

# Criar o AppImage
echo "🏗️  Gerando AppImage..."
cd build/appimage

# Executar linuxdeploy
./linuxdeploy-x86_64.AppImage \
    --appdir AppDir \
    --executable "AppDir/$EXEC_NAME" \
    --desktop-file "AppDir/$EXEC_NAME.desktop" \
    --icon-file "AppDir/$EXEC_NAME.png" \
    --output appimage \
    --verbose 2 || echo "⚠️  linuxdeploy pode ter avisos, verificando..."

echo ""

# Verificar se AppImage foi criado
if ls *.AppImage 2>/dev/null | grep -v linuxdeploy; then
    APPIMAGE_FILE=$(ls -t *.AppImage 2>/dev/null | grep -v linuxdeploy | head -1)
    cd "$SCRIPT_DIR"
    echo "=========================================="
    echo "✅ AppImage criado com sucesso!"
    echo "=========================================="
    echo ""
    echo "📦 Arquivo: build/appimage/$APPIMAGE_FILE"
    echo ""
    echo "🚀 Para executar:"
    echo "   chmod +x build/appimage/$APPIMAGE_FILE"
    echo "   ./build/appimage/$APPIMAGE_FILE"
    echo ""
    echo "📁 Para distribuir:"
    echo "   Copie o arquivo .AppImage para qualquer Linux x86_64"
    echo ""
    echo "🔧 Para instalar no sistema:"
    echo "   ./build/appimage/$APPIMAGE_FILE --appimage-install"
    echo ""
else
    echo "⚠️  AppImage pode não ter sido gerado corretamente"
    echo "   Verifique os logs acima para erros"
    echo ""
    echo "📁 Build Linux disponível em:"
    echo "   build/linux/x64/release/bundle/"
    cd "$SCRIPT_DIR"
fi
