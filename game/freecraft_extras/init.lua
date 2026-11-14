-- FreeCraft extras (GPLv3, wie VoxeLibre). Eigener Code.
local S = core.get_translator("freecraft_extras")

-- ===== Befehle in allen Sprachen =====
local LANGS = { "en", "de", "fr", "es", "it", "pt", "nl", "pl", "ru", "tr", "ja", "zh" }
-- Reihenfolge der Namen = LANGS
local ALIAS = {
	home       = { "home", "zuhause", "maison", "casa", "casa", "casa", "thuis", "dom", "дом", "ev", "ホーム", "回家" },
	sethome    = { "sethome", "heimsetzen", "defmaison", "fijarcasa", "impostacasa", "definircasa", "zetthuis", "ustawdom", "задатьдом", "evayarla", "ホーム設定", "设置家" },
	spawn      = { "spawn", "anfang", "apparition", "aparecer", "inizio", "inicio", "beginpunt", "start", "спавн", "dogma", "スポーン", "出生点" },
	back       = { "back", "zurueck", "retour", "volver", "indietro", "voltar", "terug", "wroc", "назад", "geri", "戻る", "返回" },
	day        = { "day", "tag", "jour", "dia", "giorno", "dia", "dag", "dzien", "день", "gun", "昼", "白天" },
	night      = { "night", "nacht", "nuit", "noche", "notte", "noite", "nacht", "noc", "ночь", "gece", "夜", "夜晚" },
	skins      = { "skins", "figuren", "apparences", "aspectos", "aspetti", "aparencias", "uiterlijk", "skiny", "скины", "kostumler", "スキン", "皮肤" },
	skinupload = { "skinupload", "skinhochladen", "televerserskin", "subirskin", "caricaskin", "enviarskin", "skinuploaden", "wgrajskin", "загрузитьскин", "skinyukle", "スキン投稿", "上传皮肤" },
	settings   = { "settings", "einstellungen", "parametres", "ajustes", "impostazioni", "configuracoes", "instellingen", "ustawienia", "настройки", "ayarlar", "設定", "设置" },
	credits    = { "credits", "mitwirkende", "credits", "creditos", "crediti", "creditos", "credits", "autorzy", "авторы", "yapimcilar", "クレジット", "制作名单" },
	view       = { "view", "ansicht", "vue", "vista", "vista", "vista", "weergave", "widok", "вид", "gorunum", "視点", "视角" },
}
-- Wörter für /view (alle Sprachen)
local MODE_WORDS = {
	first = { "first", "erste", "premiere", "primera", "prima", "primeira", "eerste", "pierwsza", "первое", "birinci", "一人称", "第一" },
	third = { "third", "dritte", "troisieme", "tercera", "terza", "terceira", "derde", "trzecia", "третье", "ucuncu", "三人称", "第三" },
	any   = { "any", "frei", "libre", "libre", "libera", "livre", "vrij", "dowolna", "свободно", "serbest", "自由", "自由" },
}
-- Reihenfolge für Vorschläge (wichtigste zuerst)
local PRIORITY = { "home", "sethome", "spawn", "back", "skins", "settings", "credits", "skinupload", "view", "day", "night" }

local function lang_of(name)
	local info = core.get_player_information and core.get_player_information(name)
	local code = info and info.lang_code and info.lang_code:sub(1, 2):lower() or "en"
	for i, l in ipairs(LANGS) do if l == code then return i end end
	return 1
end
-- Befehlsname in der Sprache des Spielers
local function alias_for(cmd, name)
	local a = ALIAS[cmd]
	return a and a[lang_of(name)] or cmd
end

-- Willkommen
core.register_on_joinplayer(function(player)
	core.chat_send_player(player:get_player_name(),
		core.colorize("#55FF55", S("Welcome to FreeCraft!")) .. "  /" .. alias_for("settings", player:get_player_name())
		.. "  /" .. alias_for("skins", player:get_player_name()) .. "  /" .. alias_for("home", player:get_player_name()))
end)

core.register_chatcommand("freecraft", {
	description = S("Info about FreeCraft"),
	func = function()
		return true, S("FreeCraft by JumpIn Games – based on Luanti and VoxeLibre (GPLv3).")
			.. " notification.email321@gmail.com"
	end,
})

