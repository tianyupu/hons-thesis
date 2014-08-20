#!/bin/bash

# A basic setup script for Python 3.4 on Ubuntu 12.04, as well as
# installing scikit-learn and its dependencies, since Python 3.4
# is not included in Ubuntu 12.04 official repositories

TEMP_DIR=~/install-sklearn

SKLEARN_VERSION="scikit-learn-0.15.1"
NUMPY_VERSION="numpy-1.8.1"
SCIPY_VERSION="scipy-0.14.0"
NOSE_VERSION="nose-1.3.3.tar.gz"

SKLEARN_URL="https://pypi.python.org/packages/source/s/scikit-learn/$SKLEARN_VERSION.tar.gz"
NUMPY_URL="http://downloads.sourceforge.net/project/numpy/NumPy/1.8.1/$NUMPY_VERSION.tar.gz"
SCIPY_URL="http://downloads.sourceforge.net/project/scipy/scipy/0.14.0/$SCIPY_VERSION.tar.gz"
NOSE_URL="https://pypi.python.org/packages/source/n/nose/$NOSE_VERSION.tar.gz"

# Install build dependencies
sudo apt-get install build-essential libatlas-dev liblapack-dev libblas-dev gfortran

# Install Python 3.4 and dev headers from PPA
sudo apt-add-repository ppa:fkrull/deadsnakes
sudo apt-get update
sudo apt-get install python3.4 python3.4-dev

# Download the scipy, numpy and scikit-learn tarballs and extract them
mkdir $TEMP_DIR
cd $TEMP_DIR

wget $SKLEARN_URL $NUMPY_URL $SCIPY_URL $NOSE_URL

tar xvf "$SKLEARN_VERSION.tar.gz" "$NUMPY_VERSION.tar.gz" "$SCIPY_VERSION.tar.gz" "$NOSE_VERSION.tar.gz"

# Build and install
for folder in $NUMPY_VERSION $SCIPY_VERSION $SKLEARN_VERSION $NOSE_VERSION
do
  cd $folder
  python3.4 setup.py build
  sudo python3.4 setup.py install
  cd ..
done

# Clean up
rm -rf $TEMP_DIR/*
cd ~
rmdir $TEMP_DIR

# State that we are done
echo "setup-sklearn script completed"
