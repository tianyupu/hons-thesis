#!/bin/bash

# A script to automate the running of Weka on a given dataset.
#
# Given an ARFF file, train and test different classifiers on it and write the
# results to a file (whose filename contains the current TIMESTAMP) for closer
# examination after the run.
#
# The classifiers to be tested are loaded in a separate file, whose name is
# specified as the second filename on the command line. If they require using
# one classifier in another, make sure <OPTS> is specified at the correct place
# to include the training file commands in the right place.
#
# An optional third argument to the script is to specify the number of runs
# of the classifiers. This must be a positive integer, and defaults to 1.

# If we didn't specify an input file name to this script, exit
if [ -z $1 ]; then
  echo "Please specify an input ARFF file. Exiting."
  exit 1
fi

# If we didn't specify a config file
if [ -z $2 ]; then
  echo "Please specify a list of weka classifiers. Exiting."
  exit 2
fi

# Check if the number of runs has been specified
if [ -z $3 ]; then
  echo "Number of runs not specified; defaulting to 1."
  RUNS=1
else
  if [ $3 -gt 0 ]; then
    echo "Number of runs specified: $3."
    RUNS=$3
  fi
fi

# Weka configuration
WEKA_CP=~/Downloads/weka-3-7-11/weka.jar
COMMON_OPTIONS="-t $1" # options common to all weka classifiers
JVM_HEAPSIZE=1024m

# Output file base configuration
PREFIX=weka_result
CONFIG=$2 # indicates which config was used
OUTDIR=../../data/results/

# Read all lines of weka config into an array
declare -a CLFS
readarray -t CLFS < $2

# Run the classifiers $RUNS times
for RUN in $(seq 1 $RUNS)
do
  echo "Executing run $RUN..."
  # Create the output file based on the current timestamp of the run
  TIMESTAMP=`date +%Y%m%d%H%M%S`
  OUTFILE=$OUTDIR$PREFIX$TIMESTAMP$CONFIG
  # Record what data file and classifiers we are using in the results file
  # for later reference
  echo $1 >> $OUTFILE
  cat $2 >> $OUTFILE
  # Run all classifiers from a configuration file, substituting the filename
  # in the correct place to overcome problems with supplying arguments to
  # weka classifiers via the command line.
  # sed is run twice to remove a possible double occurrence of $COMMON_OPTIONS
  NUM_LINES=${#CLFS[@]}
  LINENUM=0
  while [ $LINENUM -lt $NUM_LINES ]
  do
    echo "Training classifier $LINENUM: ${CLFS[LINENUM]}..."
    eval $(echo "java -Xmx$JVM_HEAPSIZE -cp $WEKA_CP ${CLFS[LINENUM]} $COMMON_OPTIONS >> $OUTFILE" | sed "s:<OPTS>:$COMMON_OPTIONS:g" | sed "s:$COMMON_OPTIONS::2g")
    LINENUM=$[$LINENUM+1]
  done
done

echo "Complete."
