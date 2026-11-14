package main

import (
	"archive/zip"
	"bufio"
	"bytes"
	_ "embed"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"syscall"
	"unsafe"
)

//go:embed payload.zip
var payload []byte

var tr = map[string]map[string]string{
	"en": {"title": "FreeCraft Setup", "dir": "Installing to", "eng": "Downloading game engine (Luanti)...", "game": "Installing FreeCraft...", "lnk": "Creating shortcut...", "done": "Done! Start FreeCraft from your desktop.", "fail": "Engine download failed. Install Luanti from luanti.org, then copy %s\\games to its games folder.", "start": "Press Enter to start FreeCraft..."},
	"de": {"title": "FreeCraft Setup", "dir": "Installation nach", "eng": "Spiel-Engine (Luanti) wird geladen...", "game": "FreeCraft wird installiert...", "lnk": "Verknüpfung wird erstellt...", "done": "Fertig! Starte FreeCraft über den Desktop.", "fail": "Engine-Download fehlgeschlagen. Installiere Luanti von luanti.org und kopiere %s\\games in dessen games-Ordner.", "start": "Enter drücken, um FreeCraft zu starten..."},
	"fr": {"title": "Installation de FreeCraft", "dir": "Installation dans", "eng": "Téléchargement du moteur (Luanti)...", "game": "Installation de FreeCraft...", "lnk": "Création du raccourci...", "done": "Terminé ! Lancez FreeCraft depuis le bureau.", "fail": "Échec du téléchargement. Installez Luanti (luanti.org), puis copiez %s\\games dans son dossier games.", "start": "Entrée pour lancer FreeCraft..."},
	"es": {"title": "Instalador de FreeCraft", "dir": "Instalando en", "eng": "Descargando motor (Luanti)...", "game": "Instalando FreeCraft...", "lnk": "Creando acceso directo...", "done": "¡Listo! Inicia FreeCraft desde el escritorio.", "fail": "Falló la descarga. Instala Luanti (luanti.org) y copia %s\\games a su carpeta games.", "start": "Pulsa Enter para iniciar FreeCraft..."},
	"it": {"title": "Installazione di FreeCraft", "dir": "Installazione in", "eng": "Download del motore (Luanti)...", "game": "Installazione di FreeCraft...", "lnk": "Creazione del collegamento...", "done": "Fatto! Avvia FreeCraft dal desktop.", "fail": "Download non riuscito. Installa Luanti (luanti.org) e copia %s\\games nella sua cartella games.", "start": "Premi Invio per avviare FreeCraft..."},
	"pt": {"title": "Instalador do FreeCraft", "dir": "Instalando em", "eng": "Baixando o motor (Luanti)...", "game": "Instalando o FreeCraft...", "lnk": "Criando atalho...", "done": "Pronto! Inicie o FreeCraft pela área de trabalho.", "fail": "Falha no download. Instale o Luanti (luanti.org) e copie %s\\games para a pasta games dele.", "start": "Pressione Enter para iniciar o FreeCraft..."},
	"nl": {"title": "FreeCraft-installatie", "dir": "Installeren in", "eng": "Spel-engine (Luanti) downloaden...", "game": "FreeCraft installeren...", "lnk": "Snelkoppeling maken...", "done": "Klaar! Start FreeCraft vanaf je bureaublad.", "fail": "Download mislukt. Installeer Luanti (luanti.org) en kopieer %s\\games naar de games-map.", "start": "Druk op Enter om FreeCraft te starten..."},
	"pl": {"title": "Instalator FreeCraft", "dir": "Instalacja w", "eng": "Pobieranie silnika (Luanti)...", "game": "Instalowanie FreeCraft...", "lnk": "Tworzenie skrótu...", "done": "Gotowe! Uruchom FreeCraft z pulpitu.", "fail": "Pobieranie nie powiodło się. Zainstaluj Luanti (luanti.org) i skopiuj %s\\games do jego folderu games.", "start": "Naciśnij Enter, aby uruchomić FreeCraft..."},
	"ru": {"title": "Установка FreeCraft", "dir": "Установка в", "eng": "Загрузка движка (Luanti)...", "game": "Установка FreeCraft...", "lnk": "Создание ярлыка...", "done": "Готово! Запустите FreeCraft с рабочего стола.", "fail": "Не удалось загрузить движок. Установите Luanti (luanti.org) и скопируйте %s\\games в его папку games.", "start": "Нажмите Enter, чтобы запустить FreeCraft..."},
	"tr": {"title": "FreeCraft Kurulumu", "dir": "Kurulum yeri", "eng": "Oyun motoru (Luanti) indiriliyor...", "game": "FreeCraft kuruluyor...", "lnk": "Kısayol oluşturuluyor...", "done": "Tamam! FreeCraft'ı masaüstünden başlat.", "fail": "İndirme başarısız. Luanti'yi (luanti.org) kur ve %s\\games klasörünü onun games klasörüne kopyala.", "start": "FreeCraft'ı başlatmak için Enter'a bas..."},
	"ja": {"title": "FreeCraft セットアップ", "dir": "インストール先", "eng": "ゲームエンジン (Luanti) をダウンロード中...", "game": "FreeCraft をインストール中...", "lnk": "ショートカットを作成中...", "done": "完了！デスクトップから FreeCraft を起動してください。", "fail": "ダウンロードに失敗しました。Luanti (luanti.org) をインストールし、%s\\games を games フォルダにコピーしてください。", "start": "Enterキーで FreeCraft を起動..."},
	"zh": {"title": "FreeCraft 安装程序", "dir": "安装到", "eng": "正在下载游戏引擎 (Luanti)...", "game": "正在安装 FreeCraft...", "lnk": "正在创建快捷方式...", "done": "完成！请从桌面启动 FreeCraft。", "fail": "下载失败。请安装 Luanti (luanti.org)，然后将 %s\\games 复制到其 games 文件夹。", "start": "按 Enter 启动 FreeCraft..."},
}

