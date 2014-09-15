#!/bin/bash

# A script to automate the running of Weka on a given dataset.
#
# Given an ARFF file, train and test different classifiers on it and write the
# results to a file (whose filename contains the current TIMESTAMP) for closer
# examination after the run.
#
# The classifiers to be tested are loaded in a separate file, whose name is
# specified as the second filename on the command line.

# if we didn't specify an input file name to this script, exit
if [ -z $1 ]; then
  echo "Please specify an input ARFF file. Exiting."
  exit 1
fi

# if we didn't specify a config file
if [ -z $2 ]; then
  echo "Please specify a list of weka classifiers. Exiting."
  exit 2
fi

# Weka configuration
WEKA_CP=~/Downloads/weka-3-7-11/weka.jar
COMMON_OPTIONS="-t $1" # options common to all weka classifiers
JVM_HEAPSIZE=1024m

# Output file configuration
PREFIX=weka_result
TIMESTAMP=`date +%Y%m%d%H%M%S`
CONFIG=$2 # indicates which config was used
OUTDIR=../../data/results/
OUTFILE=$OUTDIR$PREFIX$TIMESTAMP$CONFIG

# read all lines of weka config
declare -a CLFS
readarray -t CLFS < $2

echo $1 >> $OUTFILE
cat $2 >> $OUTFILE

# run all classifiers from a configuration file
NUM_LINES=${#CLFS[@]}
LINENUM=0
while [ $LINENUM -lt $NUM_LINES ]
do
  echo "Training classifier $LINENUM: ${CLFS[LINENUM]}..."
  java -Xmx$JVM_HEAPSIZE -cp $WEKA_CP ${CLFS[LINENUM]} $COMMON_OPTIONS >> $OUTFILE
  LINENUM=$[$LINENUM+1]
done

echo "Complete."
