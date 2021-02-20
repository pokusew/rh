#!/usr/bin/env bash

set -e

rm -rf temp
mkdir -p temp
cd temp

mkdir -p a/1 a/2 a/3 b/1 b/4 b/5 b/5/ws b/5/ws/devel opt/ros/kinetic
touch b/5/ws/.catkin_workspace

cat > b/5/ws/devel/setup.bash << END
#!/usr/bin/env bash

echo "setup running"
END

cat > opt/ros/kinetic/setup.bash << END
#!/usr/bin/env bash

echo "ROS 1 kinetic activated"
END

export RH_PROJECTS_DIRS="$PWD/a:$PWD/b"
export RH_ROS_1_INSTALL_DIR="$PWD/opt/ros"

source ../rh.sh
rh env
rh versions
rh sw kinetic --silent
rh projects
rh cd 5
