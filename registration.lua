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
			{-0.5, -0.5, -0.5, 0.0, 0.5, -0.4}
		},
		groups = {shaft=1},
		sounds = default.node_sound_stone_defaults()
	},
	["elevator_shaft_rightside"] = {
		description = "Elevator Shaft (Right) Side Block",
		tiles = {3, 3, 3, 1, 3, 3},
		node_box = {
			{-0.5, -0.5, -0.4, 0.5, 0.5, 0.5},
			{0.0, -0.5, -0.5, 0.5, 0.5, -0.4}
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
		sounds = default.node_sound_stone_defaults()
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
		groups = {not_in_creative_inventory=1},
		sounds = default.node_sound_stone_defaults()
	}
}


for name, def in pairs(elevator_parts_defs) do
	local full_def = {
		visual_scale = 1.0,
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		groups = {cracky=1.5},
	}

	full_def.description = def.description

	full_def.tiles = {}
	for i, index in ipairs(def.tiles) do
		full_def.tiles[i] = tex_names_used[index]
	end

	if def.node_box then
		full_def.drawtype = "nodebox"
		full_def.node_box = {
			type = "fixed",
			fixed = def.node_box
		}
	elseif def.collision_box then
		full_def.drawtype = "regular"
		full_def.collision_box = {
			type = "fixed",
			fixed = def.collision_box
		}
	end

	full_def.selection_box =
			full_def.drawtype == "node_box" and full_def.node_box or
			full_def.drawtype == "regular" and full_def.collision_box

	full_def.light_source = def.light_source

	if def.groups ~= nil then
		if def.groups.shaft then
			full_def.groups.shaft = def.groups.shaft
		end

		if def.groups.not_in_creative_inventory then
			full_def.groups.not_in_creative_inventory = def.groups.not_in_creative_inventory
		end
	end

	full_def.sounds = def.sounds

	minetest.register_node("real_elevators:" .. name, full_def)
end
