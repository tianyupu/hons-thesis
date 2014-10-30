#!/usr/bin/env bash

# A script that quicky calls summarise_results.sh and writes a CSV.

usage_msg () {
  echo "Usage: ./fast_summary.sh -n <num groups> -x <num runs> -f <input file>"
}

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

eval "./summarise_results.sh -n $NUMGROUPS -x $NUMRUNS -f $RESULTFILE | python3.4 compute_ci.py | tr ' ' ',' > "$RESULTFILE.csv""
