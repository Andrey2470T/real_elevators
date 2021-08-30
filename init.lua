elevators = {}

elevators.S = minetest.get_translator("real_elevators")
elevators.mod_storage = minetest.get_mod_storage()

local modpath = minetest.get_modpath("real_elevators")
dofile(modpath .. "/config.lua")
dofile(modpath .. "/api.lua")
dofile(modpath .. "/registration.lua")

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


