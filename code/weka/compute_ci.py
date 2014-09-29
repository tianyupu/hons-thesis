#!/usr/bin/env python3

import re
import sys

# A pattern for matching numbers with at least 1 digit and optional decimals.
number = re.compile(r'[0-9]+(([.]?[0-9]+)|([0-9]*))')

# Compute a normal 95% CI for a sample.
def compute_ci(sample):
    z95 = 1.95996
    sample = list(map(float, sample))
    n = len(sample)
    mean = sum(sample) / n

    stdev = 0
    for x in sample:
        stdev += (x-mean)**2
    stdev *= 1.0 / (n-1)
    stdev **= 0.5

    uncertainty = z95 * stdev / n**0.5

    return (mean, uncertainty)

# These are assumed to be given from the summarise_results.sh script.
ngroups = int(sys.stdin.readline().strip())
nruns = int(sys.stdin.readline().strip())

lines = [line.strip() for line in sys.stdin.readlines()]

# Get the headings for each of the various statistics that we are summarising.
# Keep track of the actual headings, as well as the indices that they appear.
# This is important for output and partitioning.
headings = []
heading_index = 0
indices = []
while heading_index < len(lines):
    indices.append(heading_index)
    headings.append(lines[heading_index])
    heading_index += ngroups * nruns + 1

# For each heading, get the output values and compute a mean and 95% CI for
# them, grouped by the number of distinct classifiers.
for i in range(len(headings)):
    heading = headings[i]
    print(heading)
    # Find the start and end points of all the data belonging to this heading.
    start_index = indices[i] + 1
    if i + 1 >= len(headings):
        partition = lines[start_index:]
    else:
        end_index = indices[i+1]
        partition = lines[start_index:end_index]
    # Split each line of the partition up, in case there are several metrics
    # on one line.
    partition = [line.split() for line in partition]
    # Split the partition into its corresponding groups and summarise the
    # numbers for each group.
    for j in range(0, len(partition), nruns):
        sample = partition[j:j+nruns]
        results = []
        for col in zip(*sample):
            m, u = compute_ci(col)
            results.append('{0:.3f}({1:.5f})'.format(m, u))
        print(' '.join(results))
