@echo off
REM Build script for ASTRO-TV (Windows)

REM Add Flutter to PATH
set "PATH=%PATH%;C:\Users\hilde\Dev\flutter\bin"

echo ==========================================
echo ASTRO-TV Build Script
echo ==========================================

REM Check if Flutter is installed
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Flutter not found in PATH
    exit /b 1
)

echo.
echo Flutter found
flutter --version

REM Clean previous build
echo.
echo Cleaning previous build...
call flutter clean

REM Get dependencies
echo.
echo Getting dependencies...
call flutter pub get

REM Build for Windows
echo.
echo Building for Windows...
call flutter build windows --release

echo.
echo ==========================================
echo Build completed!
echo Output: build\windows\x64\runner\Release\mitril_play.exe
echo ==========================================
echo.
echo Para distribuir:
echo 1. Copie todo o conteudo de build\windows\x64\runner\Release\
echo 2. Crie uma pasta Players junto com o executavel
echo 3. Coloque mpv.exe ou vlc.exe na pasta Players
echo ==========================================
