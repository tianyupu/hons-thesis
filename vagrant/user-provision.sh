#!/usr/bin/env bash

# Download and extract WEKA 3.7.11 into $HOME/Downloads
mkdir -p ~/Downloads
cd ~/Downloads

curl http://downloads.sourceforge.net/project/weka/weka-3-7/3.7.11/weka-3-7-11.zip
unzip -x weka-3-7-11.zip