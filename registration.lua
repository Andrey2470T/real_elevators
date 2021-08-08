-- Registration function.
-- Registers all necessary parts for building shaft for elevator. The outer doors and the cabin are registered separately.

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
		description = "Elevator Shaft (Left) Side Block",
		tiles = {3, 3, 1, 3, 3, 3},
		node_box = {
			{-0.5, -0.5, -0.4, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.49, 0.0, 0.5, -0.4}
		},
		groups = {shaft=1},
		sounds = default.node_sound_stone_defaults()
	},
	["elevator_shaft_rightside"] = {
		description = "Elevator Shaft (Right) Side Block",
		tiles = {3, 3, 3, 1, 3, 3},
		node_box = {
			{-0.5, -0.5, -0.4, 0.5, 0.5, 0.5},
			{0.0, -0.5, -0.49, 0.5, 0.5, -0.4}
		},
		groups = {shaft=1},
		sounds = default.node_sound_stone_defaults()
	},
	["elevator_shaft_back"] = {
		description = "Elevator Shaft Back Block",
		tiles = {2, 2, 2, 2, 2, 1},
		collision_box = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		groups = {shaft=1},
		sounds = default.node_sound_stone_defaults()
	},
	["elevator_outer_wall_leftslot"] = {
		description = "Elevator Outer Wall With Left Slot",
		tiles = {3},
		node_box = {
			{-0.5, -0.5, 0.4, 0.0, 0.5, 0.5},
			{-0.5, -0.5, 0.0, 0.5, 0.5, 0.4}
		},
		sounds = default.node_sound_stone_defaults()
	},
	["elevator_outer_wall_rightslot"] = {
		description = "Elevator Outer Wall With Right Slot",
		tiles = {3},
		node_box = {
			{0.0, -0.5, 0.4, 0.5, 0.5, 0.5},
			{-0.5, -0.5, 0.0, 0.5, 0.5, 0.4}
		},
		sounds = default.node_sound_stone_defaults()
	},
	["elevator_outer_wall"] = {
		description = "Elevator Outer Wall",
		tiles = {3},
		node_box = {-0.5, -0.5, 0.0, 0.5, 0.5, 0.5},
		sounds = default.node_sound_stone_defaults()
	},
	["elevator_outer_shaft_wall"] = {
		description = "Elevator Outer Shaft Wall",
		tiles = {3, 3, 3, 3, 1, 3},
		node_box = {-0.5, -0.5, 0.0, 0.5, 0.5, 0.5},
		groups = {shaft=1},
		sounds = default.node_sound_stone_defaults()
	},
	["elevator_shaft_corner"] = {
		description = "Elevator Shaft Corner Block",
		tiles = {2},
		collision_box = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		sounds = default.node_sound_stone_defaults()
	},
	["elevator_outer_wall_with_trigger_off"] = {
		description = "Elevator Outer Wall With Trigger (off)",
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
			elevators.activate(pos)
		end
	},
	["elevator_outer_wall_with_trigger_on"] = {
		description = "Elevator Outer Wall With Trigger (on)",
		tiles = {5, 6, 7, 8, 2, 10},
		node_box = {
			{-0.5, -0.5, 0.0, 0.5, 0.5, 0.4},
			{-0.5, -0.5, 0.4, 0.0, 0.5, 0.5},
			{-0.185, -0.25, -0.05, 0.185, 0.25, 0.0}
		},
		light_source = 3,
		groups = {not_in_creative_inventory=1, trigger=1, state=1},
		sounds = default.node_sound_stone_defaults(),
		on_construct = function(pos)
			local timer = minetest.get_node_timer(pos)
			timer:start(10)
		end,
		on_timer = function(pos, elapsed)
			elevators.deactivate(pos)
		end
	},
	["elevator_doors_closed"] = {
		visual_scale = 0.5,
		description = "Elevator doors (closed)",
		mesh = "real_elevators_elevator_doors_closed.b3d",
		tiles = {4},
		collision_box = {-0.5, -0.5, 0.4, 0.5, 1.5, 0.5},
		groups = {doors=1, state=0},
		sounds = default.node_sound_metal_defaults()
	},
	--[[["elevator_doors_opening"] = {
		visual_scale = 0.5,
		description = "Elevator doors (opening)",
		mesh = "real_elevators_elevator_doors_opening.b3d",
		tiles = {
			{
				name = "real_elevators_outer_doors_opening_anim.png",
				animation = {
					type = "vertical_frames",
					aspect_w = 320,
					aspect_h = 32,
					length = 1
				}
			}
		},
		collision_box = {-0.5, -0.5, 0.4, 0.5, 1.5, 0.5},
		groups = {not_in_creative_inventory=1, doors=1, state=1},
		sounds = default.node_sound_metal_defaults(),
		on_construct = function(pos)
			local timer = minetest.get_node_timer(pos)
			timer:start(0.9)
		end,
		on_timer = function(pos, elapsed)
			minetest.set_node(pos, {name = "real_elevators:elevator_doors_opened", param2 = minetest.get_node(pos).param2})
		end
	},]]
	["elevator_doors_opened"] = {
		visual_scale = 0.5,
		description = "Elevator doors (opened)",
		mesh = "real_elevators_elevator_doors_opened.b3d",
		tiles = {4},
		collision_box = {
			{-1.0, -0.5, 0.4, -0.5, 1.5, 0.5},
			{0.5, -0.5, 0.4, 1.0, 1.5, 0.5}
		},
		groups = {not_in_creative_inventory=1, doors=1, state=1},
		sounds = default.node_sound_metal_defaults()
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
		if type(index) == "table" then
			full_def.tiles[i] = index
		elseif type(index) == "number" then
			full_def.tiles[i] = tex_names_used[index]
		end
	end

	if def.node_box then
		full_def.drawtype = "nodebox"
		full_def.node_box = {
			type = "fixed",
			fixed = def.node_box
		}
	elseif def.collision_box then
		if type(def.mesh) == "string" and #def.mesh > 0 then
			full_def.drawtype = "mesh"
			full_def.mesh = def.mesh
		else
			full_def.drawtype = "regular"
		end

		full_def.collision_box = {
				type = "fixed",
				fixed = def.collision_box
			}
	end

	full_def.selection_box =
			full_def.drawtype == "node_box" and full_def.node_box or
			(full_def.drawtype == "regular" or full_def.drawtype == "mesh") and full_def.collision_box

	full_def.light_source = def.light_source

	if def.groups ~= nil then
		full_def.groups.shaft = def.groups.shaft
		full_def.groups.state = def.groups.state
		full_def.groups.trigger = def.groups.trigger
		full_def.groups.doors = def.groups.doors
	end

	full_def.sounds = def.sounds

	full_def.on_construct = def.on_construct
	full_def.on_rightclick = def.on_rightclick
	full_def.on_timer = def.on_timer

	minetest.register_node("real_elevators:" .. name, full_def)
end

elevators.elevator_doors = {}

minetest.register_node("real_elevators:elevator_cabin", {
	description = "Elevator cabin",
	visual_scale = 0.5,
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
		local left_door, right_door = elevators.set_doors(pos, -0.45, 0.25)

		local str_pos = vector.to_string(pos)
		elevators.elevator_doors[str_pos] = {left_door, right_door}
	end,
	on_destruct = function(pos)
		local str_pos = vector.to_string(pos)

		if elevators.elevator_doors[str_pos] then
			elevators.elevator_doors[str_pos][1]:remove()
			elevators.elevator_doors[str_pos][2]:remove()

			elevators.elevator_doors[str_pos] = nil
		end
	end
})

minetest.register_entity("real_elevators:elevator_door_moving", {
	visual_size = {x=5, y=5, z=5},
	visual = "mesh",
	mesh = "real_elevators_elevator_door.b3d",
	physical = true,
	collide_with_objects = true,
	collisionbox = {-0.25, -0.5, -0.05, 0.25, 1.5, 0.05},
	pointable = true,
	textures = {tex_names_used[4]},
	on_activate = function(self, staticdata, dtime_s)
		if staticdata ~= "" then
			self.start_pos = vector.from_string(staticdata)
		else
			self.start_pos = self.object:get_pos()
		end
	end,
	on_step = function(self, dtime, moveresult)
		if not self.end_pos then
			return
		else
			if vector.length(self.object:get_velocity()) == 0 then
				-- The door is obstructed!
				self.object:set_velocity(self.vel)
			end
		end


		local dist = vector.distance(self.start_pos, self.end_pos)
		local cur_dist = vector.distance(self.object:get_pos(), self.start_pos)

		if (math.abs(dist - cur_dist)) < 0.05 then
			self.object:set_pos(self.end_pos)
			self.object:set_velocity(vector.new())
			self.end_pos = nil
		end

	end,
	get_staticdata = function(self)
		return vector.to_string(self.start_pos)
	end
})
