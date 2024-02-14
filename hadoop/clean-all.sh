#!/bin/bash

# Check if a file name is provided as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

# Assign the first argument to a variable
FILENAME=$1

# Check if the file exists
if [ ! -f "$FILENAME" ]; then
    echo "File not found: $FILENAME"
    exit 1
fi

REMOTE_COMMAND="if [ ! -f ~/ha ]; then rm -rf ~/ha; fi; if [ ! -f ~/hadoop-2.7.4/logs ]; then rm -rf ~/hadoop-2.7.4/logs"

while IFS= read -r line
do
    ssh -n "$line" "$REMOTE_COMMAND"
done < "$FILENAME"
