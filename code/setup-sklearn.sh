#!/bin/bash

# A basic setup script for Python 3.4 on Ubuntu 12.04, as well as
# installing scikit-learn and its dependencies, since Python 3.4
# is not included in Ubuntu 12.04 official repositories

TEMP_DIR=~/install-sklearn

SKLEARN_NAME="scikit-learn-0.15.1"
NUMPY_NAME="numpy-1.8.1"
SCIPY_NAME="scipy-0.14.0"
NOSE_NAME="nose-1.3.3"
PYPARSING_NAME="pyparsing-2.0.2"
PYDOT_NAME="prologic-pydot-ac76697320d6"

SKLEARN_URL="https://pypi.python.org/packages/source/s/scikit-learn/$SKLEARN_NAME.tar.gz"
NUMPY_URL="http://downloads.sourceforge.net/project/numpy/NumPy/1.8.1/$NUMPY_NAME.tar.gz"
SCIPY_URL="http://downloads.sourceforge.net/project/scipy/scipy/0.14.0/$SCIPY_NAME.tar.gz"
NOSE_URL="https://pypi.python.org/packages/source/n/nose/$NOSE_NAME.tar.gz"
PYPARSING_URL="http://downloads.sourceforge.net/project/pyparsing/pyparsing/pyparsing-2.0.2/$PYPARSING_NAME.zip"
PYDOT_URL="https://bitbucket.org/prologic/pydot/get/ac76697320d6.zip"

# Install build dependencies and extras
sudo apt-get install build-essential libatlas-dev liblapack-dev libblas-dev gfortran graphviz

# Install Python 3.4 and dev headers from PPA
sudo apt-add-repository ppa:fkrull/deadsnakes
sudo apt-get update
sudo apt-get install python3.4 python3.4-dev

# Download the packages
mkdir $TEMP_DIR
cd $TEMP_DIR

wget $SKLEARN_URL $NUMPY_URL $SCIPY_URL $NOSE_URL $PYPARSING_URL $PYDOT_URL

# Extract, build and install tars
for package in $NUMPY_NAME $SCIPY_NAME $SKLEARN_NAME $NOSE_NAME
do
  tar xvf "$package.tar.gz"
  cd $package
  python3.4 setup.py build
  sudo python3.4 setup.py install
  cd ..
done

# Extract and install zips
for package in $PYPARSING_NAME $PYDOT_NAME
do
  unzip "$package.zip"
  cd $package
  sudo python3.4 setup.py install
  cd ..
done

# Clean up
sudo rm -rf $TEMP_DIR

# State that we are done
echo "setup-sklearn script completed"
