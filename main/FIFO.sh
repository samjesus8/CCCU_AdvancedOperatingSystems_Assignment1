#!/bin/sh

# Username passed as a parameter so we can import correct file
uname="$1"

sim_data_path="$(pwd)/simdata/simdata_$uname.txt"

# Check if the simdata file exists
if [ ! -f "$sim_data_path" ]; then
    echo "Error: Simdata file not found for user '$uname'!!!"
    exit 1
fi

# Read the simdata file line by line
while IFS= read -r line; do
    # Split the line into individual bytes
    set -- $(echo "$line" | tr ', ' '\n')
    for byte; do
        echo "Processing byte: $byte"
    done
done < "$sim_data_path"