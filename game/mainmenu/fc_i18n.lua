-- FreeCraft menu texts (12 languages). English is the fallback.
local L = {}
local keys = {"single","multi","host","settings","quit","back","play","newworld","del","worldname","create",
 "creative","damage","name","pass","pass_opt","addr","port","join","start","vis","private","public","srvname",
 "hint_join","hint_host","lan","net","noworld","delq","yes","no","err_name","err_addr","err_port","err_world","title_host","title_multi","title_single","unknown"}
local function add(lang, vals) L[lang] = {} for i,k in ipairs(keys) do L[lang][k] = vals[i] end end

add("en",{"Singleplayer","Multiplayer","Host a server","Settings","Quit","Back","Play","New world","Delete","World name","Create",
 "Creative mode","Enable damage","Player name","Password","Password (optional)","Server IP address","Port","Join","Start server","Visibility","Private (friends only)","Public (listed)","Server name",
 "Ask the host for the IP address and port.","Friends on your WiFi use the LAN address. Friends elsewhere use the Internet address (router: forward UDP port, or use a free VPN like Radmin VPN).","LAN address (same WiFi)","Internet address","No world yet","Delete this world?","Yes, delete","Cancel","Please enter a player name.","Please enter the server IP address.","Please enter a valid port (1-65535).","Please choose a world first.","Host a server","Join a server","Singleplayer","unknown"})
add("de",{"Einzelspieler","Mehrspieler","Server hosten","Einstellungen","Beenden","Zurück","Spielen","Neue Welt","Löschen","Weltname","Erstellen",
 "Kreativmodus","Schaden einschalten","Spielername","Passwort","Passwort (optional)","Server-IP-Adresse","Port","Beitreten","Server starten","Sichtbarkeit","Privat (nur Freunde)","Öffentlich (in Liste)","Servername",
 "Frag den Host nach IP-Adresse und Port.","Freunde im selben WLAN nutzen die LAN-Adresse. Freunde woanders nutzen die Internet-Adresse (Router: UDP-Port freigeben oder ein kostenloses VPN wie Radmin VPN nutzen).","LAN-Adresse (selbes WLAN)","Internet-Adresse","Noch keine Welt","Diese Welt löschen?","Ja, löschen","Abbrechen","Bitte einen Spielernamen eingeben.","Bitte die Server-IP-Adresse eingeben.","Bitte einen gültigen Port eingeben (1-65535).","Bitte zuerst eine Welt wählen.","Server hosten","Server beitreten","Einzelspieler","unbekannt"})
add("fr",{"Solo","Multijoueur","Héberger un serveur","Paramètres","Quitter","Retour","Jouer","Nouveau monde","Supprimer","Nom du monde","Créer",
 "Mode créatif","Activer les dégâts","Nom du joueur","Mot de passe","Mot de passe (facultatif)","Adresse IP du serveur","Port","Rejoindre","Démarrer le serveur","Visibilité","Privé (amis seulement)","Public (listé)","Nom du serveur",
 "Demande l'adresse IP et le port à l'hôte.","Les amis sur ton Wi-Fi utilisent l'adresse LAN. Les autres utilisent l'adresse Internet (routeur : rediriger le port UDP, ou un VPN gratuit comme Radmin VPN).","Adresse LAN (même Wi-Fi)","Adresse Internet","Aucun monde","Supprimer ce monde ?","Oui, supprimer","Annuler","Entre un nom de joueur.","Entre l'adresse IP du serveur.","Entre un port valide (1-65535).","Choisis d'abord un monde.","Héberger un serveur","Rejoindre un serveur","Solo","inconnue"})
add("es",{"Un jugador","Multijugador","Crear servidor","Ajustes","Salir","Atrás","Jugar","Mundo nuevo","Borrar","Nombre del mundo","Crear",
 "Modo creativo","Activar daño","Nombre de jugador","Contraseña","Contraseña (opcional)","IP del servidor","Puerto","Unirse","Iniciar servidor","Visibilidad","Privado (solo amigos)","Público (en lista)","Nombre del servidor",
 "Pide al anfitrión la IP y el puerto.","Los amigos en tu WiFi usan la dirección LAN. Los demás usan la dirección de Internet (router: abrir el puerto UDP, o un VPN gratis como Radmin VPN).","Dirección LAN (mismo WiFi)","Dirección de Internet","Aún no hay mundo","¿Borrar este mundo?","Sí, borrar","Cancelar","Escribe un nombre de jugador.","Escribe la IP del servidor.","Escribe un puerto válido (1-65535).","Elige primero un mundo.","Crear servidor","Unirse a un servidor","Un jugador","desconocida"})
