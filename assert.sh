#!/usr/bin/env bash

# NOTE: Do NOT run this file directly (It is even not executable!)!

# USAGE:
#   source assert.sh

# ASCII color sequences
# credits: https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# see also: https://unix.stackexchange.com/questions/269077/tput-setaf-color-table-how-to-determine-color-codes
red=$(tput setaf 1)
green=$(tput setaf 2)
cyan=$(tput setaf 6)
gray=$(tput setaf 8)
bold=$(tput bold)
rst=$(tput sgr0)

assert() {
	echo "${gray}--- assert ${bold}${cyan}$1${rst}"
	if $1; then
		echo "${gray}>>> return code = ${bold}${cyan}$?${gray} >>> ${bold}${green}TEST PASSED${rst}"
		return 0
	else
		echo "${gray}>>> return code = ${bold}${cyan}$?${gray} >>> ${bold}${red}TEST FAILED${rst}"
		return 1
	fi
}

assert-not() {
	echo "${gray}--- assert not ${bold}${cyan}$1${rst}"
	if $1; then
		echo "${gray}>>> return code = ${bold}${cyan}$?${gray} >>> ${bold}${red}TEST FAILED${rst}"
		return 1
	else
		echo "${gray}>>> return code = ${bold}${cyan}$?${gray} >>> ${bold}${green}TEST PASSED${rst}"
		return 0
	fi
}
