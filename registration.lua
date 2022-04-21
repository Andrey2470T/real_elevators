-- MINETEST REGISTRATION FUNCTIONS CALLS.
-- ============================================================================


local tex_names_used = {
	"real_elevators_shaft_back_block.png",
	"real_elevators_shaft_back_block2.png",
	"real_elevators_shaft_side_block2.png",
	"real_elevators_outer_doors.png",
	"real_elevators_outer_wall_with_button_top.png",
	"real_elevators_outer_wall_with_button_bottom.png",
	"real_elevators_outer_wall_with_button_right.png",
	"real_elevators_outer_wall_with_button_left.png",
	"real_elevators_outer_wall_with_button_front_off.png",
	"real_elevators_outer_wall_with_button_front_on.png",
}

local elevator_parts_defs = {
	["elevator_shaft_leftside"] = {
		description = elevators.S("Elevator Shaft (Left) Side Block"),
		tiles = {3, 3, 3, 3, 3, 1},
		node_box = {
            {-0.5, -0.5, 0.0, -0.4, 0.5, 0.5},
			{-0.4, -0.5, -0.5, 0.5, 0.5, 0.5}
		},
		groups = {shaft=1},
		sounds = default.node_sound_stone_defaults(),
		craft = {
			recipe = {
				{"", "default:clay_lump", "basic_materials:steel_bar"},
				{"", "default:clay_lump", "basic_materials:steel_bar"},
				{"", "default:clay_lump", "basic_materials:steel_bar"}
			}
		}
	},
	["elevator_shaft_rightside"] = {
		description = elevators.S("Elevator Shaft (Right) Side Block"),
		tiles = {3, 3, 3, 3, 3, 1},
		node_box = {
			{-0.5, -0.5, -0.5, 0.4, 0.5, 0.5},
			{0.4, -0.5, 0.0, 0.5, 0.5, 0.5}
		},
		groups = {shaft=1},
		sounds = default.node_sound_stone_defaults(),
		craft = {
			recipe = {
				{"basic_materials:steel_bar", "default:clay_lump", ""},
				{"basic_materials:steel_bar", "default:clay_lump", ""},
				{"basic_materials:steel_bar", "default:clay_lump", ""}
			}
		}
	},
	["elevator_shaft_back"] = {
		description = elevators.S("Elevator Shaft Back Block"),
		tiles = {2, 2, 2, 2, 2, 1},
		collision_box = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		groups = {shaft=1},
		sounds = default.node_sound_stone_defaults(),
		craft = {
			recipe = {
				{"basic_materials:steel_bar", "default:clay_lump", "basic_materials:steel_bar"},
				{"basic_materials:steel_bar", "default:clay_lump", "basic_materials:steel_bar"},
				{"basic_materials:steel_bar", "default:clay_lump", "basic_materials:steel_bar"}
			}
		}
	},
	["elevator_outer_wall_leftslot"] = {
		description = elevators.S("Elevator Outer Wall With Left Slot"),
		tiles = {3},
		node_box = {
			{-0.5, -0.5, 0.4, 0.0, 0.5, 0.5},
			{-0.5, -0.5, 0.0, 0.5, 0.5, 0.4}
		},
		sounds = default.node_sound_stone_defaults(),
		craft = {
			recipe = {
				{"", "", "default:clay_lump"},
				{"", "", "default:clay_lump"},
				{"", "", "default:clay_lump"}
			}
		}
	},
	["elevator_outer_wall_rightslot"] = {
		description = elevators.S("Elevator Outer Wall With Right Slot"),
		tiles = {3},
		node_box = {
			{0.0, -0.5, 0.4, 0.5, 0.5, 0.5},
			{-0.5, -0.5, 0.0, 0.5, 0.5, 0.4}
		},
		sounds = default.node_sound_stone_defaults(),
		craft = {
			recipe = {
				{"default:clay_lump", "", ""},
				{"default:clay_lump", "", ""},
				{"default:clay_lump", "", ""}
			}
		}
	},
	["elevator_outer_wall"] = {
		description = elevators.S("Elevator Outer Wall"),
		tiles = {3},
		node_box = {-0.5, -0.5, 0.0, 0.5, 0.5, 0.5},
		sounds = default.node_sound_stone_defaults(),
		craft = {
			recipe = {
				{"", "default:clay_lump", ""},
				{"", "default:clay_lump", ""},
				{"", "default:clay_lump", ""}
			}
		}
	},
	["elevator_outer_shaft_wall"] = {
		description = elevators.S("Elevator Outer Shaft Wall"),
		tiles = {3, 3, 3, 3, 3, 1},
		node_box = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.0},
		groups = {shaft=1},
		sounds = default.node_sound_stone_defaults(),
		craft = {
			recipe = {"real_elevators:elevator_shaft_back"},
			replacements = {{"real_elevators:elevator_shaft_back", "real_elevators:elevator_outer_wall"}}
		}
	},
	["elevator_shaft_corner"] = {
		description = elevators.S("Elevator Shaft Corner Block"),
		tiles = {2},
		collision_box = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		sounds = default.node_sound_stone_defaults(),
		craft = {
			type = "shapeless",
			recipe = {"default:clay"}
		}
	},
	["elevator_outer_wall_with_trigger_off"] = {
		description = elevators.S("Elevator Outer Wall With Trigger (off)"),
		tiles = {5, 6, 7, 8, 2, 9},
		node_box = {
			{-0.5, -0.5, 0.0, 0.5, 0.5, 0.4},
			{-0.5, -0.5, 0.4, 0.0, 0.5, 0.5},
			{-0.185, -0.25, -0.05, 0.185, 0.25, 0.0}
		},
		light_source = 3,
		groups = {trigger=1, state=0},
		sounds = default.node_sound_stone_defaults(),
		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			elevators.call(pos)
		end,
		craft = {
			recipe = {
				{"default:clay_lump", "default:clay_lump", "default:clay_lump"},
				{"default:clay_lump", "basic_materials:ic", "default:clay_lump"},
				{"default:clay_lump", "basic_materials:plastic_sheet", "default:clay_lump"}
			}
		}
	},
	["elevator_outer_wall_with_trigger_on"] = {
		description = elevators.S("Elevator Outer Wall With Trigger (on)"),
		tiles = {5, 6, 7, 8, 2, 10},
		node_box = {
			{-0.5, -0.5, 0.0, 0.5, 0.5, 0.4},
			{-0.5, -0.5, 0.4, 0.0, 0.5, 0.5},
			{-0.185, -0.25, -0.05, 0.185, 0.25, 0.0}
		},
		light_source = 3,
		drop = "real_elevators:elevator_outer_wall_with_trigger_off",
		groups = {not_in_creative_inventory=1, trigger=1, state=1},
		sounds = default.node_sound_stone_defaults()
	},
	["elevator_doors_closed"] = {
		visual_scale = 0.5,
		description = elevators.S("Elevator doors (closed)"),
		mesh = "real_elevators_elevator_doors_closed.b3d",
		tiles = {4},
		collision_box = {-0.5, -0.5, 0.4, 0.5, 1.5, 0.5},
		groups = {doors=1, state=0},
		sounds = default.node_sound_metal_defaults(),
		craft = {
			type = "shapeless",
			recipe = {"stairs:slab_steelblock", "stairs:slab_steelblock", "stairs:slab_steelblock", "stairs:slab_steelblock"}
		}
	},
	["elevator_doors_opened"] = {
		visual_scale = 0.5,
		description = elevators.S("Elevator doors (opened)"),
		mesh = "real_elevators_elevator_doors_opened.b3d",
		tiles = {4},
		collision_box = {
			{-1.0, -0.5, 0.4, -0.5, 1.5, 0.5},
			{0.5, -0.5, 0.4, 1.0, 1.5, 0.5}
		},
		groups = {not_in_creative_inventory=1, doors=1, state=1},
		sounds = default.node_sound_metal_defaults()
	},
	["elevator_winch"] = {
		description = elevators.S("Elevator Winch"),
		mesh = "real_elevators_winch.b3d",
		tiles = {"real_elevators_winch.png"},
		collision_box = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		sounds = default.node_sound_metal_defaults(),
		craft = {
			recipe = {
				{"basic_materials:gear_steel", "basic_materials:steel_wire", "basic_materials:motor"},
				{"basic_materials:steel_bar", "basic_materials:steel_bar", "basic_materials:steel_bar"},
				{"basic_materials:steel_bar", "real_elevators:elevator_rope", "basic_materials:steel_bar"}
			}
		}
	},
	["elevator_rope"] = {
		description = elevators.S("Elevator Rope"),
		drawtype = "plantlike",
		tiles = {"real_elevators_rope.png"},
		collision_box = {-0.2, -0.5, -0.2, 0.2, 0.5, 0.2},
		walkable = false,
		climbable = true,
		sounds = default.node_sound_leaves_defaults(),
		craft = {
			recipe = {
				{"", "farming:cotton", ""},
				{"", "basic_materials:steel_strip", ""},
				{"", "farming:cotton", ""}
			}
		}
	}
}