add("it",{"Giocatore singolo","Multigiocatore","Crea server","Impostazioni","Esci","Indietro","Gioca","Nuovo mondo","Elimina","Nome del mondo","Crea",
 "Modalità creativa","Attiva danni","Nome giocatore","Password","Password (facoltativa)","IP del server","Porta","Entra","Avvia server","Visibilità","Privato (solo amici)","Pubblico (in elenco)","Nome del server",
 "Chiedi all'host IP e porta.","Gli amici sul tuo WiFi usano l'indirizzo LAN. Gli altri usano l'indirizzo Internet (router: apri la porta UDP, o una VPN gratuita come Radmin VPN).","Indirizzo LAN (stesso WiFi)","Indirizzo Internet","Nessun mondo","Eliminare questo mondo?","Sì, elimina","Annulla","Inserisci un nome giocatore.","Inserisci l'IP del server.","Inserisci una porta valida (1-65535).","Scegli prima un mondo.","Crea server","Entra in un server","Giocatore singolo","sconosciuto"})
add("pt",{"Um jogador","Multijogador","Criar servidor","Configurações","Sair","Voltar","Jogar","Novo mundo","Excluir","Nome do mundo","Criar",
 "Modo criativo","Ativar dano","Nome do jogador","Senha","Senha (opcional)","IP do servidor","Porta","Entrar","Iniciar servidor","Visibilidade","Privado (só amigos)","Público (na lista)","Nome do servidor",
 "Peça ao anfitrião o IP e a porta.","Amigos no seu WiFi usam o endereço LAN. Os outros usam o endereço da Internet (roteador: liberar a porta UDP, ou uma VPN grátis como Radmin VPN).","Endereço LAN (mesmo WiFi)","Endereço da Internet","Nenhum mundo ainda","Excluir este mundo?","Sim, excluir","Cancelar","Digite um nome de jogador.","Digite o IP do servidor.","Digite uma porta válida (1-65535).","Escolha um mundo primeiro.","Criar servidor","Entrar em um servidor","Um jogador","desconhecido"})
add("nl",{"Alleen spelen","Multiplayer","Server hosten","Instellingen","Afsluiten","Terug","Spelen","Nieuwe wereld","Verwijderen","Wereldnaam","Maken",
 "Creatieve modus","Schade aan","Spelernaam","Wachtwoord","Wachtwoord (optioneel)","Server-IP-adres","Poort","Meedoen","Server starten","Zichtbaarheid","Privé (alleen vrienden)","Openbaar (in lijst)","Servernaam",
 "Vraag de host om IP-adres en poort.","Vrienden op je wifi gebruiken het LAN-adres. Anderen gebruiken het internetadres (router: UDP-poort doorsturen, of een gratis VPN zoals Radmin VPN).","LAN-adres (zelfde wifi)","Internetadres","Nog geen wereld","Deze wereld verwijderen?","Ja, verwijderen","Annuleren","Vul een spelernaam in.","Vul het server-IP-adres in.","Vul een geldige poort in (1-65535).","Kies eerst een wereld.","Server hosten","Server joinen","Alleen spelen","onbekend"})
add("pl",{"Jeden gracz","Wielu graczy","Hostuj serwer","Ustawienia","Wyjdź","Wstecz","Graj","Nowy świat","Usuń","Nazwa świata","Utwórz",
 "Tryb kreatywny","Włącz obrażenia","Nazwa gracza","Hasło","Hasło (opcjonalne)","Adres IP serwera","Port","Dołącz","Uruchom serwer","Widoczność","Prywatny (tylko znajomi)","Publiczny (na liście)","Nazwa serwera",
 "Poproś hosta o adres IP i port.","Znajomi w Twoim WiFi używają adresu LAN. Pozostali używają adresu internetowego (router: przekieruj port UDP albo darmowy VPN, np. Radmin VPN).","Adres LAN (to samo WiFi)","Adres internetowy","Brak światów","Usunąć ten świat?","Tak, usuń","Anuluj","Wpisz nazwę gracza.","Wpisz adres IP serwera.","Wpisz prawidłowy port (1-65535).","Najpierw wybierz świat.","Hostuj serwer","Dołącz do serwera","Jeden gracz","nieznany"})
