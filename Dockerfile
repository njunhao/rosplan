FROM osrf/ros:kinetic-desktop-full

# install ROSPlan dependencies (wget and unzip is for running bash script to install openCV)
RUN apt-get update \
	&& apt-get -y install \
	flex  \
	ros-kinetic-move-base-msgs \
	ros-kinetic-mongodb-store \
	ros-kinetic-tf2-bullet \
	ros-kinetic-laser-geometry \
	freeglut3-dev \
	python-catkin-tools \
	bison \
	libbdd-dev \
	wget \
	unzip

# install openCV
COPY install_opencv2_ubuntu.sh install_opencv2_ubuntu.sh

# need to do chmod for older versions of Docker
RUN /bin/bash -c "chmod +x ./install_opencv2_ubuntu.sh \
	&& ./install_opencv2_ubuntu.sh"

# download packages
RUN /bin/bash -c "mkdir -p /workspace/ROS/ROSPlan/src \
	&& cd /workspace/ROS/ROSPlan/src \
	&& git clone https://github.com/clearpathrobotics/occupancy_grid_utils \
	&& git clone https://github.com/KCL-Planning/rosplan"

# install ROSPlan
RUN /bin/bash -c "source /opt/ros/kinetic/setup.bash \
	&& cd /workspace/ROS/ROSPlan \
	&& rosdep update \
	&& catkin build"

# clean up
RUN rm ./install_opencv2_ubuntu.sh ./opencv-2.4.13.5.zip \
	&& apt-get autoclean \
	&& apt-get clean all \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /tmp/* /var/tmp/*

# source ROS environment
RUN echo "source /workspace/ROS/ROSPlan/devel/setup.bash --extend" >> /root/.bashrc

WORKDIR /workspace