@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
cd /d "%~dp0"
title FreeCraft Server
echo ==========================================
echo   FreeCraft Server  (JumpIn Games)
echo ==========================================
echo.
set PORT=30000
set /p PORT=Port [30000]: 
if "%PORT%"=="" set PORT=30000
echo.
echo   1 = Private  (nur Freunde mit IP und Port)
echo   2 = Oeffentlich (erscheint in der Serverliste)
set VIS=1
set /p VIS=Auswahl [1]: 
if not exist "worlds\Server" mkdir "worlds\Server"
if not exist "worlds\Server\world.mt" (
  > "worlds\Server\world.mt" echo gameid = freecraft
  >> "worlds\Server\world.mt" echo backend = sqlite3
  >> "worlds\Server\world.mt" echo player_backend = sqlite3
  >> "worlds\Server\world.mt" echo auth_backend = sqlite3
  >> "worlds\Server\world.mt" echo mod_storage_backend = sqlite3
)
copy /y minetest.conf server.conf >nul
>> server.conf echo port = %PORT%
>> server.conf echo ipv6_server = false
>> server.conf echo server_name = FreeCraft Server
if "%VIS%"=="2" (
  >> server.conf echo server_announce = true
  >> server.conf echo server_address = 
) else (
  >> server.conf echo server_announce = false
)
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -match '^(192\.168|10\.|172\.(1[6-9]|2[0-9]|3[01]))'} | Select-Object -First 1).IPAddress"`) do set LANIP=%%i
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "try{(Invoke-RestMethod https://api.ipify.org -TimeoutSec 5)}catch{''}"`) do set NETIP=%%i
echo.
echo ------------------------------------------
echo  Server startet...
echo  Gleiches WLAN / LAN : %LANIP%  Port %PORT%
echo  Internet            : %NETIP%  Port %PORT%  (UDP-Portfreigabe im Router noetig)
echo  Beenden: Strg+C
echo ------------------------------------------
echo.
"bin\luanti.exe" --server --gameid freecraft --world "worlds\Server" --config server.conf
pause
