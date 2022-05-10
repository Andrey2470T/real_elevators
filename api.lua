-- REAL ELEVATORS API
-- ============================================================================


elevators.trigger_states = {
	off = "elevator_outer_wall_with_trigger_off",
	on = "elevator_outer_wall_with_trigger_on"
}

elevators.doors_states = {
	closed = "elevator_doors_closed",
	open = "elevator_doors_opened"
}

elevators.current_marked_pos = minetest.deserialize(elevators.mod_storage:get_string("current_marked_pos"))
elevators.elevators_nets = minetest.deserialize(elevators.mod_storage:get_string("elevators_nets")) or {}

-- Temporary savings of the cabin formspec context. It is used for receiving an input info only after an event is triggered, then deleted.
elevators.cab_fs_contexts = {}

minetest.debug("Loading mod...")
minetest.debug("elevators.elevators_nets: " .. dump(elevators.elevators_nets))
--minetest.debug("elevators.elevators_nets: " .. dump(elevators.elevators_nets))


-- 'elevators' global table contains:

-- 'current_marked_pos' saves current selected position by 'floor_mark_tool' that can be used to create a new floor destination for an elevator net
-- 'elevators_nets' is table with data about each elevator net, it contains:
--		'floors' is table containing data about each floor (number of floor, description, position)
--		'cabin' is table containing data about the cabin in this net:
--			'position' is temporary position table, it is initialized when a cabin is just set, not a node and doesn't locate on any floor
--			'cur_elevator_position_index' contains index of floor inside 'floors' table where the elevator cabin is locating currently (in state of a node)
--			'elevator_object' is object of elevator cabin (present when its state is 'active')
--			'inner_doors' is table containing inner left and right door objects.
--			'queue' is table with positions in 'floors' table, where the elevator was called. It must arrive them in certain order (from position with index 1 to #queue)
--			'attached_objs' is table containing attached objects (including players) that want to transmit themselves to target floor.
--			'last_light_pos' is position of a light that the elevator cabin is emitting when it is switched on inside.
--		'outer_doors' is table containing outer left and right door objects (present when cabin state is 'opening'/'closing'). As per each elevator net, the only outer doors on some floor can be currently open, it is pointless to save it in 'floors' inside the floor.
-- the table is indexed with elevator net name strings
-- net name is saved in 'elevator_net_name' metadata field


-- Elevator cabin can have 5 states: 'idle', 'active', 'opening', 'closing', 'pending' and 'broken'
-- 'idle' - doors are closed and cabin is static
-- 'active' - doors are closed and cabin is moving (upwards or downwards)
-- 'opening' - doors are opening
-- 'closing' - doors are closing
-- 'pending' - doors are open and the elevator is waiting for coming objects for 10 seconds (can be configured in settings)
-- 'broken'  - elevator is not callable, it doesn`t move to floors and doesn`t open/close doors. It happens when any inner door is absent. The only way to fix it is to reset the elevator and its whole net.

-- Elevator state is saved in 'state' its metadata field


-- Returns true if 'player' is online, otherwise false.
elevators.is_player_online = function(player)
	if not player:is_player() then
		return
	end

	for i, obj in ipairs(minetest.get_connected_players()) do
		if obj == player then
			return true
		end
	end

	return false
end
-- Sets an only door object (left or right). It should be called when elevator cabin is instantiated and on activating the elevator.
-- Params:
-- *pos* is position of a node where the door will be placed.
-- *z_shift* is shift number towards to the facedir of *pos*.
-- *x_shift* is shift relatively *pos*.
elevators.set_door = function(pos, dir, z_shift, x_shift, is_left)
	-- Set left door entity
	local sign = is_left and 1 or -1
	local door_movedir = vector.rotate_around_axis(dir, {x=0, y=1, z=0}, sign*math.pi/2)
	local door_shift = vector.add(vector.multiply(door_movedir, x_shift), vector.multiply(dir, z_shift))
	local door_pos = vector.add(pos, door_shift)
	local door = minetest.add_entity(door_pos, "real_elevators:elevator_door_moving")
	elevators.rotate_door(door, vector.multiply(dir, -1))

	return door
end

-- Sets cabin object. It should be called when state is "active" to convert node to entity and also when it is falling down.
-- Params:
-- *pos* is position of cabin node.
-- *dir* is face direction of that node.
elevators.set_cabin = function(pos, dir)
	local cabin = minetest.add_entity(pos, "real_elevators:elevator_cabin_activated")
	cabin:set_rotation({x=0, y=vector.dir_to_rotation(dir).y, z=0})

	return cabin
end

-- Rotates door object around Y axis by angle enclosed between '{x=0, y=0, z=1}' and 'dir' vectors. Those vectors must be mutually-perpendicular! Except mesh, it rotates also its collision & selection boxes.
-- Params:
-- *door* is ObjectRef of door.
-- *dir* is target direction.
elevators.rotate_door = function(door, dir)
	local yaw = vector.dir_to_rotation(dir).y
	door:set_rotation({x=0, y=yaw, z=0})

	local collbox = door:get_properties().collisionbox
	local box = {
		[1] = {x=collbox[1], y=collbox[2], z=collbox[3]},
		[2] = {x=collbox[4], y=collbox[5], z=collbox[6]}
	}

	box[1] = vector.rotate_around_axis(box[1], {x=0, y=1, z=0}, yaw)
	box[2] = vector.rotate_around_axis(box[2], {x=0, y=1, z=0}, yaw)

	door:set_properties({
		collisionbox = {box[1].x, box[1].y, box[1].z, box[2].x, box[2].y, box[2].z},
		selectionbox = {box[1].x, box[1].y, box[1].z, box[2].x, box[2].y, box[2].z}
	})
end


-- Opens/closes both door objects.
-- Params:
-- *net_name* is name of elevator net whose elevator cabin should open/close its doors.
-- *action* is action: "open"/"close"
elevators.move_doors = function(net_name, action)
	local net = elevators.elevators_nets[net_name]
	if not net then
		return false
	end
	--minetest.debug("move_doors (1)")

	local door_states = elevators.check_for_doors(net_name)
	--minetest.debug("door_states: " .. dump(door_states))
	if door_states.inner == "absent" then
		net.cabin.state = "idle"
		return false
	elseif door_states.inner == "unloaded" then
		return false
	end
	--minetest.debug("move_doors (2)")
	if door_states.outer == "absent" then
		net.cabin.state = "idle"
		return false
	elseif door_states.outer == "unloaded" then
		return false
	end
	--minetest.debug("move_doors (3)")
	local cabin_pos = net.floors[net.cabin.cur_elevator_position_index].position
	local cabin = minetest.get_node(cabin_pos)
	local cabin_dir = minetest.facedir_to_dir(cabin.param2)
	local doors_pos = vector.add(cabin_pos, vector.multiply(cabin_dir, -1))

	local sign = action == "open" and 1 or -1
	local left_dir = vector.rotate_around_axis(cabin_dir, {x=0, y=1, z=0}, sign*math.pi/2)
	local right_dir = vector.multiply(left_dir, -1)

	local left_door_entity = net.cabin.inner_doors.left:get_luaentity()
	left_door_entity.end_pos = vector.add(net.cabin.inner_doors.left:get_pos(), vector.multiply(left_dir, 0.5))
	left_door_entity.vel = vector.new(left_dir) * elevators.settings.DOORS_VELOCITY
	net.cabin.inner_doors.left:set_velocity(left_door_entity.vel)

	local right_door_entity = net.cabin.inner_doors.right:get_luaentity()
	right_door_entity.end_pos = vector.add(net.cabin.inner_doors.right:get_pos(), vector.multiply(right_dir, 0.5))
	right_door_entity.vel = vector.new(right_dir) * elevators.settings.DOORS_VELOCITY
	net.cabin.inner_doors.right:set_velocity(right_door_entity.vel)

	minetest.remove_node(doors_pos)
	local x_shift = action == "close" and 0.75 or 0.25
	local outer_left_door = elevators.set_door(doors_pos, cabin_dir, 0.45, x_shift, true)
	local outer_right_door = elevators.set_door(doors_pos, cabin_dir, 0.45, x_shift, false)

	net.outer_doors = {left = outer_left_door, right = outer_right_door}
	local outer_ldoor_entity = net.outer_doors.left:get_luaentity()
	outer_ldoor_entity.end_pos = vector.add(net.outer_doors.left:get_pos(), vector.multiply(left_dir, 0.5))
	outer_ldoor_entity.vel = vector.new(left_dir) * elevators.settings.DOORS_VELOCITY
	net.outer_doors.left:set_velocity(outer_ldoor_entity.vel)

	local outer_rdoor_entity = net.outer_doors.right:get_luaentity()
	outer_rdoor_entity.end_pos = vector.add(net.outer_doors.right:get_pos(), vector.multiply(right_dir, 0.5))
	outer_rdoor_entity.vel = vector.new(right_dir) * elevators.settings.DOORS_VELOCITY
	net.outer_doors.right:set_velocity(outer_rdoor_entity.vel)

	net.cabin.state = action == "open" and "opening" or "closing"

	return true
end


-- Cause to call the elevator. It just adds to the queue of calls.
-- In order to call, it checks if the elevator is not called yet and outer doors locate to the left of the trigger and they are closed, otherwise returns false. Returns true on success.
-- Params:
-- *trigger_pos* is positon of trigger.
elevators.call = function(trigger_pos)
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

	local doors_pos = elevators.get_doors_pos_from_trigger_pos(trigger_pos)
	local doors = minetest.get_node(doors_pos)

	local is_doors = minetest.get_item_group(doors.name, "doors")
	local is_off = minetest.get_item_group(doors.name, "state")

	if is_doors == 0 then
		return false
	else
		if is_off == 1 then
			return false
		end
	end

	local target_pos = vector.add(doors_pos, minetest.facedir_to_dir(doors.param2))
	local net_name, floor_i = elevators.get_net_name_and_floor_index_from_floor_pos(target_pos)

	if not net_name or not floor_i then
		return false
	end

	minetest.set_node(trigger_pos, {name="real_elevators:" .. elevators.trigger_states.on, param2 = node.param2})

	-- Add to the end of the queue the floor destination position
	elevators.elevators_nets[net_name].cabin.queue[#elevators.elevators_nets[net_name].cabin.queue+1] = target_pos

	return true
end

-- Returns net name and index of floor in 'elevators.elevators_nets[floor_i].floors' table with position 'pos'.
-- Params:
-- *pos* is position of floor.
elevators.get_net_name_and_floor_index_from_floor_pos = function(pos)
	for name, data in pairs(elevators.elevators_nets) do
		for i, floor in ipairs(data.floors) do
			if vector.equals(pos, floor.position) then
				return name, i
			end
		end
	end

	return
end

-- Returns name of the net which the cabin with 'pos' position belongs to.
-- Params:
-- *pos* is cabin position
elevators.get_net_name_from_cabin_pos = function(pos)
	for name, data in pairs(elevators.elevators_nets) do
		local cabin_pos = elevators.get_cabin_pos_from_net_name(name)
		if cabin_pos and vector.equals(pos, cabin_pos) then
			return name
		end
	end

	return
end

-- Returns the current position of the cabin of the net with 'net_name' name.
-- Params:
-- *net_name* is net name
elevators.get_cabin_pos_from_net_name = function(net_name)
	local net = elevators.elevators_nets[net_name]

	local pos
	if net.cabin.cur_elevator_position_index then
		pos = net.floors[net.cabin.cur_elevator_position_index].position
	elseif net.cabin.elevator_object then
		if type(net.cabin.elevator_object) == "userdata" then
			pos = elevators.get_centre_y_pos_from_node_pos(net.cabin.elevator_object:get_pos())
		elseif type(net.cabin.elevator_object) == "table" then
			pos = elevators.get_centre_y_pos_from_node_pos(net.cabin.elevator_object)
		end
	elseif net.cabin.position then
		pos = net.cabin.position
	end

	return {x=pos.x, y=pos.y, z=pos.z}
end

elevators.get_trigger_pos = function(cabin_pos, dir)
	local up = vector.new(0, 1, 0)
	local fwd = vector.multiply(dir, -1)
	local right = vector.rotate_around_axis(dir, vector.new(0, 1, 0), math.pi/2)
	local shift = vector.add(vector.add(right, up), fwd)

	return vector.add(cabin_pos, shift)
end

elevators.get_doors_pos_from_trigger_pos = function(trigger_pos)
	local dir = minetest.facedir_to_dir(minetest.get_node(trigger_pos).param2)
	local right_down_shift = vector.add(vector.rotate_around_axis(dir, {x=0, y=1, z=0}, -math.pi/2), {x=0, y=-1, z=0})
	local right_closest_node_pos = vector.add(trigger_pos, right_down_shift)

	return right_closest_node_pos
end

elevators.get_doors_pos_from_cabin_pos = function(cabin_pos)
	local to_doors = vector.multiply(minetest.facedir_to_dir(minetest.get_node(cabin_pos).param2), -1)
	local outer_doors_pos = vector.add(cabin_pos, to_doors)

	return outer_doors_pos
end
-- Converts the elevator cabin from node state to entity doing it 'active' and makes to move smoothly to the destination floor position.
-- Params:
-- *net_name* is name of net.
-- *target_pos* is target position of arrival.
elevators.activate = function(net_name, target_pos)
	local net = elevators.elevators_nets[net_name]

	if not net then
		return false
	end

	if net.cabin.elevator_object then
		-- The elevator is already activated, so just pending for arrival
		return false
	end

	local pos = elevators.get_cabin_pos_from_net_name(net_name)

	if not pos then
		return false
	end

	if net.cabin.state ~= "idle" then
		-- It means, whether the elevator is currently opening/closing or pending for objects and so can`t move
		return false
	end

	local dir = minetest.facedir_to_dir(minetest.get_node(pos).param2)
	local is_ldoor_inner, is_rdoor_inner = net.cabin.inner_doors.left:get_luaentity(), net.cabin.inner_doors.right:get_luaentity()
	minetest.remove_node(pos)
	local cabin_obj = elevators.set_cabin(pos, dir)

	local self = cabin_obj:get_luaentity()
	self.elevator_net_name = net_name

	if is_ldoor_inner then
		local left_door = elevators.set_door(pos, {x=0, y=0, z=1}, -0.45, 0.25, true)
		left_door:set_attach(cabin_obj, "", vector.multiply(vector.subtract(left_door:get_pos(), pos), 10))
		net.cabin.inner_doors.left = left_door
	end
	if is_rdoor_inner then
		local right_door = elevators.set_door(pos, {x=0, y=0, z=1}, -0.45, 0.25, false)
		right_door:set_attach(cabin_obj, "", vector.multiply(vector.subtract(right_door:get_pos(), pos), 10))
		net.cabin.inner_doors.right = right_door
	end

	net.cabin.position = nil
	net.cabin.cur_elevator_position_index = nil
	self.end_pos = target_pos
	net.cabin.elevator_object = cabin_obj
	net.cabin.state = "active"
	self.dir = dir

	net.cabin.attached_objs = {}

	local objs = minetest.get_objects_in_area(vector.add(pos, vector.new(-0.5, -0.5, -0.5)), vector.add(pos, vector.new(0.5, 1.5, 0.5)))

	for i, obj in ipairs(objs) do
		local allow_attach = false
		if obj:is_player() then
			allow_attach = true
			obj:get_meta():set_string("attached_cabin_elevator_name", net_name)
		else
			local self = obj:get_luaentity()
			if self.name ~= "real_elevators:elevator_cabin_activated" and self.name ~= "real_elevators:elevator_door_moving" then
				allow_attach = true
			end
		end
		if allow_attach then
			obj:set_attach(cabin_obj, "", vector.multiply(vector.subtract(obj:get_pos(), pos), 10))

			if obj:is_player() then
				local eye_offset = obj:get_eye_offset()
				obj:set_eye_offset({x=eye_offset.x, y=eye_offset.y-0.5*10, z=eye_offset.z})
			end
			net.cabin.attached_objs[#net.cabin.attached_objs+1] = obj
		end
	end

	cabin_obj:set_velocity(vector.direction(pos, self.end_pos) * elevators.settings.CABIN_VELOCITY)
	elevators.elevators_nets[net_name] = net
	return true
end

-- Converts the elevator cabin from entity state to node doing it "opening" (not "idle" !) and makes to open doors
-- Params:
-- *net_name* is name of net.
elevators.deactivate = function(net_name, move_doors)
	local net = elevators.elevators_nets[net_name]

	if not net then
		return false
	end

	if not net.cabin.elevator_object then
		return false
	end

	local pos = elevators.get_centre_y_pos_from_node_pos(net.cabin.elevator_object:get_pos())
	local dir = net.cabin.elevator_object:get_luaentity().dir
	local net_name = net.cabin.elevator_object:get_luaentity().elevator_net_name
	local _, floor_i = elevators.get_net_name_and_floor_index_from_floor_pos(pos)

	local is_ldoor_inner, is_rdoor_inner = net.cabin.inner_doors.left:get_luaentity(), net.cabin.inner_doors.right:get_luaentity()
	net.cabin.elevator_object:remove()
	minetest.set_node(pos, {name = "real_elevators:elevator_cabin", param2 = minetest.dir_to_facedir(dir)})
	--elevators.elevators_nets[net_name] = net
	--local _, floor_i = elevators.get_net_name_and_floor_index_from_floor_pos(pos)

	if floor_i then
		net.cabin.cur_elevator_position_index = floor_i
	else
		net.cabin.position = pos
	end
	net.cabin.elevator_object = nil
	--net.cabin.attached_objs = {}
	--minetest.set_node(pos, {name = "real_elevators:elevator_cabin", param2 = minetest.dir_to_facedir(dir)})

	if is_ldoor_inner then
		local left_door = elevators.set_door(pos, dir, -0.45, 0.25, true)
		net.cabin.inner_doors.left = left_door
	end
	if is_rdoor_inner then
		local right_door = elevators.set_door(pos, dir, -0.45, 0.25, false)
		net.cabin.inner_doors.right = right_door
	end
	table.remove(net.cabin.queue, 1)

	elevators.elevators_nets[net_name] = net
	local trigger_pos = elevators.get_trigger_pos(pos, dir)
	local trigger = minetest.get_node(trigger_pos)
	local is_trigger = minetest.get_item_group(trigger.name, "trigger")
	if is_trigger == 1 then
		minetest.set_node(trigger_pos, {name = "real_elevators:" .. elevators.trigger_states.off, param2 = trigger.param2})
	end
	if move_doors then
		elevators.move_doors(net_name, "open")
	else
		net.cabin.state = "idle"
	end

	return true
end

elevators.get_centre_y_pos_from_node_pos = function(pos)
	local p = {x=pos.x, y=pos.y, z=pos.z}
	p.y = math.modf(p.y)

	return p
end

-- Checks for availability of surrounding shaft nodes (having 'shaft=1' group) and also checks for their proper orientation (should face towards to the cabin). Returns true if success, otherwise false.
-- Params:
-- *pos* is position of cabin.
-- *surrounded_node_dir* is cabin node direction.
-- *placer* is PlayerRef. If not nil, send chat messages to that player about failure reasons.
elevators.check_for_surrounding_shaft_nodes = function(pos, surrounded_node_dir, playername)
	local left_dir = vector.rotate_around_axis(surrounded_node_dir, {x=0, y=1, z=0}, math.pi/2)
	local right_dir = vector.rotate_around_axis(surrounded_node_dir, {x=0, y=1, z=0}, -math.pi/2)

	local surround_nodes_positions = {
		vector.add(pos, left_dir),												-- Left pos
		vector.add(pos, right_dir),												-- Right pos
		vector.add(pos, surrounded_node_dir),									-- Back pos
		vector.add(pos, vector.add(left_dir, vector.new(0, 1, 0))),				-- Left upper pos
		vector.add(pos, vector.add(right_dir, vector.new(0, 1, 0))),			-- Right upper pos
		vector.add(pos, vector.add(surrounded_node_dir, vector.new(0, 1, 0)))	-- Back upper pos
	}

	for i, p in ipairs(surround_nodes_positions) do
		local shaft = minetest.get_node(p)
		local is_shaft = minetest.get_item_group(shaft.name, "shaft")

		if is_shaft == 0 then
			if playername then
				minetest.chat_send_player(playername, "The elevator cabin can not be outside of the shaft!")
			end
			return false
		end

		local shaft_dir = minetest.facedir_to_dir(shaft.param2)
		local shaft_rel_pos = vector.subtract(p, pos)
		local right_dir = vector.cross(vector.new(0, 1, 0), vector.normalize(shaft_rel_pos))
		local horiz_shaft_rel_pos = vector.round(vector.normalize(vector.rotate_around_axis(shaft_rel_pos, right_dir, -vector.dir_to_rotation(shaft_rel_pos).x)))

		if not vector.equals(shaft_dir, horiz_shaft_rel_pos) then
			if playername then
				minetest.chat_send_player(playername, "The elevator cabin can not be outside of the shaft!")
			end
			return false
		end
	end

	if playername then
		local up_node = minetest.get_node(vector.add(pos, vector.new(0, 1, 0)))

		if up_node.name ~= "air" then
			minetest.chat_send_player(playername, "There is no space for placing/moving the elevator cabin!")
			return false
		end
	end

	return true
end

-- Checks for rope continuity and winch availability. Returns true if success, otherwise false and reason: '1' is rope is intercepted, '2' is rope is too long. In both cases sends message to player with 'playername'
-- Params:
-- *pos* is position of cabin.
-- *playername* is name of player to send message about failure.
elevators.check_for_rope = function(pos, playername)
	--minetest.debug("cabin position: " .. minetest.pos_to_string(pos))
	--minetest.debug("cabin: " .. minetest.get_node(pos).name)
	if not pos then
		return false
	end
	local rope_pos = {x=pos.x, y=pos.y+2, z=pos.z}

	for n = 1, elevators.settings.MAX_ROPE_LENGTH do
		local node = minetest.get_node(rope_pos)
		if node.name == "real_elevators:elevator_winch" or node.name == "ignore" then
			return true
		elseif node.name ~= "real_elevators:elevator_rope" then
			--minetest.debug("The interception is at " .. minetest.pos_to_string(rope_pos) .. " position")
			--minetest.debug("The node at the interception pos: " .. dump({name = node.name, dir = minetest.facedir_to_dir(node.param2)}))
			if playername then
				minetest.chat_send_player(playername, "The rope is intercepted!")
			end
			--minetest.chat_send_player(playername, "The rope is intercepted!")
			return false, 1, rope_pos
		end

		rope_pos = {x=rope_pos.x, y=rope_pos.y+1, z=rope_pos.z}
	end

	if playername then
		minetest.chat_send_player(playername, "The rope is too long!")
	end
	--minetest.chat_send_player(playername, "The rope is too long!")
	return false, 2
end

-- Checks for doors availability of cabin with 'net_name' net name.
-- It returns table with next fields:
-- ["outer"] = ("success", "absent", "unloaded")
-- ["inner"] = ("success", "absent", "unloaded")
elevators.check_for_doors = function(net_name)
	local net = elevators.elevators_nets[net_name]
	--minetest.debug("check_for_doors()")
	if not net then
		return
	end

	local states = {outer="absent", inner="absent"}

	if type(net.cabin.inner_doors.left) == "userdata" and type(net.cabin.inner_doors.right) == "userdata" then
		--minetest.debug("check_for_doors(1)")
		local inner_left_door_self = net.cabin.inner_doors.left:get_luaentity()
		local inner_right_door_self = net.cabin.inner_doors.right:get_luaentity()

		if inner_left_door_self and inner_right_door_self then
			--minetest.debug("check_for_doors(2)")
			states.inner = "success"
		end
	elseif type(net.cabin.inner_doors.left) == "table" or type(net.cabin.inner_doors.right) == "table" then
		states.inner = "unloaded"
	end
	--minetest.debug("state: " .. net.cabin.state)
	if net.cabin.state == "opening" or net.cabin.state == "closing" then
		if net.outer_doors then
			if type(net.outer_doors.left) == "userdata" and type(net.outer_doors.right) == "userdata" then
				local outer_left_door_self = net.outer_doors.left:get_luaentity()
				local outer_right_door_self = net.outer_doors.right:get_luaentity()

				if outer_left_door_self and outer_right_door_self then
					states.outer = "success"
				end
			elseif type(net.outer_doors.left) == "table" or type(net.outer_doors.right) == "table" then
				states.outer = "unloaded"
			end
		end
	else
		local cabin_pos = elevators.get_cabin_pos_from_net_name(net_name)
		local outer_doors = minetest.get_node(elevators.get_doors_pos_from_cabin_pos(cabin_pos))

		if minetest.get_item_group(outer_doors.name, "doors") == 1 then
			states.outer = "success"
		end
	end

	return states
end

elevators.check_for_owner = function(net_name, playername)
	local owner = elevators.elevators_nets[net_name].owner

	if owner ~= playername then
		minetest.chat_send_player(playername, "You can not edit the elevator net because you are not an owner of that!")
		return false
	end

	return true
end


-- Formspec
-- ============================================================================

-- Shows the current formspec for the player with "playername" name. If the context is not set for him or no the context of the cabin, then create it.
elevators.show_formspec = function(net_name, playername)
	local pl_context = elevators.cab_fs_contexts[playername]

	if not pl_context then
		elevators.cab_fs_contexts[playername] = {}
		pl_context = elevators.cab_fs_contexts[playername]
	end

	local fs
	local fs_name
	if not pl_context[net_name] then
		if #elevators.elevators_nets[net_name].floors == 0 then
			fs = elevators.get_add_floor_formspec()
			fs_name = "real_elevators:add_floor"
		else
			fs = elevators.get_floor_list_formspec(net_name)
			fs_name = "real_elevators:floors_list"
		end
		pl_context[net_name] = {
			cur_formspec_name = fs_name,
			cur_formspec_str = fs,
			sel_floors_ind = {}
		}
	else
		fs_name = pl_context[net_name].cur_formspec_name
		fs = pl_context[net_name].cur_formspec_str
	end
	-- Formspec of which elevator net is currently opened?
	pl_context.cur_opened_fs_el_net = net_name
	minetest.show_formspec(playername, fs_name, fs)
end

-- Switches the current formspec of the player to other with "fs_name" name. Also it is used to update the form of the current formspec.
elevators.switch_formspec = function(net_name, playername, fs, fs_name)
	local net_context = elevators.cab_fs_contexts[playername][net_name]

	net_context.cur_formspec_name = "real_elevators:" .. fs_name
	net_context.cur_formspec_str = fs
end

-- Updates the same opened formspecs for each player. If "is_close" == true, it closes opened forms of each player.
-- When necessary to update: adding/deleting floor in the floors list, probably in some other cases.
elevators.update_formspec_to_all_viewers = function(net_name, fs, fs_name, is_close)
	for pl_name, context in pairs(elevators.cab_fs_contexts) do
		if context.cur_opened_fs_el_net == net_name then
			if is_close then
				minetest.show_formspec(pl_name, "", "")
				context.cur_opened_fs_el_net = ""
			else
				if context[net_name].cur_formspec_name == "real_elevators:floors_list" then
					elevators.switch_formspec(net_name, pl_name, fs, fs_name)
					elevators.show_formspec(net_name, pl_name)
				end
			end
		end
	end
end

-- Returns form of when player is needed to create new elevator net.
elevators.get_enter_elevator_net_name_formspec = function()
	local form = [[
		formspec_version[4]size[6,3]
		style_type[label;font=normal,bold]label[0.5,0.5;Enter name for new elevator net to create:]
		field[2,1;2,0.5;elevator_net_name;;]button[2,2;2,0.5;elevator_net_name_enter;Enter]
	]]

	return form
end

-- Returns form of when player wants to create new floor with defining number/description/position of that destination.
elevators.get_add_floor_formspec = function(number, description, position)
	number = number or 0
	description = description or ""
	local form = {
		"formspec_version[4]",
		"size[10,5]",
		"style_type[label;font=normal,bold;font_size=*1.5]",
		"label[1.5,0.5;Add new floor for the elevator net:]",
		("style_type[label;font_size=]field[0.5,2;1,1;floor_number;Number:;%s]"):format(tostring(number)),
		("field[2.5,2;3,1;floor_description;Description:;%s]field[6.5,2;2.5,1;floor_pos;Position:;"):format(description)
	}

	if not position then
		if elevators.current_marked_pos then
			table.insert(form, minetest.pos_to_string(elevators.current_marked_pos) .. "]")
		else
			table.insert(form, "]")
		end
	else
		table.insert(form, position .. "]")
	end

	table.insert(form, "image_button[0.5,3;0.5,0.5;real_elevators_floor_plus.png;floor_add;]")
	table.insert(form, "image_button[1,3;0.5,0.5;real_elevators_floor_minus.png;floor_reduce;]")
	table.insert(form, "button[1.75,3.5;2.5,1;set_floor;Set]")
	table.insert(form, "button[5.25,3.5;2.5,1;cancel_floor;Cancel]")

	return table.concat(form, "")
end

-- Returns form of list with all created floors. Allows to be teleported to anything of them on clicking the corresponding floor button.
elevators.get_floor_list_formspec = function(elevator_net_name)--, selected_floors)
	local form = {
		"formspec_version[4]",
		"size[5,9]",
		"style_type[label;font=normal,bond]",
		"label[1,0.5;Select a floor to lift to it:]",
		"style_type[box;bordercolors=dimgray]",
		"box[1.5,1;2,6;darkgray]"
	}

	if elevator_net_name == "" then
		return
	end

	local btns_space = 0.4
	local y_space = btns_space
	local button_size = 1
	local step_h = 0.1

	local floors = elevators.elevators_nets[elevator_net_name].floors
	local sc_h

	if #floors <= 4 then
		sc_h = 6
	else
		sc_h = btns_space * (#floors+1) + button_size * #floors
	end

	local steps_c = (sc_h - 6) / step_h
	table.insert(form, ("scrollbaroptions[min=0;max=%f;smallstep=%f;largestep=%f]"):format(steps_c, steps_c / 7, steps_c / 7))
	table.insert(form, "scrollbar[3.5,1;0.2,6;vertical;floor_list_scrollbar;]")
	table.insert(form, "scroll_container[1.5,1;2,6;floor_list_scrollbar;vertical;]")

	for i, floor in ipairs(floors) do
		local but_name = "floor_" .. tostring(i)
		local cb_name = "mark_for_del_" .. tostring(i)
		table.insert(form, ("checkbox[0.3,%f;%s;;false]"):format(y_space+0.5, cb_name))
		table.insert(form, ("button[0.7,%f;%f,%f;%s;%u]"):format(y_space, button_size, button_size, but_name, floor.number))
		table.insert(form, ("tooltip[%s;Floor #%u:%q.\nLocates at: %s]"):format(but_name, floor.number, floor.description, minetest.pos_to_string(floor.position)))

		y_space = y_space + (button_size + btns_space)
	end

	table.insert(form, "scroll_container_end[]")
	table.insert(form, "image_button[0.5,7.5;1,1;real_elevators_floor_plus.png;add_floor;]tooltip[add_floor;Add still floors]")
	table.insert(form, "image_button[2,7.5;1,1;real_elevators_delete_floor.png;delete_floor;]tooltip[delete_floor;Delete selected floors]")
	table.insert(form, "image_button[3.5,7.5;1,1;real_elevators_lightup_cabin.png;lightup_cabin;]tooltip[lightup_cabin;Toggle to light up/down the cabin]")

	return table.concat(form, "")
end


-- Callbacks
-- ============================================================================

-- Global step. Passed in 'minetest.register_globalstep()'.
elevators.global_step = function(dtime)
	for name, data in pairs(elevators.elevators_nets) do
		local pos = elevators.get_cabin_pos_from_net_name(name)


		-- Update cabin light position if "is_light_on" == true
		local above_pos = {x=pos.x, y=pos.y+1, z=pos.z}
		local is_moving_or_light_on = data.cabin.last_light_pos and
				(not vector.equals(data.cabin.last_light_pos, above_pos) or not data.is_light_on)

		if is_moving_or_light_on and minetest.get_node(data.cabin.last_light_pos).name == "real_elevators:light" then
			minetest.remove_node(data.cabin.last_light_pos)
			data.cabin.last_light_pos = nil
		end

		if data.is_light_on then
			if minetest.get_node(above_pos).name == "air" then
				minetest.set_node(above_pos, {name="real_elevators:light"})
				data.cabin.last_light_pos = above_pos
			end
		end

		if data.cabin.state == "active" then

			-- Update rope
			if minetest.get_node(above_pos).name == "real_elevators:elevator_rope" then
				minetest.remove_node(above_pos)
			end

			local up_pos = {x=pos.x, y=pos.y+2, z=pos.z}
			if minetest.get_node(up_pos).name ~= "real_elevators:elevator_winch" then
				minetest.set_node(up_pos, {name="real_elevators:elevator_rope"})
			end
			local self = type(data.cabin.elevator_object) == "userdata" and data.cabin.elevator_object:get_luaentity()

			if self and not self.end_pos then
				-- The elevator has arrived!
				elevators.deactivate(name, self.status == "arrived")
			end
		elseif data.cabin.state == "opening" or data.cabin.state == "closing" then
			--minetest.debug("state: " .. data.cabin.state)
			local door_states = elevators.check_for_doors(name)
			if door_states.inner == "absent" or door_states.outer == "absent" then
				data.cabin.state = "idle"
			end
			if door_states.inner == "success" and door_states.outer == "success" then
				local inner_left_door_self = data.cabin.inner_doors.left:get_luaentity()
				local inner_right_door_self = data.cabin.inner_doors.right:get_luaentity()
				local outer_left_door_self = data.outer_doors.left:get_luaentity()
				local outer_right_door_self = data.outer_doors.right:get_luaentity()
				if not inner_left_door_self.end_pos and not inner_right_door_self.end_pos and
					not outer_left_door_self.end_pos and not outer_right_door_self.end_pos then
					local pos = data.floors[data.cabin.cur_elevator_position_index].position
					--minetest.debug("Doors are open/closed")
					local doors_pos = vector.add(pos, vector.multiply(minetest.facedir_to_dir(minetest.get_node(pos).param2), -1))
					if data.cabin.state == "opening" then
						--minetest.debug("Pending for objects")
						data.cabin.state = "pending"
						minetest.set_node(doors_pos, {name = "real_elevators:" .. elevators.doors_states.open, param2 = minetest.get_node(pos).param2})
						local timer = minetest.get_node_timer(pos)
						timer:start(elevators.settings.PENDING_TIME)
					else
							--minetest.debug("Setting inactive")
						data.cabin.state = "idle"
							minetest.set_node(doors_pos, {name = "real_elevators:" .. elevators.doors_states.closed, param2 = minetest.get_node(pos).param2})
					end

					data.outer_doors.left:remove()
					data.outer_doors.right:remove()
					data.outer_doors = nil
				end
			end
		elseif data.cabin.state == "idle" then
			if #data.cabin.queue > 0 then
				elevators.activate(name, data.cabin.queue[1])
			end
		end

		-- Check for the integrity of the rope
		local is_rope, state = elevators.check_for_rope(pos)

		if not is_rope then
			if state == 1 then
				--minetest.debug("Cabin is falling down!")
				local dir
				-- The rope is intercepted, it can not move anymore, so remove its data from 'elevators.elevators_nets' and makes to fall down.
				if type(data.cabin.elevator_object) == "userdata" then
					--minetest.debug("data.cabin.elevator_object: " .. dump(data.cabin.elevator_object))
					--minetest.debug("data.cabin.elevator_object:get_luaentity(): " .. dump(data.cabin.elevator_object:get_luaentity()))
					dir = data.cabin.elevator_object:get_luaentity().dir
					data.cabin.elevator_object:remove()
				elseif not data.cabin.elevator_object then
					dir = minetest.facedir_to_dir(minetest.get_node(pos).param2)
					minetest.remove_node(pos)
				end
				local falling_cabin = elevators.set_cabin(pos, dir)
				falling_cabin:set_acceleration({x=0, y=-elevators.settings.GRAVITY, z=0})
				falling_cabin:get_luaentity().status = "fallen"
			elseif state == 2 then
				--minetest.debug("Rope is too long!")
				if type(data.cabin.elevator_object) == "userdata" then
					local self = data.cabin.elevator_object:get_luaentity()
					self.end_pos = nil
					self.status = "stopped"
					elevators.deactivate(name, false)
				end
			end
		end
		--[[local pos = elevators.get_cabin_pos_from_net_name(name)
		local above_pos = {x=pos.x, y=pos.y+1, z=pos.z}
		--minetest.debug("data.cabin.last_light_pos: " .. (data.cabin.last_light_pos and minetest.pos_to_string(data.cabin.last_light_pos) or ""))
		--minetest.debug("above_pos: " .. (above_pos and minetest.pos_to_string(above_pos) or ""))
		--minetest.debug("data.is_light_on: " .. tostring(data.is_light_on))
		local is_moving_or_light_on = data.cabin.last_light_pos and
				(not vector.equals(data.cabin.last_light_pos, above_pos) or not data.is_light_on)
		--minetest.debug("last_light_pos: " .. minetest.pos_to_string(data.cabin.last_light_pos or {}))
		--minetest.debug("is_moving_or_light_on: " .. tostring(is_moving_or_light_on))
		if is_moving_or_light_on and minetest.get_node(data.cabin.last_light_pos).name == "real_elevators:light" then
			minetest.remove_node(data.cabin.last_light_pos)
			data.cabin.last_light_pos = nil
		end

		if data.is_light_on then
			if minetest.get_node(above_pos).name == "air" then
				minetest.set_node(above_pos, {name="real_elevators:light"})
				data.cabin.last_light_pos = above_pos
			end
		end

		if data.cabin.state == "active" then
			-- Update rope
			if minetest.get_node(above_pos).name == "real_elevators:elevator_rope" then
				minetest.remove_node(above_pos)
			end

			local up_pos = {x=pos.x, y=pos.y+2, z=pos.z}
			if minetest.get_node(up_pos).name ~= "real_elevators:elevator_winch" then
				minetest.set_node(up_pos, {name="real_elevators:elevator_rope"})
			end
		end

		local is_rope, state = elevators.check_for_rope(pos)

		if not is_rope then
			if state == 1 then
				--minetest.debug("Cabin is falling down!")
				local dir
				-- The rope is intercepted, it can not move anymore, so remove its data from 'elevators.elevators_nets' and makes to fall down.
				if type(data.cabin.elevator_object) == "userdata" then
					--minetest.debug("data.cabin.elevator_object: " .. dump(data.cabin.elevator_object))
					--minetest.debug("data.cabin.elevator_object:get_luaentity(): " .. dump(data.cabin.elevator_object:get_luaentity()))
					dir = data.cabin.elevator_object:get_luaentity().dir
					data.cabin.elevator_object:remove()
				elseif not data.cabin.elevator_object then
					dir = minetest.facedir_to_dir(minetest.get_node(pos).param2)
					minetest.remove_node(pos)
				end
				local falling_cabin = elevators.set_cabin(pos, dir)
				falling_cabin:set_acceleration({x=0, y=-elevators.settings.GRAVITY, z=0})
				falling_cabin:get_luaentity().status = "fallen"
			elseif state == 2 then
				--minetest.debug("Rope is too long!")
				if type(data.cabin.elevator_object) == "userdata" then
					local self = data.cabin.elevator_object:get_luaentity()
					self.end_pos = nil
					self.status = "stopped"
					elevators.deactivate(name, false)
				end
			end
		end]]
	end
end

-- Passed to 'minetest.register_on_shutdown()'.
elevators.on_shutdown = function()
	for name, net in pairs(elevators.elevators_nets) do

		-- Detach all lua-entities from each elevator cabin
		for i, obj in ipairs(net.cabin.attached_objs) do
			if not obj:is_player() then
				elevators.detach_obj_from_cabin(obj, name, i)
			end
		end
		net.cabin.elevator_object = type(net.cabin.elevator_object) == "userdata" and net.cabin.elevator_object:get_pos() or net.cabin.elevator_object

		net.cabin.inner_doors.left = type(net.cabin.inner_doors.left) == "userdata" and net.cabin.inner_doors.left:get_pos() or net.cabin.inner_doors.left
		net.cabin.inner_doors.right = type(net.cabin.inner_doors.right) == "userdata" and net.cabin.inner_doors.right:get_pos() or net.cabin.inner_doors.right

		if net.outer_doors then
			net.outer_doors.left = type(net.outer_doors.left) == "userdata" and net.outer_doors.left:get_pos() or net.outer_doors.left
			net.outer_doors.right = type(net.outer_doors.right) == "userdata" and net.outer_doors.right:get_pos() or net.outer_doors.right
		end

		minetest.debug("Saving \'elevators.elevators_nets\' table...")
		local saved_elevators_nets = minetest.deserialize(elevators.mod_storage:get_string("elevators_nets")) or {}
		saved_elevators_nets[name] = net
		elevators.mod_storage:set_string("elevators_nets", minetest.serialize(saved_elevators_nets))
		minetest.debug("elevators.elevators_nets: " .. dump(saved_elevators_nets))

		elevators.elevators_nets[name] = nil
		net = nil
	end
	elevators.mod_storage:set_string("current_marked_pos", minetest.serialize(elevators.current_marked_pos))
end

elevators.on_receive_fields = function(player, formname, fields)
	if formname ~= "real_elevators:add_floor" and formname ~= "real_elevators:floors_list" then
		return
	end

	local pl_name = player:get_player_name()
	local net_name =  elevators.cab_fs_contexts[pl_name].cur_opened_fs_el_net
	local net = elevators.elevators_nets[net_name]

	if fields.quit then
		elevators.cab_fs_contexts[pl_name].cur_opened_fs_el_net = ""
		return
	end

	if fields.set_floor then
		if fields.floor_number == "" or not tonumber(fields.floor_number) then
			minetest.chat_send_player(pl_name, "The floor number must be set!")
			return
		end

		local floor_pos = minetest.string_to_pos(fields.floor_pos)

		if not floor_pos then
			minetest.chat_send_player(pl_name, "The floor position must be set!")
			return
		end

		for i, floor in ipairs(net.floors) do
			if floor.number == fields.floor_number then
				minetest.chat_send_player(pl_name, "There is already the floor with such number in this elevator net!")
				return
			end
			if vector.equals(floor.position, floor_pos) then
				minetest.chat_send_player(pl_name, "There is already the floor with such position in this elevator net!")
				return
			end
		end

		-- In future, probably horizontally moving elevators will be added, but for now only vertically
		local pos = elevators.get_cabin_pos_from_net_name(net_name)
		if pos.x ~= floor_pos.x or pos.z ~= floor_pos.z then
			minetest.chat_send_player(pl_name, "You can not add floor with position that is not aligned with the elevator cabin position along Y axis!")
			return
		end
		--elevators.elevators_nets[elevator_net_name].floors[#elevators.elevators_nets[elevator_net_name].floors+1] = {}
		table.insert(net.floors, {})
		local new_floor = net.floors[#net.floors]
		new_floor.number = fields.floor_number
		new_floor.description = fields.floor_description
		new_floor.position = floor_pos

		local fs, fs_name = elevators.get_floor_list_formspec(net_name), "floors_list"
		elevators.switch_formspec(net_name, pl_name, fs, fs_name)
		elevators.show_formspec(net_name, pl_name)
		elevators.update_formspec_to_all_viewers(net_name, fs, fs_name, false)

		--meta:set_string("formspec", elevators.get_floor_list_formspec(net_name))
	end

	if fields.cancel_floor then
		elevators.switch_formspec(net_name, pl_name, elevators.get_floor_list_formspec(net_name), "floors_list")
		elevators.show_formspec(net_name, pl_name)
		--meta:set_string("formspec", elevators.get_floor_list_formspec(net_name))
	end

	if fields.add_floor then
		if elevators.check_for_owner(net_name, pl_name) then
			elevators.switch_formspec(net_name, pl_name, elevators.get_add_floor_formspec(), "add_floor")
			elevators.show_formspec(net_name, pl_name)
		end
		--meta:set_string("formspec", elevators.get_add_floor_formspec())
	end

	if fields.floor_add and fields.floor_number ~= "" then
		elevators.switch_formspec(net_name, pl_name, elevators.get_add_floor_formspec(tonumber(fields.floor_number)+1, fields.floor_description, fields.floor_pos), "add_floor")
		elevators.show_formspec(net_name, pl_name)
		--meta:set_string("formspec", elevators.get_add_floor_formspec(tonumber(fields.floor_number)+1, fields.floor_description, fields.floor_pos))
	end

	if fields.floor_reduce and fields.floor_number ~= "" then
		elevators.switch_formspec(net_name, pl_name, elevators.get_add_floor_formspec(tonumber(fields.floor_number)-1, fields.floor_description, fields.floor_pos), "add_floor")
		elevators.show_formspec(net_name, pl_name)
		--meta:set_string("formspec", elevators.get_add_floor_formspec(tonumber(fields.floor_number)-1, fields.floor_description, fields.floor_pos))
	end

	if fields.delete_floor then
		if not elevators.check_for_owner(net_name, pl_name) then
			return
		end
		if #elevators.cab_fs_contexts[pl_name][net_name].sel_floors_ind > 0 then
			local new_floors = {}
			for i, floor in ipairs(net.floors) do
				if table.indexof(elevators.cab_fs_contexts[pl_name][net_name].sel_floors_ind, i) == -1 then
					table.insert(new_floors, floor)
				end
			end
			net.floors = new_floors
			elevators.cab_fs_contexts[pl_name][net_name].sel_floors_ind = {}
		end

		local fs, fs_name = elevators.get_floor_list_formspec(net_name), "floors_list"
		elevators.switch_formspec(net_name, pl_name, fs, fs_name)
		elevators.show_formspec(net_name, pl_name)
		elevators.update_formspec_to_all_viewers(net_name, fs, fs_name, false)
		--meta:set_string("formspec", elevators.get_floor_list_formspec(net_name))
	end

	if fields.lightup_cabin then
		local is_owner = elevators.check_for_owner(net_name, pl_name)
		if is_owner then
			net.is_light_on = not net.is_light_on
		end
	end

	local state = net.cabin.state
	for i, floor in ipairs(net.floors) do
		if state == "pending" or state == "idle" then
			if fields["floor_" .. tostring(i)] then
				table.insert(net.cabin.queue, 1, floor.position)

				if state == "pending" then
					local timer = minetest.get_node_timer(elevators.get_cabin_pos_from_net_name(net_name))
					timer:stop()
					elevators.move_doors(net_name, "close")
					return
				end
			end
		end
		local is_sel = fields["mark_for_del_" .. tostring(i)]
		if is_sel then
			local cabin_context = elevators.cab_fs_contexts[pl_name][net_name]
			if is_sel == "true" then
				table.insert(cabin_context.sel_floors_ind, i)
			else
				table.remove(cabin_context.sel_floors_ind, table.indexof(cabin_context.sel_floors_ind, i))
			end
		end
	end
end

elevators.on_leaveplayer = function(player)
	local meta = player:get_meta()
	elevators.detach_obj_from_cabin(player, meta:get_string("attached_cabin_elevator_name"))
	meta:set_string("attached_cabin_elevator_name", "")
end
--[[elevators.on_join = function(player)
	for name, data in pairs(elevators.elevators_nets) do
		for i, pos in ipairs(data.cabin.attached_objs) do
			if vector.equals(player:get_pos(), pos) then
				local cabin_pos = elevators.get_cabin_pos_from_net_name(name)
				player:set_attach(data.cabin.elevator_object, "", vector.multiply(vector.subtract(player:get_pos(), cabin_pos), 10))
			end
		end
	end
end]]

elevators.detach_obj_from_cabin = function(obj, net_name, attached_objs_i)
	if not net_name or net_name == "" then
		return false
	end

	local net = elevators.elevators_nets[net_name]

	if not net then
		return false
	end

	if obj:is_player() then
		local eye_offset = obj:get_eye_offset()
		obj:set_eye_offset({x=eye_offset.x, y=eye_offset.y+0.5*10, z=eye_offset.z})
	end

	obj:set_detach()

	if attached_objs_i then
		table.remove(net.cabin.attached_objs, attached_objs_i)
	else
		for i, o in ipairs(net.cabin.attached_objs) do
			if o == obj then
				table.remove(net.cabin.attached_objs, i)
				break
			end
		end
	end

	minetest.debug("detach_obj_from_cabin(): net.cabin.attached_objs: " .. dump(net.cabin.attached_objs))

	return true
end

elevators.create_net = function(net_name, creater_name, pos)
	if net_name == "" then
		minetest.chat_send_player(creater_name, "The elevator net name can not be empty!")
		return
	end
	if elevators.elevators_nets[net_name] then
		minetest.chat_send_player(creater_name, "This elevator net name already exists!")
		return
	end
	elevators.elevators_nets[net_name] = {
		floors = {},
		cabin = {
			position = pos,
			inner_doors = {},
			queue = {},
			attached_objs = {}
		},
		owner = creater_name,
		is_light_on = false
	}

	local left_door = elevators.set_door(pos, minetest.facedir_to_dir(minetest.get_node(pos).param2), -0.45, 0.25, true)
	local right_door = elevators.set_door(pos, minetest.facedir_to_dir(minetest.get_node(pos).param2), -0.45, 0.25, false)
	elevators.elevators_nets[net_name].cabin.inner_doors.left = left_door
	elevators.elevators_nets[net_name].cabin.inner_doors.right = right_door

	elevators.elevators_nets[net_name].cabin.state = "idle"
	--meta:set_string("elevator_net_name", fields.elevator_net_name)
	minetest.get_meta(pos):set_string("formspec", "")
	minetest.after(0.1, elevators.show_formspec, net_name, creater_name)

	return true
end

elevators.remove_net = function(net_name)
	local net = elevators.elevators_nets[net_name]

	if not net then
		return
	end
	net.cabin.inner_doors.left:remove()
	net.cabin.inner_doors.right:remove()

	if net.outer_doors then
		net.outer_doors.left:remove()
		net.outer_doors.right:remove()
	end

	minetest.debug("attached_objs: " .. dump(net.cabin.attached_objs))
	for i, obj in ipairs(net.cabin.attached_objs) do
		elevators.detach_obj_from_cabin(obj, net_name, i)
	end

	for pl_name, context in pairs(elevators.cab_fs_contexts) do
		context[net_name] = nil
	end

	if net.is_light_on then
		local pos = elevators.get_cabin_pos_from_net_name(net_name)
		pos.y = pos.y + 1

		if minetest.get_node(pos).name == "real_elevators:light" then
			minetest.remove_node(pos)
		end
	end
	net = nil
	elevators.elevators_nets[net_name] = nil

	return true
end
