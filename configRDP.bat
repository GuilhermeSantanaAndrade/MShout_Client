@echo off

FOR /L %%W IN (14,1,45) DO MODE CON:LINES=1 COLS=%%W
FOR /L %%W IN (1,1,20) DO MODE CON:COLS=45 LINES=%%W
findstr "�%skip%Boss" "%~f0" >nul
if %errorlevel%==1 goto teste
if %errorlevel%==0 goto direto
:teste
Set tt=0
set a=�
set s=Boss
:navega
cls
echo.
echo   Esse processo sera pedido somente uma vez
echo.
:segue
echo.
echo.    Login de acesso ao computador remoto
echo.
set /p login="Digite seu login: "
if "%login%"=="" echo opcao invalida&cls&goto segue
echo.
echo.    Senha de acesso ao computador remoto
echo.
set /p senha="Digite a senha: "
if "%senha%"=="" echo opcao invalida&cls&goto segue
::::::::::::::::::::::::::
echo.
echo.       IP do computador remoto
echo.
echo   Enter para ser solicitado 
echo   O ip em toda exexu��o do programa
echo.
set /p ip="Ex. 172.16.7.125: "
if "%ip%"=="" set ip=skip
cls
echo.
echo.
echo.
echo Caso queira refazer o processo remova
echo  a ultima linha do final desse batch
echo.
echo.
echo.
pause
::::::::::::::::::::::::::
cls
(
echo Login:%login%;Senha:%senha%;ip:%ip%; %a%%s%
)>>%0

:direto
echo.
echo.
echo.
@FOR %%# IN ( M S H O T - CONECTANDO . . .) DO @SET/P=%%~#<NUL&>NUL PING -n 1 0
findstr "�%skip%Boss" "%~f0" > $_
for /f "tokens=2 delims=:;" %%a in ($_) do (
set login=%%a
)
echo.
for /f "tokens=4 delims=:;" %%a in ($_) do (
set senha=%%a
)

echo.
for /f "tokens=6 delims=:;" %%a in ($_) do (
set ip=%%a
)
if "%ip%"=="skip" (
echo.
echo.
echo.
Set /p ip=Digite o ip do computador remoto
)

for %%f in ($_) do del %%f

mstsc.exe /w:800 /h:600 /v %ip%
(
echo set w = createObject ("Wscript.Shell"^)
echo wscript.sleep "2000"
echo. 'w.sendkeys "%login%"
echo wscript.sleep "500"
echo. 'w.sendkeys "{TAB}"
echo wscript.sleep "500"
echo w.sendkeys "%senha%"
echo wscript.sleep "500"
echo w.sendkeys "{ENTER}"
) > Conecta.vbs
cscript.exe //nologo Conecta.vbs
for %%f in (Conecta.vbs) do del /q /s  %%f >nul


:SAINDO
(
Echo. On Error Resume Next
Echo. Dim Sh
Echo. Set Sh = WScript.CreateObject("WScript.Shell"^)
)>Satti.vbs 
CSCRIPT //NOLOGO Satti.vbs 
del /q /s Satti.vbs >nul
exit

:Login:administrator;Senha:@chiita3;ip:192.168.103.11; �Boss
