elevators = {}

--[[elevators.get_formspec = function(floors_num)
    local formspec = "formspec_version[4]"
    local but_size_x = 3
    local but_size_y = 1.5

    local ctner_pad = 0.3
    local fspec_pad = 0.5

    local ctner_size_x = 2*ctner_pad + but_size_x
    local ctner_size_y = 2*ctner_pad + 4*but_size_y + 3*ctner_pad
    local container = "scroll_container[" .. fspec_pad .. "," .. fspec_pad .. ";" .. ctner_size_x .. "," .. ctner_size_y

    if floors_num > 4 then
        container = container .. ";floor_selection_scrl_bar;vertical;]"
    else
        container = container .. ";;;]"
    end]]




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
			{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4}			-- Front
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
			{-0.5, -0.5, -0.5, 0.5, 1.5, -0.4}			-- Front
		}
	},
	groups = {cracky=1.5},
	sounds = default.node_sound_metal_defaults()
})

minetest.register_node("real_elevators:elevator_shaft_leftside", {
	description = "Elevator Shaft (Left) Side Block",
	visual_scale = 1.0,
	drawtype = "nodebox",
	tiles = {
		"real_elevators_shaft_side_block2.png",
		"real_elevators_shaft_side_block2.png",
		"real_elevators_shaft_back_block.png",
		"real_elevators_shaft_side_block2.png",
		"real_elevators_shaft_side_block2.png",
		"real_elevators_shaft_side_block2.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.5, 0.0, 0.5, -0.4}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4, 0.5, 0.5, 0.5},
			{-0.5, -0.5, -0.5, 0.0, 0.5, -0.4}
		}
	},
	groups = {cracky=1.5},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("real_elevators:elevator_shaft_rightside", {
	description = "Elevator Shaft (Right) Side Block",
	visual_scale = 1.0,
	drawtype = "nodebox",
	tiles = {
		"real_elevators_shaft_side_block2.png",
		"real_elevators_shaft_side_block2.png",
		"real_elevators_shaft_side_block2.png",
		"real_elevators_shaft_back_block.png",
		"real_elevators_shaft_side_block2.png",
		"real_elevators_shaft_side_block2.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4, 0.5, 0.5, 0.5},
			{0.0, -0.5, -0.5, 0.5, 0.5, -0.4}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, -0.4, 0.5, 0.5, 0.5},
			{0.0, -0.5, -0.5, 0.5, 0.5, -0.4}
		}
	},
	groups = {cracky=1.5},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("real_elevators:elevator_shaft_back", {
	description = "Elevator Shaft Back Block",
	visual_scale = 1.0,
	tiles = {
		"real_elevators_shaft_back_block2.png",
		"real_elevators_shaft_back_block2.png",
		"real_elevators_shaft_back_block2.png",
		"real_elevators_shaft_back_block2.png",
		"real_elevators_shaft_back_block2.png",
		"real_elevators_shaft_back_block.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	collision_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
	},
	groups = {cracky=1.5},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("real_elevators:elevator_outer_wall_leftslot", {
	description = "Elevator Outer Wall With Left Slot",
	visual_scale = 1.0,
	drawtype = "nodebox",
	tiles = {
		"real_elevators_shaft_side_block2.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.4, 0.0, 0.5, 0.5},
			{-0.5, -0.5, 0.0, 0.5, 0.5, 0.4}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.4, 0.0, 0.5, 0.5},
			{-0.5, -0.5, 0.0, 0.5, 0.5, 0.4}
		}
	},
	groups = {cracky=1.5},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("real_elevators:elevator_outer_wall_rightslot", {
	description = "Elevator Outer Wall With Right Slot",
	visual_scale = 1.0,
	drawtype = "nodebox",
	tiles = {
		"real_elevators_shaft_side_block2.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{0.0, -0.5, 0.4, 0.5, 0.5, 0.5},
			{-0.5, -0.5, 0.0, 0.5, 0.5, 0.4}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{0.0, -0.5, 0.4, 0.5, 0.5, 0.5},
			{-0.5, -0.5, 0.0, 0.5, 0.5, 0.4}
		}
	},
	groups = {cracky=1.5},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("real_elevators:elevator_doors", {
	description = "Elevator doors",
	visual_scale = 0.5,
	drawtype = "mesh",
	mesh = "real_elevators_elevator_doors.b3d",
	tiles = {"real_elevators_outer_doors.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	collision_box = {
		type = "fixed",
		fixed = {
			-0.5, -0.5, 0.4, 0.5, 1.5, 0.5
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			-0.5, -0.5, 0.4, 0.5, 1.5, 0.5
		}
	},
	groups = {cracky=1.5},
	sounds = default.node_sound_metal_defaults()
})

minetest.register_node("real_elevators:elevator_outer_wall", {
	description = "Elevator Outer Wall",
	visual_scale = 1.0,
	drawtype = "nodebox",
	tiles = {
		"real_elevators_shaft_side_block2.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			-0.5, -0.5, 0.0, 0.5, 0.5, 0.5
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			-0.5, -0.5, 0.0, 0.5, 0.5, 0.5
		}
	},
	groups = {cracky=1.5},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("real_elevators:elevator_shaft_corner", {
	description = "Elevator Shaft Corner Block",
	visual_scale = 1.0,
	tiles = {
		"real_elevators_shaft_back_block2.png",
		"real_elevators_shaft_back_block2.png",
		"real_elevators_shaft_back_block2.png",
		"real_elevators_shaft_back_block2.png",
		"real_elevators_shaft_back_block2.png",
		"real_elevators_shaft_back_block2.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	collision_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
	},
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}
	},
	groups = {cracky=1.5},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("real_elevators:elevator_outer_wall_with_trigger_off", {
	description = "Elevator Outer Wall With Trigger (off)",
	visual_scale = 1.0,
	drawtype = "nodebox",
	tiles = {
		"real_elevators_outer_wall_with_button_top.png",
		"real_elevators_outer_wall_with_button_bottom.png",
		"real_elevators_outer_wall_with_button_right.png",
		"real_elevators_outer_wall_with_button_left.png",
		"real_elevators_shaft_back_block2.png",
		"real_elevators_outer_wall_with_button_front.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	node_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.0, 0.5, 0.5, 0.4},
			{-0.5, -0.5, 0.4, 0.0, 0.5, 0.5},
			{-0.185, -0.25, -0.05, 0.185, 0.25, 0.0}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.5, -0.5, 0.0, 0.5, 0.5, 0.5},
			{-0.5, -0.5, 0.4, 0.0, 0.5, 0.5},
			{-0.185, -0.25, -0.05, 0.185, 0.25, 0.0}
		}
	},
	groups = {cracky=1.5},
	sounds = default.node_sound_stone_defaults()
})
