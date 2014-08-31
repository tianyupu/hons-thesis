#!/bin/bash

# A script to automate the running of Weka on a given dataset.
#
# Given an ARFF file, train and test different classifiers on it and write the
# results to a file (whose filename contains the current timestamp) for closer
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
weka_cp=~/Downloads/weka-3-7-11/weka.jar
common_options="-t $1" # options common to all weka classifiers
jvm_heapsize=1024m

# Output file configuration
prefix=weka_result
timestamp=`date +%Y%m%d%H%M%S`
suffix=$2 # indicates which config was used
separator="########################################"
outdir=../../data/results/
outfile=$outdir$prefix$timestamp$suffix

# read all lines of weka config
declare -a clfs
readarray -t clfs < $2

echo $1 >> $outfile
cat $2 >> $outfile

# run all classifiers from a configuration file
num_lines=${#clfs[@]}
i=0
while [ $i -lt $num_lines ]
do
  echo "Training classifier $i: ${clfs[i]}..."
  java -Xmx$jvm_heapsize -cp $weka_cp ${clfs[i]} $common_options >> $outfile
  for j in {0..1}
  do
    echo $separator >> $outfile
  done
  i=$[$i+1]
done

echo "Complete."
exit 0
