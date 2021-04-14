echo off
@echo off
setlocal enabledelayedexpansion

REM -- check XHTML support (IE 9+)
set xhtml=0
for /f %%G in ('"reg query "HKCR\IE.AssocFile.XHT" /ve 2>&1 | findstr /c:".XHT" "') do set xhtml=1

REM -- reset file extensions
set exts=HTM,HTML
if %xhtml% == 1 (set exts=%exts%,XHT,XHTML)

for %%G in (%exts%) do (
set ext=%%G
set ext=!ext:~0,3!
reg add "HKCU\Software\Classes\.%%G" /ve /t REG_SZ /d "IE.AssocFile.!ext!" /f >nul
)

set exts=%exts%,MHT,MHTML,URL
set acl=%temp%\acl_%random%%random%.txt

for %%G in (%exts%) do (
set key=HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.%%G\UserChoice
echo !key! [1 7 17]>"%acl%"
regini "%acl%" >nul
set ext=%%G
set ext=!ext:~0,3!
reg add "!key!" /v "Progid" /t REG_SZ /d "IE.AssocFile.!ext!" /f >nul
)
del "%acl%" 2>nul

REM -- reset MIME associations
for %%G in (message/rfc822,text/html) do (
set key=HKCU\Software\Microsoft\Windows\Shell\Associations\MIMEAssociations\%%G\UserChoice
reg add "!key!" /v "Progid" /t REG_SZ /d "IE.%%G" /f >nul
)

REM -- reset URL protocols
for %%A in (FTP,HTTP,HTTPS) do (
set key=HKCU\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\%%A\UserChoice
reg add "!key!" /v "Progid" /t REG_SZ /d "IE.%%A" /f >nul
for %%B in (DefaultIcon,shell) do (
set key=HKCU\Software\Classes\%%A
reg delete "!key!\%%B" /f >nul 2>&1
reg copy "HKCR\IE.%%A\%%B" "!key!\%%B" /s /f >nul
reg add "!key!" /v "EditFlags" /t REG_DWORD /d 2 /f >nul
reg add "!key!" /v "URL Protocol" /t REG_SZ /d "" /f >nul
))

REM -- reset the start menu Internet link (Vista and earlier)
reg add "HKCU\Software\Clients\StartMenuInternet" /ve /t REG_SZ /d "IEXPLORE.EXE" /f

REM -- reset cached icons
if %xhtml% == 1 (
ie4uinit -cleariconcache
) else (
taskkill /im explorer.exe /f >nul
start explorer
)

REM pause
REM exit /b

exit
