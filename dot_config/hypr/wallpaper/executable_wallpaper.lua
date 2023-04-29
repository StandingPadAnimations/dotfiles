#!/usr/bin/lua

local sh = require('sh')
local socket = require('socket')
local signal = require('posix.signal')
local lfs = require('lfs')

sh.install()

-- Wallpaper path to make my life easier
local wallpaper_path = "/home/mahid/.config/hypr/wallpaper"

-- Lock file to prevent multiple instances. We use LFS here
-- because it's a lot easier and works properly compared to 
-- using some mkdir or flock workaround
local lock_file = lfs.lock_dir(wallpaper_path, 2)
if not lock_file then
	print("Lock file exists!")
	return
end

-- Signal to handle Ctrl+C so that we delete the lock file. I 
-- have no idea if this is actually needed but you never know
signal.signal(signal.SIGINT, function(_)
	lock_file:free()
	os.exit()
end)


local function wallpaper_loop()
	-- Constants
	local transition_fps = 60
	local transition_step = 20
	local interval = 5
	local positions = {"top-right", "top-left", "bottom-right", "bottom-left"}

	-- Multi-part commands
	local swww_img = sh.command('swww', 'img')

	-- Get random image
	local function get_image()
		local imgs = {}
		for file in lfs.dir(wallpaper_path) do
			local ext = file:match('^.+(%..+)$')
			if ext == ".png" or ext == ".jpg" then
				table.insert(imgs, wallpaper_path.."/"..file)
			end
		end
		return imgs[math.random(#imgs)]
	end

	-- Main loop
	local img = get_image()
	while true do
		-- Random position for some variation
		local pos = positions[math.random(#positions)]

		-- Select new image. Doesn't make sense to call swww 
		-- again with the same image as last time
		while true do
			local n_img = get_image()
			if n_img ~= img then
				img = n_img
				break
			end
		end

		-- Change wallpaper. This does a call to the shell
		swww_img(img,
			'--transition-type', 'outer',
			'--transition-pos', pos,
			'--transition-fps', transition_fps,
			'--transition-step', transition_step)
		socket.sleep(interval)
	end
end

-- This is vital, it prevents an annoying Rust error from swww. I assume
-- it comes from the fact that we call swww not as a daemon to avoid it printing
-- so many god damn errors in TTY after closing Hyprland
--
-- Don't touch, otherwise everything breaks
socket.sleep(1)

-- Error handling cause I don't want to spend 5 hours each time debugging
-- Lua not wanting to execute
local ok, res = pcall(wallpaper_loop)
if ok then
	print("YAY")
else
	io.output(wallpaper_loop.."/error.txt")
	io.write(res)

	-- Free the file if there's an error
	lock_file:free()
end