-- Shader-Look
local function apply_look(player)
	if not player or not player:is_player() or not player.set_lighting then return end
	player:set_lighting({
		shadows = { intensity = 0.55 },
		saturation = 1.12,
		exposure = { luminance_min = -3.0, luminance_max = -1.0, exposure_correction = 0.0,
			speed_dark_bright = 1000, speed_bright_dark = 1000, center_weight_power = 1.5 },
		bloom = { intensity = 0.05, strength_factor = 1.0, radius = 1.0 },
		volumetric_light = { strength = 0.25 },
	})
end

-- Wolken
local function apply_clouds(player)
	if player and player:is_player() and player.set_clouds then
		player:set_clouds({ density = 0.45, color = "#fffffff0", ambient = "#404060",
			height = 140, thickness = 12, speed = {x = 2, z = 0} })
	end
end

core.register_on_joinplayer(function(player)
	core.after(1, function() apply_look(player); apply_clouds(player) end)
end)

-- Ansicht: /view first / third / any  (auch /ansicht erste / dritte / frei)
local modes = {}
for mode, words in pairs(MODE_WORDS) do for _, w in ipairs(words) do modes[w] = mode end end
local function view_cmd(name, param)
	local p = core.get_player_by_name(name)
	if not p or not p.set_camera then return false, S("Not supported by this Luanti version (use F7).") end
	local m = modes[param]
	if not m then return false, S("Usage: /view first | third | any") end
	p:set_camera({ mode = m })
	return true, S("View: @1", param)
end
local def = { params = "first | third | any",
	description = S("Camera: first = first person, third = from behind, any = switch with F7"),
	func = view_cmd }
core.register_chatcommand("view", def)
-- (Alias in allen Sprachen wird weiter unten registriert)

-- Leise Hintergrundmusik (eigene Komposition, eigener Code, GPLv3)
local function play_music(name)
	local p = core.get_player_by_name(name)
	if not p then return end
	core.sound_play("freecraft_ambient", { to_player = name, gain = 0.12 }, true)
	core.after(180 + math.random(0, 120), play_music, name)
end
core.register_on_joinplayer(function(player)
	core.after(20, play_music, player:get_player_name())
end)


-- ===== Einstellungen & Credits =====
local function read_file(path)
	local f = io.open(path, "r")
	if not f then return "" end
	local t = f:read("*a"); f:close(); return t
end

local function credits_text()
	local gp = core.get_game_info().path
	local people = read_file(gp .. "/CREDITS.md")
	return table.concat({
		core.colorize("#FFDD55", "FreeCraft"),
		S("Studio / Owner: JumpIn Games"),
		S("Created and published by JumpIn Games."),
		"© 2026 JumpIn Games (" .. S("FreeCraft's own parts") .. ")",
		S("Contact:") .. " notification.email321@gmail.com",
		"",
		core.colorize("#FFDD55", S("Written by us")),
		S("Our own mod code (freecraft_extras), the procedurally generated block textures, the logo, the ambient music, the installer and all translations of the extras."),
		"",
		core.colorize("#FFDD55", S("Thanks to the projects that helped us")),
		S("Luanti – the open source voxel engine (LGPL 2.1+) by Perttu Ahola (celeron55) and the Luanti contributors. https://www.luanti.org"),
		S("VoxeLibre (formerly MineClone2) – the open source game this version is built on (GPLv3). https://content.luanti.org/packages/Wuzzy/mineclone2/"),
		S("Mob textures based on Pixel Perfection by XSSheep (CC BY-SA 4.0); models by 22i (GPLv3)."),
		"",
		core.colorize("#FFDD55", S("VoxeLibre contributors")),
		(people:gsub("#+ ", "")),
		"",
		S("FreeCraft is not affiliated with or endorsed by Mojang or Microsoft. Minecraft is a trademark of Mojang Synergies AB."),
		S("License: GPLv3 – see LICENSE.txt and NOTICE.md in the FreeCraft folder."),
	}, "\n")
end

