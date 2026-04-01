#!/bin/bash

# Script de instalação de dependências para compilar MitrilPlay no Bazzite
# Bazzite é baseado em Fedora Silverblue/Bluefin (ostree)
# Instalação nativa via rpm-ostree
# Sem containers ou distrobox
# NÃO execute como root/sudo - o script gerencia isso automaticamente

set -e

echo "=========================================="
echo "MitrilPlay - Instalação no Bazzite"
echo "=========================================="
echo ""

# NÃO rodar como root - Homebrew não permite
if [ "$EUID" -eq 0 ]; then
    echo "❌ NÃO execute como root!"
    echo "   Execute normalmente: ./install-deps-bazzite.sh"
    exit 1
fi

echo "🐧 Sistema: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'=' -f2 | tr -d '"')"
echo ""

# ==========================================
# 1. Homebrew para dependências básicas
# ==========================================

if ! command -v brew &> /dev/null; then
    echo "📦 Instalando Homebrew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    echo ""
else
    echo "✅ Homebrew já instalado"
    echo ""
fi

# Atualizar homebrew
echo "📦 Atualizando Homebrew..."
brew update
echo ""

# Instalar ferramentas básicas via homebrew
echo "📦 Instalando ferramentas via Homebrew..."
brew install \
    git \
    curl \
    unzip \
    xz \
    zip
echo ""

# ==========================================
# 2. Flutter (instalação manual para Linux)
# ==========================================

FLUTTER_DIR="$HOME/flutter"
FLUTTER_BIN="$FLUTTER_DIR/bin"

# Versão mínima necessária (com Dart 3.5.3+)
FLUTTER_VERSION="3.27.0"

if [ -f "$FLUTTER_BIN/flutter" ]; then
    CURRENT_VERSION=$(flutter --version 2>/dev/null | grep "Flutter " | cut -d' ' -f2)
    echo "✅ Flutter já instalado em $FLUTTER_DIR (versão $CURRENT_VERSION)"
    
    if command -v flutter &> /dev/null; then
        DART_VERSION=$(flutter --version 2>/dev/null | grep "Dart " | cut -d' ' -f2)
        echo "   Dart $DART_VERSION"
    fi
    echo ""
else
    echo "📦 Baixando Flutter $FLUTTER_VERSION para Linux..."
    cd ~
    
    FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
    
    curl -L -o flutter.tar.xz "$FLUTTER_URL"
    tar xf flutter.tar.xz
    rm flutter.tar.xz
    
    echo ""
    echo "✅ Flutter instalado em $FLUTTER_DIR"
    echo ""
fi

# Adicionar Flutter ao PATH
if ! grep -q "flutter/bin" ~/.bashrc; then
    echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
fi
export PATH="$HOME/flutter/bin:$PATH"

echo "📌 Configurando PATH..."
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo ""

# Verificar Flutter
if command -v flutter &> /dev/null; then
    echo "✅ Flutter instalado:"
    flutter --version
    echo ""
    
    echo "📌 Aceitando licenças do Android SDK..."
    yes | flutter doctor --android-licenses 2>/dev/null || true
    echo ""
else
    echo "❌ Flutter não encontrado após instalação"
    exit 1
fi

# ==========================================
# 3. rpm-ostree para dependências Linux
# ==========================================

echo "📦 Instalando dependências via rpm-ostree (requer sudo)..."
echo "   (será solicitada sua senha de administrador)"
echo ""

# Todas as dependências necessárias para Flutter + media_kit
PACKAGES="gtk3-devel clang cmake ninja-build pkgconf-pkg-config \
          mesa-libGLU libstdc++-devel ca-certificates gnupg2 \
          libblkid-devel libmount-devel libsecret-devel jsoncpp-devel \
          alsa-lib-devel xz-devel \
          mpv mpv-devel \
          libjpeg-turbo-devel"

echo "📦 Instalando pacotes essenciais..."
# Usa || true para continuar mesmo se alguns pacotes já estiverem instalados
sudo rpm-ostree install -y --allow-inactive $PACKAGES 2>/dev/null || {
    echo "⚠️  Alguns pacotes já estavam instalados, continuando..."
}

echo ""
echo "=========================================="
echo "✅ Dependências instaladas!"
echo "=========================================="
echo ""

# Configurar variáveis de ambiente
echo "📌 Configurando variáveis de ambiente..."
cat >> ~/.bashrc << 'EOF'

# Flutter e Linux Desktop
export PATH="$HOME/flutter/bin:$PATH"

# PKG_CONFIG para encontrar bibliotecas do sistema
export PKG_CONFIG_PATH="/usr/lib64/pkgconfig:/usr/share/pkgconfig:$PKG_CONFIG_PATH"
export PKG_CONFIG_SYSROOT_DIR="/"
EOF

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PKG_CONFIG_PATH="/usr/lib64/pkgconfig:/usr/share/pkgconfig"

echo ""
echo "📌 Verificando dependências..."
echo "   GTK3: $(pkg-config --modversion gtk+-3.0 2>/dev/null || echo 'não encontrado')"
echo "   MPV: $(pkg-config --modversion mpv 2>/dev/null || echo 'não encontrado')"
echo "   ALSA: $(pkg-config --exists alsa && echo 'ok' || echo 'não encontrado')"
echo ""

echo "📌 Importante:"
echo "   1. É necessário REINICIAR o sistema para aplicar as camadas rpm-ostree"
echo "   2. Após reiniciar, as variáveis de ambiente serão carregadas automaticamente"
echo ""
read -p "Reiniciar agora? (s/n): " response
if [[ "$response" =~ ^[Ss]$ ]]; then
    systemctl reboot
fi
