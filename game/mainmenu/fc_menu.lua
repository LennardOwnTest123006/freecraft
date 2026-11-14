-- FreeCraft main menu (JumpIn Games)
local esc = core.formspec_escape
local GAME = "freecraft"
local T = fc_T

local function tex(n) return esc(defaulttexturedir .. n) end

local function lan_ip() return core.settings:get("fc_lan_ip") or "" end

-- ---------------------------------------------------------------- helpers
local function theme()
	local g = pkgmgr.find_by_gameid(GAME)
	if g then mm_game_theme.set_game(g) end
end

local function dlg(name, fs, handler)
	return dialog_create(name, fs, handler, function(ev)
		if ev == "DialogShow" then theme() end
		return false
	end)
end

local function worlds()
	menudata.worldlist:set_filtercriteria(GAME)
	menudata.worldlist:refresh()
	return menudata.worldlist:get_list()
end

local function ensure_world()
	if #worlds() == 0 then
		core.create_world("FreeCraft World", GAME, {mg_name = "v7"})
		worlds()
	end
end

local function world_names()
	local t = {}
	for _, w in ipairs(worlds()) do t[#t+1] = esc(w.name) end
	return t
end

local function sel_index(name, count)
	local i = tonumber(core.settings:get(name)) or 1
	if i < 1 or i > count then i = 1 end
	return i
end

local STYLE = table.concat({
	"bgcolor[#00000000;false]",
	"style_type[button;bgimg=" .. tex("fc_btn.png") .. ";bgimg_hovered=" .. tex("fc_btn_h.png") .. ";bgimg_pressed=" .. tex("fc_btn_p.png") .. ";bgimg_middle=8;border=false;textcolor=#ffffff;font_size=*1.1]",
	"style_type[button_exit;bgimg=" .. tex("fc_btn.png") .. ";bgimg_hovered=" .. tex("fc_btn_h.png") .. ";bgimg_pressed=" .. tex("fc_btn_p.png") .. ";bgimg_middle=8;border=false;textcolor=#ffffff]",
	"style_type[field;bgcolor=#070a16;textcolor=#ffffff;border=true]",
	"style_type[pwdfield;bgcolor=#070a16;textcolor=#ffffff;border=true]",
	"style_type[textlist;bgcolor=#050914;highlight=#1c8f9a;highlight_text=#ffffff]",
	"style_type[dropdown;bgcolor=#070a16;textcolor=#ffffff]",
	"style_type[textarea;textcolor=#e8f4ff;border=false]",
})

local function panel(w, h)
	return ("background9[0,0;%f,%f;%s;false;14]"):format(w, h, tex("fc_panel.png"))
end

local function head(w, title)
	return ("style_type[label;font_size=*1.45;font=bold]label[%f,0.75;%s]style_type[label;font_size=*1;font=normal]"):format(2.4, esc(title))
		.. "button[0.4,0.3;1.8,0.9;back;" .. esc("← " .. T("back")) .. "]"
end

local function go(name)
	return ("style[%s;bgimg=%s;bgimg_hovered=%s;bgimg_pressed=%s]"):format(name, tex("fc_btn_go.png"), tex("fc_btn_go_h.png"), tex("fc_btn_p.png"))
end

local open_single, open_multi, open_host, open_home, open_settings, open_credits, open_content

local function open(d, from)
	d:set_parent(from)
	from:hide()
	d:show()
end

-- ------------------------------------------------------------------- Home
local function home_fs()
	local f = {"formspec_version[6]size[8.4,11.4]padding[0.05,0.05]", STYLE, "image[-0.3,-0.1;9,2.68;" .. tex("fc_logo.png") .. "]"}
	local items = {
		{"single", T("single"), true}, {"multi", T("multi")}, {"host", T("host")},
		{"content", T("mods")}, {"settings", T("settings")}, {"quit", T("quit")},
	}
	local y = 2.5
	for _, it in ipairs(items) do
		if it[3] then f[#f+1] = go(it[1]) end
		f[#f+1] = ("button[1,%f;6.4,1.15;%s;%s]"):format(y, it[1], esc(it[2]))
		y = y + 1.38
	end
	f[#f+1] = "style_type[label;font_size=*0.8]label[2.6,11.05;FreeCraft 1.0  ·  JumpIn Games]"
	return table.concat(f)
end

local function home_handler(this, fields)
	if fields.quit then core.close() return true end
	if fields.single   then open(open_single(), this) return true end
	if fields.multi    then open(open_multi(), this) return true end
	if fields.host     then open(open_host(), this) return true end
	if fields.content  then open(open_content(), this) return true end
	if fields.settings then open(open_settings(), this) return true end
	return false
end

function open_home()
	return dialog_create("fc_home", home_fs, home_handler, function(ev)
		if ev == "MenuQuit" then core.close() return true end
		if ev == "DialogShow" then theme() end
		return false
	end)
end

-- --------------------------------------------------------------- Settings
local PRESETS = {
	low   = {enable_dynamic_shadows=false, enable_bloom=false, enable_volumetric_lighting=false, enable_waving_leaves=false,
	         enable_waving_plants=false, enable_waving_water=false, fsaa="0", viewing_range="80", smooth_lighting=false},
	mid   = {enable_dynamic_shadows=true, shadow_map_texture_size="1024", shadow_strength_gamma="0.8", shadow_soft_radius="8",
	         enable_bloom=false, enable_volumetric_lighting=false, enable_waving_leaves=true, enable_waving_plants=true,
	         enable_waving_water=false, fsaa="2", viewing_range="120", smooth_lighting=true},
	high  = {enable_dynamic_shadows=true, shadow_map_texture_size="2048", shadow_strength_gamma="0.85", shadow_soft_radius="10",
	         enable_bloom=true, enable_volumetric_lighting=false, enable_waving_leaves=true, enable_waving_plants=true,
	         enable_waving_water=true, fsaa="2", viewing_range="160", smooth_lighting=true},
	ultra = {enable_dynamic_shadows=true, shadow_map_texture_size="4096", shadow_strength_gamma="0.85", shadow_soft_radius="12",
	         shadow_map_max_distance="200", enable_bloom=true, enable_volumetric_lighting=true, enable_auto_exposure=true,
	         enable_waving_leaves=true, enable_waving_plants=true, enable_waving_water=true, fsaa="4", viewing_range="200",
	         smooth_lighting=true},
}

local function apply_preset(id)
	for k, v in pairs(PRESETS[id]) do
		if type(v) == "boolean" then core.settings:set_bool(k, v) else core.settings:set(k, v) end
	end
	core.settings:set("fc_gfx", id)
	if core.settings.write then core.settings:write() end
end

local function settings_fs()
	local cur = core.settings:get("fc_gfx") or ""
	local f = {"formspec_version[6]size[9,10.6]padding[0.05,0.05]", STYLE, panel(9, 10.6), head(9, T("settings_title"))}
	f[#f+1] = "style_type[label;font_size=*1.1]label[0.6,2.0;" .. esc(T("graphics")) .. "]style_type[label;font_size=*1]"
	local ids = {{"low", "g_low"}, {"mid", "g_mid"}, {"high", "g_high"}, {"ultra", "g_ultra"}}
	for i, p in ipairs(ids) do
		local name = "gfx_" .. p[1]
		if cur == p[1] then f[#f+1] = go(name) end
		f[#f+1] = ("button[%f,2.4;1.9,1;%s;%s]"):format(0.6 + (i - 1) * 1.97, name, esc(T(p[2])))
	end
	f[#f+1] = "style_type[textarea;font_size=*0.9]textarea[0.6,3.55;7.8,0.95;;;" .. esc(T("g_note")) .. "]style_type[textarea;font_size=*1]"
	f[#f+1] = "button[0.6,4.6;7.8,1.1;all;" .. esc(T("allsettings")) .. "]"
	f[#f+1] = "button[0.6,6.0;7.8,1.1;credits;" .. esc(T("credits")) .. "]"
	f[#f+1] = "button[0.6,7.4;7.8,1.1;lang;Language / Sprache]"
	return table.concat(f)
end

local function settings_handler(this, fields)
	if fields.back then this:delete() return true end
	for _, id in ipairs({"low", "mid", "high", "ultra"}) do
		if fields["gfx_" .. id] then apply_preset(id) return true end
	end
	if fields.all or fields.lang then open(create_settings_dlg(), this) return true end
	if fields.credits then open(open_credits(), this) return true end
	return false
end

function open_settings() return dlg("fc_settings", settings_fs, settings_handler) end

-- ---------------------------------------------------------------- Credits
function open_credits()
	return dlg("fc_credits", function()
		return table.concat({
			"formspec_version[6]size[9,8.6]padding[0.05,0.05]", STYLE, panel(9, 8.6), head(9, T("credits")),
			"textarea[0.7,1.6;7.6,6.4;;;" .. esc(T("credits_text")) .. "]",
		})
	end, function(this, fields)
		if fields.back then this:delete() return true end
		return false
	end)
end

-- ----------------------------------------------------- Mods & texture packs
local function txp_list()
	if pkgmgr.reload_texture_packs then pkgmgr.reload_texture_packs() end
	return pkgmgr.texture_packs or {}
end

function open_content()
	return dlg("fc_content", function()
		local packs = txp_list()
		local names, sel = {esc(T("none"))}, 1
		for i, p in ipairs(packs) do
			names[#names+1] = esc(p.name)
			if p.enabled then sel = i + 1 end
		end
		return table.concat({
			"formspec_version[6]size[9,9.6]padding[0.05,0.05]", STYLE, panel(9, 9.6), head(9, T("mods")),
			go("dl"),
			"button[0.6,1.7;7.8,1.1;dl;" .. esc(T("mods_dl")) .. "]",
			"button[0.6,3.0;7.8,1.1;txp;" .. esc(T("mods_txp")) .. "]",
			"label[0.6,4.5;" .. esc(T("txp_pick")) .. "]",
			("dropdown[0.6,4.8;7.8,0.9;pack;%s;%d;true]"):format(table.concat(names, ","), sel),
			"button[0.6,6.2;3.8,1;moddir;" .. esc(T("mods_dir")) .. "]",
			"button[4.6,6.2;3.8,1;txpdir;" .. esc(T("txp_dir")) .. "]",
		})
	end, function(this, fields)
		if fields.back then this:delete() return true end
		if fields.dl then open(create_contentdb_dlg(), this) return true end
		if fields.txp then open(create_contentdb_dlg("txp"), this) return true end
		if fields.moddir then core.open_dir(core.get_user_path() .. DIR_DELIM .. "mods") return true end
		if fields.txpdir then core.open_dir(core.get_user_path() .. DIR_DELIM .. "textures") return true end
		if fields.pack then
			local i = tonumber(fields.pack)
			local packs = txp_list()
			for k, p in ipairs(packs) do
				pkgmgr.set_texture_pack_enabled(p.path, i == k + 1)
			end
			pkgmgr.reload_texture_packs()
			mm_game_theme.init()
			return true
		end
		return false
	end)
end

-- ----------------------------------------------------------- Singleplayer
local function apply_options(idx, creative, damage)
	core.settings:set_bool("creative_mode", creative)
	core.settings:set_bool("enable_damage", damage)
	menu_worldmt(idx, "creative_mode", tostring(creative))
	menu_worldmt(idx, "enable_damage", tostring(damage))
end

local function single_fs()
	local names = world_names()
	local idx = sel_index("fc_sel_world", #names)
	local creative = core.settings:get_bool("creative_mode")
	local damage = core.settings:get_bool("enable_damage", true)
	local f = {"formspec_version[6]size[9.4,10.2]padding[0.05,0.05]", STYLE, panel(9.4, 10.2), head(9.4, T("title_single")), go("play"), go("create")}
	if #names == 0 then
		f[#f+1] = "label[0.6,2.2;" .. esc(T("noworld")) .. "]"
	else
		f[#f+1] = ("textlist[0.6,1.6;8.2,3;worlds;%s;%d;false]"):format(table.concat(names, ","), idx)
	end
	f[#f+1] = ("checkbox[0.7,5.1;cb_creative;%s;%s]"):format(esc(T("creative")), tostring(creative))
	f[#f+1] = ("checkbox[0.7,5.8;cb_damage;%s;%s]"):format(esc(T("damage")), tostring(damage))
	f[#f+1] = "button[0.6,6.55;4.1,1.05;play;" .. esc(T("play")) .. "]"
	f[#f+1] = "button[4.85,6.55;1.9,1.05;wmods;Mods]button[6.85,6.55;1.95,1.05;del;" .. esc(T("del")) .. "]"
	f[#f+1] = "field[0.6,8.5;5.4,0.9;newname;" .. esc(T("worldname")) .. ";]"
	f[#f+1] = "button[6.2,8.5;2.6,0.9;create;" .. esc(T("create")) .. "]"
	f[#f+1] = "field_close_on_enter[newname;false]"
	return table.concat(f)
end

local function single_handler(this, fields)
	if fields.back then this:delete() return true end
	local n = #worlds()
	local idx = sel_index("fc_sel_world", n)
	if fields.worlds then
		local ev = core.explode_textlist_event(fields.worlds)
		if ev.type == "CHG" or ev.type == "DCL" then
			core.settings:set("fc_sel_world", ev.index)
			idx = ev.index
		end
		if ev.type == "DCL" then fields.play = true
		elseif ev.type == "CHG" then return true end
	end
	if fields.cb_creative then core.settings:set_bool("creative_mode", core.is_yes(fields.cb_creative)) return true end
	if fields.cb_damage then core.settings:set_bool("enable_damage", core.is_yes(fields.cb_damage)) return true end
	if fields.wmods then
		local raw = menudata.worldlist:get_raw_index(idx)
		if raw then open(create_configure_world_dlg(raw), this) end
		return true
	end
	if fields.create then
		local name = (fields.newname or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if name ~= "" then
			local msg = core.create_world(name, GAME, {mg_name = "v7"})
			if msg == nil then
				worlds()
				core.settings:set("fc_sel_world", #worlds())
			end
		end
		return true
	end
	if fields.del then
		local w = worlds()[idx]
		if w then
			local dd = dlg("fc_del", function()
				return "formspec_version[6]size[8,3.6]" .. STYLE .. panel(8, 3.6) ..
					"label[0.6,0.9;" .. esc(T("delq") .. " " .. w.name) .. "]" ..
					"button[0.6,1.9;3.3,1;yes;" .. esc(T("yes")) .. "]button[4.1,1.9;3.3,1;no;" .. esc(T("no")) .. "]"
			end, function(d, f)
				if f.yes then
					core.delete_world(menudata.worldlist:get_raw_index(idx))
					menudata.worldlist:refresh()
					d:delete() return true
				end
				if f.no then d:delete() return true end
				return false
			end)
			open(dd, this)
		end
		return true
	end
	if fields.play then
		if n == 0 then ensure_world() n = #worlds() idx = 1 end
		local w = worlds()[idx]
		if not w then return true end
		apply_options(idx, core.settings:get_bool("creative_mode"), core.settings:get_bool("enable_damage", true))
		core.settings:set_bool("enable_server", false)
		gamedata.selected_world = menudata.worldlist:get_raw_index(idx)
		gamedata.mode = "singleplayer"
		core.start()
		return true
	end
	return false
end

function open_single()
	ensure_world()
	return dlg("fc_single", single_fs, single_handler)
end

-- ------------------------------------------------------ Multiplayer (join)
local mstate = {tab = 1, sel = 1}

local function public_servers()
	local out = {}
	for _, s in ipairs(serverlistmgr.servers or {}) do
		if s.address and s.port and tostring(s.gameid or ""):lower() == GAME then
			out[#out+1] = s
		end
	end
	return out
end

local function multi_fs()
	local name = core.settings:get("name") or ""
	if name == "" then name = "Player" end
	local f = {"formspec_version[6]size[10,10.4]padding[0.05,0.05]", STYLE, panel(10, 10.4), head(10, T("title_multi")), (mstate.tab == 1) and go("tab_pub") or go("tab_dir"), go("join"), go("join_pub")}
	-- tab buttons (active tab highlighted)
	f[#f+1] = "button[0.6,1.5;4.5,0.95;tab_pub;" .. esc(T("servers")) .. "]button[5.0,1.5;4.4,0.95;tab_dir;" .. esc(T("direct")) .. "]"
	if mstate.tab == 1 then
		local list = public_servers()
		if #list == 0 then
			local sv = serverlistmgr.servers
			local loading = (not sv) or (#sv == 1 and not sv[1].address and sv[1].name == fgettext("Loading..."))
			local msg = loading and T("loading") or T("no_servers")
			f[#f+1] = "textarea[0.8,3.0;8.4,3;;;" .. esc(msg) .. "]"
		else
			local rows = {}
			for _, s in ipairs(list) do
				rows[#rows+1] = esc(("%s  (%d/%d %s)"):format(s.name or s.address, tonumber(s.clients) or 0, tonumber(s.clients_max) or 0, T("players")))
			end
			if mstate.sel > #list then mstate.sel = 1 end
			f[#f+1] = ("textlist[0.6,2.7;8.8,4.2;srv;%s;%d;false]"):format(table.concat(rows, ","), mstate.sel)
		end
		f[#f+1] = "field[0.6,7.6;5.1,0.9;name;" .. esc(T("name")) .. ";" .. esc(name) .. "]"
		f[#f+1] = "button[0.6,8.9;3.8,1;refresh;" .. esc(T("refresh")) .. "]button[4.6,8.9;4.8,1;join_pub;" .. esc(T("join")) .. "]"
		f[#f+1] = "pwdfield[5.9,7.6;3.5,0.9;pwd;" .. esc(T("pass_opt")) .. "]"
	else
		local addr = core.settings:get("address") or ""
		local port = core.settings:get("remote_port") or "30000"
		f[#f+1] = "style_type[label;font_size=*0.85]label[0.6,2.85;" .. esc(T("hint_join")) .. "]style_type[label;font_size=*1]"
		f[#f+1] = ("field[0.6,3.5;5.6,0.9;addr;%s;%s]"):format(esc(T("addr")), esc(addr))
		f[#f+1] = ("field[6.4,3.5;3,0.9;port;%s;%s]"):format(esc(T("port")), esc(port))
		f[#f+1] = ("field[0.6,5.2;4.3,0.9;name;%s;%s]"):format(esc(T("name")), esc(name))
		f[#f+1] = ("pwdfield[5.1,5.2;4.3,0.9;pwd;%s]"):format(esc(T("pass_opt")))
		f[#f+1] = "button[2.5,7.2;5,1.1;join;" .. esc(T("join")) .. "]"
	end
	f[#f+1] = "field_close_on_enter[addr;false]field_close_on_enter[name;false]field_close_on_enter[pwd;false]field_close_on_enter[port;false]"
	return table.concat(f)
end

local function do_join(name, addr, port, pwd)
	name = (name or ""):gsub("%s", "")
	addr = (addr or ""):gsub("%s", "")
	port = tonumber(port or "")
	if name == "" or addr == "" or not port or port < 1 or port > 65535 then return true end
	port = math.floor(port)
	gamedata.mode = "join"
	gamedata.playername = name
	gamedata.password = pwd or ""
	gamedata.address = addr
	gamedata.port = port
	gamedata.allow_login_or_register = "any"
	gamedata.selected_world = 0
	core.settings:set("name", name)
	core.settings:set("address", addr)
	core.settings:set("remote_port", tostring(port))
	core.start()
	return true
end

local function multi_handler(this, fields)
	if fields.back then this:delete() return true end
	if fields.name and fields.name ~= "" then core.settings:set("name", fields.name) end
	if fields.tab_pub then mstate.tab = 1 serverlistmgr.sync() return true end
	if fields.tab_dir then mstate.tab = 2 return true end
	if fields.refresh then serverlistmgr.servers = nil serverlistmgr.sync() return true end
	if fields.srv then
		local ev = core.explode_textlist_event(fields.srv)
		if ev.type == "CHG" or ev.type == "DCL" then mstate.sel = ev.index end
		if ev.type == "DCL" then fields.join_pub = true else return true end
	end
	if fields.join_pub then
		local s = public_servers()[mstate.sel]
		if s then return do_join(fields.name or core.settings:get("name"), s.address, s.port, fields.pwd) end
		return true
	end
	if fields.join or fields.key_enter then
		return do_join(fields.name, fields.addr, fields.port, fields.pwd)
	end
	return false
end

function open_multi()
	mstate.tab = 1
	serverlistmgr.sync()
	return dialog_create("fc_multi", multi_fs, multi_handler, function(ev)
		if ev == "DialogShow" then theme() end
		return false
	end)
end

-- ------------------------------------------------------------------- Host
local function host_fs()
	local names = world_names()
	local idx = sel_index("fc_sel_world", #names)
	local name = core.settings:get("name") or ""
	if name == "" then name = "Player" end
	local port = core.settings:get("port") or "30000"
	if port == "" then port = "30000" end
	local creative = core.settings:get_bool("creative_mode")
	local damage = core.settings:get_bool("enable_damage", true)
	local public = core.settings:get_bool("server_announce")
	local ip = lan_ip()
	local f = {"formspec_version[6]size[9.4,11.9]padding[0.05,0.05]", STYLE, panel(9.4, 11.9), head(9.4, T("title_host")), go("start"),
		"style_type[label;font_size=*0.95]label[0.7,1.85;" .. esc((names[idx] or "FreeCraft World")) .. "]style_type[label;font_size=*1]",
		("field[0.6,2.8;5.4,0.9;name;%s;%s]"):format(esc(T("name")), esc(name)),
		("field[6.2,2.8;2.6,0.9;port;%s;%s]"):format(esc(T("port")), esc(port)),
		("pwdfield[0.6,4.5;8.2,0.9;pwd;%s]"):format(esc(T("pass_opt"))),
		("checkbox[0.7,5.85;cb_creative;%s;%s]"):format(esc(T("creative")), tostring(creative)),
		("checkbox[0.7,6.5;cb_damage;%s;%s]"):format(esc(T("damage")), tostring(damage)),
		("dropdown[0.6,7.2;8.2,0.9;vis;%s,%s;%d;true]"):format(esc(T("private")), esc(T("public")), public and 2 or 1),
		("field[0.6,8.9;8.2,0.9;srvname;%s;%s]"):format(esc(T("srvname")), esc(core.settings:get("server_name") or "")),
		"button[2.2,10.0;5,1.1;start;" .. esc(T("start")) .. "]",
		"field_close_on_enter[name;false]field_close_on_enter[port;false]field_close_on_enter[pwd;false]field_close_on_enter[srvname;false]",
	}
	if ip ~= "" then
		f[#f+1] = "style_type[label;font_size=*0.8]label[0.7,11.5;" .. esc(T("lan") .. ": " .. ip .. ":" .. port) .. "]"
	end
	return table.concat(f)
end

local function host_handler(this, fields)
	if fields.back then this:delete() return true end
	if fields.name and fields.name ~= "" then core.settings:set("name", fields.name) end
	if fields.port and tonumber(fields.port) then core.settings:set("port", fields.port) end
	if fields.srvname then core.settings:set("server_name", fields.srvname) end
	if fields.cb_creative then core.settings:set_bool("creative_mode", core.is_yes(fields.cb_creative)) return true end
	if fields.cb_damage then core.settings:set_bool("enable_damage", core.is_yes(fields.cb_damage)) return true end
	if fields.vis then core.settings:set_bool("server_announce", tonumber(fields.vis) == 2) end
	if fields.start or fields.key_enter then
		local n = #worlds()
		if n == 0 then ensure_world() n = #worlds() end
		local idx = sel_index("fc_sel_world", n)
		local name = (fields.name or ""):gsub("%s", "")
		local port = tonumber(fields.port or "")
		if name == "" or not port or port < 1 or port > 65535 then return true end
		port = math.floor(port)
		apply_options(idx, core.settings:get_bool("creative_mode"), core.settings:get_bool("enable_damage", true))
		core.settings:set_bool("enable_server", true)
		core.settings:set("name", name)
		core.settings:set("port", tostring(port))
		local sn = (fields.srvname or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if sn == "" then sn = "FreeCraft – " .. name end
		core.settings:set("server_name", sn)
		core.settings:set("server_description", "FreeCraft server by " .. name)
		gamedata.selected_world = menudata.worldlist:get_raw_index(idx)
		gamedata.mode = "host"
		gamedata.playername = name
		gamedata.password = fields.pwd or ""
		gamedata.port = port
		gamedata.address = ""
		core.start()
		return true
	end
	return false
end

function open_host()
	ensure_world()
	return dlg("fc_host", host_fs, host_handler)
end

function fc_create_home() return open_home() end
