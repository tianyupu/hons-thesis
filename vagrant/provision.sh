#!/usr/bin/env bash

cd /vagrant/vagrant

apt-get update
apt-get install -y curl python-software-properties unzip git vim tmux

# OpenJDK 6 (for WEKA)
apt-get install -y default-jdk

# TeX Live
source setup-texlive.sh

# Python 3.4 and scipy, numpy, and scikit-learn
source setup-python.sh

# Go to the vagrant folder in the project root folder and run user provision scripts
su -c "source user-provision.sh" vagrant