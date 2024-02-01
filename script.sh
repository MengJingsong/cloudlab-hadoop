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

REMOTE_COMMAND="if [ ! -f ~/.ssh/id_rsa ]; then ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' -q; fi"
KEYS_FILE="all_keys"
> "$KEYS_FILE"

# Read the file line by line
while IFS= read -r line
do
    echo "connecting to $line"
    ssh -n "$line" "$REMOTE_COMMAND" </dev/null
    ssh -n "$line" 'cat ~/.ssh/id_rsa.pub' >> "$KEYS_FILE"
    # scp -q "$line:/.ssh/id_rsa.pub" .
    # cat id_rsa.pub >> "$KEYS_FILE"
    echo "connecting to $line finished"
done < "$FILENAME"

while IFS= read -r line
do
    scp "$KEYS_FILE" "$line:/users/jason92/$KEYS_FILE"
    ssh -n "$line" "cat /users/jason92/$KEYS_FILE >> /users/jason92/.ssh/authorized_keys;rm /users/jason92/$KEYS_FILE"
done < "$FILENAME"
