#!/bin/sh

# Username passed as a parameter so we can import correct file
uname="$1"

sim_data_path="$(pwd)/simdata/simdata_$uname.txt"

# Check if the simdata file exists
if [ ! -f "$sim_data_path" ]; then
    echo "Error: Simdata file not found for user '$uname'!!!"
    return
fi

# Read the simdata file line by line
while IFS= read -r line; do
    # Split the line into individual bytes
    IFS=', ' read -r -a bytes <<< "$line"

    # Process each byte in FIFO manner
    for byte in "${bytes[@]}"; do
        echo "Processing byte: $byte"
    done
done < "$sim_data_path"