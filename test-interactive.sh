#!/usr/bin/env bash

./prepare-test-data.sh

mkfifo temp/debug

export RH_DEBUG="$PWD/temp/debug"
export RH_PROJECTS_DIRS="$PWD/temp/a:$PWD/temp/b"
export RH_ROS_1_INSTALL_DIR="$PWD/temp/opt/ros"
source rh.sh
