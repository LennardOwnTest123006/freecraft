# FreeCraft

**A free, open-source 3D block sandbox game for Windows – by JumpIn Games.**
No account. No paywall. Your worlds are saved locally on your PC.

🌐 Website & one-click download: **https://freecraft-download.pages.dev**

## Multiplayer & servers

**Play with friends (easiest way):** start FreeCraft → **Host server** → pick a name → **Start server**. The in-game chat then shows the addresses to share:
- same WiFi / LAN: `192.168.x.x` + port (default 30000)
- over the Internet: your public IP + port (your router must forward **UDP 30000** to your PC; or use a free VPN like Radmin VPN / ZeroTier and share the VPN address instead). Type `/ip` any time to show them again.

Friends start FreeCraft → **Multiplayer**, type IP and port, **Join**.

**Private vs. public:** in *Host server* choose *Private (friends only)* – nobody can find it without IP and port – or *Public*, which announces the server to the public Luanti server list.

**Dedicated server (`FreeCraft Server.bat`):** it is in the install folder (`%LOCALAPPDATA%\FreeCraft`) and there is a *FreeCraft Server* shortcut on the desktop. It asks for the port and private/public, prints the LAN and Internet address and runs without a window of the game.

**24/7 server:** run `FreeCraft Server.bat` on an always-on machine (spare PC, Raspberry Pi with the Linux build of Luanti, or a cheap VPS), forward UDP 30000, and keep it running as a Windows service/scheduled task at start-up (e.g. `schtasks /create /tn FreeCraftServer /tr "\"%LOCALAPPDATA%\FreeCraft\FreeCraft Server.bat\"" /sc onstart`). Back up `worlds\Server`.

## Download

1. Open the website above and click **Download FreeCraft for Windows**, or join the files from [`dl/`](dl/) yourself (see below).
2. Run **`FreeCraft-Setup.exe`**. Internet is needed once: the installer fetches the game engine.
3. Start **FreeCraft** from the desktop shortcut.

> Windows SmartScreen may warn because the installer is not code-signed: click *More info → Run anyway*.

<details>
<summary>Join the installer parts manually</summary>

The installer is split into 8 parts of 10 MB in [`dl/`](dl/) (`manifest.json` lists them, with the SHA-256 checksum).

- **Windows (cmd):** `copy /b FreeCraft-Setup.part00+FreeCraft-Setup.part01+FreeCraft-Setup.part02+FreeCraft-Setup.part03+FreeCraft-Setup.part04+FreeCraft-Setup.part05+FreeCraft-Setup.part06+FreeCraft-Setup.part07 FreeCraft-Setup.exe`
- **Linux / macOS:** `cat FreeCraft-Setup.part* > FreeCraft-Setup.exe`
</details>

## Features
- Survival & creative modes, mining, crafting, PvP, swimming with transparent water
- Mobs, caves, Nether and End
- Shaders: dynamic shadows, bloom, clouds, day/night cycle – quality adapts to your PC at install time
- Skins: 3D preview, example skins, upload your own (`/skins`, `/skinupload`)
- Host your own server with **FreeCraft Server.bat** – friends can join, mods and plugins possible
- 12 languages, chosen automatically from Windows; chat commands exist in every language (with suggestions while you type)

## Requirements
| | |
|---|---|
| System | Windows 10 / 11 (64 bit) |
| Graphics | OpenGL-compatible GPU (integrated graphics work) |
| Memory | 4 GB (8 GB recommended) |
| Disk | about 500 MB |
| Internet | only for installing and multiplayer |

## Useful commands
`/skins` choose a skin · `/settings` settings & credits · `/sethome` `/home` `/spawn` · `/day` `/night` · `/back` · `/view` view distance

## Repository
| Folder | Content |
|---|---|
| `installer/` | Windows installer (Go) |
| `game/` | Default config and the `freecraft_extras` mod (skins, commands, translations) |
| `website/` | Source of the download website (static HTML/CSS/JS, Cloudflare Pages) |
| `dl/` | Installer parts + `manifest.json` |

## Credits & license
Created and published by **JumpIn Games**. Third-party credits and licenses: in the game under **Settings → Credits**.
Licensed under **GPL-3.0** – see [`LICENSE`](LICENSE).
FreeCraft is not affiliated with Mojang or Microsoft. Minecraft is a trademark of Mojang Synergies AB.

Contact: notification.email321@gmail.com

## Uninstall

Windows Settings → Apps → **FreeCraft** → Uninstall, or run `Uninstall FreeCraft.bat` in `%LOCALAPPDATA%\FreeCraft`, or start `FreeCraft Setup.exe` again and press **U**. You can keep a backup of your worlds on the Desktop.
