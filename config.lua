-- Configuration file

elevators.settings = {}

elevators.settings.CABIN_VELOCITY = tonumber(minetest.settings:get("real_elevators_cabin_velocity")) or 1.0
elevators.settings.DOORS_VELOCITY = tonumber(minetest.settings:get("real_elevators_doors_velocity")) or 0.25
elevators.settings.MAX_ROPE_LENGTH = tonumber(minetest.settings:get("real_elevators_max_rope_length")) or 500
elevators.settings.GRAVITY = tonumber(minetest.settings:get("real_elevators_gravity")) or 9.8

minetest.debug("elevators.settings.MAX_ROPE_LENGTH: " .. elevators.settings.GRAVITY)
