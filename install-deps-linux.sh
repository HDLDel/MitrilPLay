#!/bin/bash

# Script de instalação de dependências para compilar ASTRO-TV no Linux
# Suporta: Fedora/RHEL (dnf) e Ubuntu/Debian (apt)
# Executar como root ou com sudo

set -e

echo "=========================================="
echo "ASTRO-TV - Instalação de Dependências Linux"
echo "=========================================="
echo ""

# Detectar distribuição
if [ -f /etc/fedora-release ]; then
    DISTRO="fedora"
    PACKAGE_MANAGER="dnf"
elif [ -f /etc/redhat-release ]; then
    DISTRO="rhel"
    PACKAGE_MANAGER="dnf"
elif [ -f /etc/arch-release ]; then
    DISTRO="arch"
    PACKAGE_MANAGER="pacman"
elif [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
    DISTRO="debian"
    PACKAGE_MANAGER="apt"
else
    DISTRO="unknown"
    PACKAGE_MANAGER="unknown"
fi

echo "🐧 Distribuição detectada: $DISTRO"
echo "📦 Gerenciador de pacotes: $PACKAGE_MANAGER"
echo ""

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Por favor, execute como root (use sudo)"
    echo "   Exemplo: sudo $0"
    exit 1
fi

# Função para instalar no Fedora/RHEL
install_fedora() {
    echo "📦 Atualizando repositórios..."
    dnf check-update || true

    echo ""
    echo "📦 Instalando dependências do sistema..."
    dnf install -y \
        curl \
        git \
        unzip \
        xz \
        zip \
        mesa-libGLU \
        clang \
        cmake \
        ninja-build \
        pkgconf-pkg-config \
        gtk3-devel \
        xz-devel \
        libstdc++-devel \
        ca-certificates \
        gnupg2 \
        libmount-devel \
        libsecret-devel \
        jsoncpp-devel \
        libblkid-devel \
        alsa-lib-devel

    echo ""
    echo "📦 Opcional: Instalando MPV e VLC do sistema..."
    dnf install -y mpv vlc mpv-devel || echo "⚠️  Alguns pacotes de mídia falharam, ignorando..."
}

# Função para instalar no Arch Linux
install_arch() {
    echo "📦 Atualizando repositórios..."
    pacman -Sy --noconfirm

    echo ""
    echo "📦 Instalando dependências do sistema..."
    pacman -S --noconfirm \
        curl \
        git \
        unzip \
        xz \
        zip \
        glu \
        clang \
        cmake \
        ninja \
        pkg-config \
        gtk3 \
        xz \
        gcc-libs \
        ca-certificates \
        gnupg \
        util-linux-libs \
        libsecret \
        jsoncpp \
        util-linux

    echo ""
    echo "📦 Opcional: Instalando MPV e VLC do sistema..."
    pacman -S --noconfirm mpv vlc || echo "⚠️  Alguns pacotes de mídia falharam, ignorando..."
}

# Função para instalar no Ubuntu/Debian
install_debian() {
    echo "📦 Atualizando repositórios..."
    apt-get update

    echo ""
    echo "📦 Instalando dependências do sistema..."
    apt-get install -y \
        curl \
        git \
        unzip \
        xz-utils \
        zip \
        libglu1-mesa \
        clang \
        cmake \
        ninja-build \
        pkg-config \
        libgtk-3-dev \
        liblzma-dev \
        libstdc++-12-dev \
        ca-certificates \
        gnupg \
        lsb-release \
        libblkid-dev \
        libmount-dev \
        libsecret-1-dev \
        libjsoncpp-dev

    echo ""
    echo "📦 Opcional: Instalando MPV e VLC do sistema..."
    apt-get install -y libmpv-dev mpv vlc || echo "⚠️  Alguns pacotes de mídia falharam, ignorando..."
}

# Executar instalação baseada na distribuição
case $PACKAGE_MANAGER in
    dnf)
        install_fedora
        ;;
    pacman)
        install_arch
        ;;
    apt)
        install_debian
        ;;
    *)
        echo "❌ Gerenciador de pacotes não suportado: $PACKAGE_MANAGER"
        echo ""
        echo "📦 Distribuições suportadas:"
        echo "   - Fedora (dnf)"
        echo "   - RHEL/CentOS (dnf)"
        echo "   - Ubuntu/Debian (apt)"
        echo "   - Arch Linux (pacman)"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "✅ Instalação concluída!"
echo "=========================================="
echo ""
echo "📁 Agora compile com:"
echo "   ./build-linux.sh"
echo ""