for name, def in pairs(elevator_parts_defs) do
	local full_def = {
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		groups = {cracky=1.5},
	}

	full_def.visual_scale = def.visual_scale or 1.0
	full_def.description = def.description

	full_def.tiles = {}
	for i, index in ipairs(def.tiles) do
		if type(index) == "number" then
			full_def.tiles[i] = tex_names_used[index]
		else
			full_def.tiles[i] = index
		end
	end

	if def.node_box then
		full_def.drawtype = "nodebox"
		full_def.node_box = {
			type = "fixed",
			fixed = def.node_box
		}
	elseif def.collision_box then
		if type(def.mesh) == "string" and def.mesh ~= "" then
			full_def.drawtype = "mesh"
			full_def.mesh = def.mesh
		else
			full_def.drawtype = def.drawtype
		end

		full_def.collision_box = {
				type = "fixed",
				fixed = def.collision_box
			}
	end

	full_def.selection_box =
			full_def.drawtype == "node_box" and full_def.node_box or full_def.collision_box

	full_def.walkable = def.walkable
	full_def.pointable = def.pointable
	full_def.climbable = def.climbable
	full_def.light_source = def.light_source

	if def.groups ~= nil then
		for name, value in pairs(def.groups) do
			full_def.groups[name] = value
		end
	end

	full_def.sounds = def.sounds

	full_def.on_construct = def.on_construct
	full_def.on_rightclick = def.on_rightclick
	full_def.on_timer = def.on_timer

	minetest.register_node("real_elevators:" .. name, full_def)

	if def.craft then
		local craft_def = def.craft
		craft_def.type = craft_def.type or craft_def.replacements and "shapeless"
		craft_def.output = "real_elevators:" .. name

		minetest.register_craft(craft_def)
	end
