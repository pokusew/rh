#!/usr/bin/env bash

# rh - ROS Helper
# A simple helper to make working with different ROS versions and projects easier.
# HOMEPAGE: https://github.com/pokusew/rh

# NOTE: Do NOT run this file directly (It is even not executable!)!

# INSTALLATION:
#
#   Requirements: Bash 4+
#
#   1. Download the current version of rh.sh
#      from https://raw.githubusercontent.com/pokusew/rh/master/rh.sh
#
#   2. Add something like the following to your `~/.bashrc` (supply your own values):
#      export RH_PROJECTS_DIRS="/some/dir1:/another/dir2:/some/completely/different/dir3"
#      export RH_ROS_INSTALL_DIRS="/opt/ros"
#      export RH_SRC="/absolute/path/to/rh.sh"
#      source "$RH_SRC"
#
#      Note: There can be multiple dirs specified in *_DIRS variables.
#            Individual dirs are separated by `:`,
#            the left-most specified directory has the highest priority
#

export RH_VERSION="0.0.7"

# ROADMAP:
# * continually improve as I discover more needs while using ROS 1/2

# NOTE 1: problem - xargs runs command even when stdin is empty
#   tail -n +2 could be workaround for missing option --no-run-if-empty in BSD's xargs (it is GNU only extension)
#   BUT is seems that BSD's xargs does NOT run command when stdin is empty
#   SO we use --no-run-if-empty only on Linux
#   see https://stackoverflow.com/questions/8296710/how-to-ignore-xargs-commands-if-stdin-input-is-empty
#   see https://stackoverflow.com/questions/339483/how-can-i-remove-the-first-line-of-a-text-file-using-bash-sed-script

