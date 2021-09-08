-- MINETEST REGISTRATION FUNCTIONS CALLS.
-- ==================================================================


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
		--meta:set_string("state", "idle")
		meta:set_string("formspec", net_name and elevators.elevators_nets[net_name].cabin.formspec or elevators.get_enter_elevator_net_name_formspec())
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
		local net_name = minetest.get_meta(pos):get_string("elevator_net_name")
		if net_name ~= "" then
			elevators.elevators_nets[net_name].cabin.inner_doors.left:remove()
			elevators.elevators_nets[net_name].cabin.inner_doors.right:remove()
			elevators.elevators_nets[net_name] = nil
		end
	end,
	on_timer = function(pos, elapsed)
		local net_name = minetest.get_meta(pos):get_string("elevator_net_name")

		if net_name ~= "" then
			--minetest.debug("Closing doors...")
			elevators.move_doors(net_name, "close")
		end
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if fields.quit then
			return
		end

		if fields.elevator_net_name_enter then
			if fields.elevator_net_name == "" then
				minetest.chat_send_player(sender:get_player_name(), "The elevator net name can not be empty!")
				return
			end
			if elevators.elevators_nets[fields.elevator_net_name] then
				minetest.chat_send_player(sender:get_player_name(), "This elevator net name already exists!")
				return
			end
			elevators.elevators_nets[fields.elevator_net_name] = {
				floors = {},
				cabin = {
					position = pos,
					inner_doors = {},
					queue = {},
					attached_objs = {}
				}
			}

			local left_door, right_door = elevators.set_doors(pos, minetest.facedir_to_dir(minetest.get_node(pos).param2), -0.45, 0.25)
			elevators.elevators_nets[fields.elevator_net_name].cabin.inner_doors.left = left_door
            elevators.elevators_nets[fields.elevator_net_name].cabin.inner_doors.right = right_door

			elevators.elevators_nets[fields.elevator_net_name].cabin.state = "idle"
			local meta = minetest.get_meta(pos)
			meta:set_string("elevator_net_name", fields.elevator_net_name)
			meta:set_string("formspec", elevators.get_add_floor_formspec())
		end

		if fields.set_floor then
			if fields.floor_number == "" then
				minetest.chat_send_player(sender:get_player_name(), "The floor number must be set!")
				return
			end

			local floor_pos = minetest.string_to_pos(fields.floor_pos)

			if not floor_pos then
				if elevators.current_marked_pos then
					floor_pos = elevators.current_marked_pos
				else
					minetest.chat_send_player(sender:get_player_name(), "The floor position must be set!")
				end
				return
			end

			local elevator_net_name = minetest.get_meta(pos):get_string("elevator_net_name")

			for i, floor in ipairs(elevators.elevators_nets[elevator_net_name].floors) do
				if floor.number == fields.floor_number then
					minetest.chat_send_player(sender:get_player_name(), "There is already the floor with such number in this elevator net!")
					return
				end
				if vector.equals(floor.position, floor_pos) then
					minetest.chat_send_player(sender:get_player_name(), "There is already the floor with such position in this elevator net!")
					return
				end
			end

			-- In future, probably horizontally moving elevators will be added, but for now only vertically
			if pos.x ~= floor_pos.x or pos.z ~= floor_pos.z then
				minetest.chat_send_player(sender:get_player_name(), "You can not add floor with position that is not aligned with the elevator cabin position along Y axis!")
				return
			end
			elevators.elevators_nets[elevator_net_name].floors[#elevators.elevators_nets[elevator_net_name].floors+1] = {}
			local new_floor = elevators.elevators_nets[elevator_net_name].floors[#elevators.elevators_nets[elevator_net_name].floors]
			new_floor.number = fields.floor_number
            new_floor.description = fields.floor_description
			new_floor.position = floor_pos

			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", elevators.get_floor_list_formspec(elevator_net_name))
		end

		if fields.add_floor then
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", elevators.get_add_floor_formspec())
		end

		if fields.floor_add and fields.floor_number ~= "" then
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", elevators.get_add_floor_formspec(tonumber(fields.floor_number)+1, fields.floor_description, fields.floor_pos))
		end

		if fields.floor_reduce and fields.floor_number ~= "" then
			local meta = minetest.get_meta(pos)
			meta:set_string("formspec", elevators.get_add_floor_formspec(tonumber(fields.floor_number)-1, fields.floor_description, fields.floor_pos))
		end

		local net_name = minetest.get_meta(pos):get_string("elevator_net_name")

		local state = elevators.elevators_nets[net_name].cabin.state
		if net_name ~= "" and (state == "pending" or state == "idle") then
			for i, floor in ipairs(elevators.elevators_nets[net_name].floors) do
				if fields["floor_" .. tostring(i)] then
					table.insert(elevators.elevators_nets[net_name].cabin.queue, 1, floor.position)

					if state == "pending" then
						local timer = minetest.get_node_timer(pos)
						timer:stop()
						elevators.move_doors(net_name, "close")
					end
				end
			end
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
		if staticdata ~= "" then
			local data = minetest.deserialize(staticdata)
			self.end_pos = data[1]
			self.dir = data[2]
			self.elevator_net_name = data[3]
			self.is_falling = data[4]
		end

		if not self.elevator_net_name then
			return
		end

		local net = elevators.elevators_nets[self.elevator_net_name]

		local pos = self.object:get_pos()
		if type(net.cabin.elevator_object) == "table" and vector.equals(net.cabin.elevator_object, pos) then
			net.cabin.elevator_object = self.object

			for i, obj in ipairs(net.cabin.attached_objs) do
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
			end
		end

		--minetest.debug("[on_activate()] " .. self.elevator_net_name .. ": " .. dump(elevators.elevators_nets[self.elevator_net_name]))
	end,
	on_step = function(self, dtime, moveresult)
		if not self.end_pos or self.is_falling then
			return
		end

		local pos = self.object:get_pos()

		-- Update rope
		minetest.remove_node({x=pos.x, y=pos.y+1, z=pos.z})

		local top_pos = {x=pos.x, y=pos.y+2, z=pos.z}
		local top_node = minetest.get_node(top_pos)

		if top_node.name == "real_elevators:elevator_winch" then
			if vector.direction(pos, top_pos) == vector.normalize(self.object:get_velocity()) then
				-- The cabin can not move up as on the top of it there is a winch impeding!
				self.object:set_velocity(vector.new())
				self.end_pos = nil
				return
			end
		else
			minetest.set_node({x=pos.x, y=pos.y+2, z=pos.z}, {name="real_elevators:elevator_rope"})
		end

		-- Check for shaft nodes availability
		local is_shaft = elevators.check_for_surrounding_shaft_nodes(pos, self.dir)

		if not is_shaft then
			-- The cabin can not move further as at its level there are no enough shaft nodes!
			self.object:set_velocity(vector.new())
			self.end_pos = nil
			return
		end

		--minetest.remove_node({x=pos.x, y=pos.y+1, z=pos.z})
		local dist = vector.distance(pos, self.end_pos)

		if dist < 0.05 then
			--minetest.debug("The cabin is about to stop...")
			-- The cabin is arrived!
			self.object:set_pos(self.end_pos)
			self.object:set_velocity(vector.new())
			self.end_pos = nil
		end

		--[[local top_pos = {x=pos.x, y=pos.y+2, z=pos.z}
		local top_node = minetest.get_node(top_pos)

		if top_node.name == "real_elevators:elevator_winch" and
			vector.direction(pos, top_pos) == vector.normalize(self.object:get_velocity()) then
			-- The cabin can not move up as on the top of it there is a winch impeding!
			self.object:set_velocity(vector.new())
			self.end_pos = nil
			return
		end

		if top_node.name ~= "real_elevators:elevator_winch" then
			minetest.set_node({x=pos.x, y=pos.y+2, z=pos.z}, {name="real_elevators:elevator_rope"})
		end]]
	end,
	on_deactivate = function(self)
		minetest.debug("on_deactivate()")
		--minetest.debug("self.elevator_net_name: " .. (self.elevator_net_name ~= nil and self.elevator_net_name or "nil"))
		if not self.elevator_net_name then
			return
		end

		if self.is_remove then
			elevators.remove_net(self.elevator_net_name)
		else
			elevators.save_entities_positions_in_net(self.elevator_net_name)
		end
	end,
	on_death = function(self)
		minetest.debug("on_death()")
		if not self.elevator_net_name then
			return
		end

		elevators.remove_net(self.elevator_net_name)
	end,
	get_staticdata = function(self)
		return minetest.serialize({self.end_pos, self.dir, self.elevator_net_name, self.is_falling})
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

		elevators.update_cabins_formspecs()
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

minetest.register_on_shutdown(elevators.on_shutdown)
minetest.register_globalstep(elevators.global_step)
minetest.register_on_joinplayer(elevators.on_join)
