#!/usr/bin/env bash

# NOTE: Do NOT run this file directly (It is even not executable!)!

# USAGE:
#   source assert.sh

# ASCII color sequences
# credits: https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# see also: https://unix.stackexchange.com/questions/269077/tput-setaf-color-table-how-to-determine-color-codes
red=$(tput setaf 1)
green=$(tput setaf 2)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
gray=$(tput setaf 8)
bold=$(tput bold)
rst=$(tput sgr0)

assert-prepare() {
	__assert_test_id=0
	__assert_temp_dir=${1:-/tmp/assert-results}
	mkdir -p "$__assert_temp_dir"
	echo "${gray}--- assert temp dir is set to: ${cyan}$__assert_temp_dir${rst}"
}

# USAGE: assert command-to-run [expected-exit-code=0] [-- expected-output]
# note: expected-output can e also set via global variable ASSERT_OUTPUT
#       if ASSERT_OUTPUT it automatically cleared (unset) before returning from assert
#       also expected-output via argument takes precedence over ASSERT_OUTPUT (which is still unset anyway)
# note: command-to-run is NOT run within subshell
#       so it affects the current working directory and global variables symbols, shell options, ...
assert() {

	local -i test_id="$__assert_test_id"
	test_id+=1
	__assert_test_id="$test_id"
	local test_id_str
	printf -v test_id_str "%02d" "$test_id"
	local temp_file="$__assert_temp_dir/test-$test_id_str.log"

	local test_cmd="$1"
	local expected_exit_code="${2:-0}"
	if [[ -v ASSERT_OUTPUT ]]; then
		local expected_output="$ASSERT_OUTPUT"
		unset ASSERT_OUTPUT
	fi
	if [[ $3 == "--" ]]; then
		local expected_output="$4"
	fi

	local test_output
	local test_exit_code
	local test_output_matches=1

	echo "${gray}--- assert ${bold}${test_id_str} ${cyan}${test_cmd}${rst}"

	# invoke test command and capture its output and exit code
	# note: we do not want to run the command in subshell (TODO: make it configurable)

	# preserve errexit option state
	if [[ -o errexit ]]; then
		set +e # temporarily disable errexit option
		local enable_errexit=1
	fi

	$test_cmd >"$temp_file" 2>&1
	test_exit_code=$?
	test_output=$(cat "$temp_file")
	if [[ $ASSERT_SILENT != "1" ]]; then
		echo "$test_output"
	fi

	# restore errexit option state if needed
	if [[ $enable_errexit -eq 1 ]]; then
		set -e
	fi

	# -v = true if the shell variable is set (has been assigned a value)
	# see https://www.gnu.org/software/bash/manual/html_node/Bash-Conditional-Expressions.html
	if [[ -v expected_output && $test_output != "$expected_output" ]]; then
		test_output_matches=0
	fi

	if [[ $expected_exit_code -eq $test_exit_code && $test_output_matches -eq 1 ]]; then
		echo "${gray}>>> ${bold}${green}TEST PASSED${rst}"
		return 0
	fi

	echo "${gray}>>> ${bold}${red}TEST FAILED${rst}"
	if [[ $expected_exit_code -ne "$test_exit_code" ]]; then
		echo "${gray}>>> ${bold}${red}return code ${magenta}$test_exit_code${red} is not the expected ${cyan}$expected_exit_code${rst}"
	fi
	if [[ $test_output_matches -ne 1 ]]; then
		echo "${gray}>>> ${bold}${red}output differs from the expected${rst}"
		echo "${gray}>>> ${bold}${magenta}EXPECTED${gray} output:${rst}"
		echo "$expected_output"
		hexdump <<<"$expected_output"
		echo "${gray}>>> ${bold}${cyan}REAL TEST${gray} output:${rst}"
		echo "$test_output"
		hexdump <<<"$test_output"
	fi

	return 1

}

assert-cleanup() {
	if [[ -d $__assert_temp_dir ]]; then
		rm -r "$__assert_temp_dir"
	fi
	unset __assert_test_id
	unset __assert_temp_dir
}

print-success() {
	echo "${bold}${green}$1${rst}"
}
