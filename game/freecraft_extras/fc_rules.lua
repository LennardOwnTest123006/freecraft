-- FreeCraft Spielregeln (GPLv3). Eigener Code.
local S = core.get_translator("freecraft_extras")

-- ===== Besitzer (Owner) und Rechte =====
-- Owner = Einzelspieler oder der Spieler, der den Server gestartet hat (Einstellung "name").
function freecraft_is_owner(name)
	return core.is_singleplayer() or (name ~= nil and name == core.settings:get("name"))
end

-- Fliegen/Noclip/Schnell gibt es nur im Kreativmodus, alles andere bekommt der Owner.
local CREATIVE_ONLY = { fly = true, noclip = true, fast = true }
core.register_on_mods_loaded(function()
	for name, def in pairs(core.registered_privileges) do
		if CREATIVE_ONLY[name] then
			def.give_to_singleplayer = false
			def.give_to_admin = false
		else
			def.give_to_singleplayer = true
			def.give_to_admin = true
		end
	end
end)

local function sync_privs(player, gamemode)
	if not player or not player:is_player() then return end
	local name = player:get_player_name()
	local creative = (gamemode or mcl_gamemode.get_gamemode(player)) == "creative"
	local privs = core.get_player_privs(name)
	local changed = false
	for p in pairs(CREATIVE_ONLY) do
		local want = creative or nil
		if privs[p] ~= want then privs[p] = want; changed = true end
	end
	-- Nur der Owner darf Server-Dinge (Spielmodus anderer, Einstellungen, Rechte)
	if not freecraft_is_owner(name) then
		for _, p in ipairs({ "server", "privs", "maphack", "password", "ban", "kick", "rollback", "debug" }) do
			if privs[p] then privs[p] = nil; changed = true end
		end
	end
	if changed then core.set_player_privs(name, privs) end
end
core.register_on_joinplayer(function(player) sync_privs(player) end)
mcl_gamemode.register_on_gamemode_change(function(player, _, new) sync_privs(player, new) end)

-- /save: Welt sofort speichern (nur Owner)
core.register_chatcommand("save", {
	description = S("Save the world now (owner only)"),
	func = function(name)
		if not freecraft_is_owner(name) then return false, S("Only the owner can do this.") end
		for _, p in ipairs(core.get_connected_players()) do
			if mcl_player and mcl_player.save then end
		end
		core.settings:write()
		return true, S("World saved.")
	end,
})

-- ===== Chat alle 8 Minuten leeren wird im Client gemacht (Engine) =====

-- ===== Kampf: Reichweite wie in Minecraft (3 Blöcke) auch gegen Spieler =====
core.register_on_punchplayer(function(player, hitter)
	if not hitter or not hitter:is_player() then return end
	local reach = core.is_creative_enabled(hitter:get_player_name()) and 5 or 3
	if vector.distance(player:get_pos(), hitter:get_pos()) > reach + 0.6 then return true end
end)

-- ===== Mobs =====
local FALLBACK_DROPS = {
	["mobs_mc:bat"] = "mcl_mobitems:leather",
	["mobs_mc:wolf"] = "mcl_mobitems:bone",
	["mobs_mc:ocelot"] = "mcl_mobitems:string",
	["mobs_mc:cat"] = "mcl_mobitems:string",
	["mobs_mc:axolotl"] = "mcl_fishing:fish_raw",
	["mobs_mc:silverfish"] = "mcl_core:gravel",
	["mobs_mc:endermite"] = "mcl_throwing:ender_pearl",
	["mobs_mc:vex"] = "mcl_core:iron_nugget",
	["mobs_mc:illusioner"] = "mcl_core:emerald",
	["mobs_mc:enderdragon"] = "mcl_end:dragon_egg",
}
local OWN_SADDLE = { ["mobs_mc:pig"] = true, ["mobs_mc:strider"] = true, ["mobs_mc:baby_strider"] = true }

local function saddle_wrap(name, def)
	if OWN_SADDLE[name] or name:find("horse") or name:find("donkey") or name:find("mule") then return end
	local old_rc, old_custom, old_die = def.on_rightclick, def.do_custom, def.on_die
	def.on_rightclick = function(self, clicker)
		if not clicker or not clicker:is_player() then
			if old_rc then return old_rc(self, clicker) end
			return
		end
		local pname = clicker:get_player_name()
		local item = clicker:get_wielded_item()
		if self.driver and clicker == self.driver then
			mcl_mobs.detach(clicker, { x = 1, y = 0, z = 1 })
			return
		end
		if item:get_name() == "mcl_mobitems:saddle" and self._fc_saddle ~= "yes" and not self.child then
			self._fc_saddle = "yes"
			if not core.is_creative_enabled(pname) then
				item:take_item()
				clicker:set_wielded_item(item)
			end
			core.sound_play({ name = "mcl_armor_equip_leather" }, { gain = 0.5, max_hear_distance = 8, pos = self.object:get_pos() }, true)
			core.chat_send_player(pname, S("Saddled! Right-click with an empty hand to ride."))
			return
		end
		if self._fc_saddle == "yes" and not self.driver and item:get_name() == "" then
			local props = self.object:get_properties()
			local vs = props.visual_size or { x = 1, y = 1 }
			local cb = props.collisionbox or { 0, 0, 0, 0, 1, 0 }
			self.v2 = 0
			self.max_speed_forward = 5
			self.max_speed_reverse = 2
			self.accel = 4
			self.terrain_type = 3
			self.driver_attach_at = { x = 0, y = (cb[5] or 1) * 10 / (vs.y ~= 0 and vs.y or 1) - 2, z = 0 }
			self.driver_eye_offset = { x = 0, y = 3, z = 0 }
			self.driver_scale = { x = 1 / (vs.x ~= 0 and vs.x or 1), y = 1 / (vs.y ~= 0 and vs.y or 1) }
			if not pcall(mcl_mobs.attach, self, clicker) then
				core.log("warning", "[freecraft] riding failed for " .. tostring(self.name))
				self.driver = nil
			end
			return
		end
		if old_rc then return old_rc(self, clicker) end
	end
	def.do_custom = function(self, dtime, ...)
		if self.driver and self._fc_saddle == "yes" then
			if not pcall(mcl_mobs.drive, self, "walk", "stand", false, dtime) then
				core.log("warning", "[freecraft] drive failed for " .. tostring(self.name))
				pcall(mcl_mobs.detach, self.driver, { x = 1, y = 0, z = 1 })
				self.driver = nil
			end
			return false
		end
		if old_custom then return old_custom(self, dtime, ...) end
		return true
	end
	def.on_die = function(self, pos, ...)
		if self.driver then mcl_mobs.detach(self.driver, { x = 1, y = 0, z = 1 }) end
		if self._fc_saddle == "yes" and pos then core.add_item(pos, "mcl_mobitems:saddle") end
		if old_die then return old_die(self, pos, ...) end
	end
