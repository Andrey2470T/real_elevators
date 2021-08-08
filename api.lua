elevators.trigger_states = {
	off = "elevator_outer_wall_with_trigger_off",
	on = "elevator_outer_wall_with_trigger_on"
}

elevators.doors_states = {
	closed = "elevator_doors_closed",
	open = "elevator_doors_opened"
}

-- Sets both door objects. It should be called when elevator cabin is instantiated and on activating the elevator.
-- Params:
-- *pos* is position of a node where doors will be placed.
-- *z_shift* is shift number towards to the facedir of *pos*.
-- *x_shift* is shift relatively *pos*.
elevators.set_doors = function(pos, z_shift, x_shift)
	local node = minetest.get_node(pos)
	local dir = minetest.facedir_to_dir(node.param2)

	local y_angle = vector.dir_to_rotation(dir).y

	-- Set left door entity
	local left_door_movedir = vector.rotate_around_axis(dir, {x=0, y=1, z=0}, math.pi/2)
	local left_door_shift = vector.add(vector.multiply(left_door_movedir, x_shift), vector.multiply(dir, z_shift))
	local left_door_pos = vector.add(pos, left_door_shift)
	local left_door = minetest.add_entity(left_door_pos, "real_elevators:elevator_door_moving")
	left_door:set_rotation({x=0, y=y_angle, z=0})

	-- Set right door entity
	local right_door_movedir = vector.rotate_around_axis(dir, {x=0, y=1, z=0}, -math.pi/2)
	local right_door_shift = vector.add(vector.multiply(right_door_movedir, x_shift), vector.multiply(dir, z_shift))
	local right_door_pos = vector.add(pos, right_door_shift)
	local right_door = minetest.add_entity(right_door_pos, "real_elevators:elevator_door_moving")
	right_door:set_rotation({x=0, y=y_angle+math.pi, z=0})

	return left_door, right_door
end

-- Opens/closes both door objects. Called when the elevator is activated.
-- Params:
-- *left_door* is left door object.
-- *right_door* is right door object.
-- *facedir* is direction relatively which those doors will be moving away from each other.
-- *action* maybe "open" or "close".
elevators.move_doors = function(left_door, right_door, facedir, action)
	local left_dir = vector.rotate_around_axis(facedir, {x=0, y=1, z=0}, math.pi/2)
	local right_dir = vector.rotate_around_axis(facedir, {x=0, y=1, z=0}, -math.pi/2)

	local left_door_mvdir
	local right_door_mvdir

	if action == "open" then
		left_door_mvdir = left_dir
		right_door_mvdir = right_dir
	elseif action == "close" then
		left_door_mvdir = right_dir
		right_door_mvdir = left_dir
	else
		return
	end

	local left_door_entity = left_door:get_luaentity()
	left_door_entity.end_pos = vector.add(left_door:get_pos(), vector.multiply(left_door_mvdir, 0.5))
	left_door_entity.vel = vector.multiply(left_door_mvdir, 0.25)
	left_door:set_velocity(left_door_entity.vel)

	local right_door_entity = right_door:get_luaentity()
	right_door_entity.end_pos = vector.add(right_door:get_pos(), vector.multiply(right_door_mvdir, 0.5))
	right_door_entity.vel = vector.multiply(right_door_mvdir, 0.25)
	right_door:set_velocity(right_door_entity.vel)
end

-- Recursive function. Returns nil if the movement was implemented.
local function wait_for_moving(left_door_outer, right_door_outer, left_door_inner, right_door_inner, replace_pos, replace_to)
	local left_door_outer_entity = left_door_outer:get_luaentity()
	local right_door_outer_entity = right_door_outer:get_luaentity()
	local left_door_inner_entity = left_door_inner:get_luaentity()
	local right_door_inner_entity = right_door_inner:get_luaentity()
	if not left_door_outer_entity.end_pos and
		not right_door_outer_entity.end_pos and
		not left_door_inner_entity.end_pos and
		not right_door_inner_entity.end_pos then

		left_door_outer:remove()
		right_door_outer:remove()

		minetest.set_node(replace_pos, {name=replace_to, param2=minetest.get_node(replace_pos).param2})

		return
	end

	minetest.after(0.05, wait_for_moving, left_door_outer, right_door_outer, left_door_inner, right_door_inner, replace_pos, replace_to)
end

