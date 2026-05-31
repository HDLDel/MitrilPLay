# ASTRO-TV

Aplicativo IPTV para Windows e Linux

## 🚀 Instalação Rápida

### Windows

1. **Instalar Flutter** (se for compilar):
   ```powershell
   # Baixe e instale o Flutter SDK
   # Adicione ao PATH: C:\src\flutter\bin
   ```

2. **Compilar**:
   ```powershell
   .\build.bat
   ```

3. **Configurar Players**:
   - Crie uma pasta `Players` junto ao executável
   - Coloque `mpv.exe` ou `vlc.exe` lá
   - Veja [PLAYERS.md](PLAYERS.md) para detalhes

### Linux (Ubuntu/Debian)

1. **Instalar dependências**:
   ```bash
   sudo ./install-deps-linux.sh
   ```

2. **Compilar**:
   ```bash
   ./build-linux.sh
   ```

3. **Configurar Players**:
   - Crie uma pasta `Players` junto ao executável
   - Coloque `mpv.AppImage` ou `vlc.AppImage` lá
   - Ou instale mpv/vlc no sistema: `sudo apt install mpv`

## 📁 Estrutura do Projeto

```
ASTRO-TV/
├── lib/                      # Código fonte Dart/Flutter
├── build.bat                 # Script de build (Windows)
├── build-linux.sh            # Script de build (Linux)
├── install-deps-linux.sh     # Instala dependências (Linux)
├── PLAYERS.md                # Configuração dos players
└── README.md                 # Este arquivo
```

## 🎯 Funcionalidades

- ✅ Reprodução via players externos (MPV/VLC)
- ✅ Suporte a TV ao vivo, Filmes e Séries
- ✅ Filtros por tipo de conteúdo
- ✅ Busca de canais
- ✅ Favoritos
- ✅ Histórico
- ✅ Xtream Codes
- ✅ M3U
- ✅ Salva posição de reprodução
- ✅ Logs de erro detalhados

## 🛠️ Compilação

### Windows

```powershell
# Limpar e compilar
.\build.bat

# O executável estará em:
# build\windows\x64\runner\Release\open_tv.exe
```

### Linux

```bash
# Instalar dependências (primeira vez)
sudo ./install-deps-linux.sh

# Compilar
./build-linux.sh

# O executável estará em:
# build/linux/x64/release/bundle/open_tv
```

## 📦 Distribuição

### Windows

Copie todo o conteúdo de `build\windows\x64\runner\Release\`:

```
Distribuição-Windows/
├── open_tv.exe
├── data/
├── icudtl.dat
├── ...
└── Players/
    └── mpv.exe
```

### Linux

Copie todo o conteúdo de `build/linux/x64/release/bundle/`:

```
Distribuição-Linux/
├── open_tv
├── data/
├── icudtl.dat
├── lib/
└── Players/
    └── mpv.AppImage
```

## 🔧 Configuração dos Players

Veja [PLAYERS.md](PLAYERS.md) para instruções detalhadas.

### Resumo

| Plataforma | Players Suportados |
|------------|-------------------|
| Windows | `mpv.exe`, `vlc.exe` |
| Linux | `mpv.AppImage`, `vlc.AppImage`, `mpv` (sistema), `vlc` (sistema) |

## 📝 Logs

Os logs são salvos em:

- **Windows**: `%APPDATA%\OpenTV\logs\app.log`
- **Linux**: `~/.local/share/OpenTV/logs/app.log` ou `$XDG_DATA_HOME/OpenTV/logs/app.log`

## 🐛 Solução de Problemas

### "Nenhum player encontrado"

- Verifique se a pasta `Players` existe
- Verifique se o executável do player está no local correto
- No Linux, certifique-se de que o AppImage é executável: `chmod +x Players/mpv.AppImage`

### Erro de compilação no Linux

```bash
# Reinstalar dependências
sudo ./install-deps-linux.sh

# Limpar e recompilar
./build-linux.sh
```

### Player não inicia

- Tente abrir o player manualmente para testar
- Verifique os logs para mais detalhes

## 📌 Requisitos

### Windows
- Windows 10 ou superior
- Visual Studio Build Tools 2022 (para compilar)
- Flutter SDK

### Linux
- Ubuntu 20.04+ ou Debian 11+ (para compilar)
- Flutter SDK
- GTK3, Clang, CMake

## 🚀 Uso

1. Abra o aplicativo
2. Adicione suas fontes (M3U ou Xtream)
3. Use os filtros para navegar:
   - 📺 **TV** - Canais ao vivo
   - 🎬 **Filmes** - Filmes
   - 📺 **Séries** - Séries
4. Clique em um canal para reproduzir
5. Use a busca para encontrar conteúdo específico

## 📄 Licença

Veja o arquivo [LICENSE](LICENSE) para detalhes.