__rh_get_ros_versions() {

	local install_dirs
	# see https://github.com/koalaman/shellcheck/wiki/SC2206
	IFS=":" read -r -a install_dirs <<<"$RH_ROS_INSTALL_DIRS"

	# no install dirs to search in
	if [[ ${#install_dirs[@]} == 0 ]]; then
		return 1
	fi

	# TODO: some of the install dirs do not exist (currently find prints warning)

	local xargs_additional_options=()
	# see "NOTE 1" at the top of the file
	if [[ $(uname) == "Linux" ]]; then
		# let's hope this is GNU/Linux which supports xargs --no-run-if-empty
		xargs_additional_options+=("--no-run-if-empty")
	fi

	find "${install_dirs[@]}" -mindepth 1 -maxdepth 1 -type d \
		-print0 | xargs "${xargs_additional_options[@]}" -0 basename -a | sort | uniq

	return 0

}

__rh_get_ros_version_dir() {

	local version_name="$1"

	# no version name given
	if [[ -z $version_name ]]; then
		return 1
	fi

	local install_dirs
	# see https://github.com/koalaman/shellcheck/wiki/SC2206
	IFS=":" read -r -a install_dirs <<<"$RH_ROS_INSTALL_DIRS"

	# no install dirs to search in
	if [[ ${#install_dirs[@]} == 0 ]]; then
		return 1
	fi

	# search in order (the left most dir is examined at first)
	for i_dir in "${install_dirs[@]}"; do
		# this install dir ($i_dir) contains subdirectory named $version_name
		if [[ -d "$i_dir/$version_name" ]]; then
			echo "$i_dir/$version_name"
			return 0
		fi
	done

	return 1

}

# return path to all workspaces (catkin/colcon/any) (relative to the current directory) (separated by \n)
# workspaces are directories that contains any of the following files in their root:
#   .catkin_workspace / .colcon_workspace / .workspace
# first argument specifies the search root (relative to the current directory)
# if no argument is given, the current directory is used as the search root
__rh_get_workspaces() {

	local search_root="."

	if [[ -n $1 ]]; then
		search_root="$1"
	fi

	# TODO: search_root dir does not exist (currently find prints warning)

	local xargs_additional_options=()
	# see "NOTE 1" at the top of the file
	if [[ $(uname) == "Linux" ]]; then
		# let's hope this is GNU/Linux which supports xargs --no-run-if-empty
		xargs_additional_options+=("--no-run-if-empty")
	fi

	# TODO: maybe limit depth (best, make it configurable)
	find "$search_root" \( -name .catkin_workspace -o -name .colcon_workspace -o -name .workspace \) -type f \
		-print0 | xargs "${xargs_additional_options[@]}" -0 -n 1 dirname | sort | uniq

	return 0

}

# return project names in all projects dirs (separated by \n)
# duplicates in names are removed, thus resulting names are sorted and unique
__rh_get_project_names() {

	local projects_dirs
	# see https://github.com/koalaman/shellcheck/wiki/SC2206
	IFS=":" read -r -a projects_dirs <<<"$RH_PROJECTS_DIRS"

	# no projects dirs to search in
	if [[ ${#projects_dirs[@]} == 0 ]]; then
		return 1
	fi

	# TODO: some of the projects dirs do not exist (currently find prints warning)

	local xargs_additional_options=()
	# see "NOTE 1" at the top of the file
	if [[ $(uname) == "Linux" ]]; then
		# let's hope this is GNU/Linux which supports xargs --no-run-if-empty
		xargs_additional_options+=("--no-run-if-empty")
	fi

	find "${projects_dirs[@]}" -mindepth 1 -maxdepth 1 -type d \
		-print0 | xargs "${xargs_additional_options[@]}" -0 basename -a | sort | uniq

	return 0

}

# searches trough subdirectories of projects dirs
# and returns the first matching directory with the given project name
__rh_get_project_dir() {

	local project_name="$1"

	# no project name given
	if [[ -z $project_name ]]; then
		return 1
	fi

	local projects_dirs
	# see https://github.com/koalaman/shellcheck/wiki/SC2206
	IFS=":" read -r -a projects_dirs <<<"$RH_PROJECTS_DIRS"

	# no projects dirs to search in
	if [[ ${#projects_dirs[@]} == 0 ]]; then
		return 1
	fi

	# search in order (left most projects dir is examined at first)
	for p_dir in "${projects_dirs[@]}"; do
		# this projects dir ($p_dir) contains subdirectory named $project_name
		if [[ -d "$p_dir/$project_name" ]]; then
			echo "$p_dir/$project_name"
			return 0
		fi
	done

	return 1

}

# rh stands for ROS Helpers
# A simple helper to make working with different ROS versions and projects easier.
rh() {

	# ASCII color sequences
	# credits: https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
	# see also: https://unix.stackexchange.com/questions/269077/tput-setaf-color-table-how-to-determine-color-codes
	__rh_red=$(tput setaf 1)
	__rh_green=$(tput setaf 2)
	__rh_yellow=$(tput setaf 11)
	__rh_cyan=$(tput setaf 6)
	__rh_gray=$(tput setaf 8)
	__rh_bold=$(tput bold)
	__rh_rst=$(tput sgr0)

	__rh_print_help() {
		# note: here we could use heredoc (multiline string) instead of of multiple echo(s)
		#       but echo(s) work better with syntax highlighting (at least in JetBrain's IDEs)
		echo "${__rh_bold}${__rh_cyan}rh - ROS helper${__rh_rst}"
		echo "A simple helper to make working with different ROS versions and projects easier."
		echo "${__rh_gray}Homepage: ${__rh_rst}https://github.com/pokusew/rh"
		echo "${__rh_gray}Version: ${__rh_rst}$RH_VERSION"
		echo "${__rh_gray}Usage: ${__rh_bold}${__rh_cyan}rh ${__rh_green}<command> ${__rh_yellow}[command options]${__rh_rst}"
		echo "${__rh_gray}Commands:${__rh_rst}"
		echo "  ${__rh_bold}${__rh_cyan}rh ${__rh_green}help${__rh_rst}"
		echo "    prints this help"
		echo "  ${__rh_bold}${__rh_cyan}rh ${__rh_green}env${__rh_rst}"
		echo "    prints env variables related to ROS"
		echo "  ${__rh_bold}${__rh_cyan}rh ${__rh_green}versions${__rh_rst}"
		echo "    lists all available ROS 1 and ROS 2 versions"
		echo "    versions are searched in dirs specified in RH_ROS_INSTALL_DIRS"
		echo "  ${__rh_bold}${__rh_cyan}rh ${__rh_green}sw ${__rh_yellow}<ros version name>${__rh_rst}"
		echo "    activates given ROS version"
		echo "    versions are searched in dirs specified in RH_ROS_INSTALL_DIRS"
		echo "  ${__rh_bold}${__rh_cyan}rh ${__rh_green}projects${__rh_rst}"
		echo "    lists all available projects"
		echo "    projects are searched in dirs specified in RH_PROJECTS_DIRS"
		echo "  ${__rh_bold}${__rh_cyan}rh ${__rh_green}cd ${__rh_yellow}<project name>${__rh_rst}"
		echo "    changes into project dir of the given project"
		echo "    projects are searched in dirs specified in RH_PROJECTS_DIRS"
		echo "  ${__rh_bold}${__rh_cyan}rh ${__rh_green}dev${__rh_rst}"
		echo "    tries to source install/setup.bash or devel/setup.bash (relative to the current working dir)"
		echo "  ${__rh_bold}${__rh_cyan}rh ${__rh_green}ldev${__rh_rst}"
		echo "    tries to source install/local_setup.bash or devel/local_setup.bash (relative to the current working dir)"
		echo "  ${__rh_bold}${__rh_cyan}rh ${__rh_green}wcd${__rh_rst}"
		echo "    recursively searches for workspaces dirs and changes to the nearest found"
		echo "  ${__rh_bold}${__rh_cyan}rh ${__rh_green}rosdep-check-src${__rh_rst}"
		echo "    runs 'rosdep check -i --from-path src' in the current working dir"
		echo "  ${__rh_bold}${__rh_cyan}rh ${__rh_green}rosdep-install-src${__rh_rst}"
		echo "    runs 'rosdep install -i --from-path src' in the current working dir"
	}

	__rh_env() {
		# print env variables related to rh, ROS 1, ROS 2
		env | grep --ignore-case --color=always -e RH -e ROS -e CMAKE -e PYTHON -e COLCON -e AMENT | sort
		return 0
	}

	__rh_versions() {

		if [[ -z $RH_ROS_INSTALL_DIRS ]]; then
			echo "${__rh_red}RH_ROS_INSTALL_DIRS env variable not set or is empty${__rh_rst}"
			return 1
		fi

		__rh_get_ros_versions

		return 0

	}

	__rh_sw() {

		local desired_version="$2"
		local silent=0

		if [[ $3 == "--silent" ]]; then
			silent=1
		fi

		# no desired version given
		if [[ -z $desired_version ]]; then
			if [[ $silent != 1 ]]; then
				echo "${__rh_red}no version given${__rh_rst}"
				echo "usage: rh sw <ros version name>"
			fi
			return 1
		fi

		local version_dir
		version_dir=$(__rh_get_ros_version_dir "$desired_version")

		if [[ -n $version_dir && -r "$version_dir/setup.bash" ]]; then
			[[ $silent != 1 ]] && echo "sourcing $version_dir/setup.bash"
			# shellcheck disable=SC1090
			source "$version_dir/setup.bash"
			return 0
		fi

		if [[ $silent != 1 ]]; then

			echo "${__rh_red}version with name '$desired_version' was not found in any of the following install dirs:${__rh_rst}"

			local -i i
			local install_dirs
			# see https://github.com/koalaman/shellcheck/wiki/SC2206
			IFS=":" read -r -a install_dirs <<<"$RH_ROS_INSTALL_DIRS"
			for i_dir in "${install_dirs[@]}"; do
				# ((i++)) # Bash 5+
				i+=1
				echo "  $i. $i_dir"
			done

		fi

		return 1

	}

	__rh_projects() {

		if [[ -z $RH_PROJECTS_DIRS ]]; then
			echo "${__rh_red}RH_PROJECTS_DIRS env variable not set or is empty${__rh_rst}"
			return 1
		fi

		__rh_get_project_names

		return 0

	}

	__rh_cd() {

		if [[ -z $RH_PROJECTS_DIRS ]]; then
			echo "${__rh_red}RH_PROJECTS_DIRS env variable not set or is empty${__rh_rst}"
			return 1
		fi

		local project_name="$2"

		# no project name given
		if [[ -z $project_name ]]; then
			echo "${__rh_red}no project name given${__rh_rst}"
			echo "usage: rh cd <project name>"
			return 1
		fi

		local project_dir
		project_dir=$(__rh_get_project_dir "$project_name")

		if [[ -n $project_dir ]]; then
			echo "changing into '$project_dir' directory"
			# shellcheck disable=SC2164
			cd "$project_dir"
			return 0
		fi

		echo "${__rh_red}project with name '$project_name' was not found in any of the following project dirs:${__rh_rst}"

		local -i i
		local projects_dirs
		# see https://github.com/koalaman/shellcheck/wiki/SC2206
		IFS=":" read -r -a projects_dirs <<<"$RH_PROJECTS_DIRS"
		for p_dir in "${projects_dirs[@]}"; do
			# ((i++)) # Bash 5+
			i+=1
			echo "  $i. $p_dir"
		done

		return 1

	}

	__rh_wcd() {

		local workspaces
		IFS=$'\n' read -r -a workspaces <<<"$(__rh_get_workspaces .)"

		if [[ ${#workspaces[@]} -gt 0 ]]; then
			echo "changing into workspace ${workspaces[0]}"
			# shellcheck disable=SC2164
			cd "${workspaces[0]}"
			return 0
		fi

		echo "no supported workspace found"
		return 1

	}

	__rh_dev() {

		if [[ $1 == "ldev" || $2 == "--local" ]]; then
			local setup_files_to_try=(
				'install/local_setup.bash' # ROS 2: default colcon
				'devel/local_setup.bash' # ROS 1: default catkin
			)
		else
			local setup_files_to_try=(
				'install/setup.bash' # ROS 2: default colcon
				'devel/setup.bash' # ROS 1: default catkin
			)
		fi

		for setup_file in "${setup_files_to_try[@]}"; do
			if [[ -r "$setup_file" ]]; then
				echo "sourcing $setup_file"
				# shellcheck disable=SC1090
				source "$setup_file"
				echo "current ROS related env variables:"
				__rh_env
				return 0
			fi
		done

		echo "current directory does not contain any of the files (or they may not be readable):"
		for setup_file in "${setup_files_to_try[@]}"; do
			echo "  $setup_file"
		done

		return 1

	}

	__rh_rosdep_check_src() {
		# note: src is prefixed by $PWD and printed just for clarity
		echo "running ${__rh_bold}${__rh_cyan}rosdep check -i --from-path $PWD/src${__rh_rst}"
		rosdep check -i --from-path "$PWD/src"
	}

	__rh_rosdep_install_src() {
		# note: src is prefixed by $PWD and printed just for clarity
		echo "running ${__rh_bold}${__rh_cyan}rosdep install -i --from-path $PWD/src${__rh_rst}"
		rosdep install -i --from-path "$PWD/src"
	}

	__rh_cleanup() {

		unset __rh_red
		unset __rh_green
		unset __rh_yellow
		unset __rh_cyan
		unset __rh_gray
		unset __rh_bold
		unset __rh_rst

		unset __rh_print_help
		unset __rh_env
		unset __rh_versions
		unset __rh_sw
		unset __rh_projects
		unset __rh_cd
		unset __rh_wcd
		unset __rh_dev
		unset __rh_rosdep_check_src
		unset __rh_rosdep_install_src

		unset __rh_cleanup

	}

	# local readonly associative array (dictionary)
	local -A sub_cmd_map
	sub_cmd_map=(
		["help"]=__rh_print_help
		["env"]=__rh_env
		["versions"]=__rh_versions
		["sw"]=__rh_sw
		["projects"]=__rh_projects
		["cd"]=__rh_cd
		["wcd"]=__rh_wcd
		["dev"]=__rh_dev
		["ldev"]=__rh_dev
		["rosdep-check-src"]=__rh_rosdep_check_src
		["rosdep-install-src"]=__rh_rosdep_install_src
	)
	readonly sub_cmd_map

	# TODO: in the future, handle options (prefixed by -) independently of their positions

	if [[ -n $1 && -n ${sub_cmd_map[$1]} ]]; then
		# echo "handler of '$1' is '${sub_cmd_map[$1]}'"
		# calls handler of the subcommand
		${sub_cmd_map[$1]} "$@"
		# remembers its exit code
		local exit_code=$?
		# cleanups global variables and function assignments
		__rh_cleanup
		# return with exit code of the subcommand
		return $exit_code
	fi

	echo "${__rh_red}Unknown subcommand '${1}'${__rh_rst}"
	__rh_print_help
	__rh_cleanup
	return 1

}

# Bash autocompletion for rh command
#   debugging note:
#     To debug __rh_complete behaviour set RH_DEBUG variable in your current terminal,
#     i.e. type `export RH_DEBUG=/absolute/path/to/log/file/or/pipe`
#     and in another terminal, type `tail -f /absolute/path/to/log/file/or/pipe`.
#     Pipe writes will cause rh autocompletion to block, until someone reads the written data from pipe.
#   Bash autocompletion docs:
#     see https://iridakos.com/programming/2018/03/01/bash-programmable-completion-tutorial
#     see https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion.html
#     see https://www.gnu.org/software/bash/manual/html_node/Programmable-Completion-Builtins.html
#     see (search for COMP_*) https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html#Bash-Variables
__rh_complete() {

	__rh_filter_reply() {

		# $1 is thw wordlist
		# $2 is the current partial
		# $3 is the current whole word
		# $4 indicates whether the current word is the last one
		local wordlist="$1"
		local partial="$2"
		local word="$3"
		local is_last_word="$4"

		# TODO: https://github.com/koalaman/shellcheck/wiki/SC2207
		COMPREPLY=($(compgen -W "$wordlist" "$partial"))

		if [[ ${#COMPREPLY[@]} == 1 && $is_last_word == 0 ]]; then
			COMPREPLY=("${COMPREPLY[0]} ")

		# if we are applying an autocomplete hint in a MIDDLE of the current word
		# we add an explicit space at the end of the hint to push the remaining part of the current word
		# to a next position
		elif [[ ${#COMPREPLY[@]} == 1 && $partial != "$word" ]]; then
			COMPREPLY[0]="${COMPREPLY[0]} "

		fi

		__rh_debug_reply

	}

	__rh_debug_reply() {
		if [[ -n $RH_DEBUG ]]; then
			{
				echo -n "  COMPREPLY (${#COMPREPLY[@]}) = "
				for i in "${COMPREPLY[@]}"; do
					echo -n "'$i' "
				done
				echo ""
			} >>"$RH_DEBUG"
		fi
	}

	__rh_unset_local_fn() {
		unset __rh_filter_reply
		unset __rh_debug_reply
		unset __rh_unset_local_fn
	}

	# see https://github.com/koalaman/shellcheck/wiki/SC2206
	local before_point="${COMP_LINE:0:$COMP_POINT}"
	local after_point="${COMP_LINE:$COMP_POINT}"
	local partials
	IFS=" " read -r -a partials <<<"$before_point"
	local partial="${partials[$COMP_CWORD]}"
	local is_last_word=0
	if [[ $after_point == "" ]]; then
		is_last_word=1
	fi

	if [[ -n $RH_DEBUG ]]; then
		{
			echo "---------------------------"
			echo "__rh_complete DEBUG:"
			echo "  COMP_LINE = '$COMP_LINE'"
			echo "  COMP_CWORD = $COMP_CWORD"
			echo "  COMP_POINT = $COMP_POINT"
			echo "  before_point = '$before_point'"
			echo "  after_point = '$after_point'"
			echo "  is_last_word = $is_last_word"
			echo -n "  partials (${#partials[@]}) = "
			for i in "${partials[@]}"; do
				echo -n "'$i' "
			done
			echo ""
			echo "  partial = '$partial'"
			echo -n "  COMP_WORDS (${#COMP_WORDS[@]}) = "
			for i in "${COMP_WORDS[@]}"; do
				echo -n "'$i' "
			done
			echo ""
		} >>"$RH_DEBUG"
	fi

	# rh subcommands
	if [[ $COMP_CWORD == 1 ]]; then
		# TODO: get subcommand names from sub_cmd_map (currently it is a local variable in rh function)
		__rh_filter_reply \
			"help env versions sw projects cd dev ldev wcd rosdep-check-src rosdep-install-src" \
			"$partial" \
			"${COMP_WORDS[1]}" \
			$is_last_word
		__rh_unset_local_fn
		return
	fi

	local sub_cmd="${COMP_WORDS[1]}"

	# rh cd arguments
	if [[ $sub_cmd == "cd" && $COMP_CWORD == 2 ]]; then
		__rh_filter_reply "$(__rh_get_project_names)" "$partial" "${COMP_WORDS[2]}" $is_last_word
		__rh_unset_local_fn
		return
	fi

	# rh sw arguments
	if [[ $sub_cmd == "sw" && $COMP_CWORD == 2 ]]; then
		__rh_filter_reply "$(__rh_get_ros_versions)" "$partial" "${COMP_WORDS[2]}" $is_last_word
		__rh_unset_local_fn
		return
	fi

	# no autocomplete hint
	__rh_debug_reply

	__rh_unset_local_fn
	return

}

# register __rh_complete as autocomplete function for rh command
complete -F __rh_complete rh
