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


-- 'elevators' global table contains:

-- 'current_marked_pos' saves current selected position by 'floor_mark_tool' that can be used to create a new floor destination for an elevator net
-- 'elevators_nets' is table with data about each elevator net, it contains:
--		'floors' is table containing data about each floor (number of floor, description, position)
--		'cabin' is table containing data about the cabin in this net:
--			'position' is temporary position table, it is initialized when a cabin is just set, not a node and doesn't locate on any floor'
--			'cur_elevator_position_index' contains index of floor inside 'floors' table where the elevator cabin is locating currently (in state of a node)
--			'elevator_object' is object of elevator cabin (present when its state is 'active')
--			'inner_doors' is table containing inner left and right door objects.
--			'queue' is table with positions in 'floors' table, where the elevator was called. It must arrive them in certain order (from position with index 1 to #queue)
--		'outer_doors' is table containing outer left and right door objects (present when cabin state is 'opening'/'closing'). As per each elevator net, the only outer doors on some floor can be currently open, it is pointless to save it in 'floors' inside the floor.
-- the table is indexed with elevator net name strings
-- net name is saved in 'elevator_net_name' metadata field


-- Elevator cabin can have 5 states: 'idle', 'active', 'opening', 'closing' and 'pending'
-- 'idle' - doors are closed and cabin is static
-- 'active' - doors are closed and cabin is moving (upwards or downwards)
-- 'opening' - doors are opening
-- 'closing' - doors are closing
-- 'pending' - doors are open and the elevator is waiting for coming objects for 10 seconds (can be configured in settings)

-- Elevator state is saved in 'state' its metadata field


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


-- Opens/closes both door objects.
-- Params:
-- *net_name* is name of elevator net whose elevator cabin should open/close its doors.
-- *action* is action: "open"/"close"
elevators.move_doors = function(net_name, action)
	local net = elevators.elevators_nets[net_name]
	if not net then
		return false
	end

	local cabin_pos = net.floors[net.cabin.cur_elevator_position_index].position
	local cabin = minetest.get_node(cabin_pos)
	local cabin_dir = minetest.facedir_to_dir(cabin.param2)
	local doors_pos = vector.add(cabin_pos, vector.multiply(cabin_dir, -1))
	local doors = minetest.get_node(doors_pos)
	local is_doors = minetest.get_item_group(doors.name, "doors")

	local left_dir
	local right_dir

	if action == "open" then
		left_dir = vector.rotate_around_axis(cabin_dir, {x=0, y=1, z=0}, math.pi/2)
	elseif action == "close" then
		left_dir = vector.rotate_around_axis(cabin_dir, {x=0, y=1, z=0}, -math.pi/2)
	else
		return false
	end

	right_dir = vector.multiply(left_dir, -1)

	local left_door_entity = net.cabin.inner_doors.left:get_luaentity()
	left_door_entity.end_pos = vector.add(net.cabin.inner_doors.left:get_pos(), vector.multiply(left_dir, 0.5))
	left_door_entity.vel = vector.multiply(left_dir, 0.25)
	net.cabin.inner_doors.left:set_velocity(left_door_entity.vel)

	local right_door_entity = net.cabin.inner_doors.right:get_luaentity()
	right_door_entity.end_pos = vector.add(net.cabin.inner_doors.right:get_pos(), vector.multiply(right_dir, 0.5))
	right_door_entity.vel = vector.multiply(right_dir, 0.25)
	net.cabin.inner_doors.right:set_velocity(right_door_entity.vel)

	if is_doors then
		minetest.remove_node(doors_pos)
		local outer_left_door, outer_right_door = elevators.set_doors(doors_pos, 0.5, 0.25)
		net.outer_doors = {left = outer_left_door, right = outer_right_door}

		local outer_ldoor_entity = net.outer_doors.left:get_luaentity()
		outer_ldoor_entity.end_pos = vector.add(net.outer_doors.left:get_pos(), vector.multiply(left_dir, 0.5))
		outer_ldoor_entity.vel = vector.multiply(left_dir, 0.25)
		net.outer_doors.left:set_velocity(outer_ldoor_entity.vel)

		local outer_rdoor_entity = net.outer_doors.right:get_luaentity()
		outer_rdoor_entity.end_pos = vector.add(net.outer_doors.right:get_pos(), vector.multiply(right_dir, 0.5))
		outer_rdoor_entity.vel = vector.multiply(right_dir, 0.25)
		net.outer_doors.right:set_velocity(outer_rdoor_entity.vel)
	end

	net.cabin.state = action == "open" and "opening" or "closing"

	return true
end


-- Cause to call the elevator. It just adds to the queue of calls.
-- In order to call, it checks if the elevator is not called yet and outer doors locate to the left of the trigger and they are closed, otherwise returns false. Returns true on success.
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

	local dir = minetest.facedir_to_dir(node.param2)
	local right_down_shift = vector.add(vector.rotate_around_axis(dir, {x=0, y=1, z=0}, -math.pi/2), {x=0, y=-1, z=0})
	local right_closest_node_pos = vector.add(trigger_pos, right_down_shift)
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

	local target_pos = vector.add(trigger_pos, vector.add(right_down_shift, dir))
	local net_name, floor_i = elevators.get_net_name_and_floor_index_from_floor_pos(target_pos)

	if not net_name or not floor_i then
		return false
	end

	minetest.set_node(trigger_pos, {name="real_elevators:" .. elevators.trigger_states.on, param2 = node.param2})

	-- Add to the end of the queue the floor destination position
	elevators.elevators_nets[net_name].cabin.queue[#elevators.elevators_nets[net_name].cabin.queue+1] = target_pos

	return true
end

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

-- Converts the elevator cabin from node state to entity doing it 'active' and makes to move smoothly to the destination floor position.
elevators.activate = function(net_name, target_pos)
	local net = table.copy(elevators.elevators_nets[net_name])

	if not net then
		return false
	end

	if net.cabin.elevator_object then
		-- The elevator is already activated, so just pending for arrival
		return false
	end

	local pos
	if net.cabin.position then
		pos = net.cabin.position
	elseif net.cabin.cur_elevator_position_index then
		pos = net.floors[net.cabin.cur_elevator_position_index].position
	end

	if not pos then
		return false
	end

	if net.cabin.state ~= "idle" then
		-- It means, whether the elevator is currently opening/closing or pending for objects and so can`t move
		return false
	end

	local dir = minetest.facedir_to_dir(minetest.get_node(pos).param2)
	local meta = minetest.get_meta(pos)
	local formspec = meta:get_string("formspec")
	minetest.remove_node(pos)

	local cabin_obj = minetest.add_entity(pos, "real_elevators:elevator_cabin_activated")
	cabin_obj:set_rotation({x=0, y=vector.dir_to_rotation(dir).y, z=0})
	elevators.elevators_nets[net_name] = net

	local self = cabin_obj:get_luaentity()
	self.elevator_net_name = net_name

	local pos = cabin_obj:get_pos()
	local left_door, right_door = elevators.set_doors(pos, -0.45, 0.25)
	left_door:set_attach(cabin_obj, "", vector.subtract(left_door:get_pos(), pos))
	right_door:set_attach(cabin_obj, "", vector.subtract(right_door:get_pos(), pos))
	net.cabin.inner_doors.left = left_door
	net.cabin.inner_doors.right = right_door
	net.cabin.position = nil
	net.cabin.cur_elevator_position_index = nil
	self.end_pos = target_pos
	net.cabin.elevator_object = cabin_obj
	net.cabin.formspec = formspec
	net.cabin.state = "active"
	self.dir = dir

	cabin_obj:set_velocity(vector.normalize(vector.subtract(self.end_pos, pos)))

	return true
end

-- Converts the elevator cabin from entity state to node doing it "opening" (not "idle" !) and makes to open doors
elevators.deactivate = function(net_name)
	local net = table.copy(elevators.elevators_nets[net_name])

	if not net then
		return false
	end

	if not net.cabin.elevator_object then
		return false
	end

	local pos = net.cabin.elevator_object:get_pos()
	local dir = net.cabin.elevator_object:get_luaentity().dir

	net.cabin.elevator_object:remove()
	net.cabin.elevator_object = nil
	local net_name, floor_i = elevators.get_net_name_and_floor_index_from_floor_pos(pos)
	net.cabin.cur_elevator_position_index = floor_i
	minetest.set_node(pos, {name = "real_elevators:elevator_cabin", param2 = minetest.dir_to_facedir(dir)})
	local left_door, right_door = elevators.set_doors(pos, -0.45, 0.25)
	net.cabin.inner_doors.left = left_door
	net.cabin.inner_doors.right = right_door
	table.remove(net.cabin.queue, 1)
	elevators.elevators_nets[net_name] = net
	local trigger_pos = vector.add(pos, vector.add(vector.add(vector.multiply(dir, -1), vector.new(0, 1, 0)), vector.rotate_around_axis(dir, vector.new(0, 1, 0), math.pi/2)))
	local trigger = minetest.get_node(trigger_pos)
	local is_trigger = minetest.get_item_group(trigger.name, "trigger")

	if is_trigger then
		minetest.set_node(trigger_pos, {name = "real_elevators:" .. elevators.trigger_states.off, param2 = trigger.param2})
	end

	minetest.get_meta(pos):set_string("elevator_net_name", net_name)

	local success = elevators.move_doors(net_name, "open")
	if not success then
		return false
	end

	return true
end

elevators.global_step = function(dtime)
	for name, data in pairs(elevators.elevators_nets) do
		if data.cabin.state == "active" then
			local self = data.cabin.elevator_object:get_luaentity()

			if self and not self.end_pos then
				-- The elevator has arrived!
				minetest.debug("The elevator has arrived!")
				elevators.deactivate(name)
			end
		elseif data.cabin.state == "opening" or data.cabin.state == "closing" then
			local inner_left_door_self = data.cabin.inner_doors.left:get_luaentity()
			local inner_right_door_self = data.cabin.inner_doors.right:get_luaentity()
			local outer_left_door_self = data.outer_doors.left:get_luaentity()
			local outer_right_door_self = data.outer_doors.right:get_luaentity()

			if (inner_left_door_self and not inner_left_door_self.end_pos) and
				(inner_right_door_self and not inner_right_door_self.end_pos) and
				(outer_left_door_self and not outer_left_door_self.end_pos) and
				(outer_right_door_self and not outer_right_door_self.end_pos) then
				local pos = data.floors[data.cabin.cur_elevator_position_index].position
				local doors_pos = vector.add(pos, vector.multiply(minetest.facedir_to_dir(minetest.get_node(pos).param2), -1))
				if data.cabin.state == "opening" then
					data.cabin.state = "pending"
					minetest.set_node(doors_pos, {name = "real_elevators:" .. elevators.doors_states.open, param2 = minetest.get_node(pos).param2})
					local timer = minetest.get_node_timer(pos)
					timer:start(10)
				else
					data.cabin.state = "idle"
					minetest.set_node(doors_pos, {name = "real_elevators:" .. elevators.doors_states.closed, param2 = minetest.get_node(pos).param2})
				end

				data.outer_doors.left:remove()
				data.outer_doors.right:remove()
				data.outer_doors = nil
			end
		elseif data.cabin.state == "idle" then
			if #data.cabin.queue > 0 then
				elevators.activate(name, data.cabin.queue[1])
			end
		end
	end
end

elevators.update_cabins_formspecs = function()
	for name, data in pairs(elevators.elevators_nets) do
		if data.cabin.state == "active" then
			data.cabin.formspec = elevators.get_floor_list_formspec(name)
		else
			local meta = minetest.get_meta(data.cabin.position or data.floors[data.cabin.cur_elevator_position_index].position)
			if #data.floors == 0 then
				meta:set_string("formspec", elevators.get_add_floor_formspec())
			else
				meta:set_string("formspec", elevators.get_floor_list_formspec(name))
			end
		end
	end
end

elevators.check_for_surrounding_shaft_nodes = function(pos, surrounded_node_dir, placer)
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

	local playername
	if placer then
		playername = placer:get_player_name()
	end
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
		local horiz_shaft_rel_pos = vector.rotate_around_axis(shaft_rel_pos, right_dir, -vector.dir_to_rotation(shaft_rel_pos).x)

		if not vector.equals(shaft_dir, vector.round(vector.normalize(horiz_shaft_rel_pos))) then
			if playername then
				minetest.chat_send_player(playername, "The elevator cabin can not be outside of the shaft!")
			end
			return false
		end
	end

	local up_node = minetest.get_node(vector.add(pos, vector.new(0, 1, 0)))

	if up_node.name ~= "air" then
		if playername then
			minetest.chat_send_player(playername, "There is no space for placing/moving the elevator cabin!")
		end
		return false
	end

	return true
end

elevators.get_enter_elevator_net_name_formspec = function()
	local form = "formspec_version[4]size[6,3]style_type[label;font=normal,bold]label[0.5,0.5;Enter name for new elevator net to create:]" ..
			"field[2,1;2,0.5;elevator_net_name;;]button[2,2;2,0.5;elevator_net_name_enter;Enter]"

	return form
end

elevators.get_add_floor_formspec = function()
	local form = "formspec_version[4]size[10,5]style_type[label;font=normal,bold;font_size=*1.5]label[1.5,0.5;Add new floor for the elevator net:]" ..
			"style_type[label;font_size=]field[0.5,2;1,1;floor_number;Number:;0]field[2.5,2;3,1;floor_description;Description:;]field[6.5,2;2.5,1;floor_pos;Position:;"

	if elevators.current_marked_pos then
		form = form .. "(" .. elevators.current_marked_pos.x .. ", " .. elevators.current_marked_pos.y .. ", " .. elevators.current_marked_pos.z .. ")]"
	else
		form = form .. "]"
	end

	form = form .. "image_button[0.5,3;0.5,0.5;real_elevators_floor_plus.png;floor_add;]image_button[1,3;0.5,0.5;real_elevators_floor_minus.png;floor_reduce;]button[3.5,3.5;2.5,1;set_floor;Set]"

	return form
end

elevators.get_floor_list_formspec = function(elevator_net_name)
	local form = {
		"formspec_version[4]",
		"size[4,9]",
		"style_type[label;font=normal,bond]",
		"label[0.5,0.5;Select a floor to lift to it:]",
		"style_type[box;bordercolors=dimgray]",
		"box[1,1;2,6;darkgray]",
		"scrollbar[3,1;0.2,6;vertical;floor_list_scrollbar;]",
		"scroll_container[1,1;2,6;floor_list_scrollbar;vertical;1]"
	}

	if elevator_net_name == "" then
		return
	end

	local y_space = 0.25
	for i, floor in ipairs(elevators.elevators_nets[elevator_net_name].floors) do
		local but_name = "floor_" .. tostring(i)
		form[#form+1] = "button[0.5," .. tostring(y_space) .. ";1,1;" .. but_name .. ";" .. floor.number .. "]"
		form[#form+1] = "tooltip[" .. but_name .. ";Floor #" .. floor.number .. ": \"" .. floor.description .. "\".\nLocates at: " .. minetest.pos_to_string(floor.position) .. "]"
	end

	form[#form+1] = "scroll_container_end[]"
	form[#form+1] = "image_button[1.5,7.5;1,1;real_elevators_floor_plus.png;add_floor;]tooltip[add_floor;Add still floors]"

	return table.concat(form, "")
end