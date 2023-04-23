#!/bin/bash

# Edit bellow to control the images transition
export SWWW_TRANSITION_FPS=60
export SWWW_TRANSITION_STEP=20

# This controls (in seconds) when to switch to the next image
INTERVAL=5

# All positions
POSITIONS=("top-right" "top-left" "bottom-right" "bottom-left")

# Lock file
exec 100>"$HOME/.config/hypr/wallpaper/animated-wallpaper.lock" || exit 1
flock -w 10 100 || exit 1

img="$(find "$HOME"/.config/hypr/wallpaper/{*.png,*.jpg} | shuf | head -1)"
while true; do
	pos="${POSITIONS[$RANDOM % ${#POSITIONS[@]}]}"
	while true; do
		n_img="$(find "$HOME"/.config/hypr/wallpaper/{*.png,*.jpg} | shuf | head -1)"
		if [ "$n_img" != "$img" ]
		then
			img="$n_img"
			break
		fi
	done

	swww img "$img" --transition-type outer --transition-pos "$pos"
	sleep $INTERVAL
done
