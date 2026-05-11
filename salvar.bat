@echo off
cls
echo ======================================================
echo           GIT AUTO-COMMIT - MITRIL PLAY
echo ======================================================
echo.

:: 1. Pergunta qual a mensagem do commit
set /p mensagem="Digite o que voce alterou hoje: "

:: Se o usuario der enter sem digitar nada, define uma mensagem padrao
if "%mensagem%"=="" set mensagem="Atualizacao de rotina"

echo.
echo [+] Removendo arquivos temporarios do Flutter...
call flutter clean >nul 2>&1

echo [+] Preparando arquivos no Git...
git add .

echo [+] Criando ponto de restauracao (Commit)...
git commit -m "%mensagem%"

echo.
echo ======================================================
echo           SUCESSO! PROJETO VERSIONADO
echo ======================================================
echo.
echo Ultimos 5 registros no historico:
git log --oneline -n 5
echo.
pause