
import csv
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--input-file')
parser.add_argument('--output-file')

args = parser.parse_args()

inputFile=args.input_file
outputFile=args.output_file
columnsRequired=["Postcode 1","Location"]

with open(inputFile) as inf:
    with open(outputFile, 'w' ) as outf:
        writer = csv.writer(outf)
        reader = csv.DictReader(inf)
        for row in reader:
            cols=[]
            for field in columnsRequired:
                cols.append(row[field].replace(" ", ""))
                cols.append(row[field].replace("(", ""))
                cols.append(row[field].replace(")", ""))
            writer.writerow(cols)
