#!/usr/bin/env bash

set -e

./prepare-test-data.sh

export RH_PROJECTS_DIRS="$PWD/temp/a:$PWD/temp/b"
export RH_ROS_1_INSTALL_DIR="$PWD/temp/opt/ros"
source rh.sh

rh env
rh versions
rh sw kinetic --silent
rh projects
rh cd 5
