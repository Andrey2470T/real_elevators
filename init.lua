elevators = {}

dofile(minetest.get_modpath("real_elevators") .. "/registration.lua")

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

minetest.register_node("real_elevators:elevator_doors_closed", {
	description = "Elevator doors (closed)",
	visual_scale = 0.5,
	drawtype = "mesh",
	mesh = "real_elevators_elevator_doors_closed.b3d",
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

minetest.register_node("real_elevators:elevator_doors_opening", {
	description = "Elevator doors (opening)",
	visual_scale = 0.5,
	drawtype = "mesh",
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
	groups = {cracky=1.5, not_in_creative_inventory=1},
	sounds = default.node_sound_metal_defaults(),
	on_construct = function(pos)
		local timer = minetest.get_node_timer(pos)
		timer:start(0.9)
	end,
	on_timer = function(pos, elapsed)
		minetest.set_node(pos, {name = "real_elevators:elevator_doors_opened", param2 = minetest.get_node(pos).param2})
	end
})

minetest.register_node("real_elevators:elevator_doors_opened", {
	description = "Elevator doors (opened)",
	visual_scale = 0.5,
	drawtype = "mesh",
	mesh = "real_elevators_elevator_doors_opened.b3d",
	tiles = {"real_elevators_outer_doors.png"},
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	collision_box = {
		type = "fixed",
		fixed = {
			{-1.0, -0.5, 0.4, -0.5, 1.5, 0.5},
			{0.5, -0.5, 0.4, 1.0, 1.5, 0.5}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-1.0, -0.5, 0.4, -0.5, 1.5, 0.5},
			{0.5, -0.5, 0.4, 1.0, 1.5, 0.5}
		}
	},
	groups = {cracky=1.5, not_in_creative_inventory=1},
	sounds = default.node_sound_metal_defaults()
})

