elevators = {}

elevators.get_formspec = function(floors_num)
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
    end
    
    


minetest.register_node("real_elevators:elevator_cabin", {
    visual_scale = 0.5, 
    drawtype = "mesh",
    mesh = "elevator_cabin.b3d"
    tiles = {},
    sunlight_propagates = true,
    node_box = {
        type = "fixed",
        fixed = {
            {-0.5, -0.5, -0.5, 0.5, -0.3, 0.5},     -- Bottom
            {-0.5, -0.3, -0.5, -0.3, 0.3, 0.5},     -- Left Side
            {0.3, -0.3, -0.5, 0.5, 0.3, 0.5},       -- Right Side
            {-0.5, 0.3, -0.5, 0.5, 0.5, 0.5}        -- Top
    },
    sounds = default.node_sound_metal_defaults()
})
