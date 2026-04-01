#!/bin/bash

# Script para criar pacote de distribuição do ASTRO-TV

set -e

echo "=========================================="
echo "ASTRO-TV - Criando Pacote de Distribuição"
echo "=========================================="
echo ""

# Obter diretório do script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Verificar se o build existe
if [ ! -d "build/linux/x64/release/bundle" ]; then
    echo "❌ Build não encontrado!"
    echo ""
    echo "📦 Compile primeiro com:"
    echo "   ./build-linux.sh"
    echo ""
    exit 1
fi

# Criar pasta de distribuição
DIST_DIR="dist/ASTRO-TV-Linux"
echo "📦 Criando pacote em: $DIST_DIR"

if [ -d "$DIST_DIR" ]; then
    echo "⚠️  Pasta já existe. Removendo..."
    rm -rf "$DIST_DIR"
fi

mkdir -p "$DIST_DIR"

# Copiar build
echo "📋 Copiando arquivos do build..."
cp -r build/linux/x64/release/bundle/* "$DIST_DIR/"

# Criar pasta Players
echo "📁 Criando pasta Players..."
mkdir -p "$DIST_DIR/Players"

# Criar README de distribuição
cat > "$DIST_DIR/LEIAME.md" << 'EOF'
# ASTRO-TV - Linux

## 🚀 Como Usar

1. **Instale um player** (se ainda não tiver):
   ```bash
   # Fedora/RHEL
   sudo dnf install mpv
   # ou
   sudo dnf install vlc

   # Ubuntu/Debian
   sudo apt install mpv
   # ou
   sudo apt install vlc

   # Arch Linux
   sudo pacman -S mpv
   # ou
   sudo pacman -S vlc
   ```

2. **Ou coloque players na pasta Players**:
   - `mpv.AppImage` - Baixe em https://mpv.io/installation/
   - `vlc.AppImage` - Baixe em https://www.videolan.org/vlc/

3. **Execute o aplicativo**:
   ```bash
   ./open_tv
   ```

## 📁 Estrutura

```
ASTRO-TV-Linux/
├── open_tv           # Executável principal
├── data/             # Recursos do app
├── lib/              # Bibliotecas
├── icudtl.dat        # Dados ICU
└── Players/          # Coloque seus players aqui
    ├── mpv.AppImage
    └── vlc.AppImage
```

## 🎯 Uso

1. Abra o aplicativo
2. Adicione suas fontes IPTV (M3U ou Xtream)
3. Use os filtros para navegar:
   - 📺 TV - Canais ao vivo
   - 🎬 Filmes
   - 📺 Séries
4. Clique para reproduzir

## 📝 Logs

Os logs são salvos em:
- `~/.local/share/OpenTV/logs/app.log`

## ❓ Problemas?

- Veja os logs para detalhes
- Certifique-se de que os players estão na pasta Players
- No Linux, torne os AppImages executáveis:
  ```bash
  chmod +x Players/mpv.AppImage
  ```
EOF

echo ""
echo "=========================================="
echo "✅ Pacote criado com sucesso!"
echo "=========================================="
echo ""
echo "📦 Local: $DIST_DIR"
echo ""
echo "🎯 Para testar:"
echo "   cd $DIST_DIR"
echo "   ./open_tv"
echo ""
echo "📦 Para distribuir, compacte:"
echo "   cd dist"
echo "   tar -czf ASTRO-TV-Linux.tar.gz ASTRO-TV-Linux/"
echo ""
