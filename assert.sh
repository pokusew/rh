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

assert() {

	# usage: command-to-run [expected-exit-code=0] [-- expected-output]

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

	echo "${gray}--- assert ${bold}${cyan}${test_cmd}${rst}"

	# invoke test command and capture its output and exit code
	# see https://unix.stackexchange.com/questions/526904/bash-redirect-command-output-to-stdout-and-variable
	# see https://stackoverflow.com/questions/6871859/piping-command-output-to-tee-but-also-save-exit-code-of-command
	set -o pipefail
	set +e
	test_output="$($test_cmd | tee /dev/tty)"
	test_exit_code=$?
	set -e
	set +o pipefail

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

print-success() {
	echo "${bold}${green}$1${rst}"
}
