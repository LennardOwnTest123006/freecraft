# FreeCraft engine

`bin/FreeCraft.exe` is built from the open-source Luanti 5.18.0 engine (LGPL-2.1-or-later)
with the changes in `freecraft-engine.patch` (name, version display, icon, F9 camera toggle,
hand animation, pause menu, chat clearing, click-through focus).

Build (Linux host, Windows target): apply the patch to the `5.18.0` tag of
https://github.com/luanti-org/luanti, then configure with CMake using a clang-based
MinGW toolchain (we use `zig cc -target x86_64-windows-gnu`), linking against the DLLs
of the official 5.18.0 win64 release. `misc/luanti-icon.ico` is replaced by `game/freecraft.ico`.
