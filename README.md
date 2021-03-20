# rh - ROS Helper

[![build status](https://img.shields.io/github/workflow/status/pokusew/rh/CI?logo=github)](https://github.com/pokusew/rh/actions?query=workflow%3ACI)

A simple helper to make working with different ROS versions and projects easier.
Powerful autocompletion included.


## Installation

**Requirements:** Bash 4+

1. Download the current version of [rh.sh](https://raw.githubusercontent.com/pokusew/rh/master/rh.sh).

2. Add something like the following to your `~/.bashrc` **(supply your own values)**:
    ```bash
    export RH_PROJECTS_DIRS="/some/dir1:/another/dir2:/some/completely/different/dir3"
    export RH_ROS_INSTALL_DIRS="/opt/ros"
    source path/to/rh.sh
    ```
    **Note:** There can be multiple dirs specified in `*_DIRS` variables.
    Individual dirs are separated by `:`, the left-most specified directory has the highest priority.

The same info can be also found directly in the [**INSTALLATION** comment in rh.sh](./rh.sh#L5).


## Usage

Upon successful installation, type `rh help`:

```
$ rh help
rh - ROS helper
A simple helper to make working with different ROS versions and projects easier.
Version: 0.0.3
Usage: rh <command> [command options]
Commands:
  rh help
    prints this help
  rh env
    prints env variables related to ROS
  rh versions
    lists all available ROS 1 and ROS 2 versions
    versions are searched in dirs specified in RH_ROS_INSTALL_DIRS
  rh sw <ros version name>
    activates given ROS version
    versions are searched in dirs specified in RH_ROS_INSTALL_DIRS
  rh projects
    lists all available projects
    projects are searched in dirs specified in RH_PROJECTS_DIRS
  rh cd <project name>
    changes into workspace of the given project
    projects are searched in dirs specified in RH_PROJECTS_DIRS
  rh dev
    tries to source devel/setup.bash (relative to the current working dir)
  rh wcd
    recursively searches for catkin workspaces and changes to first found
    and sources its devel/setup.bash
```
