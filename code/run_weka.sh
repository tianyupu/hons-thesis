#!/bin/bash

# A script to automate the running of Weka on a given dataset.
#
# Given an ARFF file, train and test different classifiers on it and write the
# results to a file (whose filename contains the current timestamp) for closer
# examination after the run.
#
# Can run all classifiers or a specific classifier (specified on the command
# line as the second argument, after the input ARFF file path).

# Weka configuration
weka_cp=~/Downloads/weka-3-7-11/weka.jar
common_options="-t $1" # options common to all weka classifiers
jvm_heapsize=1024m

# Output file configuration
prefix=weka_result
suffix=`date +%Y%m%d%H%M%S`
separator="########################################"
outdir=../data/results/
outfile=$outdir$prefix$suffix

# Weka classifier classes, with classifier-specific options
clf[1]=weka.classifiers.bayes.NaiveBayes
clf[2]=weka.classifiers.trees.J48
clf[3]=weka.classifiers.functions.Logistic
clf[4]=weka.classifiers.functions.SMO
clf[5]="weka.classifiers.lazy.IBk -K 10"
clf[6]=weka.classifiers.lazy.KStar
clf[7]="weka.classifiers.functions.MultilayerPerceptron -H i"

# if we didn't specify an input file name to this script, exit
if [ -z $1 ]; then
  echo "Please specify an input ARFF file. Exiting."
  exit 1
fi

# execute a single classifier
if [ $2 ]; then
  echo "Training a single classifier: ${clf[$2]}..."
  java -Xmx$jvm_heapsize -cp $weka_cp ${clf[$2]} $common_options >> $outfile
  echo "Complete."
  exit 0
fi

# else use all classifiers and append results to an output file
for index in {1..7}
do
  echo "Training classifier $index: ${clf[index]}..."
  java -Xmx$jvm_heapsize -cp $weka_cp ${clf[index]} $common_options >> $outfile
  for j in {0..1}
  do
    echo $separator >> $outfile
  done
done

echo "Complete."
exit 0
