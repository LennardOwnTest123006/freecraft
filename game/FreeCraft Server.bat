@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
cd /d "%~dp0"
title FreeCraft Server
set L=en
for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "(Get-Culture).TwoLetterISOLanguageName"`) do set L=%%i
if /i "!L!"=="en" goto lang_en
if /i "!L!"=="de" goto lang_de
if /i "!L!"=="fr" goto lang_fr
if /i "!L!"=="es" goto lang_es
if /i "!L!"=="it" goto lang_it
if /i "!L!"=="pt" goto lang_pt
if /i "!L!"=="nl" goto lang_nl
if /i "!L!"=="pl" goto lang_pl
if /i "!L!"=="ru" goto lang_ru
if /i "!L!"=="tr" goto lang_tr
if /i "!L!"=="ja" goto lang_ja
if /i "!L!"=="zh" goto lang_zh
goto lang_en
:lang_en
set "M1=Port [30000]: "
set "M2=1 = Private  (friends with IP and port only)"
set "M3=2 = Public (listed in the server list)"
set "M4=Choice [1]: "
set "M5=Server starting..."
set "M6=Same WiFi / LAN"
set "M7=Internet"
set "M8=(UDP port forwarding needed on router)"
set "M9=Quit: Ctrl+C"
goto langdone
:lang_de
set "M1=Port [30000]: "
set "M2=1 = Privat  (nur Freunde mit IP und Port)"
set "M3=2 = Öffentlich (erscheint in der Serverliste)"
set "M4=Auswahl [1]: "
set "M5=Server startet..."
set "M6=Gleiches WLAN / LAN"
set "M7=Internet"
set "M8=(UDP-Portfreigabe im Router nötig)"
set "M9=Beenden: Strg+C"
goto langdone
:lang_fr
set "M1=Port [30000] : "
set "M2=1 = Privé  (amis avec IP et port)"
set "M3=2 = Public (visible dans la liste)"
set "M4=Choix [1] : "
set "M5=Démarrage du serveur..."
set "M6=Même Wi-Fi / LAN"
set "M7=Internet"
set "M8=(redirection de port UDP requise sur la box)"
set "M9=Quitter : Ctrl+C"
goto langdone
:lang_es
set "M1=Puerto [30000]: "
set "M2=1 = Privado  (solo amigos con IP y puerto)"
set "M3=2 = Público (aparece en la lista)"
set "M4=Opción [1]: "
set "M5=Iniciando servidor..."
set "M6=Mismo WiFi / LAN"
set "M7=Internet"
set "M8=(se necesita abrir el puerto UDP en el router)"
set "M9=Salir: Ctrl+C"
goto langdone
:lang_it
set "M1=Porta [30000]: "
set "M2=1 = Privato  (solo amici con IP e porta)"
set "M3=2 = Pubblico (appare nell'elenco)"
set "M4=Scelta [1]: "
set "M5=Avvio del server..."
set "M6=Stesso WiFi / LAN"
set "M7=Internet"
set "M8=(serve l'apertura della porta UDP sul router)"
set "M9=Esci: Ctrl+C"
goto langdone
:lang_pt
set "M1=Porta [30000]: "
set "M2=1 = Privado  (só amigos com IP e porta)"
set "M3=2 = Público (aparece na lista)"
set "M4=Escolha [1]: "
set "M5=Iniciando servidor..."
set "M6=Mesmo Wi-Fi / LAN"
set "M7=Internet"
set "M8=(é preciso liberar a porta UDP no roteador)"
set "M9=Sair: Ctrl+C"
goto langdone
:lang_nl
set "M1=Poort [30000]: "
set "M2=1 = Privé  (alleen vrienden met IP en poort)"
set "M3=2 = Openbaar (verschijnt in de serverlijst)"
set "M4=Keuze [1]: "
set "M5=Server start..."
set "M6=Zelfde wifi / LAN"
set "M7=Internet"
set "M8=(UDP-poort doorsturen op router nodig)"
set "M9=Stoppen: Ctrl+C"
goto langdone
:lang_pl
set "M1=Port [30000]: "
set "M2=1 = Prywatny  (tylko znajomi z IP i portem)"
set "M3=2 = Publiczny (widoczny na liście serwerów)"
set "M4=Wybór [1]: "
set "M5=Uruchamianie serwera..."
set "M6=Ta sama sieć WiFi / LAN"
set "M7=Internet"
set "M8=(wymagane przekierowanie portu UDP w routerze)"
set "M9=Zakończ: Ctrl+C"
goto langdone
:lang_ru
set "M1=Порт [30000]: "
set "M2=1 = Приватный  (только друзья с IP и портом)"
set "M3=2 = Публичный (виден в списке серверов)"
set "M4=Выбор [1]: "
set "M5=Запуск сервера..."
set "M6=Та же сеть Wi-Fi / LAN"
set "M7=Интернет"
set "M8=(нужен проброс UDP-порта на роутере)"
set "M9=Выход: Ctrl+C"
goto langdone
:lang_tr
set "M1=Port [30000]: "
set "M2=1 = Özel  (yalnızca IP ve portu bilen arkadaşlar)"
set "M3=2 = Herkese açık (sunucu listesinde görünür)"
set "M4=Seçim [1]: "
set "M5=Sunucu başlatılıyor..."
set "M6=Aynı WiFi / LAN"
set "M7=İnternet"
set "M8=(yönlendiricide UDP port yönlendirme gerekir)"
set "M9=Çıkış: Ctrl+C"
goto langdone
:lang_ja
set "M1=ポート [30000]: "
set "M2=1 = プライベート（IPとポートを知る友達のみ）"
set "M3=2 = 公開（サーバーリストに表示）"
set "M4=選択 [1]: "
set "M5=サーバーを起動中..."
set "M6=同じWi-Fi / LAN"
set "M7=インターネット"
set "M8=（ルーターでUDPポート開放が必要）"
set "M9=終了: Ctrl+C"
goto langdone
:lang_zh
set "M1=端口 [30000]: "
set "M2=1 = 私人（仅知道 IP 和端口的朋友）"
set "M3=2 = 公开（显示在服务器列表）"
set "M4=选择 [1]: "
set "M5=服务器启动中..."
set "M6=同一 WiFi / 局域网"
set "M7=互联网"
set "M8=（路由器需开放 UDP 端口）"
set "M9=退出: Ctrl+C"
goto langdone
:langdone
echo ==========================================
echo   FreeCraft Server  (JumpIn Games)
echo ==========================================
echo.
set PORT=30000
set /p PORT=!M1!
if "%PORT%"=="" set PORT=30000
echo.
echo   !M2!
echo   !M3!
set VIS=1
set /p VIS=!M4!
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
echo  !M5!
echo  !M6! : %LANIP%  Port %PORT%
echo  !M7! : %NETIP%  Port %PORT%  !M8!
echo  !M9!
echo ------------------------------------------
echo.
"bin\FreeCraft-Server.exe" --server --gameid freecraft --world "worlds\Server" --config server.conf
pause
