#!/usr/bin/env bash

dir="/usr/share/doc/polybar/ArchDark"
themes=(`ls --hide="launch.sh" $dir`)

launch_bar() {
	# Terminate already running bar instances
	killall -q polybar

	# Wait until the processes have been shut down
	while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
	polybar -q main -c "$dir/$style/config.ini" &

}

style="archdark"
launch_bar
