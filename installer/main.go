package main

import (
	"archive/zip"
	"bytes"
	_ "embed"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"runtime"
	"strings"
	"syscall"
	"unsafe"
)

//go:embed payload.zip
var payload []byte

//go:embed strings.json
var strJSON []byte

//go:embed setup.ps1
var setupPS []byte

var known = map[string]bool{"en": true, "de": true, "fr": true, "es": true, "it": true, "pt": true, "nl": true, "pl": true, "ru": true, "tr": true, "ja": true, "zh": true}

func lang() string {
	k := syscall.NewLazyDLL("kernel32.dll").NewProc("GetUserDefaultLocaleName")
	buf := make([]uint16, 85)
	r, _, _ := k.Call(uintptr(unsafe.Pointer(&buf[0])), 85)
	if r == 0 {
		return "en"
	}
	l := strings.ToLower(syscall.UTF16ToString(buf))
	if len(l) >= 2 && known[l[:2]] {
		return l[:2]
	}
	return "en"
}

func hidden(name string, args ...string) *exec.Cmd {
	c := exec.Command(name, args...)
	c.SysProcAttr = &syscall.SysProcAttr{HideWindow: true, CreationFlags: 0x08000000}
	return c
}

func copyDir(src, dst string) {
	filepath.Walk(src, func(p string, fi os.FileInfo, err error) error {
		if err != nil {
			return nil
		}
		rel, _ := filepath.Rel(src, p)
		t := filepath.Join(dst, rel)
		if fi.IsDir() {
			os.MkdirAll(t, 0o755)
			return nil
		}
		b, e := os.ReadFile(p)
		if e == nil {
			os.WriteFile(t, b, 0o644)
		}
		return nil
	})
}

