#!/bin/bash

# Script de compilação para ASTRO-TV (Windows e Linux)
# Requisitos: Flutter SDK instalado e configurado

set -e

echo "=========================================="
echo "ASTRO-TV - Script de Compilação"
echo "=========================================="

# Verificar se Flutter está instalado
if ! command -v flutter &> /dev/null; then
    echo "❌ Erro: Flutter não está instalado ou não está no PATH"
    exit 1
fi

echo "✅ Flutter encontrado: $(flutter --version --short)"

# Limpar build anterior
echo ""
echo "🧹 Limpando build anterior..."
flutter clean

# Obter dependências
echo ""
echo "📦 Obtendo dependências..."
flutter pub get

# Verificar plataforma
PLATFORM=$(uname -s 2>/dev/null || echo "Windows")

# Build para Linux
if [[ "$PLATFORM" == "Linux" ]] || [[ "$1" == "linux" ]]; then
    echo ""
    echo "🐧 Compilando para Linux..."
    
    # Habilitar suporte ao Linux
    flutter config --enable-linux-desktop
    
    # Build de release
    flutter build linux --release
    
    echo ""
    echo "✅ Build Linux concluído!"
    echo "📁 Saída: build/linux/x64/release/bundle/"
fi

# Build para Windows
if [[ "$PLATFORM" == "Windows_NT" ]] || [[ "$1" == "windows" ]]; then
    echo ""
    echo "🪟 Compilando para Windows..."
    
    # Habilitar suporte ao Windows
    flutter config --enable-windows-desktop
    
    # Build de release
    flutter build windows --release
    
    echo ""
    echo "✅ Build Windows concluído!"
    echo "📁 Saída: build/windows/x64/runner/Release/"
fi

# Se nenhum argumento foi passado e não é Linux/Windows nativo
if [[ -z "$1" ]] && [[ "$PLATFORM" != "Linux" ]] && [[ "$PLATFORM" != "Windows_NT" ]]; then
    echo ""
    echo "⚠️  Plataforma não suportada: $PLATFORM"
    echo "Use 'bash build.sh linux' ou 'bash build.sh windows' para compilar para uma plataforma específica"
fi

echo ""
echo "=========================================="
echo "Compilação finalizada!"
echo "=========================================="
