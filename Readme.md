# Run

Requires Docker and a Linux desktop with X11/XWayland, `xhost`, and `/dev/dri`, Had to use Docker for my machine

## Enter Docker (terminal)

```bash
git clone https://github.com/mshaik15/uwrt_onboarding.git
cd uwrt_onboarding
bash run.sh
```

For an existing clone, run `bash run.sh` from the repository.

## First build (inside Docker)

```bash
cd /root/ws
source /opt/ros/humble/setup.bash
apt-get update
rosdep update
rosdep install --from-paths src/turtlesim --ignore-src --rosdistro humble -y
colcon build --packages-select turtlesim
```

## Run turtlesim (inside Docker)

```bash
source /root/ws/install/setup.bash
ros2 run turtlesim turtlesim_node
```

## Run teleop — second terminal

From the repository on the host

```bash
bash run.sh
```

Then inside Docker

```bash
source /root/ws/install/setup.bash
ros2 run turtlesim turtle_teleop_key
```

Focus the teleop terminal: arrow keys move, lowercase `p` draws a star, and Ctrl+C exits
