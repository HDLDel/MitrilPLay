# ASTRO-TV - Scripts Disponíveis

## 🪟 Windows

### `build.bat`
Compila o aplicativo para Windows.

**Uso:**
```powershell
.\build.bat
```

**Saída:**
```
build\windows\x64\runner\Release\open_tv.exe
```

---

### `setup-vs.bat`
Baixa e instala o Visual Studio Build Tools 2022 com os componentes necessários para compilar no Windows.

**Uso:**
```powershell
.\setup-vs.bat
```
⚠️ Executar como Administrador

---

### `cleanup-vs.bat`
Remove o Visual Studio Build Tools e libera espaço em disco (~5-10 GB).

**Uso:**
```powershell
.\cleanup-vs.bat
```
⚠️ Executar como Administrador

---

## 🐧 Linux

### `install-deps-linux.sh`
Instala todas as dependências necessárias para compilar no Linux (Ubuntu/Debian).

**Uso:**
```bash
sudo ./install-deps-linux.sh
```

**O que instala:**
- curl, git, unzip, xz-utils
- clang, cmake, ninja-build
- libgtk-3-dev, libglu1-mesa
- libmpv-dev, mpv, vlc (opcional)

---

### `build-linux.sh`
Compila o aplicativo para Linux.

**Uso:**
```bash
./build-linux.sh
```

**Pré-requisitos:**
- Executar `install-deps-linux.sh` primeiro

**Saída:**
```
build/linux/x64/release/bundle/open_tv
```

---

### `create-dist.sh`
Cria um pacote de distribuição pronto para compartilhar.

**Uso:**
```bash
./create-dist.sh
```

**Saída:**
```
dist/ASTRO-TV-Linux/
├── open_tv
├── data/
├── lib/
├── icudtl.dat
└── Players/
```

---

## 📁 Fluxo de Trabalho Recomendado

### Windows (Desenvolvimento)

1. **Primeira vez:**
   ```powershell
   # Instalar Flutter SDK
   # Adicionar ao PATH
   ```

2. **Compilar:**
   ```powershell
   .\build.bat
   ```

3. **Testar:**
   ```powershell
   .\build\windows\x64\runner\Release\open_tv.exe
   ```

---

### Linux (Desenvolvimento)

1. **Primeira vez:**
   ```bash
   sudo ./install-deps-linux.sh
   ```

2. **Compilar:**
   ```bash
   ./build-linux.sh
   ```

3. **Testar:**
   ```bash
   cd build/linux/x64/release/bundle
   ./open_tv
   ```

4. **Criar pacote de distribuição:**
   ```bash
   ./create-dist.sh
   ```

---

## 📦 Estrutura de Distribuição

### Windows
```
ASTRO-TV-Windows/
├── open_tv.exe
├── data/
├── icudtl.dat
├── ...
└── Players/
    └── mpv.exe
```

### Linux
```
ASTRO-TV-Linux/
├── open_tv
├── data/
├── lib/
├── icudtl.dat
└── Players/
    └── mpv.AppImage
```

---

## 🔧 Permissões Linux

Após copiar os scripts para Linux, torne-os executáveis:

```bash
chmod +x install-deps-linux.sh
chmod +x build-linux.sh
chmod +x create-dist.sh
```

---

## 📝 Logs

- **Windows**: `%APPDATA%\OpenTV\logs\app.log`
- **Linux**: `~/.local/share/OpenTV/logs/app.log`

---

## 🆘 Solução de Problemas

### Windows: "Flutter not found"
```powershell
$env:Path += ";C:\Users\hilde\Dev\flutter\bin"
```

### Linux: "Permission denied"
```bash
chmod +x *.sh
```

### Linux: "Build not found"
```bash
# Verifique se as dependências estão instaladas
sudo ./install-deps-linux.sh

# Compile novamente
./build-linux.sh
```
