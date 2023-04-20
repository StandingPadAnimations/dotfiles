#!/bin/bash

# Edit bellow to control the images transition
export SWWW_TRANSITION_FPS=60
export SWWW_TRANSITION_STEP=20

# This controls (in seconds) when to switch to the next image
INTERVAL=5

exec 100>"$HOME/.config/hypr/wallpaper/animated-wallpaper.lock" || exit 1
flock -w 10 100 || exit 1
while true; do
	img="$(find "$HOME"/.config/hypr/wallpaper/*.png | shuf | head -1)"
	swww img "$img" --transition-type outer --transition-pos top-right
	sleep $INTERVAL
done
