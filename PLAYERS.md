# Configuração dos Players Externos

O ASTRO-TV usa players externos para reproduzir o conteúdo. Siga as instruções abaixo para configurar.

## 📁 Estrutura da Pasta Players

Crie uma pasta chamada `Players` no mesmo diretório onde está o aplicativo:

```
ASTRO-TV/
├── open_tv              (aplicativo principal - Linux)
├── open_tv.exe          (aplicativo principal - Windows)
└── Players/             (pasta dos players)
    ├── mpv/
    │   └── mpv.exe      (MPV para Windows)
    ├── mpv.AppImage     (MPV para Linux)
    ├── vlc/
    │   └── vlc.exe      (VLC para Windows)
    └── vlc.AppImage     (VLC para Linux)
```

## 🪟 Windows

### Opção 1: MPV (Recomendado)

1. Baixe o MPV em: https://mpv.io/installation/
2. Extraia para `Players/mpv/`
3. O executável deve ficar em: `Players/mpv/mpv.exe`

Ou copie diretamente para:
- `Players/mpv.exe`

### Opção 2: VLC

1. Baixe o VLC em: https://www.videolan.org/vlc/
2. Instale ou extraia para `Players/vlc/`
3. O executável deve ficar em: `Players/vlc/vlc.exe`

Ou copie diretamente para:
- `Players/vlc.exe`

O aplicativo também procura nas instalações padrão:
- `C:\Program Files\VideoLAN\VLC\vlc.exe`
- `C:\Program Files (x86)\VideoLAN\VLC\vlc.exe`

## 🐧 Linux

### Opção 1: MPV AppImage

1. Baixe o MPV AppImage em: https://mpv.io/installation/
2. Coloque em `Players/mpv.AppImage`
3. Torne executável: `chmod +x Players/mpv.AppImage`

### Opção 2: VLC AppImage

1. Baixe o VLC AppImage em: https://www.videolan.org/vlc/
2. Coloque em `Players/vlc.AppImage`
3. Torne executável: `chmod +x Players/vlc.AppImage`

### Opção 3: Players do Sistema

Se não usar AppImage, instale via package manager:

```bash
# Ubuntu/Debian
sudo apt install mpv
# ou
sudo apt install vlc

# Fedora
sudo dnf install mpv
# ou
sudo dnf install vlc

# Arch
sudo pacman -S mpv
# ou
sudo pacman -S vlc
```

## 🔧 Ordem de Prioridade

O aplicativo tenta abrir os players nesta ordem:

### Windows:
1. `Players/mpv/mpv.exe`
2. `Players/mpv.exe`
3. `Players/vlc/vlc.exe`
4. `Players/vlc.exe`
5. `C:\Program Files\VideoLAN\VLC\vlc.exe`
6. `C:\Program Files (x86)\VideoLAN\VLC\vlc.exe`

### Linux:
1. `Players/mpv.AppImage`
2. `Players/vlc.AppImage`
3. `mpv` (do sistema)
4. `vlc` (do sistema)

## ⚙️ Comandos Usados

### MPV:
```bash
mpv <url> --no-terminal
```

### VLC:
```bash
vlc <url>
```

## ❓ Solução de Problemas

### "Nenhum player encontrado"
- Verifique se a pasta `Players` existe
- Verifique se o executável está no local correto
- No Linux, certifique-se de que o AppImage é executável

### Player não inicia
- Tente abrir o player manualmente para testar
- Verifique os logs em `%APPDATA%\OpenTV\logs\app.log`

### Vídeo não reproduz
- O formato do vídeo pode não ser suportado pelo player
- Tente atualizar o player para a versão mais recente
