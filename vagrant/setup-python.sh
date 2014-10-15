#!/usr/bin/env bash

# A basic setup script for Python 3.4 on Ubuntu 12.04, as well as
# installing scikit-learn and its dependencies, since Python 3.4
# is not included in Ubuntu 12.04 official repositories

temp_dir=~/install-sklearn

sklearn_name="scikit-learn-0.15.1"
numpy_name="numpy-1.8.1"
scipy_name="scipy-0.14.0"
nose_name="nose-1.3.3"
pyparsing_name="pyparsing-2.0.2"
pydot_name="prologic-pydot-ac76697320d6"

sklearn_url="https://pypi.python.org/packages/source/s/scikit-learn/$sklearn_name.tar.gz"
numpy_url="http://downloads.sourceforge.net/project/numpy/NumPy/1.8.1/$numpy_name.tar.gz"
scipy_url="http://downloads.sourceforge.net/project/scipy/scipy/0.14.0/$scipy_name.tar.gz"
nose_url="https://pypi.python.org/packages/source/n/nose/$nose_name.tar.gz"
pyparsing_url="http://downloads.sourceforge.net/project/pyparsing/pyparsing/pyparsing-2.0.2/$pyparsing_name.zip"
pydot_url="https://bitbucket.org/prologic/pydot/get/ac76697320d6.zip"

# Install build dependencies and extras
echo "=== INSTALLING PYTHON BUILD DEPENDENCIES"
sudo apt-get install -y build-essential libatlas-dev liblapack-dev libblas-dev gfortran graphviz wget > /dev/null

# Install Python 3.4 and dev headers from PPA
echo "=== INSTALLING PYTHON 3.4"
sudo apt-add-repository ppa:fkrull/deadsnakes -y
sudo apt-get update > /dev/null
sudo apt-get install -y python3.4 python3.4-dev > /dev/null

# Download the packages
mkdir $temp_dir
cd $temp_dir

echo "=== DOWNLOADING PACKAGES FOR SCIKIT-LEARN, NUMPY, SCIPY AND DEPENDENCIES"
wget $sklearn_url $numpy_url $scipy_url $nose_url $pyparsing_url
wget -O $pydot_name.zip $pydot_url

# Extract, build and install tars
for package in $numpy_name $scipy_name $sklearn_name $nose_name
do
  tar xvf "$package.tar.gz"
  cd $package
  echo "=== BUILDING AND INSTALLING $package FROM SOURCE"
  python3.4 setup.py build
  sudo python3.4 setup.py install
  cd ..
done

# Extract and install zips
for package in $pyparsing_name $pydot_name
do
  unzip "$package.zip"
  cd $package
  echo "=== INSTALLING $package FROM SOURCE"
  sudo python3.4 setup.py install
  cd ..
done

# Clean up
sudo rm -rf $temp_dir