func lang() string {
	k := syscall.NewLazyDLL("kernel32.dll").NewProc("GetUserDefaultLocaleName")
	buf := make([]uint16, 85)
	r, _, _ := k.Call(uintptr(unsafe.Pointer(&buf[0])), 85)
	if r == 0 {
		return "en"
	}
	l := strings.ToLower(syscall.UTF16ToString(buf))
	if len(l) >= 2 {
		if _, ok := tr[l[:2]]; ok {
			return l[:2]
		}
	}
	return "en"
}

func unzip(data []byte, dst, strip string) error {
	zr, err := zip.NewReader(bytes.NewReader(data), int64(len(data)))
	if err != nil {
		return err
	}
	for _, f := range zr.File {
		name := f.Name
		if strip != "" {
			name = strings.TrimPrefix(name, strip)
		}
		if name == "" {
			continue
		}
		p := filepath.Join(dst, filepath.FromSlash(name))
		if !strings.HasPrefix(p, filepath.Clean(dst)+string(os.PathSeparator)) {
			continue
		}
		if f.FileInfo().IsDir() {
			os.MkdirAll(p, 0o755)
			continue
		}
		os.MkdirAll(filepath.Dir(p), 0o755)
		rc, err := f.Open()
		if err != nil {
			return err
		}
		w, err := os.Create(p)
		if err != nil {
			rc.Close()
			return err
		}
		io.Copy(w, rc)
		w.Close()
		rc.Close()
	}
	return nil
}