func unzip(data []byte, dst, strip string, cb func(i, n int)) error {
	zr, err := zip.NewReader(bytes.NewReader(data), int64(len(data)))
	if err != nil {
		return err
	}
	for idx, f := range zr.File {
		if cb != nil && idx%50 == 0 {
			cb(idx, len(zr.File))
		}
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

func engine(dst string, pr func(int, string)) error {
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
			var buf bytes.Buffer
			chunk := make([]byte, 64*1024)
			for {
				n, e := r.Body.Read(chunk)
				buf.Write(chunk[:n])
				if r.ContentLength > 0 {
					pr(5+int(float64(buf.Len())/float64(r.ContentLength)*55), "eng")
				}
				if e == io.EOF {
					break
				}
				if e != nil {
					r.Body.Close()
					return e
				}
			}
			r.Body.Close()
			data := buf.Bytes()
			// Top-Ordner entfernen
			zr, _ := zip.NewReader(bytes.NewReader(data), int64(len(data)))
			strip := ""
			if len(zr.File) > 0 {
				if i := strings.Index(zr.File[0].Name, "/"); i > 0 {
					strip = zr.File[0].Name[:i+1]
				}
			}
			return unzip(data, dst, strip, nil)
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

// Engine-Dateien auf FreeCraft umstellen (Namen, Doku entfernen, Menütexte)
func rebrand(dst string) {
	os.Remove(filepath.Join(dst, "bin", "luanti.exe"))
	os.RemoveAll(filepath.Join(dst, "doc"))
	os.Remove(filepath.Join(dst, "minetest.conf.example"))
	filepath.Walk(filepath.Join(dst, "builtin"), func(p string, fi os.FileInfo, err error) error {
		if err != nil || fi.IsDir() {
			return nil
		}
		if strings.HasSuffix(p, ".lua") || strings.HasSuffix(p, ".txt") {
			if b, e := os.ReadFile(p); e == nil && bytes.Contains(b, []byte("Luanti")) {
				os.WriteFile(p, bytes.ReplaceAll(b, []byte("Luanti"), []byte("FreeCraft")), 0o644)
			}
		}
		return nil
	})
}

type workArgs struct{ Dst, Lang, User, Disp, Prog string }

func setName(dst, user, disp string) {
	p := filepath.Join(dst, "minetest.conf")
	b, _ := os.ReadFile(p)
	re := regexp.MustCompile(`(?m)^\s*(name|freecraft_display_name)\s*=.*\r?\n?`)
	s := re.ReplaceAllString(string(b), "")
	s += "\nname = " + user + "\nfreecraft_display_name = " + disp + "\n"
	os.WriteFile(p, []byte(s), 0o644)
}

func worker(argf string) {
	raw, err := os.ReadFile(argf)
	if err != nil {
		return
	}
	raw = bytes.TrimPrefix(raw, []byte("\xef\xbb\xbf"))
	var a workArgs
	if json.Unmarshal(raw, &a) != nil {
		return
	}
	pr := func(p int, key string) { os.WriteFile(a.Prog, []byte(fmt.Sprintf("%d|%s", p, key)), 0o644) }
	fail := func() { os.WriteFile(a.Prog, []byte("-1|fail"), 0o644) }
	dst := a.Dst
	os.MkdirAll(dst, 0o755)
	pr(2, "eng")
	if err := engine(dst, pr); err != nil {
		fail()
		return
	}
	rebrand(dst)
	pr(62, "game")
	if err := unzip(payload, dst, "FreeCraft/", func(i, n int) { pr(62+i*28/n, "game") }); err != nil {
		fail()
		return
	}
	os.Remove(filepath.Join(dst, "Uninstall FreeCraft.bat"))
	tune(dst)
	// gespeicherte Welten wiederherstellen
	docs := filepath.Join(os.Getenv("USERPROFILE"), "Documents", "FreeCraft Saves")
	if _, e := os.Stat(filepath.Join(dst, "worlds")); e != nil {
		if _, e2 := os.Stat(filepath.Join(docs, "worlds")); e2 == nil {
			copyDir(filepath.Join(docs, "worlds"), filepath.Join(dst, "worlds"))
		}
		if _, e2 := os.Stat(filepath.Join(docs, "client")); e2 == nil {
			copyDir(filepath.Join(docs, "client"), filepath.Join(dst, "client"))
		}
	}
	setName(dst, a.User, a.Disp)
	pr(92, "lnk")
	exe := filepath.Join(os.Getenv("SystemRoot"), "System32", "wscript.exe")
	vbs := `"` + filepath.Join(dst, "FreeCraft.vbs") + `"`
	ico := filepath.Join(dst, "freecraft.ico")
	mk := func(name, target, args, wd string, style int) string {
		return fmt.Sprintf(`$s=(New-Object -ComObject WScript.Shell).CreateShortcut([Environment]::GetFolderPath('Desktop')+'\%s.lnk');$s.TargetPath='%s';$s.Arguments='%s';$s.WorkingDirectory='%s';$s.IconLocation='%s';$s.WindowStyle=%d;$s.Save()`, name, target, args, wd, ico, style)
	}
	os.MkdirAll(filepath.Join(dst, "worlds"), 0o755)
	ps := mk("FreeCraft", exe, vbs, dst, 1) + ";" + mk("FreeCraft Server", filepath.Join(dst, "FreeCraft Server.bat"), "", dst, 1) + ";" + mk("FreeCraft Worlds", filepath.Join(dst, "worlds"), "", dst, 1)
	hidden("powershell", "-NoProfile", "-Command", ps).Run()
	un := filepath.Join(dst, "Uninstall FreeCraft.exe")
	key := `HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\FreeCraft`
	for _, kv := range [][2]string{{"DisplayName", "FreeCraft"}, {"Publisher", "JumpIn Games"}, {"DisplayVersion", "1.0"}, {"DisplayIcon", ico}, {"InstallLocation", dst}, {"UninstallString", `"` + un + `"`}} {
		hidden("reg", "add", key, "/v", kv[0], "/d", kv[1], "/f").Run()
	}
	pr(100, "done")
}

func main() {
	if len(os.Args) >= 3 && os.Args[1] == "--worker" {
		worker(os.Args[2])
		return
	}
	self, _ := os.Executable()
	tmp := filepath.Join(os.TempDir(), "fc_setup")
	os.MkdirAll(tmp, 0o755)
	sj := filepath.Join(tmp, "strings.json")
	os.WriteFile(sj, append([]byte("\xef\xbb\xbf"), strJSON...), 0o644)
	ps := filepath.Join(tmp, "setup.ps1")
	os.WriteFile(ps, setupPS, 0o644)
	dst := filepath.Join(os.Getenv("LOCALAPPDATA"), "FreeCraft")
	c := hidden("powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-STA", "-WindowStyle", "Hidden", "-File", ps,
		"-Exe", self, "-Dst", dst, "-StrFile", sj, "-SysLang", lang(),
		"-ArgFile", filepath.Join(tmp, "args.json"), "-ProgFile", filepath.Join(tmp, "progress.txt"))
	c.Run()
}
