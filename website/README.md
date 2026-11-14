# FreeCraft – Download-Website

Statische Seite (HTML/CSS/JS, kein Build nötig), responsiv, 12 Sprachen.

- **Sprache:** automatisch nach System-/Browsersprache, Fallback Englisch; oben rechts jederzeit umschaltbar ("Automatic" = Systemsprache).
- **Bilder:** echte FreeCraft-Screenshots (`img/shots/`), je Sprache für Hauptmenü, /skins und Inventar.
- **3D-Skins:** eigener WebGL-Viewer (`js/skin3d.js`), Skins in `img/skins/`.
- **Download:** `config.js` (Repo + `downloadBase`). Die Seite setzt `FreeCraft-Setup.exe` aus den Teilen in `dl/` zusammen und prüft die Größe.
- **Icon:** `favicon.ico`, `img/icons/` (aktuelles blaues FreeCraft-Logo).

Hosting: Ordnerinhalt auf Cloudflare Pages / GitHub Pages hochladen. Nach Updates Strg+F5 (Cache).
Quellcode frei (Open Source). Kontakt: siehe `config.js`.