func engine(dst string) error {
	resp, err := http.Get("https://api.github.com/repos/luanti-org/luanti/releases/tags/5.18.0")
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	var rel struct {
		Assets []struct {
			Name string `json:"name"`
			URL  string `json:"browser_download_url"`
		} `json:"assets"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&rel); err != nil {
		return err
	}
	for _, a := range rel.Assets {
		n := strings.ToLower(a.Name)
		if strings.Contains(n, "win64") && strings.HasSuffix(n, ".zip") {
			r, err := http.Get(a.URL)
			if err != nil {
				return err
			}
			data, err := io.ReadAll(r.Body)
			r.Body.Close()
			if err != nil {
				return err
			}
			// Top-Ordner (z. B. luanti-5.x-win64/) entfernen
			zr, _ := zip.NewReader(bytes.NewReader(data), int64(len(data)))
			strip := ""
			if len(zr.File) > 0 {
				if i := strings.Index(zr.File[0].Name, "/"); i > 0 {
					strip = zr.File[0].Name[:i+1]
				}
			}
			return unzip(data, dst, strip)
		}
	}
	return fmt.Errorf("no win64 asset")
}

type memStatus struct {
	Length, MemoryLoad                                                             uint32
	TotalPhys, AvailPhys, TotalPageFile, AvailPageFile, TotalVirtual, AvailVirtual uint64
	AvailExtendedVirtual                                                           uint64
}

func ramGB() int {
	var m memStatus
	m.Length = uint32(unsafe.Sizeof(m))
	r, _, _ := syscall.NewLazyDLL("kernel32.dll").NewProc("GlobalMemoryStatusEx").Call(uintptr(unsafe.Pointer(&m)))
	if r == 0 {
		return 8
	}
	return int(m.TotalPhys >> 30)
}

// Qualität an PC anpassen (leicht / mittel / hoch)
func tune(dst string) {
	cores, ram := runtime.NumCPU(), ramGB()
	var extra string
	switch {
	case cores <= 4 || ram < 8:
		extra = "\n# Auto: leichter PC\nvideo_driver = opengl\nfsaa = 0\nclient_mesh_chunk = 2\nenable_dynamic_shadows = false\nenable_bloom = false\nenable_volumetric_lighting = false\nviewing_range = 80\nfsaa = 0\nsmooth_lighting = false\nenable_waving_leaves = false\nenable_waving_water = false\nfps_max = 60\nmcl_mob_cap_monster = 40\nmcl_mob_cap_animal = 10\n"
	case cores <= 8 || ram < 16:
		extra = "\n# Auto: mittlerer PC\nshadow_map_texture_size = 1024\nviewing_range = 120\nfsaa = 2\n"
	default:
		extra = "\n# Auto: starker PC\nviewing_range = 180\nshadow_map_texture_size = 2048\nshadow_map_max_distance = 140\nfsaa = 4\nenable_auto_exposure = true\n"
	}
	f, err := os.OpenFile(filepath.Join(dst, "minetest.conf"), os.O_APPEND|os.O_WRONLY, 0o644)
	if err == nil {
		f.WriteString(extra)
		f.Close()
	}
}

func main() {
	syscall.NewLazyDLL("kernel32.dll").NewProc("SetConsoleOutputCP").Call(65001)
	t := tr[lang()]
	dst := filepath.Join(os.Getenv("LOCALAPPDATA"), "FreeCraft")
	fmt.Println(t["title"])
	if _, err := os.Stat(filepath.Join(dst, "Uninstall FreeCraft.bat")); err == nil {
		q := "FreeCraft is already installed.  [Enter] = update/reinstall   [U] = uninstall: "
		if lang() == "de" {
			q = "FreeCraft ist bereits installiert.  [Enter] = aktualisieren   [U] = deinstallieren: "
		}
		fmt.Print(q)
		a, _ := bufio.NewReader(os.Stdin).ReadString('\n')
		if strings.HasPrefix(strings.ToLower(strings.TrimSpace(a)), "u") {
			c := exec.Command("cmd", "/c", "start", "", filepath.Join(dst, "Uninstall FreeCraft.bat"))
			c.Dir = dst
			c.Start()
			return
		}
	}
	fmt.Println(t["dir"], dst)
	os.MkdirAll(dst, 0o755)
	fmt.Println(t["eng"])
	engErr := engine(dst)
	fmt.Println(t["game"])
	if err := unzip(payload, dst, "FreeCraft/"); err != nil {
		fmt.Println(err)
	}
	tune(dst)
	if engErr != nil {
		fmt.Printf(t["fail"]+"\n", dst)
		bufio.NewReader(os.Stdin).ReadString('\n')
		return
	}
	fmt.Println(t["lnk"])
	exe := filepath.Join(dst, "FreeCraft.bat")
	ico := filepath.Join(dst, "freecraft.ico")
	mk := func(name, target, args, wd string, style int) string {
		return fmt.Sprintf(`$s=(New-Object -ComObject WScript.Shell).CreateShortcut([Environment]::GetFolderPath('Desktop')+'\%s.lnk');$s.TargetPath='%s';$s.Arguments='%s';$s.WorkingDirectory='%s';$s.IconLocation='%s';$s.WindowStyle=%d;$s.Save()`, name, target, args, wd, ico, style)
	}
	os.MkdirAll(filepath.Join(dst, "worlds"), 0o755)
	ps := mk("FreeCraft", exe, "", dst, 7) + ";" + mk("FreeCraft Server", filepath.Join(dst, "FreeCraft Server.bat"), "", dst, 1) + ";" + mk("FreeCraft Worlds", filepath.Join(dst, "worlds"), "", dst, 1)
	exec.Command("powershell", "-NoProfile", "-Command", ps).Run()
	un := filepath.Join(dst, "Uninstall FreeCraft.bat")
	key := `HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\FreeCraft`
	for _, kv := range [][2]string{{"DisplayName", "FreeCraft"}, {"Publisher", "JumpIn Games"}, {"DisplayVersion", "1.0"}, {"DisplayIcon", ico}, {"InstallLocation", dst}, {"UninstallString", `"` + un + `"`}} {
		exec.Command("reg", "add", key, "/v", kv[0], "/d", kv[1], "/f").Run()
	}
	fmt.Println(t["done"])
	fmt.Println(t["start"])
	bufio.NewReader(os.Stdin).ReadString('\n')
	c := exec.Command("cmd", "/c", exe)
	c.Dir = dst
	c.Start()
}
