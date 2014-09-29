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
#
# Another optional fourth argument to the script is to specify whether or not
# to save ROC curve data for the model. Specify the -r flag to do so.

# Define a function that prints out usage information for various missing
# argument cases
usage_msg ()
{
  echo "Usage: ./run_weka.sh -i <input arff file> -w <filename with list of weka commands> [-n <number of runs>] [-r]"
}

# Initialise some variables
TRAINING_FILE=
WEKACONFIG=
OUTPUT_ROC=false

# Process command line arguments
while [[ $# > 0 ]]; do
  key="$1"
  shift
  case $key in
    -i)
      TRAINING_FILE="$1"
      shift
      ;;
    -w)
      WEKACONFIG="$1"
      shift
      ;;
    -n)
      RUNS="$1"
      shift
      ;;
    -r)
      OUTPUT_ROC=true
      ;;
    *)
      echo "Unknown option: $key"
      usage_msg
      ;;
  esac
done

echo "TRAINING_FILE: $TRAINING_FILE"
echo "WEKACONFIG: $WEKACONFIG"
echo "RUNS: $RUNS"
echo "OUTPUT_ROC: $OUTPUT_ROC"

# Sanity check for the input files
if [ -z "$TRAINING_FILE" ] || [ -z "$WEKACONFIG" ]; then
  echo "Input ARFF file or WEKA config not specified. Exiting."
  usage_msg
  exit 1
fi
if [ ! -e "$TRAINING_FILE" ]; then
  echo "$TRAINING_FILE does not exist. Please check the path and try again."
  exit 2
fi
if [ ! -e "$WEKACONFIG" ]; then
  echo "$WEKACONFIG does not exist. Please check the path and try again."
  exit 3
fi

# Check if the number of runs has been specified
if [ -z $RUNS ]; then
  echo "Number of runs not specified; defaulting to 1."
  RUNS=1
else
  if [[ ! $RUNS =~ ^[1-9][0-9]* ]]; then
    echo "Number of runs specified is not a number."
    exit 4
  fi
  if [ $RUNS -gt 0 ]; then
    echo "Number of runs specified: $RUNS."
  fi
fi

# Weka configuration
WEKA_CP=~/Downloads/weka-3-7-11/weka.jar
# options common to all weka classifiers; -v suppresses training data output
COMMON_OPTIONS="-v -t $TRAINING_FILE"
JVM_HEAPSIZE=1024m

# Output file base configuration
PREFIX=weka_result
CONFIG="$WEKACONFIG" # indicates which config was used
OUT_FOLDER=../../data/results/
TIMESTAMP=`date +%Y%m%d%H%M%S`
OUTFILE=$PREFIX$TIMESTAMP${CONFIG}_$RUNS # use a single file naming scheme for all runs
ROC_FOLDER=${OUT_FOLDER}roc/$OUTFILE # sub folder for roc threshold outputs
RESULTFILE=$OUT_FOLDER$OUTFILE

# Create the output folders if they don't exist
if [ ! -d "$OUT_FOLDER" ]; then
  mkdir -p "$OUT_FOLDER"
fi
if [ ! -d "$ROC_FOLDER" ] && [ $OUTPUT_ROC ]; then
  mkdir -p "$ROC_FOLDER"
fi

# Record what training file and classifiers (and their options) we used and
# how many runs were performed
echo $RUNS >> $RESULTFILE
echo "$TRAINING_FILE" >> $RESULTFILE
cat "$WEKACONFIG" >> $RESULTFILE

# Read all lines of weka config into an array
declare -a CLFS
readarray -t CLFS < "$WEKACONFIG"

# Run all classifiers from a configuration file, substituting the filename
# in the correct place to overcome problems with supplying arguments to
# weka classifiers via the command line.
# sed is run twice to remove a possible double occurrence of $OPTIONS
NUM_LINES=${#CLFS[@]}
LINENUM=0
while [ $LINENUM -lt $NUM_LINES ]; do
  for run in $(seq 1 $RUNS)
  do
    SEED=$RANDOM
    echo "Training classifier $[$LINENUM+1] run #$run with seed $SEED: ${CLFS[LINENUM]}"
    if [ $OUTPUT_ROC ]; then
      ROC_FILE="${LINENUM}_$(echo ${CLFS[LINENUM]} | awk '{print $1}')_$run.arff"
      ROC_OPTION="-threshold-file $ROC_FOLDER/$ROC_FILE"
    fi
    OPTIONS="$ROC_OPTION -s $SEED $COMMON_OPTIONS"
    eval $(echo "java -Xmx$JVM_HEAPSIZE -cp $WEKA_CP ${CLFS[LINENUM]} $OPTIONS >> $RESULTFILE" | sed "s:<OPTS>:$OPTIONS:g" | sed "s:$OPTIONS::2g")
  done
  LINENUM=$[$LINENUM+1]
done

echo "Complete."
