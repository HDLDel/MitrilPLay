@echo off
REM ============================================================================
REM setup-vs.bat - Configura o ambiente de compilação C++ para Windows
REM ============================================================================
REM Este script baixa e instala o Visual Studio Build Tools 2022 com a
REM workload "Desenvolvimento para desktop com C++" (incluindo MSVC, Windows SDK e CMake)
REM necessária para compilar projetos Flutter para Windows.
REM Executar como Administrador.
REM ============================================================================

echo ===================================================
echo   ASTRO-TV - Instalacao do Ambiente de Compilacao
echo ===================================================
echo.

REM Verificar se esta rodando como Administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ALERTA EM CAIXA ALTA] ESTE SCRIPT PRECISA SER EXECUTADO COMO ADMINISTRADOR!
    echo Por favor, clique com o botao direito e selecione "Executar como Administrador".
    echo.
    pause
    exit /b 1
)

echo [1/3] Verificando se o Visual Studio Build Tools ja esta instalado...
set "VS_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"
if exist "%VS_PATH%\VC\Tools\MSVC" (
    echo O compilador C++ (MSVC) ja esta instalado em:
    echo %VS_PATH%
    echo.
    echo O ambiente ja parece estar configurado!
    goto check_flutter
)

echo Visual Studio Build Tools nao encontrado ou incompleto.
echo Iniciando o processo de instalacao...
echo.

echo [2/3] Baixando o instalador do Visual Studio Build Tools 2022...
set "BOOTSTRAPPER_URL=https://aka.ms/vs/17/release/vs_buildtools.exe"
set "TEMP_INSTALLER=%TEMP%\vs_buildtools.exe"

if exist "%TEMP_INSTALLER%" del "%TEMP_INSTALLER%"

curl -L -o "%TEMP_INSTALLER%" "%BOOTSTRAPPER_URL%"
if %errorLevel% neq 0 (
    echo.
    echo AVISO: Falha ao baixar o instalador com curl. Tentando via PowerShell...
    powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri '%BOOTSTRAPPER_URL%' -OutFile '%TEMP_INSTALLER%'"
    if %errorLevel% neq 0 (
        echo ERRO CRITICO: Nao foi possivel baixar o instalador. Verifique sua conexao com a internet.
        pause
        exit /b 1
    )
)
echo Download concluido com sucesso.
echo.

echo [3/3] Instalando componentes (Desktop development with C++ + Windows SDK + CMake)...
echo [ALERTA EM CAIXA ALTA] A INSTALACAO PODE DEMORAR DE 5 A 15 MINUTOS DEPENDENDO DA CONEXAO E DISCO.
echo Por favor, aguarde a conclusao. A janela do instalador executara de forma passiva.
echo.

REM Executa a instalacao silenciosa/passiva com os pacotes recomendados
start /wait "" "%TEMP_INSTALLER%" --norestart --passive --downloadThenInstall --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended

if %errorLevel% neq 0 (
    echo.
    echo AVISO: O instalador retornou um codigo diferente de zero (%errorLevel%).
    echo Se a instalacao falhar, tente rodar novamente ou instalar manualmente.
) else (
    echo.
    echo Instalacao dos componentes do Visual Studio concluida!
)

REM Limpar instalador temporario
if exist "%TEMP_INSTALLER%" del "%TEMP_INSTALLER%"

:check_flutter
echo.
echo ===================================================
echo   Verificacao do Flutter e Configuracao Windows
echo ===================================================
echo.

REM Adicionar Flutter ao PATH para a sessao atual se estiver na pasta padrao
set "DEFAULT_FLUTTER=C:\Users\hilde\Dev\flutter\bin"
if exist "%DEFAULT_FLUTTER%\flutter.bat" (
    set "PATH=%DEFAULT_FLUTTER%;%PATH%"
    echo Encontrado Flutter em: %DEFAULT_FLUTTER%
)

where flutter >nul 2>&1
if %errorLevel% equ 0 (
    echo Flutter encontrado no PATH.
    echo Habilitando suporte para compilacao Windows...
    call flutter config --enable-windows-desktop
    echo.
    echo Executando 'flutter doctor' para validar o ambiente:
    call flutter doctor
) else (
    echo [AVISO] Flutter SDK nao foi encontrado no PATH.
    echo Certifique-se de instalar o Flutter e adiciona-lo ao PATH do Windows.
    echo O caminho padrao configurado no build.bat e: C:\Users\hilde\Dev\flutter
)

echo.
echo ===================================================
echo   Processo de Configuracao Concluido!
echo ===================================================
echo.
echo Agora voce pode compilar o projeto rodando o script:
echo .\build.bat
echo.
pause
