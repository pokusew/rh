#!/usr/bin/env bash

./prepare-test-data.sh

if [[ ! -e debug.local.fifo ]]; then
	mkfifo -p debug.local.fifo
fi

export RH_DEBUG="$PWD/debug.local.fifo"
export RH_PROJECTS_DIRS="$PWD/temp/a:$PWD/temp/b"
export RH_ROS_1_INSTALL_DIR="$PWD/temp/opt/ros"
source rh.sh
