@echo off

REM ============================================================================
REM build.bat - Compila o MitrilPlay para Windows
REM ============================================================================

echo ==========================================
echo MitrilPlay Build Script
echo ==========================================
echo.

REM Add Flutter to PATH
set PATH=C:\Users\hilde\Dev\flutter\bin;%PATH%

REM Verificar Flutter
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ERRO: Flutter nao encontrado
    pause
    exit /b 1
)

echo [1/4] Verificando Flutter...
call flutter --version
echo.

echo [2/4] Habilitando Windows...
call flutter config --enable-windows-desktop
echo.

echo [3/4] Limpando build anterior...
call flutter clean
echo.

echo [4/4] Obtendo dependencias e compilando...
call flutter pub get
if %errorlevel% neq 0 (
    echo.
    echo ERRO: Falha ao obter dependencias
    pause
    exit /b 1
)

echo.
echo Compilando...
call flutter build windows --release
if %errorlevel% neq 0 (
    echo.
    echo ERRO: Falha na compilacao!
    pause
    exit /b 1
)

echo.
echo ==========================================
echo Build concluido com sucesso!
echo ==========================================
echo.
echo Executavel: build\windows\x64\runner\Release\mitril_play.exe
echo.
pause
