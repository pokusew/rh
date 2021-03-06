#!/usr/bin/env bash

set -e

rm -rf temp
mkdir -p temp
cd temp

mkdir -p a/1 a/2 a/3 b/1 b/4 b/4/install b/5 b/5/ws b/5/ws/devel opt/ros/kinetic home/another/ros/foxy
touch b/5/ws/.catkin_workspace
touch b/4/.workspace
touch a/1/.colcon_workspace

cat >b/5/ws/devel/setup.bash <<END
#!/usr/bin/env bash

echo "setup running"
END

cat >b/4/install/local_setup.bash <<END
#!/usr/bin/env bash

echo "local setup running"
END

cat >opt/ros/kinetic/setup.bash <<END
#!/usr/bin/env bash

echo "ROS 1 kinetic activated"
END

cat >home/another/ros/foxy/setup.bash <<END
#!/usr/bin/env bash

echo "ROS 2 foxy activated"
END
