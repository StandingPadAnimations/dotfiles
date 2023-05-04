#!/usr/bin/lua

local sh = require('sh')
local socket = require('socket')
local signal = require('posix.signal')
local lfs = require('lfs')

sh.install()

-- Wallpaper path to make my life easier
local wallpaper_path = '/home/mahid/.config/hypr/wallpaper'

-- Lock file to prevent multiple instances. We use LFS here
-- because it's a lot easier and works properly compared to 
-- using some mkdir or flock workaround. If the file still exists, then
-- check to see if there's multiple processes running. If not, then remove the lockfile,
-- otherwise delete
--
-- We do it before the Ctrl+C signal thing so that it doesn't interfere with it
local lock_file = lfs.lock_dir(wallpaper_path, 2)
if not lock_file then
	local processes = pgrep('-lf', 'wallpaper.lua')
	local _, count = tostring(processes):gsub("wallpaper.lua", "")
	print(count)
	if count > 1 then
		print('Already running!')
		return
	else
		-- LFS gurantees that the file will be called lockfile.lfs
		rm(wallpaper_path..'/lockfile.lfs')
		lock_file = lfs.lock_dir(wallpaper_path, 2)
	end
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
	local interval = 30
	local positions = {'top-right', "top-left", "bottom-right", "bottom-left"}
	local last_modified = nil
	local iterations = 0
	local imgs = {}

	-- Multi-part commands
	local swww_img = sh.command('swww', 'img')

	-- Get a random image file path
	local function get_image()
		-- If starting the script or the folder has been modified, then refresh all of the files
		-- so that we have a fresh set of images. We do it like this because it's faster
		local temp_last_modified = lfs.attributes(wallpaper_path, 'modification')
		if last_modified == nil or temp_last_modified > last_modified then
			imgs = {}
			last_modified = temp_last_modified

			-- Go through every file, check the extension, and if it's an image, add
			-- it to the imgs table
			for file in lfs.dir(wallpaper_path) do
				local ext = file:match('^.+(%..+)$')
				if ext == '.png' or ext == ".jpg" then
					table.insert(imgs, wallpaper_path..'/'..file)
				end
			end
		end

		-- Select a random image and return it
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
		iterations = iterations + 1

		-- I choose 50 for no reason other then why not lol
		if iterations == 50 then
			-- Let's also set the random seed to make it even more random
			math.randomseed(os.time())
			iterations = 0
			math.random() -- to make sure all future numbers are random
		end
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
	print('YAY')
else
	io.output(wallpaper_path..'/error.txt')
	io.write(res)

	-- Free the file if there's an error
	lock_file:free()
end
