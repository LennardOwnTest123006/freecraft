# FreeCraft – Mods, Plugins & Server (Tutorial)

## 1. Mods installieren
1. Hauptmenü → **Mods & Texturpakete** → *Mods herunterladen* (öffnet den Mod-Katalog „ContentDB“) – oder
2. Mod-Ordner von Hand in den Ordner `mods` im FreeCraft-Ordner kopieren (Button *Mod-Ordner* im Menü öffnet ihn).

## 2. Mods aktivieren
* **Einzelspieler:** Hauptmenü → Einzelspieler → Welt wählen → **Mods** → Mod anklicken → *Aktivieren* → Speichern.
* **Eigener Server:** `FreeCraft Server.bat` aktiviert **alle** Mods aus dem Ordner `mods` automatisch für die Welt `worlds\Server`.
  Wer deinem Server beitritt, lädt die Mods automatisch herunter.
* **Texturpakete:** Hauptmenü → Mods & Texturpakete → *Aktives Texturpaket*.

## 3. Eigene Mod bauen (10 Minuten)
Lege einen Ordner `mods/meinemod` an mit zwei Dateien:

`mod.conf`
```
name = meinemod
description = Meine erste Mod
depends = mcl_core
```

`init.lua`
```lua
-- neuer Block
core.register_node("meinemod:rubin_block", {
    description = "Rubinblock",
    tiles = {"meinemod_rubin.png"},          -- PNG nach meinemod/textures/ legen
    groups = {pickaxey = 2, building_block = 1},
    sounds = mcl_sounds.node_sound_stone_defaults(),
})

-- neues Item
core.register_craftitem("meinemod:rubin", {
    description = "Rubin",
    inventory_image = "meinemod_rubin_item.png",
})

-- Rezept: 9 Rubine -> Rubinblock
core.register_craft({
    output = "meinemod:rubin_block",
    recipe = {
        {"meinemod:rubin", "meinemod:rubin", "meinemod:rubin"},
        {"meinemod:rubin", "meinemod:rubin", "meinemod:rubin"},
        {"meinemod:rubin", "meinemod:rubin", "meinemod:rubin"},
    },
})

-- Chat-Befehl
core.register_chatcommand("hallo", {
    description = "Sagt Hallo",
    func = function(name) return true, "Hallo " .. name .. "!" end,
})
```
Starte FreeCraft, aktiviere die Mod in der Welt – fertig. Fehler stehen in `debug.txt` im FreeCraft-Ordner.
Alle Block-/Item-Namen (z. B. `mcl_core:stone`) siehst du im Kreativ-Inventar mit F3 → Tooltip oder per `/giveme`.

## 4. Mod veröffentlichen
1. Ordner deiner Mod mit `mod.conf`, `init.lua`, optional `README`, `LICENSE.txt` (z. B. GPL-3.0 oder MIT) und `screenshot.png`.
2. Den Ordner als **.zip** packen (Ordnername = Modname).
3. Im Mod-Katalog (Menü → *Mods herunterladen*) ein Konto anlegen → *Add package* → ZIP/Repository-Link hochladen.
4. Nach der Prüfung können alle Spieler deine Mod direkt im Spiel herunterladen.

## 5. Tastenbelegung (wie Minecraft)
| Taste | Aktion |
|---|---|
| W A S D | Laufen |
| Leertaste | Springen |
| Strg | Sprinten |
| Shift | Schleichen |
| E | Inventar |
| Q | Item fallen lassen |
| 1–9 / Mausrad | Hotbar |
| T / Enter | Chat |
| / | Befehl |
| F1 | HUD an/aus |
| F3 | Debug-Info |
| F9 | Kamera: Ich-Ansicht → hinter dir → vor dir → Ich-Ansicht |
| F11 | Vollbild |
| F12 | Screenshot |

---

# English summary
* **Install:** Menu → Mods & texture packs → Download mods, or copy a mod folder into `mods`.
* **Enable:** Singleplayer → pick world → Mods → Enable. The server script enables every mod in `mods` automatically.
* **Make a mod:** folder with `mod.conf` + `init.lua` (see the example above, API: `core.register_node/craftitem/craft/chatcommand`).
* **Publish:** zip the mod folder, create an account in the mod catalogue (Download mods) and add the package.