end

elevators.elevator_doors = minetest.deserialize(elevators.mod_storage:get_string("elevator_doors")) or {}

minetest.register_node("real_elevators:elevator_cabin", {
	description = elevators.S("Elevator cabin"),
	visual_scale = 0.1,
	wield_scale = {x=0.1, y=0.1, z=0.1},
	drawtype = "mesh",
	mesh = "real_elevators_elevator_cabin.b3d",
	tiles = {"real_elevators_new_cabin.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4, 0.5, -0.45, 0.5},		-- Bottom
			{-0.5, -0.45, -0.4, -0.45, 1.45, 0.5},		-- Left Side
			{0.45, -0.45, -0.4, 0.5, 1.45, 0.5},		-- Right Side
			{-0.5, 1.45, -0.4, 0.5, 1.5, 0.5},			-- Top
			{-0.45, -0.45, 0.45, 0.45, 1.45, 0.5},		-- Back
			--{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4}			-- Front
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4, 0.5, -0.45, 0.5},		-- Bottom
			{-0.5, -0.45, -0.4, -0.45, 1.45, 0.5},		-- Left Side
			{0.45, -0.45, -0.4, 0.5, 1.45, 0.5},		-- Right Side
			{-0.5, 1.45, -0.4, 0.5, 1.5, 0.5},			-- Top
			{-0.45, -0.45, 0.45, 0.45, 1.45, 0.5},		-- Back
			--{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4}			-- Front
		}
	},
	groups = {cracky=1.5, cabin=1},
	sounds = default.node_sound_metal_defaults(),
	on_construct = function(pos)
		local net_name = elevators.get_net_name_from_cabin_pos(pos)

		local meta = minetest.get_meta(pos)
		meta:set_string("state", "idle")

		if not net_name then
			meta:set_string("formspec", elevators.get_enter_elevator_net_name_formspec())--net_name and elevators.elevators_nets[net_name].cabin.formspec or elevators.get_enter_elevator_net_name_formspec())
		end
	end,
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		local net_name = elevators.get_net_name_from_cabin_pos(pos)

		if not net_name then
			return
		end

		local pl_name =  clicker:get_player_name()
		if elevators.cab_fs_contexts[pl_name] and elevators.cab_fs_contexts[pl_name][net_name] and
			elevators.cab_fs_contexts[pl_name][net_name].cur_formspec_name == "real_elevators:add_floor" then
				elevators.switch_formspec(net_name, pl_name, elevators.get_add_floor_formspec(), "add_floor")
		end
		elevators.show_formspec(net_name, clicker:get_player_name())
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		local node = minetest.get_node(pos)
		local playername = placer:get_player_name()
		local success = elevators.check_for_surrounding_shaft_nodes(pos, minetest.facedir_to_dir(node.param2), playername)

		if not success then
			minetest.remove_node(pos)
		end

		success = elevators.check_for_rope(pos, playername)

		if not success then
			minetest.remove_node(pos)
		end

		return
	end,
	on_destruct = function(pos)
		local net_name = elevators.get_net_name_from_cabin_pos(pos)
		if net_name ~= "" then
			elevators.update_formspec_to_all_viewers(net_name, nil, nil, true)
			elevators.remove_net(net_name)
		end
	end,
	on_timer = function(pos, elapsed)
		local net_name = elevators.get_net_name_from_cabin_pos(pos)

		if net_name ~= "" then
			--minetest.debug("Closing doors...")
			elevators.move_doors(net_name, "close")
		end
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if fields.quit then
			return
		end

		local meta = minetest.get_meta(pos)
		local pl_name = sender:get_player_name()
		if fields.elevator_net_name_enter then
			elevators.create_net(fields.elevator_net_name, pl_name, pos)
		end
	end
})

