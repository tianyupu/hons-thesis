#!/usr/bin/python3.4

import csv
import os.path

csv_defaults = {'delimiter': ',', 'quotechar': '"'}

def makepath(*args):
    return os.path.normpath(os.path.join(*args))

def strip_ws_normalise_headings(dir_path, infile_path, outfile_path):
    """Reads an input CSV file and strips trailing whitespace, converts
    all characters in heading names to lowercase, and replaces spaces with
    underscores, writing the result to a new CSV file in the same directory.
    
    Takes a folder path, input file name, and output file name as strings.
    """
    input_path = makepath(dir_path, infile_path)
    output_path = makepath(dir_path, outfile_path)

    with open(input_path) as infile:
        csv_reader = csv.reader(infile, **csv_defaults)
        with open(output_path, 'w') as outfile:
            csv_writer = csv.writer(outfile, **csv_defaults)
            headings = None
            for row in csv_reader:
                if headings is None:
                    # convert headings to lowercase and replace spaces
                    # and slashes
                    row = map(str.lower, row)
                    table = str.maketrans({' ': '_', '/': ''})
                    row = [field.translate(table) for field in row]
                    headings = row
                # strip whitespace in each item of the row
                row = map(str.strip, row)
                # write to file
                csv_writer.writerow(list(row))

def separate_data(has_headings, *data_path):
    """Returns three lists, one with n samples and m features from the original
    CSV data, and the other with n labels for each of the samples, and the
    last one with the headings (if the data had any).
    This prepares the data for use with scikit-learn.

    Assumes that the class labels are in the last column of each row.

    Takes a string of the path to the data file, as well as a boolean
    indicating whether the CSV file has headings (which are not treated as part
    of the features or labels).
    """
    feature_matrix = []
    label_vector = []
    headings = None

    with open(makepath(*data_path)) as datafile:
        csv_reader = csv.reader(datafile, **csv_defaults)
        for row in csv_reader:
            if headings is None and has_headings:
                headings = row
                continue
            feature_matrix.append(row[:-1])
            label_vector.append(row[-1])

    return (feature_matrix, label_vector, headings)

def extract_features(dir_path, infile_path, outfile_path, headings):
    """Creates a new CSV file with only the given headings present, writing out
    a new file given by outfile_path. This means that we can extract a subset
    of all features and work with only those features/headings.

    Careful: don't forget to include the target attribute as the last item
    in headings!

    Takes a folder path, input filename, output filename as strings, and a
    list of strings containing the names of the headings we wish to keep.
    """
    if not headings:
        return
    input_path = makepath(dir_path, infile_path)
    output_path = makepath(dir_path, outfile_path)

    with open(input_path) as datafile:
        csv_reader = csv.DictReader(datafile, **csv_defaults)
        with open(output_path, 'w') as outfile:
            csv_writer = csv.DictWriter(outfile, headings, **csv_defaults)
            # preserve the headings in the first row, since DictReader reads
            # them and then doesn't count them as part of the data
            csv_writer.writerow({heading: heading for heading in headings})
            for row in csv_reader:
                # only keep the row if it's in the list we specified
                row = {k:v for k,v in row.items() if k in headings}
                csv_writer.writerow(row)

if __name__ == '__main__':
    data_dir = '../../data'
    orig_file = 'trauma_los.csv'
    cleaned_file = 'trauma_los_cleaned.csv'
    extract_file = 'trauma_los_cleaned_extract.csv'
    desired_headings = ['sex', 'normalvitals', 'gcs1', 'ssa']

    strip_ws_normalise_headings(data_dir, orig_file, cleaned_file)
    extract_features(data_dir, cleaned_file, extract_file, desired_headings)
    X, y, headings = separate_data(True, data_dir, extract_file)