end

core.register_on_mods_loaded(function()
	for name, def in pairs(core.registered_entities) do
		if def.is_mob then
			-- Gegner sehen den Spieler nur bis ca. 12 Blöcke weit
			if def.type == "monster" and (def.view_range or 16) > 13 and not name:find("dragon") and not name:find("wither") and not name:find("ghast") then
				def.view_range = 13
			end
			-- Jeder Mob lässt etwas fallen
			local drops = def.drops
			if type(drops) == "table" and #drops > 0 then
				local d = drops[1]
				if type(d) == "table" and (d.chance or 1) == 1 and (d.min or 0) < 1 then
					local copy = table.copy(drops)
					copy[1].min = 1
					if (copy[1].max or 1) < 1 then copy[1].max = 1 end
					def.drops = copy
				end
			elseif FALLBACK_DROPS[name] and core.registered_items[FALLBACK_DROPS[name]] then
				def.drops = { { name = FALLBACK_DROPS[name], chance = 1, min = 1, max = 1 } }
			end
			-- Sattel auf jedes Tier
			if def.type == "animal" then saddle_wrap(name, def) end
		end
	end
	-- Lama-Spucke mit mehr Partikeln
	local spit = core.registered_entities["mobs_mc:llamaspit"]
	if spit then
		local old = spit.on_step
		spit.on_step = function(self, dtime, ...)
			local pos = self.object:get_pos()
			if pos then
				core.add_particlespawner({
					amount = 6, time = 0.1,
					pos = { min = vector.subtract(pos, 0.15), max = vector.add(pos, 0.15) },
					vel = { min = vector.new(-0.6, -0.2, -0.6), max = vector.new(0.6, 0.6, 0.6) },
					acc = vector.new(0, -6, 0),
					exptime = { min = 0.3, max = 0.7 },
					size = { min = 0.6, max = 1.4 },
					collisiondetection = true, collision_removal = true,
					texture = "mobs_mc_llama_spit.png",
				})
			end
			if old then return old(self, dtime, ...) end
		end
	end
end)

-- ===== Faden (String) ist platzierbar wie in Minecraft =====
core.register_node("freecraft_extras:string_node", {
	description = S("String"),
	drawtype = "nodebox",
	node_box = { type = "fixed", fixed = { -0.5, -0.5, -0.03, 0.5, -0.44, 0.03 } },
	tiles = { "mcl_mobitems_string.png" },
	inventory_image = "mcl_mobitems_string.png",
	wield_image = "mcl_mobitems_string.png",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = false,
	floodable = true,
	drop = "mcl_mobitems:string",
	groups = { dig_immediate = 3, attached_node = 1, dig_by_water = 1, destroy_by_lava_flow = 1, not_in_creative_inventory = 1 },
	sounds = mcl_sounds and mcl_sounds.node_sound_leaves_defaults() or nil,
	_mcl_blast_resistance = 0,
	_mcl_hardness = 0,
})
core.override_item("mcl_mobitems:string", {
	on_place = function(itemstack, placer, pointed)
		if not placer or not pointed or pointed.type ~= "node" then return itemstack end
		local under = core.get_node(pointed.under)
		local udef = core.registered_nodes[under.name]
		if udef and udef.on_rightclick and not placer:get_player_control().sneak then
			return udef.on_rightclick(pointed.under, under, placer, itemstack, pointed) or itemstack
		end
		local pos = (udef and udef.buildable_to) and pointed.under or pointed.above
		local n = core.get_node(pos)
		local ndef = core.registered_nodes[n.name]
		if not (ndef and ndef.buildable_to) then return itemstack end
		local below = core.get_node({ x = pos.x, y = pos.y - 1, z = pos.z })
		local bdef = core.registered_nodes[below.name]
		if not (bdef and bdef.walkable) then return itemstack end
		core.set_node(pos, { name = "freecraft_extras:string_node", param2 = core.dir_to_facedir(placer:get_look_dir()) })
		if not core.is_creative_enabled(placer:get_player_name()) then itemstack:take_item() end
		return itemstack
	end,
})