minetest.register_craft({
	output = "real_elevators:elevator_cabin",
	recipe = {
		{"basic_materials:steel_bar", "default:steel_ingot", "basic_materials:steel_bar"},
		{"default:steel_ingot", "basic_materials:ic", "default:steel_ingot"},
		{"basic_materials:steel_bar", "real_elevators:elevator_doors_closed", "basic_materials:steel_bar"}
	}
})

minetest.register_entity("real_elevators:elevator_door_moving", {
	visual_size = {x=1, y=1, z=1},
	visual = "mesh",
	mesh = "real_elevators_elevator_door.b3d",
	physical = true,
	collide_with_objects = true,
	collisionbox = {-0.25, -0.5, -0.05, 0.25, 1.5, 0.05},
	pointable = true,
	textures = {tex_names_used[4]},
	on_activate = function(self, staticdata, dtime_s)
		if staticdata ~= "" then
			self.end_pos = vector.from_string(staticdata)
		end

		local pos = self.object:get_pos()
		--minetest.debug("pos: " .. dump(pos))
		for name, data in pairs(elevators.elevators_nets) do
			--minetest.debug("data.cabin.inner_doors: " .. dump(data.cabin.inner_doors))
			if type(data.cabin.inner_doors.left) == "table" and vector.equals(data.cabin.inner_doors.left, pos) then
				data.cabin.inner_doors.left = self.object

				if data.cabin.state == "active" then
					self.object:set_attach(data.cabin.elevator_object, "", vector.multiply(vector.subtract(data.cabin.elevator_object:get_pos(), pos), 10))
				end
				break
			elseif type(data.cabin.inner_doors.right) == "table" and vector.equals(data.cabin.inner_doors.right, pos) then
				data.cabin.inner_doors.right = self.object
				break
			end

			--minetest.debug("data.outer_doors: " .. dump(data.outer_doors))
			if data.outer_doors then
				if type(data.outer_doors.left) == "table" and vector.equals(data.outer_doors.left, pos) then
					data.outer_doors.left = self.object
					break
				elseif type(data.outer_doors.right) == "table" and vector.equals(data.outer_doors.right, pos) then
					data.outer_doors.right = self.object
					break
				end
			end
		end
	end,
	on_step = function(self, dtime, moveresult)
		if not self.end_pos then
			self.object:set_velocity(vector.new())
			return
		else
			if vector.length(self.object:get_velocity()) == 0 then
				-- The door is obstructed!
				self.object:set_velocity(self.vel)
			end
		end


		local dist = vector.distance(self.object:get_pos(), self.end_pos)

		if dist < 0.05 then
			self.object:set_pos(self.end_pos)
			self.object:set_velocity(vector.new())
			self.end_pos = nil
		end

	end,
	static_save = true,
	get_staticdata = function(self)
		return self.end_pos and vector.to_string(self.end_pos) or ""
	end
})

