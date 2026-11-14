@echo off
chcp 65001 >nul
title FreeCraft deinstallieren / Uninstall
set "D=%~dp0"
echo FreeCraft wird entfernt / FreeCraft will be removed:
echo   %D%
echo.
set K=J
set /p K=Welten behalten (Backup auf dem Desktop)? / Keep worlds (backup on Desktop)? [J/N]: 
taskkill /f /im luanti.exe >nul 2>&1
timeout /t 2 /nobreak >nul
if /i "%K%"=="J" (
  if exist "%D%worlds" xcopy /e /i /y /q "%D%worlds" "%USERPROFILE%\Desktop\FreeCraft-Welten-Backup" >nul
)
if /i "%K%"=="Y" (
  if exist "%D%worlds" xcopy /e /i /y /q "%D%worlds" "%USERPROFILE%\Desktop\FreeCraft-Welten-Backup" >nul
)
powershell -NoProfile -Command "$d=[Environment]::GetFolderPath('Desktop'); 'FreeCraft','FreeCraft Server','FreeCraft Worlds' | ForEach-Object { Remove-Item -Force -ErrorAction SilentlyContinue (Join-Path $d ($_+'.lnk')) }"
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\FreeCraft" /f >nul 2>&1
echo Fertig. / Done.
start "" powershell -NoProfile -WindowStyle Hidden -Command "Start-Sleep 2; Remove-Item -Recurse -Force -ErrorAction SilentlyContinue '%D%'"
exit
