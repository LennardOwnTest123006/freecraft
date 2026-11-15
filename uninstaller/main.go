package main

import (
	_ "embed"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
	"unsafe"
)

//go:embed strings.json
var strJSON []byte

//go:embed uninst.ps1
var ps1 []byte

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

func main() {
	self, _ := os.Executable()
	dst := filepath.Dir(self)
	tmp := filepath.Join(os.TempDir(), "fc_uninst")
	os.MkdirAll(tmp, 0o755)
	sj := filepath.Join(tmp, "strings.json")
	os.WriteFile(sj, append([]byte("\xef\xbb\xbf"), strJSON...), 0o644)
	ps := filepath.Join(tmp, "uninst.ps1")
	os.WriteFile(ps, ps1, 0o644)
	c := exec.Command("powershell", "-NoProfile", "-ExecutionPolicy", "Bypass", "-STA", "-WindowStyle", "Hidden", "-File", ps,
		"-Dst", dst, "-StrFile", sj, "-SysLang", lang())
	c.SysProcAttr = &syscall.SysProcAttr{HideWindow: true, CreationFlags: 0x08000000}
	c.Start()
}
