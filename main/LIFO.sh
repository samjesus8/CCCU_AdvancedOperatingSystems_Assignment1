#!/bin/sh

uname="$1"

# Path to the simdata file
sim_data_path="$(pwd)/simdata/simdata_$uname.txt"

# Check if the simdata file exists
if [ ! -f "$sim_data_path" ]; then
    echo "Error: Simdata file not found for user '$uname'."
    exit 1
fi

# Read the simdata file line by line and store the lines in an array
lines=()
while IFS= read -r line; do
    lines+=("$line")
done < "$sim_data_path"

# Process each line in reverse order
for ((i=${#lines[@]}-1; i>=0; i--)); do
    # Store each byte in an array
    bytes=$(echo "${lines[i]}" | tr ',' '\n')

    # Process each byte in reverse order
    for byte in $(echo "$bytes" | sed '1!G;h;$!d'); do
        # Remove any non-numeric characters
        byte=$(echo "$byte" | tr -cd '0-9')

        # Output the processed byte
        echo "Processing byte: B$byte"
    done
done