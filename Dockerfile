FROM osrf/ros:humble-desktop-full


    # ros-humble-ros2-control \
    # ros-humble-ros2-controllers \
    # ros-humble-slam-toolbox \
    # ros-humble-v4l2-camera \
    # ros-humble-nav2-bringup \
    # ros-humble-nav2-msgs \
    # ros-humble-nav2-mppi-controller \
    # ros-humble-navigation2 \
    # ros-humble-cv-bridge \
    # ros-humble-xacro \
    # ros-humble-velodyne \
    # ros-humble-rmw-cyclonedds-cpp \


# # Use Cyclone DDS as middleware
# RUN apt-get update && apt-get install -y --no-install-recommends \
# ros-humble-rmw-cyclonedds-cpp
# ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
# Example of installing programs


RUN apt-get update \
    && apt-get install -y \
    nano \
    vim \
    git \
    python3-rosdep \
    python3-pip \
    v4l-utils \
    ros-humble-v4l2-camera \
    ros-humble-velodyne \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/WiringPi/WiringPi.git
RUN cd WiringPi && ./build

RUN git clone --recurse-submodules https://github.com/Iredele/scrap_ws.git
RUN cd scrap_ws
WORKDIR /scrap_ws
RUN mkdir -p src
RUN mv diff_drive_HWInterface/ src/
RUN mv README.md src/
RUN mv scrap_pkg/ src/
RUN mv velodyne/ src/

RUN apt-get update \
# && sudo rosdep init \
&& rosdep update \
&& rosdep install --from-paths src --ignore-src -r -y \
&& rm -rf /var/lib/apt/lists/*


# RUN rosdep install --from-paths src --rosdistro humble -y --ignore-src --skip-keys="diagnostic-updater"


# RUN sudo rosdep install -i --from-path src --rosdistro humble -y --skip-keys="diagnostic-updater"


# Example of copying a file
COPY config/ /site_config/


# Create a non-root user
ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && mkdir /home/$USERNAME/.config && chown $USER_UID:$USER_GID /home/$USERNAME/.config


# Set up sudo
RUN apt-get update \
  && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  && rm -rf /var/lib/apt/lists/*


# Copy the entrypoint and bashrc scripts so we have 
# our container's environment set up correctly
COPY entrypoint.sh /entrypoint.sh
COPY bashrc /home/${USERNAME}/.bashrc


# Set up entrypoint and default command
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
CMD ["bash"]