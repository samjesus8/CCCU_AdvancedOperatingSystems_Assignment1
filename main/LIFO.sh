#!/bin/sh

uname="$1"

# Path to the simdata file
sim_data_path="$(pwd)/simdata/simdata_$uname.txt"

# Check if the simdata file exists
if [ ! -f "$sim_data_path" ]; then
    echo "Error: Simdata file not found for user '$uname'."
    return
fi

# Read the simdata file line by line in reverse order
tac "$sim_data_path" | while IFS= read -r line; do
    # Split the line into individual bytes
    IFS=', ' read -r -a bytes <<< "$line"

    # Process each byte
    for (( i=${#bytes[@]}-1; i>=0; i-- )); do
        echo "Processing byte: ${bytes[i]}"
    done
done