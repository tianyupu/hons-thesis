#!/usr/bin/env bash

cd /vagrant/vagrant

echo "=== UPDATING PACKAGE MANAGER"
apt-get update > /dev/null

echo "=== INSTALLING TOOLS"
apt-get install -y curl python-software-properties unzip git vim tmux > /dev/null

# OpenJDK 7 (for WEKA)
echo "=== INSTALLING OPENJDK 7 JRE"
apt-get install -y openjdk-7-jre > /dev/null

# TeX Live
source setup-texlive.sh || exit 1

# Python 3.4 and scipy, numpy, and scikit-learn
source setup-python.sh || exit 1

# Go to the vagrant folder in the project root folder and run user provision scripts
su -c "source user-provision.sh" vagrant || exit 1

# State that we are done
echo "=== SETUP OF VIRTUAL MACHINE COMPLETE"
