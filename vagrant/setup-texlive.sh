#!/usr/bin/env bash

echo "=== INSTALLING TEXLIVE"
apt-add-repository ppa:texlive-backports/ppa -y
apt-get update > /dev/null
apt-get install -y texlive texlive-base texlive-latex-extra texlive-bibtex-extra pgf > /dev/null
apt-get upgrade -y > /dev/null
