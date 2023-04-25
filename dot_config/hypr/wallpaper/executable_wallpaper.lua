#!/bin/lua

local sh = require('sh')
local socket = require 'socket'

-- Swww transition options
local transition_fps = 60
local transition_step = 20

-- This controls (in seconds) when to switch to the next image
local interval = 5

-- All positions
local positions = {"top-right", "top-left", "bottom-right", "bottom-left"}

-- Lock file
os.execute('exec 100>"$HOME"/.config/hypr/wallpaper/animated-wallpaper.lock && flock -w 10 100')

-- Multi-part commands
local swww_img = sh.command('swww', 'img')

-- Main loop
local img = find('"$HOME"/.config/hypr/wallpaper/{*.png,*.jpg}') : shuf() : head('-1')
while true do
	local pos = positions[math.random(#positions)]

	-- Select new image
	while true do
		local n_img = find('"$HOME"/.config/hypr/wallpaper/{*.png,*.jpg}') : shuf() : head('-1')
		if n_img ~= img then
			img = n_img
			break
		end
	end

	-- Change wallpaper
	swww_img(tostring(img),
		'--transition-type outer',
		'--transition-pos', pos,
		'--transition-fps', transition_fps,
		'--transition-step', transition_step)
	socket.sleep(interval)
end