minetest.register_entity("real_elevators:elevator_cabin_activated", {
	visual_size = {x=1, y=1, z=1},
	visual = "mesh",
	mesh = "real_elevators_elevator_cabin.b3d",
	physical = true,
	collide_with_objects = true,
	collisionbox = {-0.5, -0.5, -0.5, 0.5, 1.5, 0.5},
	pointable = true,
	textures = {"real_elevators_new_cabin.png"},
	static_save = true,
	on_activate = function(self, staticdata, dtime_s)
		minetest.debug("on_activate()")
		if staticdata ~= "" then
			local data = minetest.deserialize(staticdata)
			self.end_pos = data[1]
			self.dir = data[2]
			self.elevator_net_name = data[3]
			self.status = data[4]
		end

		if not self.elevator_net_name then
			return
		end

		local net = elevators.elevators_nets[self.elevator_net_name]

		local pos = self.object:get_pos()
		if type(net.cabin.elevator_object) == "table" and vector.equals(net.cabin.elevator_object, pos) then
			net.cabin.elevator_object = self.object

			--[[for i, obj in ipairs(net.cabin.attached_objs) do
				if obj:is_player() then
					if elevators.is_player_online(obj) then
						obj:set_attach(self.object, "", vector.multiply(vector.subtract(obj:get_pos(), pos), 10))
					else
						obj = nil
					end
				elseif obj:get_luaentity() then
					obj:set_attach(self.object, "", vector.multiply(vector.subtract(obj:get_pos(), pos), 10))
				else
					obj = nil
				end
			end]]
		end

		--minetest.debug("[on_activate()] " .. self.elevator_net_name .. ": " .. dump(elevators.elevators_nets[self.elevator_net_name]))
	end,
	on_step = function(self, dtime, moveresult)
		--[[ 'self.status' can have the following values:
			"arrived" - if the cabin has arrived to the necessary floor
			"stopped" - if the cabin has not arrived yet and can not continue moving (the shaft is built wrong/nodes blocking the moving up or down)
			"disrupted" - if the cabin is disrupted from the rope and fell down
		]]

		if not self.end_pos then
			return
		end

		local pos = self.object:get_pos()

		-- Check for shaft nodes availability
		local is_shaft = elevators.check_for_surrounding_shaft_nodes(elevators.get_centre_y_pos_from_node_pos(pos), self.dir)

		if not is_shaft then
			minetest.debug("1")
			-- The cabin can not move further as at its level there are no enough shaft nodes!
			self.object:set_velocity(vector.new())
			self.end_pos = nil
			self.status = "stopped"
			return
		end

		local dist = vector.distance(pos, self.end_pos)

		if dist < 0.05 then
			minetest.debug("2")
			--minetest.debug("The cabin is about to stop...")
			-- The cabin is arrived!
			self.object:set_pos(self.end_pos)
			self.object:set_velocity(vector.new())
			self.end_pos = nil
			self.status = "arrived"
			return
		end

		local cur_vel = self.object:get_velocity()

		if vector.length(cur_vel) == 0 then
			minetest.debug("3")
			--self.object:set_velocity(vector.new())
			self.end_pos = nil
			self.status = "stopped"
		end
	end,
	on_deactivate = function(self)
		minetest.debug("on_deactivate()")
		--minetest.debug("self.elevator_net_name: " .. (self.elevator_net_name ~= nil and self.elevator_net_name or "nil"))
		--[[if not self.elevator_net_name then
			return
		end

		if self.is_remove then
			elevators.remove_net(self.elevator_net_name)
		else
			elevators.save_entities_positions_in_net(self.elevator_net_name)
		end]]
		if not self.elevator_net_name then
			return
		end

		elevators.remove_net(self.elevator_net_name)
	end,
	on_death = function(self)
		minetest.debug("on_death()")
		if not self.elevator_net_name then
			return
		end

		elevators.remove_net(self.elevator_net_name)
	end,
	get_staticdata = function(self)
		return minetest.serialize({self.end_pos, self.dir, self.elevator_net_name, self.status})
	end
})

