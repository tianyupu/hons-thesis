#!/usr/bin/python3.4

import csv

def strip_ws(dir_path, infile_path, outfile_path):
    """Reads an input CSV file and strips trailing whitespace, writing the
    result to a new CSV file in the same directory.
    
    Takes a folder path, input file name, and output file name as strings.
    """
    input_path = dir_path + infile_path
    output_path = dir_path + outfile_path

    with open(input_path) as infile:
        csv_reader = csv.reader(infile, delimiter=',', quotechar='"')
        with open(output_path, 'w') as outfile:
            csv_writer = csv.writer(outfile, delimiter=',', quotechar='"')
            for row in csv_reader:
                # strip whitespace in each item of the row
                row = map(str.strip, row)
                # write to file
                csv_writer.writerow(list(row))

def separate_data(data_path, has_headings=True):
    """Returns three lists, one with n samples and m features from the original
    CSV data, and the other with n labels for each of the samples, and the
    last one with the headings (if the data had any).
    This prepares the data for use with scikit-learn.

    Assumes that the class labels are in the last column of each row.

    Takes a string of the path to the data file, as well as a boolean
    indicating whether the CSV file has headings (which are not treated as part
    of the features or labels). Default value is True.
    """
    feature_matrix = []
    label_vector = []
    headings = None

    with open(data_path) as datafile:
        csv_reader = csv.reader(datafile, delimiter=',', quotechar='"')
        for row in csv_reader:
            if headings is None:
                headings = row
            feature_matrix.append(row[:-1])
            label_vector.append(row[-1])

    return (feature_matrix, label_vector, headings)

if __name__ == '__main__':
    strip_ws('../../data/', 'trauma_los.csv', 'trauma_los_cleaned.csv')
    X, y, headings = separate_data('../../data/trauma_los_cleaned.csv')
