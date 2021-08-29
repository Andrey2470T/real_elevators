-- Configuration file

elevators.settings = {}

elevators.settings.CABIN_VELOCITY = tonumber(minetest.settings:get("cabin_velocity"))
elevators.settings.DOORS_VELOCITY = tonumber(minetest.settings:get("doors_velocity"))
elevators.settings.MAX_ROPE_LENGTH = tonumber(minetest.settings:get("max_rope_length"))
elevators.settings.GRAVITY = tonumber(minetest.settings:get("gravity"))
