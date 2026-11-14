@echo off
cd /d "%~dp0"
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -match '^(192\.168|10\.|172\.(1[6-9]|2[0-9]|3[01]))'} | Select-Object -First 1).IPAddress"`) do set LANIP=%%i
powershell -NoProfile -Command "$p='minetest.conf'; $c=@(Get-Content $p | Where-Object {$_ -notmatch '^fc_lan_ip'}); $c+='fc_lan_ip = %LANIP%'; Set-Content $p $c"
start "" "bin\luanti.exe" --gameid freecraft
