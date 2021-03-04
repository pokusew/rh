#!/usr/bin/env bash

set -e

source assert.sh

./prepare-test-data.sh

export RH_PROJECTS_DIRS="$PWD/temp/a:$PWD/temp/b"
export RH_ROS_INSTALL_DIRS="$PWD/temp/home/another/ros:$PWD/temp/opt/ros"
source rh.sh

assert "rh env"
assert "rh versions"
assert-not "rh sw foxtrot"
assert "rh sw foxy --silent"
assert "rh sw kinetic --silent"
assert "rh projects"
assert "rh cd 5"
