#!/bin/bash
# Input and output files
INPUT_FILE="web-extensions.txt"
# Default = /usr/share/wordlists/seclists/Discovery/Web-Content/web-extensions.txt
OUTPUT_FILE="web-extensions-double.txt"
# Clear the output file if it exists
> $OUTPUT_FILE
# Loop through each line (extension) in the input file
while read -r EXT; do
 echo "$EXT.png" >> $OUTPUT_FILE
 echo "$EXT.jpg" >> $OUTPUT_FILE
 echo "$EXT.jpeg" >> $OUTPUT_FILE
 echo "$EXT.gif" >> $OUTPUT_FILE
done < "$INPUT_FILE"
# Notify user
echo "Results written to $OUTPUT_FILE"
