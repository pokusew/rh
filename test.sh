#!/usr/bin/env bash

# ASSERT_OUTPUT is used in assert
# shellcheck disable=SC2034

set -e

source assert.sh

./prepare-test-data.sh

export RH_PROJECTS_DIRS="$PWD/temp/a:$PWD/temp/b"
export RH_ROS_INSTALL_DIRS="$PWD/temp/home/another/ros:$PWD/temp/opt/ros"
export RH_SRC="$PWD/rh.sh"
# shellcheck source=rh.sh
source "$RH_SRC"

# see the following link for info about multiline strings (heredoc)
# https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html#Here-Documents
# tl;dr:
#   <<EOF marks heredoc start
#   <<"EOF" marks heredoc start but no expansion
#   <<-EOF marks heredoc start and all leading tab characters are stripped from input lines
#   and the line containing delimiter
#   <<-"EOF" no expansion and all leading tab characters are stripped

assert-prepare "$PWD/test"

assert "rh env"
assert "rh versions"
assert "rh sw foxtrot" 1
assert "rh sw foxy --silent"
assert "rh sw kinetic --silent"

ASSERT_OUTPUT="$(
	cat <<-"EOF"
		temp/a/1
		temp/b/4
		temp/b/5/ws
	EOF
)"
assert "__rh_get_workspaces temp" 0

assert "rh projects"
assert "rh cd 5"
assert "rh wcd"
assert "rh dev"
assert "rh ldev" 1
assert "rh cd 4"
assert "rh ldev"

print-success "ALL TESTS PASSED"

assert-cleanup
