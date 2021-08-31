-- Configuration file

elevators.settings = {}

elevators.settings.CABIN_VELOCITY = tonumber(minetest.settings:get(elevators.S("real_elevators_cabin_velocity"))) or 1.0
elevators.settings.DOORS_VELOCITY = tonumber(minetest.settings:get(elevators.S("real_elevators_doors_velocity"))) or 0.25
elevators.settings.MAX_ROPE_LENGTH = tonumber(minetest.settings:get(elevators.S("real_elevators_max_rope_length"))) or 500
elevators.settings.GRAVITY = tonumber(minetest.settings:get(elevators.S("real_elevators_gravity"))) or 9.8
elevators.settings.PENDING_TIME = tonumber(minetest.settings:get(elevators.S("real_elevators_pending_time"))) or 10
