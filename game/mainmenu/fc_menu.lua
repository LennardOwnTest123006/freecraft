-- FreeCraft main menu (JumpIn Games): simple start screen.
local esc = core.formspec_escape
local GAME = "freecraft"
local T = fc_T

local function lan_ip() return core.settings:get("fc_lan_ip") or "" end

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

local function btn(y, name, label, w)
	w = w or 6
	return ("button[%f,%f;%f,1;%s;%s]"):format((8 - w) / 2, y, w, name, esc(label))
end

local function back_btn()
	return "button[0.3,0.3;1.6,0.8;back;" .. esc("← " .. T("back")) .. "]"
end

local function footer()
	return "label[0.3,%s;FreeCraft 1.0 – JumpIn Games]"
end

-- ============== Home ==============
local function home_fs()
	return table.concat({
		"formspec_version[6]size[8,8.4]padding[0.1,0.1]",
		"style_type[button;font_size=*1.15]",
		btn(0.4, "single",   T("single")),
		btn(1.65, "multi",    T("multi")),
		btn(2.9, "host",     T("host")),
		btn(4.15, "settings", T("settings")),
		btn(5.4, "quit",     T("quit")),
		"style_type[label;font_size=*0.85]",
		"label[2.3,7.5;FreeCraft 1.0  ·  JumpIn Games]",
	})
end

local open_single, open_multi, open_host, open_home

local function open(dlg, from)
	dlg:set_parent(from)
	from:hide()
	dlg:show()
end

local function home_handler(this, fields)
	if fields.quit then core.close() return true end
	if fields.settings then
		local d = create_settings_dlg()
		open(d, this)
		return true
	end
	if fields.single then open(open_single(), this) return true end
	if fields.multi  then open(open_multi(), this) return true end
	if fields.host   then open(open_host(), this) return true end
	return false
end

function open_home()
	local d = dialog_create("fc_home", home_fs, home_handler, function(ev)
		if ev == "MenuQuit" then core.close() return true end
		return false
	end)
	return d
end