-- Activates the elevator. *trigger_pos* is position of trigger node attached to the given elevator.
elevators.activate = function(trigger_pos)
	local node = minetest.get_node(trigger_pos)

	local is_trigger = minetest.get_item_group(node.name, "trigger")
	local is_on = minetest.get_item_group(node.name, "state")

	if is_trigger == 0 then
		return false
	else
		if is_on == 1 then
			return false
		end
	end

	local dir = minetest.facedir_to_dir(node.param2)
	local right_closest_node_pos = vector.add(trigger_pos, vector.add(vector.rotate_around_axis(dir, {x=0, y=1, z=0}, -math.pi/2), {x=0, y=-1, z=0}))
	local right_closest_node = minetest.get_node(right_closest_node_pos)

	local is_doors = minetest.get_item_group(right_closest_node.name, "doors")
	is_off = minetest.get_item_group(right_closest_node.name, "state")

	if is_doors == 0 then
		return false
	else
		if is_off == 1 then
			return false
		end
	end

	local cabin_pos = vector.add(right_closest_node_pos, dir)
	local cabin = minetest.get_node(cabin_pos)
	minetest.debug("Node name: " .. cabin.name)
	local is_cabin = minetest.get_item_group(cabin.name, "cabin")

	minetest.debug("Start...")
	if is_cabin == 0 then
		return false
	end
	minetest.debug("This is a cabin, continue...")
	local cabin_str_pos = vector.to_string(cabin_pos)

	if not elevators.elevator_doors[cabin_str_pos] then
		return false
	end
	minetest.debug("This cabin has both door objects, continue...")
	minetest.set_node(trigger_pos, {name="real_elevators:" .. elevators.trigger_states.on, param2 = node.param2})
	minetest.remove_node(right_closest_node_pos)

	local left_door_outer, right_door_outer = elevators.set_doors(right_closest_node_pos, 0.5, 0.25)
	elevators.move_doors(left_door_outer, right_door_outer, dir, "open")

	local left_door_inner = elevators.elevator_doors[cabin_str_pos][1]
	local right_door_inner = elevators.elevator_doors[cabin_str_pos][2]
	elevators.move_doors(left_door_inner, right_door_inner, dir, "open")

	minetest.after(0.05, wait_for_moving, left_door_outer, right_door_outer, left_door_inner, right_door_inner, right_closest_node_pos, "real_elevators:" .. elevators.doors_states.open)
	return true
end

elevators.deactivate = function(trigger_pos)
	local node = minetest.get_node(trigger_pos)

	local is_trigger = minetest.get_item_group(node.name, "trigger")
	local is_on = minetest.get_item_group(node.name, "state")

	if is_trigger == 0 then
		return false
	else
		if is_on == 0 then
			return false
		end
	end

	local dir = minetest.facedir_to_dir(node.param2)
	local right_closest_node_pos = vector.add(trigger_pos, vector.add(vector.rotate_around_axis(dir, {x=0, y=1, z=0}, -math.pi/2), {x=0, y=-1, z=0}))
	local right_closest_node = minetest.get_node(right_closest_node_pos)

	local is_doors = minetest.get_item_group(right_closest_node.name, "doors")
	is_off = minetest.get_item_group(right_closest_node.name, "state")

	if is_doors == 0 then
		return false
	else
		if is_off == 0 then
			return false
		end
	end

	local cabin_pos = vector.add(right_closest_node_pos, dir)
	local cabin = minetest.get_node(cabin_pos)
	minetest.debug("Node name: " .. cabin.name)
	local is_cabin = minetest.get_item_group(cabin.name, "cabin")

	minetest.debug("Start...")
	if is_cabin == 0 then
		return false
	end
	minetest.debug("This is a cabin, continue...")
	local cabin_str_pos = vector.to_string(cabin_pos)

	if not elevators.elevator_doors[cabin_str_pos] then
		return false
	end

	minetest.set_node(trigger_pos, {name="real_elevators:" .. elevators.trigger_states.off, param2 = node.param2})
	minetest.remove_node(right_closest_node_pos)

	local left_door_outer, right_door_outer = elevators.set_doors(right_closest_node_pos, 0.5, 0.75)
	elevators.move_doors(left_door_outer, right_door_outer, dir, "close")

	local left_door_inner = elevators.elevator_doors[cabin_str_pos][1]
	local right_door_inner = elevators.elevator_doors[cabin_str_pos][2]
	elevators.move_doors(left_door_inner, right_door_inner, dir, "close")

	minetest.after(0.05, wait_for_moving, left_door_outer, right_door_outer, left_door_inner, right_door_inner, right_closest_node_pos, "real_elevators:" .. elevators.doors_states.closed)
	return true
end
