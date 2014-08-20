#!/usr/bin/python3.4

def strip_ws(dir_path, infile_path, outfile_path):
    """Reads an input CSV file and strips trailing whitespace, writing the
    result to a new CSV file in the same directory.
    
    Takes a folder path, input file name, and output file name as strings.
    """
    import csv
    input_path = dir_path + infile_path
    output_path = dir_path + outfile_path

    with open(input_path, 'rU') as infile:
        csv_reader = csv.reader(infile, delimiter=',', quotechar='"')
        with open(output_path, 'w') as outfile:
            csv_writer = csv.writer(outfile, delimiter=',', quotechar='"')
            for row in csv_reader:
                # strip whitespace in each item of the row
                row = map(str.strip, row)
                # write to file
                csv_writer.writerow(list(row))

if __name__ == '__main__':
    strip_ws('../../data/', 'trauma_los.csv', 'trauma_los_cleaned.csv')
