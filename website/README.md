# FreeCraft – Download-Website (freecraft-download.pages.dev)

**Der Download-Button funktioniert ohne GitHub:** Die Setup-Datei liegt in Teilen (je 20 MB) im Ordner `dl/`, weil Cloudflare Pages nur 25 MiB pro Datei erlaubt. Der Button lädt die Teile im Browser, setzt sie zusammen und speichert `FreeCraft-Setup.exe`.

**Neue Version veröffentlichen:**
1. `FreeCraft Setup.exe` in Teile schneiden: `split -b 20m -d -a 2 "FreeCraft Setup.exe" dl/FreeCraft-Setup.part`
2. `dl/manifest.json` anpassen (`version`, `size` in Bytes, `parts`-Liste)
3. Ordner neu bei Cloudflare Pages hochladen.

---
(Ältere Anleitung mit GitHub-Release, optional:)

# FreeCraft – Download-Website (Cloudflare Pages)

Statische Seite (HTML, CSS, JavaScript – keine Build-Schritte, keine Abhängigkeiten), responsiv für Handy und Desktop.
Sprachen: 12 (Standard Englisch, automatische Erkennung nach Browser/Gerät, überall umschaltbar). Credits: JumpIn Games.

## 1. Die Setup-ZIP hosten (wichtig!)
Cloudflare Pages erlaubt nur **25 MiB pro Datei** – die `FreeCraft-Setup.zip` (~82 MB) passt dort NICHT hinein.
Kostenlose Lösung: **GitHub Release**
1. GitHub-Repository anlegen (z. B. `freecraft`), dort den Quellcode (GPLv3 verlangt Quellcode-Zugang) hochladen.
2. „Releases“ → „Draft a new release“ → Tag `v1.0` → `FreeCraft-Setup.exe` (direkt, empfohlen) und/oder `FreeCraft-Setup.zip` anhängen → veröffentlichen.
3. In `config.js` eintragen: `githubRepo: "DEIN-NAME/freecraft"`.
Die Seite zeigt dann automatisch immer die **neueste** Version (Versionsnummer, Datum, Größe) und verlinkt direkt den Download. Der Button lädt die **FreeCraft-Setup.exe** der neuesten Release (Dateiname exakt `FreeCraft-Setup.exe`; gibt es keine .exe, nimmt er die ZIP).
Neue Version? Einfach ein neues Release veröffentlichen – die Website muss nicht neu deployt werden.
(Alternative ohne GitHub: in `config.js` `fallbackUrl` auf einen direkten ZIP-Link setzen, z. B. Cloudflare R2.)

## 2. Deploy auf Cloudflare Pages (kostenlos)
**Variante A – im Browser:** dash.cloudflare.com → Workers & Pages → Create → Pages → „Upload assets“ → Projektname `freecraft` → diesen Ordner (entpackt) hochladen → Deploy.
**Variante B – Kommandozeile:**
```
npx wrangler login
npx wrangler pages deploy . --project-name freecraft
```
Die Seite ist dann unter `https://freecraft.pages.dev` erreichbar (eigene Domain später unter „Custom domains“).

## Dateien
- `index.html`, `style.css`, `app.js` – Seite
- `config.js` – hier GitHub-Repo / Fallback-Link / Kontakt eintragen
- `img/` – Bilder (selbst gerenderte Vorschauen)
- `_headers` – Sicherheits- und Cache-Header für Cloudflare
