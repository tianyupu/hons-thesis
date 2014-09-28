#!/usr/bin/env bash

usage_msg () {
  echo "Usage: ./summarise_results.sh -n <num groups> -x <num runs> -f <input file>"
}

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
    *)
      echo "Unknown option: $key"
      ;;
  esac
done

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

echo "NUMGROUPS: $NUMGROUPS"
echo "NUMRUNS: $NUMRUNS"
echo "RESULTFILE: $RESULTFILE"
echo "TRAINING FILE: $(head $RESULTFILE -n 2 | tail -n 1)"

build_cmd () {
  search_string=$1
  fields_to_retrieve=$2
  awk_main=$3
  cat $RESULTFILE | grep -E "$search_string" | tail -n+$(($group*$NUMRUNS+1)) | \
    head -n $NUMRUNS | awk "$fields_to_retrieve" | awk -v runs=$NUMRUNS "$awk_main"
}

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