add("ru",{"Одиночная игра","Сетевая игра","Создать сервер","Настройки","Выход","Назад","Играть","Новый мир","Удалить","Название мира","Создать",
 "Творческий режим","Включить урон","Имя игрока","Пароль","Пароль (необязательно)","IP-адрес сервера","Порт","Войти","Запустить сервер","Видимость","Частный (только друзья)","Публичный (в списке)","Название сервера",
 "Спросите у хоста IP-адрес и порт.","Друзья в вашем Wi-Fi используют адрес LAN. Остальные – адрес в интернете (роутер: открыть UDP-порт, или бесплатный VPN, например Radmin VPN).","Адрес LAN (тот же Wi-Fi)","Адрес в интернете","Миров пока нет","Удалить этот мир?","Да, удалить","Отмена","Введите имя игрока.","Введите IP-адрес сервера.","Введите допустимый порт (1-65535).","Сначала выберите мир.","Создать сервер","Подключиться к серверу","Одиночная игра","неизвестно"})
add("tr",{"Tek oyunculu","Çok oyunculu","Sunucu kur","Ayarlar","Çık","Geri","Oyna","Yeni dünya","Sil","Dünya adı","Oluştur",
 "Yaratıcı mod","Hasarı aç","Oyuncu adı","Şifre","Şifre (isteğe bağlı)","Sunucu IP adresi","Port","Katıl","Sunucuyu başlat","Görünürlük","Özel (sadece arkadaşlar)","Herkese açık (listede)","Sunucu adı",
 "Host'tan IP adresini ve portu iste.","Aynı WiFi'deki arkadaşlar LAN adresini kullanır. Diğerleri internet adresini kullanır (modem: UDP portunu yönlendir veya Radmin VPN gibi ücretsiz bir VPN kullan).","LAN adresi (aynı WiFi)","İnternet adresi","Henüz dünya yok","Bu dünya silinsin mi?","Evet, sil","İptal","Bir oyuncu adı gir.","Sunucu IP adresini gir.","Geçerli bir port gir (1-65535).","Önce bir dünya seç.","Sunucu kur","Sunucuya katıl","Tek oyunculu","bilinmiyor"})
add("ja",{"シングルプレイ","マルチプレイ","サーバーを立てる","設定","終了","戻る","プレイ","新しいワールド","削除","ワールド名","作成",
 "クリエイティブモード","ダメージを有効にする","プレイヤー名","パスワード","パスワード（任意）","サーバーのIPアドレス","ポート","参加","サーバー開始","公開設定","非公開（友達のみ）","公開（リストに表示）","サーバー名",
 "ホストにIPアドレスとポートを聞いてください。","同じWiFiの友達はLANアドレス、離れた友達はインターネットアドレスを使います（ルーターでUDPポートを開放、またはRadmin VPNなどの無料VPN）。","LANアドレス（同じWiFi）","インターネットアドレス","ワールドがありません","このワールドを削除しますか？","はい、削除","キャンセル","プレイヤー名を入力してください。","サーバーのIPアドレスを入力してください。","有効なポートを入力してください（1-65535）。","先にワールドを選んでください。","サーバーを立てる","サーバーに参加","シングルプレイ","不明"})
add("zh",{"单人游戏","多人游戏","创建服务器","设置","退出","返回","开始","新世界","删除","世界名称","创建",
 "创造模式","启用伤害","玩家名称","密码","密码（可选）","服务器 IP 地址","端口","加入","启动服务器","可见性","私人（仅好友）","公开（显示在列表）","服务器名称",
 "请向房主询问 IP 地址和端口。","同一 WiFi 的朋友使用局域网地址，其他朋友使用互联网地址（路由器：转发 UDP 端口，或使用 Radmin VPN 等免费 VPN）。","局域网地址（同一 WiFi）","互联网地址","还没有世界","删除这个世界？","是，删除","取消","请输入玩家名称。","请输入服务器 IP 地址。","请输入有效端口（1-65535）。","请先选择一个世界。","创建服务器","加入服务器","单人游戏","未知"})

local function lang()
	local l = ""
	if core.get_language then l = core.get_language() or "" end
	if l == "" then l = core.settings:get("language") or "" end
	l = tostring(l):lower():gsub("[_%-].*$","")
	return l
end
function fc_T(k)
	local t = L[lang()] or L.en
	return t[k] or L.en[k] or k
end
