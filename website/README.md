# FreeCraft – Website (v3)

Statische Website ohne Build-Schritt: einfach den Ordner auf einen beliebigen Hoster legen
(Cloudflare Pages, Netlify, GitHub Pages …). Open Source, 0 € Kosten.

## Hochladen

* **Cloudflare Pages**: Dashboard → Workers & Pages → dein Projekt → *Create deployment* → diesen Ordner (oder die ZIP) hochladen.
* **Netlify**: <https://app.netlify.com/drop> – Ordner per Drag & Drop.
* Danach im Browser einmal `Strg + F5` drücken, damit alte Dateien aus dem Cache verschwinden.

Der Installer (ca. 80 MB) liegt **nicht** in dieser ZIP. Die Seite lädt ihn beim Klick auf
„Download" in Teilen von GitHub (`config.js` → `downloadBase`) und setzt ihn im Browser zusammen.
Dadurch bleibt die Website selbst klein (ca. 4 MB) und der Upload schnell.

## Einstellungen

Alles Wichtige steht in `config.js` (GitHub-Repo, Download-Quellen, Kontakt-E-Mail).

## Aufbau

| Pfad | Inhalt |
|---|---|
| `index.html` | die komplette Seite |
| `css/style.css` | Design (Voxel-Ecken, Farben, Layout, responsive) |
| `js/app.js` | Sprache, Galerie, Auswahl, Download, Animationen |
| `js/skin3d.js` | WebGL-Skin-Viewer (Drehen, Trägheit, Geh-Animation) |
| `js/mobs3d.js` | Mob-Drehansicht aus 16 echten Spiel-Aufnahmen |
| `js/i18n.js` | Texte in 12 Sprachen |
| `js/gsap.min.js`, `ScrollTrigger.min.js` | GSAP (lokal, keine CDN-Abfrage) |
| `img/` | Screenshots (pro Sprache), Mobs, Skins, Icons |
| `fonts/` | Bricolage Grotesque und Inter (selbst gehostet) |

## Sprache

Reihenfolge: `?lang=xx` in der URL → gespeicherte Wahl → Browser-/Systemsprache → Englisch.
Im Auswahlfeld gibt es zusätzlich „Automatic". Die Sprachnamen stehen immer auf Englisch (mit Original in Klammern).

## Barrierefreiheit

* Tastatur bedienbar, sichtbarer Fokus, Skip-Link
* `prefers-reduced-motion` wird beachtet (keine Auto-Drehung, keine Einblend-Animationen)
* Bilder mit Alt-Texten, Kontrast nach WCAG AA
