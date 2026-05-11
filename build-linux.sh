#!/bin/bash
# ==============================================================================
# build-linux.sh - Compila o MitrilPlay para Linux (build nativo)
# ==============================================================================
# Executa o build de release do Flutter para Linux, gerando executável nativo.
# Requer dependências instaladas (gtk3, clang, cmake, etc). Verifique
# install-deps-linux.sh ou install-deps-bazzite.sh para instalar pré-requisitos.
# ==============================================================================

# Script de compilação para MitrilPlay (Linux)
# Requisitos: Dependências instaladas (veja install-deps-bazzite.sh)

set -e

echo "=========================================="
echo "MitrilPlay - Compilação para Linux"
echo "=========================================="
echo ""

# Impedir execução como root
if [ "$EUID" -eq 0 ]; then
    echo "❌ Erro: Não execute este script como root (sudo)!"
    echo "   O Flutter deve ser executado como usuário normal."
    echo "   Execute apenas: ./build-linux.sh"
    echo ""
    exit 1
fi

# Verificar se Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Erro: Flutter não está instalado ou não está no PATH"
    echo ""
    echo "📦 Para instalar, execute:"
    echo "   sudo ./install-deps-linux.sh (para instalar as dependências)"
    echo "   e certifique-se de ter o Flutter instalado no sistema."
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

echo "🩺 Verificando a saúde do ambiente (flutter doctor)..."
flutter doctor
echo ""

# Obter diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "📁 Diretório do projeto: $SCRIPT_DIR"
echo ""

# Limpar build anterior
echo "🧹 Limpando build anterior..."
flutter clean
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
echo "=========================================="
echo "✅ Build concluído com sucesso!"
echo "=========================================="
echo ""
echo "📦 Executável: build/linux/x64/release/bundle/mitril_play"
echo ""
echo "📁 Para distribuir, copie todo o conteúdo da pasta:"
echo "   build/linux/x64/release/bundle/"
echo ""
echo "🚀 Para executar:"
echo "   cd build/linux/x64/release/bundle"
echo "   ./mitril_play"
echo ""
