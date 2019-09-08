#!/bin/bash

# OpenCV compiler and installer script
#
# This script is specifically created for Ubuntu (16.04 18.04)
# and Raspberry Pi http://www.raspberrypi.org but should work over any
# Debian-based distribution

# Current version of OpenCV 4.1.1

user_os=$(awk -F'"' '/^NAME/{print $2}' /etc/os-release)
current_cv=4.1.1
current_opencv_contrib=4.1.1
cores=$(nproc)
working_directory=$(pwd)

if [ "$(whoami)" != "root" ]; then
	echo "Sorry, this script must be executed with sudo or as root"
	exit 1
fi

echo
echo "----------------"
echo "Updating sources"
echo "----------------"
echo

apt-get update -qq

echo
echo "-----------------------"
echo "Installing dependencies"
echo "-----------------------"
echo
	
apt-get install -y build-essential cmake unzip pkg-config wget git
apt-get install -y libjpeg-dev libpng-dev libtiff-dev
apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
apt-get install -y libxvidcore-dev libx264-dev
apt-get install -y libgtk-3-dev
apt-get install -y libatlas-base-dev gfortran
apt-get install -y python3-dev python3-numpy python3-testresources

echo
echo "-------------------------------------"
echo "Downloading and installing Python PIP"
echo "-------------------------------------"
echo

sudo python3 $working_directory/extras/scripts/get-pip.py

echo
echo "-------------------------"
echo "Checking Operating System"
echo "-------------------------"
echo

if [[ $user_os = "Raspbian GNU/Linux" ]]
then
	echo
	echo "------------------------------------"
	echo "Installing Raspberry Pi dependencies"
	echo "------------------------------------"
	echo
	
	apt-get install -y libcanberra-gtk*
	apt-get install -y libavcodec-extra libjasper1 libjasper-dev libeigen3-dev libtbb-dev
	
	echo
	echo "---------------------------------"
	echo "Downloading and installing OpenCV"
	echo "---------------------------------"
	echo

	cd $working_directory/extras/pi/debs
	sudo dpkg -i OpenCV*.deb
	sudo ldconfig

	read -n 1 -r -s -p $'\nPress enter to continue...\n'

	echo
	echo "-----------------------------"
	echo "Checking OpenCV was installed"
	echo "-----------------------------"
	echo

	python3 $working_directory/extras/scripts/cv_test.py

	read -n 1 -r -s -p $'\nPress enter to continue...\n'

	echo
	echo "--------------------"
	echo "installing PIP Files"
	echo "--------------------"
	echo

	pip install --user dlib
	pip install --user imutils
	pip install --user scipy
	pip install --user scikit-learn
	pip install --user face_recognition


	echo
	echo "-------------------"
	echo "Removing temp files"
	echo "-------------------"
	echo

	rm -rf $working_directory/extras
	rm -rf ~/.cache/pip 

	echo
	echo "--------------------"
	echo "Finished!! Enjoy it!"
	echo "--------------------"
	echo

else

	echo
	echo "--------------------"
	echo "Decompressing OpenCV"
	echo "--------------------"
	echo

	mdkir -p $working_directory/extras/opencv/build

	echo
	echo "-------------------------------"
	echo "Compiling and installing OpenCV"
	echo "-------------------------------"
	echo

	cmake -D CMAKE_BUILD_TYPE=RELEASE \
		-D CMAKE_INSTALL_PREFIX=/usr/local \
		-D INSTALL_PYTHON_EXAMPLES=ON \
		-D INSTALL_C_EXAMPLES=OFF \
		-D OPENCV_ENABLE_NONFREE=ON \
		-D OPENCV_EXTRA_MODULES_PATH=$working_directory/extras/opencv_contrib/modules \
		-D PYTHON_EXECUTABLE=/usr/bin/python3 \
		-D BUILD_EXAMPLES=ON ..

	make -j$cores
	sudo make install
	sudo ldconfig

## TODO Fix the auto linking

	#sudo ln -s /usr/local/lib/python3.6/dist-packages/cv/python3.6/
	
	echo
	echo "-----------------------------"
	echo "Checking OpenCV was installed"
	echo "-----------------------------"
	echo

	python3 $working_directory/extras/scripts/cv_test.py

	read -n 1 -r -s -p $'\nPress enter to continue...\n'


	echo
	echo "-------------------"
	echo "Removing temp files"
	echo "-------------------"
	echo

	cd ~
	rm -rf $working_directory/extras/script/get-pip.py
	rm -rf ~/.cache/pip 
	rm -rf $working_directory/extras/pi

	echo
	echo "--------------------"
	echo "Finished!! Enjoy it!"
	echo "--------------------"
	echo