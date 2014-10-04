#!/usr/bin/env bash

apt-add-repository ppa:texlive-backports/ppa -y
apt-get update
apt-get install -y texlive texlive-base texlive-latex-extra texlive-bibtex-extra pgf
apt-get upgrade -y