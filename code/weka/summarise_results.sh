#!/usr/bin/env bash

# A script to get certain parts of result files and either summarise them
# or output them for summarising by compute_ci.py.

usage_msg () {
  echo "Usage: ./summarise_results.sh -n <num groups> -x <num runs> -f <input file> [-v] [-a]"
  echo "If -a is specified, then -v is turned on as well as it is assumed the output won't
    be piped into compute_ci.py"
}

# Default behaviour
VERBOSE=false
FIND_AVGS=false

# Process command line arguments
while [[ $# > 0 ]]; do
  key=$1
  shift
  case $key in
    -n)
      NUMGROUPS="$1"
      shift
      ;;
    -x)
      NUMRUNS="$1"
      shift
      ;;
    -f)
      RESULTFILE="$1"
      shift
      ;;
    -v)
      VERBOSE=true
      ;;
    -a)
      FIND_AVGS=true
      ;;
    *)
      echo "Unknown option: $key"
      ;;
  esac
done

# Check that the inputs make sense
if [ -z $NUMGROUPS ] || [ -z $NUMRUNS ] || [ -z $RESULTFILE ]; then
  echo "Please specify all arguments."
  usage_msg
  exit 1
fi
if [ ! -e $RESULTFILE ]; then
  echo "Input file does not exist."
  exit 2
fi

NUMBER=^[1-9][0-9]*
if [[ ! $NUMGROUPS =~ $NUMBER ]] || [[ ! $NUMRUNS =~ $NUMBER ]]; then
  echo "Number of groups or runs is not a valid number."
  exit 3
fi

# Special output for verbose mode
verbose () {
  echo "NUMGROUPS: $NUMGROUPS"
  echo "NUMRUNS: $NUMRUNS"
  echo "RESULTFILE: $RESULTFILE"
  echo "TRAINING FILE: $(head $RESULTFILE -n 2 | tail -n 1)"
}

# If -a is set, assume manual mode and set verbose on
if [ $FIND_AVGS = true ]; then
  VERBOSE=true
fi

# If -v set, then print verbose output, otherwise print terse output for
# compute_ci.py
if [ $VERBOSE = true ]; then
  verbose
else
  echo "$NUMGROUPS"
  echo "$NUMRUNS"
fi

# Build the chain of commands that will get us the numbers we want. At least
# reduces code in the section below
build_cmd () {
  search_string=$1
  fields_to_retrieve=$2
  awk_main=$3
  if [ $FIND_AVGS = true ]; then
    cat $RESULTFILE | grep -E "$search_string" | tail -n+$(($group*$NUMRUNS+1)) | \
      head -n $NUMRUNS | awk "$fields_to_retrieve" | awk -v runs=$NUMRUNS "$awk_main"
  else
    cat $RESULTFILE | grep -E "$search_string" | tail -n+$(($group*$NUMRUNS+1)) | \
      head -n $NUMRUNS | awk "$fields_to_retrieve" 
  fi
}

# Output for each desired group of metrics
# TODO: remove spaghetti.
echo "avg_correct"
for group in $(seq 0 $(($NUMGROUPS-1)))
do
  build_cmd "^Correctly" '{print $4}' 'BEGIN {numcorrect = 0} {numcorrect += $0} END {print numcorrect/runs}'
done

echo "avg_tp avg_fp avg_prec avg_rec avg_auc"
for group in $(seq 0 $(($NUMGROUPS-1)))
do
  build_cmd "^[ ]{15,}0.*0$" '{print $1, $2, $3, $4, $7}' '
      BEGIN {tp = 0; fp = 0; prec = 0; rec = 0; auc = 0;}
      {tp += $1; fp += $2; prec += $3; rec += $4; auc += $5}
      END {print tp/runs, fp/runs, prec/runs, rec/runs, auc/runs}'
done

echo "avg_tp avg_fp avg_prec avg_rec avg_auc"
for group in $(seq 0 $(($NUMGROUPS-1)))
do
  build_cmd "^[ ]{15,}0.*1$" '{print $1, $2, $3, $4, $7}' '
      BEGIN {tp = 0; fp = 0; prec = 0; rec = 0; auc = 0;}
      {tp += $1; fp += $2; prec += $3; rec += $4; auc += $5}
      END {print tp/runs, fp/runs, prec/runs, rec/runs, auc/runs}'
done

echo "avg_tp avg_fp avg_prec avg_rec avg_auc"
for group in $(seq 0 $(($NUMGROUPS-1)))
do
  build_cmd "^Weighted" '{print $3, $4, $5, $6, $9}' '
      BEGIN {tp = 0; fp = 0; prec = 0; rec = 0; auc = 0;}
      {tp += $1; fp += $2; prec += $3; rec += $4; auc += $5}
      END {print tp/runs, fp/runs, prec/runs, rec/runs, auc/runs}'
done