local function settings_formspec(tab, name)
	tab = tab or 1
	local fs = "formspec_version[4]size[11,9]" ..
		"tabheader[0.3,0.3;tab;" .. core.formspec_escape(S("Settings")) .. "," ..
		core.formspec_escape(S("Credits")) .. ";" .. tab .. ";false;true]"
	if tab == 2 then
		fs = fs .. "textarea[0.4,0.6;10.2,7.4;;;" .. core.formspec_escape(credits_text()) .. "]"
	else
		local lines = {}
		for _, c in ipairs({ "home", "sethome", "spawn", "back", "skins", "skinupload", "settings", "credits", "view", "day", "night" }) do
			local d = core.registered_chatcommands[c]
			lines[#lines+1] = "/" .. (alias_for(c, name)) .. " – " .. (d and d.description or "")
		end
		lines[#lines+1] = ""
		lines[#lines+1] = S("Language: Luanti main menu → Settings → Language. It follows your Windows language automatically.")
		lines[#lines+1] = S("Quality and graphics: Luanti main menu → Settings. FreeCraft adapts them to your PC at install time.")
		fs = fs .. "label[0.5,1;" .. core.formspec_escape(S("Commands:")) .. "]" ..
			"textarea[0.4,1.3;10.2,6.4;;;" .. core.formspec_escape(table.concat(lines, "\n")) .. "]"
	end
	return fs .. "button_exit[3.5,8.1;4,0.8;close;" .. core.formspec_escape(S("Close")) .. "]"
end

local function open_settings(name, tab)
	core.show_formspec(name, "freecraft_extras:settings", settings_formspec(tab, name))
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "freecraft_extras:settings" then return end
	if fields.tab then open_settings(player:get_player_name(), tonumber(fields.tab)) end
end)

core.register_chatcommand("settings", {
	description = S("Settings and credits"),
	func = function(name) open_settings(name, 1); return true end,
})
core.register_chatcommand("credits", {
	description = S("Credits"),
	func = function(name) open_settings(name, 2); return true end,
})

-- ===== Skin-Auswahl: eigene Skins aus textures/freecraft_skin_*.png =====
-- Eigene Skins (64x64 oder 64x32 PNG) einfach als freecraft_skin_NAME.png in diesen Ordner legen.
if core.get_modpath("mcl_skins") and mcl_skins and mcl_skins.register_simple_skin then
	local files = core.get_dir_list(core.get_modpath("freecraft_extras") .. "/textures", false)
	table.sort(files)
	local idx = 10
	for _, f in ipairs(files) do
		if f:match("^freecraft_skin_.*%.png$") then
			mcl_skins.register_simple_skin({ index = idx, texture = f, slim_arms = f:find("slim") ~= nil })
			idx = idx + 1
		end
	end
end

-- ===== /skins: eigene Skin-Auswahl mit 3D-Vorschau (nutzt VoxeLibres Skin-System) =====
local SKIN_PER_PAGE = 8
local skin_page = {}

local function skin_list()
	local keys = {}
	for k in pairs(mcl_skins.simple_skins) do if type(k) == "number" and k >= 0 then keys[#keys+1] = k end end
	table.sort(keys)
	local list = {}
	for _, k in ipairs(keys) do list[#list+1] = mcl_skins.simple_skins[k] end
	return list
end

local function skins_formspec(name)
	local list = skin_list()
	local pages = math.max(1, math.ceil(#list / SKIN_PER_PAGE))
	local page = math.min(skin_page[name] or 1, pages)
	local player = core.get_player_by_name(name)
	local cur = mcl_skins.player_skins[player] and mcl_skins.player_skins[player].simple_skins_id
	local fs = {"formspec_version[4]size[13,9.6]",
		"box[0,0;13,0.9;#1b1b1fcc]",
		"label[0.4,0.45;", core.formspec_escape(core.colorize("#FFDD55", S("Choose your skin"))), "]"}
	for i = 1, SKIN_PER_PAGE do
		local skin = list[(page - 1) * SKIN_PER_PAGE + i]
		if skin then
			local col, row = (i - 1) % 4, math.floor((i - 1) / 4)
			local x, y = 0.4 + col * 3.1, 1.1 + row * 3.9
			local mesh = skin.slim_arms and "mcl_armor_character_female.b3d" or "mcl_armor_character.b3d"
			fs[#fs+1] = ("box[%f,%f;2.9,3.7;%s]"):format(x, y, skin.texture == cur and "#55AA55aa" or "#00000055")
			fs[#fs+1] = ("model[%f,%f;2.9,3.0;sk%d;%s;%s,blank.png,blank.png;0,200;false;true;0,0]")
				:format(x, y, i, mesh, skin.texture)
			fs[#fs+1] = ("button[%f,%f;2.9,0.6;pick%d;%s]"):format(x, y + 3.05, i,
				core.formspec_escape(skin.texture == cur and S("Selected") or S("Select")))
		end
	end
	fs[#fs+1] = ("button[0.4,8.7;2,0.7;prev;<]label[2.7,9.05;%s]button[4,8.7;2,0.7;next;>]")
		:format(core.formspec_escape(page .. " / " .. pages))
	fs[#fs+1] = ("button[6.6,8.7;2.9,0.7;upload;%s]button[9.6,8.7;1.5,0.7;editor;%s]button_exit[11.2,8.7;1.5,0.7;close;%s]")
		:format(core.formspec_escape(S("Upload your skin")), core.formspec_escape(S("Editor")), core.formspec_escape(S("Close")))
	return table.concat(fs)
end

local function show_skins(name)
	core.show_formspec(name, "freecraft_extras:skins", skins_formspec(name))
end

core.register_chatcommand("skins", {
	description = S("Choose a skin (3D preview)"),
	func = function(name) show_skins(name); return true end,
})

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "freecraft_extras:skins" then return end
	local name = player:get_player_name()
	local list = skin_list()
	local page = skin_page[name] or 1
	local pages = math.max(1, math.ceil(#list / SKIN_PER_PAGE))
	if fields.prev then skin_page[name] = math.max(1, page - 1)
	elseif fields.next then skin_page[name] = math.min(pages, page + 1)
	elseif fields.upload then core.registered_chatcommands["skinupload"].func(name, ""); return
	elseif fields.editor then core.chat_send_player(name, "/skin"); core.registered_chatcommands["skin"].func(name, "")
		return
	else
		for i = 1, SKIN_PER_PAGE do
			if fields["pick" .. i] then
				local skin = list[(page - 1) * SKIN_PER_PAGE + i]
				if skin then
					local ps = mcl_skins.player_skins[player]
					ps.simple_skins_id = skin.texture
					player:get_meta():set_string("mcl_skins:skin_id", tostring(skin.index or ""))
					mcl_skins.save(player)
					mcl_skins.update_player_skin(player)
				end
			end
		end
	end
	if not fields.quit then show_skins(name) end
end)


-- ===== Eigenen Skin hochladen (wie bei Minecraft: PNG 64x64 / 64x32) =====
-- Ablauf: Skin-Upload.html (im FreeCraft-Ordner) -> PNG waehlen -> Code kopieren -> hier einfuegen.
-- Gespeichert wird pro Welt in <Welt>/skins/.
local SKIN_DIR = core.get_worldpath() .. "/skins"
local user_skins = {}   -- {filename=, index=}
local next_index = 100

local function register_user_skin(filename)
	local idx = next_index; next_index = next_index + 1
	mcl_skins.register_simple_skin({ index = idx, texture = filename, slim_arms = filename:find("_slim") ~= nil })
	user_skins[#user_skins+1] = { filename = filename, index = idx }
	return idx
end

if core.get_modpath("mcl_skins") and mcl_skins and mcl_skins.register_simple_skin then
	core.mkdir(SKIN_DIR)
	local list = core.get_dir_list(SKIN_DIR, false)
	table.sort(list)
	for _, f in ipairs(list) do
		if f:match("^freecraft_user_[%w_%-]+%.png$") then register_user_skin(f) end
	end
	core.register_on_joinplayer(function(player)
		for _, u in ipairs(user_skins) do
			core.dynamic_add_media({ filepath = SKIN_DIR .. "/" .. u.filename, to_player = player:get_player_name() }, function() end)
		end
	end)
end

local function upload_formspec(msg)
	return "formspec_version[4]size[12,9.4]" ..
		"box[0,0;12,0.9;#1b1b1fcc]label[0.4,0.45;" .. core.formspec_escape(core.colorize("#FFDD55", S("Upload your skin"))) .. "]" ..
		"textarea[0.4,1.1;11.2,2;;;" .. core.formspec_escape(S("1. Open Skin-Upload.html in the FreeCraft folder.\n2. Choose your skin PNG (64x64 or 64x32).\n3. Copy the code and paste it below.")) .. "]" ..
		"field[0.4,3.6;5,0.8;sname;" .. core.formspec_escape(S("Skin name")) .. ";]" ..
		"checkbox[5.8,4.0;slim;" .. core.formspec_escape(S("Slim arms (Alex)")) .. ";false]" ..
		"textarea[0.4,5;11.2,2.6;code;" .. core.formspec_escape(S("Skin code")) .. ";]" ..
		"label[0.4,7.9;" .. core.formspec_escape(msg or "") .. "]" ..
		"button[0.4,8.4;4.5,0.8;save;" .. core.formspec_escape(S("Save skin")) .. "]" ..
		"button_exit[8.2,8.4;3.4,0.8;close;" .. core.formspec_escape(S("Close")) .. "]"
end

core.register_chatcommand("skinupload", {
	description = S("Upload your own skin"),
	func = function(name)
		core.show_formspec(name, "freecraft_extras:upload", upload_formspec())
		return true
	end,
})

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= "freecraft_extras:upload" or not fields.save then return end
	local name = player:get_player_name()
	local function fail(m) core.show_formspec(name, formname, upload_formspec(core.colorize("#FF6666", m))) end
	local sname = (fields.sname or ""):gsub("[^%w_%-]", ""):sub(1, 24)
	if sname == "" then return fail(S("Please enter a name (letters/numbers).")) end
	local code = (fields.code or ""):gsub("%s", ""):gsub("^data:image/png;base64,", "")
	if #code == 0 or #code > 60000 then return fail(S("Skin code missing or too large.")) end
	local data = core.decode_base64(code)
	if not data or #data < 33 or data:sub(1, 8) ~= "\137PNG\r\n\26\n" then return fail(S("This is not a PNG image.")) end
	local w = data:byte(17) * 16777216 + data:byte(18) * 65536 + data:byte(19) * 256 + data:byte(20)
	local h = data:byte(21) * 16777216 + data:byte(22) * 65536 + data:byte(23) * 256 + data:byte(24)
	if w ~= 64 or (h ~= 64 and h ~= 32) then return fail(S("Skin must be 64x64 or 64x32 pixels.")) end
	local fname = "freecraft_user_" .. sname .. (fields.slim == "true" and "_slim" or "") .. ".png"
	core.mkdir(SKIN_DIR)
	local f = io.open(SKIN_DIR .. "/" .. fname, "wb")
	if not f then return fail(S("Could not save the skin.")) end
	f:write(data); f:close()
	local existing
	for _, u in ipairs(user_skins) do if u.filename == fname then existing = u end end
	local idx = existing and existing.index or register_user_skin(fname)
	core.dynamic_add_media({ filepath = SKIN_DIR .. "/" .. fname, to_player = name }, function()
		local ps = mcl_skins.player_skins[player]
		if ps then
			ps.simple_skins_id = fname
			player:get_meta():set_string("mcl_skins:skin_id", tostring(idx))
			mcl_skins.save(player)
			mcl_skins.update_player_skin(player)
		end
		core.chat_send_player(name, core.colorize("#55FF55", S("Skin saved and selected: @1", sname)))
		core.show_formspec(name, "freecraft_extras:skins", skins_formspec(name))
	end)
end)

-- ===== Komfort-Befehle: /sethome, /home, /spawn, /day, /night, /back =====
local function fmt_pos(p) return ("%d %d %d"):format(math.floor(p.x + .5), math.floor(p.y + .5), math.floor(p.z + .5)) end

core.register_chatcommand("sethome", {
	description = S("Set your home to the current position"),
	func = function(name)
		local p = core.get_player_by_name(name)
		if not p then return false end
		p:get_meta():set_string("freecraft:home", core.pos_to_string(p:get_pos()))
		return true, S("Home set: @1", fmt_pos(p:get_pos()))
	end,
})

core.register_chatcommand("home", {
	description = S("Teleport to your home"),
	func = function(name)
		local p = core.get_player_by_name(name)
		if not p then return false end
		local h = core.string_to_pos(p:get_meta():get_string("freecraft:home"))
		if not h then return false, S("No home set. Use /sethome") end
		p:set_pos(h)
		return true, S("Welcome home!")
	end,
})

core.register_chatcommand("spawn", {
	description = S("Teleport to the world spawn"),
	func = function(name)
		local p = core.get_player_by_name(name)
		if not p then return false end
		local sp = core.setting_get_pos("static_spawnpoint")
		if not sp then return false, S("This world has no fixed spawn. Use /sethome and /home") end
		p:set_pos(sp)
		return true, S("Teleported to spawn.")
	end,
})

core.register_chatcommand("day", {
	description = S("Set the time to day"),
	privs = { settime = true },
	func = function() core.set_timeofday(0.25); return true, S("It is day.") end,
})
core.register_chatcommand("night", {
	description = S("Set the time to night"),
	privs = { settime = true },
	func = function() core.set_timeofday(0.0); return true, S("It is night.") end,
})

-- Todesort merken: /back
core.register_on_dieplayer(function(player)
	local p = player:get_pos()
	player:get_meta():set_string("freecraft:death", core.pos_to_string(p))
	core.chat_send_player(player:get_player_name(),
		core.colorize("#FF8888", S("You died at @1 – use /back to return.", fmt_pos(p))))
end)

core.register_chatcommand("back", {
	description = S("Teleport to your last death position"),
	func = function(name)
		local p = core.get_player_by_name(name)
		if not p then return false end
		local d = core.string_to_pos(p:get_meta():get_string("freecraft:death"))
		if not d then return false, S("No death position saved.") end
		p:set_pos(d)
		return true, S("Back at your last death position.")
	end,
})


-- ===== Befehle in jeder Sprache + Vorschläge beim Tippen =====
local RANK = {}
core.register_on_mods_loaded(function()
	-- Aliase in allen Sprachen registrieren (ohne fremde Befehle zu überschreiben)
	for primary, names in pairs(ALIAS) do
		local def = core.registered_chatcommands[primary]
		if def then
			for _, n in ipairs(names) do
				if not core.registered_chatcommands[n] then
					core.register_chatcommand(n, def)
				end
			end
		end
	end
	-- Rang für Vorschläge: eigene Befehle (in allen Sprachen) zuerst
	for i, primary in ipairs(PRIORITY) do
		for _, n in ipairs(ALIAS[primary] or { primary }) do RANK[n] = RANK[n] or i end
	end
	RANK.freecraft = #PRIORITY + 1
end)

-- Unbekannte/unvollständige Befehle: Vorschläge zeigen ("/h" -> /home zuerst).
-- Bei genau einem Treffer eines FreeCraft-Befehls wird er direkt ausgeführt.
core.register_on_chatcommand(function(name, cmd, param)
	if core.registered_chatcommands[cmd] then return false end
	local lc = cmd:lower()
	local matches = {}
	for cname, d in pairs(core.registered_chatcommands) do
		if cname:lower():sub(1, #lc) == lc and (not d.privs or core.check_player_privs(name, d.privs)) then
			matches[#matches + 1] = { name = cname, rank = RANK[cname] or 100 }
		end
	end
	if #matches == 0 then return false end
	table.sort(matches, function(a, b)
		if a.rank ~= b.rank then return a.rank < b.rank end
		return a.name < b.name
	end)
	if #matches == 1 and RANK[matches[1].name] then
		local d = core.registered_chatcommands[matches[1].name]
		local _, msg = d.func(name, param)
		if msg then core.chat_send_player(name, msg) end
		return true
	end
	local lines = { core.colorize("#FFDD55", S("Suggestions for /@1:", cmd)) }
	for i = 1, math.min(8, #matches) do
		local d = core.registered_chatcommands[matches[i].name]
		lines[#lines + 1] = "  " .. core.colorize("#55FF55", "/" .. matches[i].name) .. " – " .. (d.description or "")
	end
	core.chat_send_player(name, table.concat(lines, "\n"))
	return true
end)
