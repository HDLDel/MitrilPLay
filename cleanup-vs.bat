@echo off
REM Script para remover componentes do Visual Studio Build Tools
REM Executar como Administrador

echo ==========================================
REM ASTRO-TV - Limpeza Visual Studio Build Tools
echo ==========================================
echo.

REM Parar processos do Visual Studio
echo Parando processos do Visual Studio...
taskkill /F /IM vs_installer.exe >nul 2>&1
taskkill /F /IM ServiceHub.* >nul 2>&1

REM Desinstalar usando o proprio instalador
echo.
echo Desinstalando componentes...
if exist "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" (
    "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" uninstall --force --passive
) else (
    echo Instalador do VS nao encontrado. Remocao manual necessaria.
)

echo.
echo Removendo pastas restantes...

REM Remover pasta do Build Tools
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools" (
    echo Removendo BuildTools...
    rmdir /s /q "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"
)

REM Remover pasta do VC (compilador C++)
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC" (
    echo Removendo VC Tools...
    rmdir /s /q "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC"
)

REM Remover Windows SDK
if exist "C:\Program Files (x86)\Windows Kits\10" (
    echo Removendo Windows SDK 10...
    rmdir /s /q "C:\Program Files (x86)\Windows Kits\10"
)

REM Remover CMake
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake" (
    echo Removendo CMake...
    rmdir /s /q "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake"
)

REM Limpar registro (opcional)
echo.
echo Limpando registro...
reg delete "HKLM\SOFTWARE\Microsoft\VisualStudio\17.0" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\VisualStudio\17.0" /f >nul 2>&1

echo.
echo ==========================================
echo Limpeza concluida!
echo ==========================================
echo.
echo Nota: Alguns arquivos podem permanecer se estiverem em uso.
echo Reinicie o computador para remover arquivos travados.
