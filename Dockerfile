FROM osrf/ros:humble-desktop

RUN apt-get update && apt-get install -y --no-install-recommends \
      ros-humble-turtlesim \
      '~nros-humble-rqt*' \
      python3-colcon-common-extensions \
      git vim \
    && rm -rf /var/lib/apt/lists/*

RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc
WORKDIR /root/ws