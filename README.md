# rh - ROS Helper

A simple helper to make working with different ROS versions and projects easier.
Powerful autocompletion included.


## Installation

**Requirements:**
* Bash 4+

See INSTALLATION comment in [rh.sh](./rh.sh).


## Usage

Upon successful installation, type `rh help`:

```
$ rh help
rh - ROS helper
A simple helper to make working with different ROS versions and projects easier.
Version: 0.0.2
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