-- ============== Singleplayer ==============
local function single_fs(data)
	local names = world_names()
	local idx = sel_index("fc_sel_world", #names)
	local creative = core.settings:get_bool("creative_mode")
	local damage = core.settings:get_bool("enable_damage", true)
	local f = {
		"formspec_version[6]size[9,9.2]padding[0.1,0.1]",
		back_btn(),
		"label[2.4,0.7;" .. esc(T("title_single")) .. "]",
	}
	if #names == 0 then
		f[#f+1] = "label[0.5,2;" .. esc(T("noworld")) .. "]"
	else
		f[#f+1] = ("textlist[0.5,1.4;8,3.2;worlds;%s;%d;false]"):format(table.concat(names, ","), idx)
	end
	f[#f+1] = ("checkbox[0.6,5.1;cb_creative;%s;%s]"):format(esc(T("creative")), tostring(creative))
	f[#f+1] = ("checkbox[0.6,5.8;cb_damage;%s;%s]"):format(esc(T("damage")), tostring(damage))
	f[#f+1] = "button[0.5,6.6;4,0.9;play;" .. esc(T("play")) .. "]"
	f[#f+1] = "button[4.7,6.6;1.9,0.9;del;" .. esc(T("del")) .. "]"
	f[#f+1] = "field[0.5,8.1;5.2,0.8;newname;" .. esc(T("worldname")) .. ";]"
	f[#f+1] = "button[5.9,8.1;2.6,0.8;create;" .. esc(T("create")) .. "]"
	f[#f+1] = "field_close_on_enter[newname;false]"
	return table.concat(f)
end

local function apply_options(idx, creative, damage)
	core.settings:set_bool("creative_mode", creative)
	core.settings:set_bool("enable_damage", damage)
	menu_worldmt(idx, "creative_mode", tostring(creative))
	menu_worldmt(idx, "enable_damage", tostring(damage))
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
	if fields.create then
		local name = (fields.newname or ""):gsub("^%s+", ""):gsub("%s+$", "")
		if name ~= "" then
			local msg = core.create_world(name, GAME, {mg_name = "v7"})
			if msg == nil then
				worlds()
				core.settings:set("fc_sel_world", menudata.worldlist:raw_index_by_uid(name) and #worlds() or 1)
			end
		end
		return true
	end
	if fields.del then
		local w = worlds()[idx]
		if w then
			local dd = dialog_create("fc_del", function()
				return "formspec_version[6]size[8,3.4]label[0.5,0.8;" .. esc(T("delq") .. " " .. w.name) .. "]" ..
					"button[0.5,1.9;3.4,0.9;yes;" .. esc(T("yes")) .. "]button[4.1,1.9;3.4,0.9;no;" .. esc(T("no")) .. "]"
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
	return dialog_create("fc_single", single_fs, single_handler)
end

-- ============== Multiplayer (join) ==============
local function multi_fs(data)
	local name = core.settings:get("name") or ""
	if name == "" then name = "Player" end
	local addr = core.settings:get("address") or ""
	local port = core.settings:get("remote_port") or "30000"
	return table.concat({
		"formspec_version[6]size[9,8.2]padding[0.1,0.1]",
		back_btn(),
		"label[2.4,0.7;" .. esc(T("title_multi")) .. "]",
		"label[0.6,1.6;" .. esc(T("hint_join")) .. "]",
		("field[0.6,2.4;8,0.8;addr;%s;%s]"):format(esc(T("addr")), esc(addr)),
		("field[0.6,3.9;3,0.8;port;%s;%s]"):format(esc(T("port")), esc(port)),
		("field[0.6,5.4;8,0.8;name;%s;%s]"):format(esc(T("name")), esc(name)),
		("pwdfield[0.6,6.9;8,0.8;pwd;%s]"):format(esc(T("pass_opt"))),
		"button[2.5,7.5;4,0.9;join;" .. esc(T("join")) .. "]",
		"field_close_on_enter[addr;false]field_close_on_enter[name;false]field_close_on_enter[pwd;false]field_close_on_enter[port;false]",
	})
end

local function multi_handler(this, fields)
	if fields.back then this:delete() return true end
	if fields.join or fields.key_enter then
		local name = (fields.name or ""):gsub("%s", "")
		local addr = (fields.addr or ""):gsub("%s", "")
		local port = tonumber(fields.port or "")
		if name == "" or addr == "" or not port or port < 1 or port > 65535 then
			return true
		end
		gamedata.mode = "join"
		gamedata.playername = name
		gamedata.password = fields.pwd or ""
		gamedata.address = addr
		gamedata.port = math.floor(port)
		gamedata.allow_login_or_register = "any"
		gamedata.selected_world = 0
		core.settings:set("name", name)
		core.settings:set("address", addr)
		core.settings:set("remote_port", tostring(math.floor(port)))
		core.start()
		return true
	end
	return false
end

function open_multi()
	return dialog_create("fc_multi", multi_fs, multi_handler)
end

-- ============== Host ==============
local function host_fs(data)
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
	local f = {
		"formspec_version[6]size[9,11.4]padding[0.1,0.1]",
		back_btn(),
		"label[2.4,0.7;" .. esc(T("title_host")) .. "]",
		("dropdown[0.6,1.4;8,0.8;world;%s;%d;true]"):format(table.concat(names, ","), idx),
		("field[0.6,3.0;5,0.8;name;%s;%s]"):format(esc(T("name")), esc(name)),
		("field[5.8,3.0;2.8,0.8;port;%s;%s]"):format(esc(T("port")), esc(port)),
		("pwdfield[0.6,4.6;8,0.8;pwd;%s]"):format(esc(T("pass_opt"))),
		("checkbox[0.6,5.8;cb_creative;%s;%s]"):format(esc(T("creative")), tostring(creative)),
		("checkbox[0.6,6.5;cb_damage;%s;%s]"):format(esc(T("damage")), tostring(damage)),
		("dropdown[0.6,7.4;8,0.8;vis;%s,%s;%d;true]"):format(esc(T("private")), esc(T("public")), public and 2 or 1),
		("field[0.6,9.0;8,0.8;srvname;%s;%s]"):format(esc(T("srvname")), esc(core.settings:get("server_name") or "")),
		"button[2.5,9.9;4,1;start;" .. esc(T("start")) .. "]",
		"field_close_on_enter[name;false]field_close_on_enter[port;false]field_close_on_enter[pwd;false]field_close_on_enter[srvname;false]",
	}
	if ip ~= "" then
		f[#f+1] = "style_type[label;font_size=*0.85]label[0.6,11.2;" .. esc(T("lan") .. ": " .. ip .. ":" .. port) .. "]"
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
	if fields.world then
		local i = tonumber(fields.world)
		if i then core.settings:set("fc_sel_world", i) end
	end
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
	return fields.world ~= nil and false
end

function open_host()
	ensure_world()
	return dialog_create("fc_host", host_fs, host_handler)
end

function fc_create_home() return open_home() end
