#!/usr/bin/env bash

./prepare-test-data.sh

if [[ ! -e debug.local.fifo ]]; then
	mkfifo -p debug.local.fifo
fi

# in another terminal, `tail -f "$PWD/debug.local.fifo"` must be running
export RH_DEBUG="$PWD/debug.local.fifo"
export RH_PROJECTS_DIRS="$PWD/temp/a:$PWD/temp/b"
export RH_ROS_INSTALL_DIRS="$PWD/temp/home/another/ros:$PWD/temp/opt/ros"
export RH_SRC="$PWD/rh.sh"
# shellcheck source=rh.sh
source "$RH_SRC"