minetest.register_tool("real_elevators:floor_mark_tool", {
	description = elevators.S("Floor Mark Tool (right-click a node to mark that position for adding a new floor for an elevator net)"),
	inventory_image = "real_elevators_floor_mark_tool.png",
	stack_max = 1,
	on_place = function(itemstack, placer, pointed_thing)
		if elevators.current_marked_pos then
			local marked_barea_obj = minetest.get_objects_inside_radius(elevators.current_marked_pos, 0.0)

			if #marked_barea_obj > 0 then
				marked_barea_obj[1]:remove()
			end
		end
		elevators.current_marked_pos = pointed_thing.under

		minetest.chat_send_player(placer:get_player_name(), "You marked block area at position: " .. minetest.pos_to_string(pointed_thing.under) .. ". Set as current one.")
		minetest.add_entity(pointed_thing.under, "real_elevators:marked_block_area")
		--elevators.update_cabins_formspecs()
	end
})

minetest.register_entity("real_elevators:marked_block_area", {
	visual = "cube",
	visual_size = {x=1, y=1, z=1},
	physical = false,
	pointable = true,
	textures = {
		"real_elevators_marked_block_area.png",
		"real_elevators_marked_block_area.png",
		"real_elevators_marked_block_area.png",
		"real_elevators_marked_block_area.png",
		"real_elevators_marked_block_area.png",
		"real_elevators_marked_block_area.png"
	}
})

minetest.register_node("real_elevators:light", {
	drawtype = "airlike",
	description = "Light",
	groups = {not_in_creative_inventory=1},
	paramtype = "light",
	sunlight_propagates = true,
	collision_box = {
		type = "fixed",
		fixed =  {0, 0, 0, 0, 0, 0}
	},
	selection_box = {
		type = "fixed",
		fixed = {0, 0, 0, 0, 0, 0}
	},
	light_source = 14
})

minetest.register_on_shutdown(elevators.on_shutdown)
minetest.register_globalstep(elevators.global_step)
minetest.register_on_player_receive_fields(elevators.on_receive_fields)
minetest.register_on_leaveplayer(elevators.on_leaveplayer)
--minetest.register_on_joinplayer(elevators.on_join)
