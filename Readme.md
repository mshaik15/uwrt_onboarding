# Setup and run

Requires a Linux desktop, Docker, Git, X11/XWayland (`DISPLAY` set), and `/dev/dri`. The current launcher is not configured for macOS, Windows, or headless hosts. No host ROS installation is required.

## First setup — host terminal

```bash
sudo apt-get update
sudo apt-get install -y git x11-xserver-utils
docker info
echo "$DISPLAY"
ls /dev/dri

git clone https://github.com/mshaik15/uwrt_onboarding.git
cd uwrt_onboarding
bash run.sh
```

## First build — inside Docker

```bash
cd /root/ws
source /opt/ros/humble/setup.bash
apt-get update
rosdep update
rosdep install --from-paths src/turtlesim --ignore-src --rosdistro humble -y
colcon build --packages-select turtlesim
source /root/ws/install/setup.bash
ros2 pkg prefix turtlesim
# Expected: /root/ws/install/turtlesim

ros2 run turtlesim turtlesim_node
```

## Teleop — second host terminal

Run from the cloned repository:

```bash
bash run.sh
```

Inside Docker:

```bash
source /root/ws/install/setup.bash
ros2 run turtlesim turtle_teleop_key
```

Keep this terminal focused. Arrow keys move; lowercase `p` draws a star. Start near the centre and wait about 28 seconds before pressing other keys. Ctrl+C exits.

## Subsequent runs

Host terminal 1, from the repository:

```bash
bash run.sh
```

Inside Docker:

```bash
source /root/ws/install/setup.bash
ros2 run turtlesim turtlesim_node
```

Use the teleop commands above in terminal 2.

## Rebuild after editing or pulling changes

Stop teleop with Ctrl+C. Open a fresh container shell with `bash run.sh`, then:

```bash
cd /root/ws
source /opt/ros/humble/setup.bash
colcon build --packages-select turtlesim
source /root/ws/install/setup.bash
ros2 run turtlesim turtle_teleop_key
```

## Troubleshooting

### Cannot save source files — host terminal

```bash
docker exec uwrt_humble chown -R "$(id -u):$(id -g)" /root/ws/src
```

Retry saving in your editor.

### Docker daemon unavailable — Linux host using systemd

```bash
sudo systemctl start docker
docker info
```

### Docker socket permission denied — host terminal

```bash
sudo usermod -aG docker "$USER"
```

Log out and back in, then retry `docker info` and `bash run.sh`.

### Window does not open / cannot connect to display — host terminal

Run from a terminal in your graphical desktop session. If `DISPLAY` is empty, open a desktop terminal first.

```bash
echo "$DISPLAY"
xhost +si:localuser:root
docker start uwrt_humble
docker exec -it -e DISPLAY="$DISPLAY" uwrt_humble bash
```

Inside Docker:

```bash
source /root/ws/install/setup.bash
ros2 run turtlesim turtlesim_node
```

### Missing `/dev/dri`

Remove the `--device /dev/dri` line from `run.sh`, then retry `bash run.sh`. If Qt reports graphics-driver errors, try inside Docker:

```bash
export QT_XCB_FORCE_SOFTWARE_OPENGL=1
export LIBGL_ALWAYS_SOFTWARE=1
source /root/ws/install/setup.bash
ros2 run turtlesim turtlesim_node
```

### Missing dependencies — inside Docker

```bash
cd /root/ws
source /opt/ros/humble/setup.bash
apt-get update
rosdep update
rosdep install --from-paths src/turtlesim --ignore-src --rosdistro humble -y
colcon build --packages-select turtlesim
```

The root-user warning from `rosdep update` is expected in this container. Do not add `--allow-overriding` if your colcon installation rejects it.

### Old teleop version / pattern key does nothing — inside Docker

Stop teleop, then:

```bash
cd /root/ws
colcon build --packages-select turtlesim
source /root/ws/install/setup.bash
ros2 pkg prefix turtlesim
# Must print: /root/ws/install/turtlesim
ros2 run turtlesim turtle_teleop_key
```

Check for the `Press lowercase 'p' to draw a shape` instruction. Focus the teleop terminal and press `p` without Shift.

### Build folders were deleted

Repeat the first-build commands. `build/`, `install/`, and `log/` are generated locally and ignored by Git.

### Container uses another checkout — host terminal

```bash
docker inspect uwrt_humble --format '{{range .Mounts}}{{println .Source "->" .Destination}}{{end}}'
```

The `/root/ws` mount must point to this checkout. `run.sh` reuses the existing `uwrt_humble` container and `uwrt` image; rebuilding an image does not update an existing container.

To recreate the container, run from the correct checkout. This removes container-only changes and installed dependencies; the mounted repository stays on the host.

```bash
docker stop uwrt_humble
docker rm uwrt_humble
docker build -t uwrt .
bash run.sh
```

Repeat the first-build commands inside the new container.
