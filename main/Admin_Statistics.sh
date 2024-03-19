#!/bin/sh

declare -A user_times
declare -A script_counts

# Function to convert time to seconds
time_to_seconds() {
    local h=$(echo $1 | cut -d ':' -f1)
    local m=$(echo $1 | cut -d ':' -f2)
    local s=$(echo $1 | cut -d ':' -f3)
    echo $((h * 3600 + m * 60 + s))
}

# Function to convert seconds to HH:MM:SS format
seconds_to_time() {
    local seconds=$1
    printf "%02d:%02d:%02d" $((seconds / 3600)) $(((seconds % 3600) / 60)) $((seconds % 60))
}

while IFS= read -r line; do
    # Extract timestamp and username
    timestamp=$(echo "$line" | grep -oP '\[\K[^]]+')
    user=$(echo "$line" | grep -oP '(?<=Menu.sh - )[^\s]+')

    if [[ $timestamp && $user ]]; then
        if [[ $line =~ has\ logged\ in ]]; then
            login_time=$(date -d "$timestamp" "+%s")
        elif [[ $line =~ has\ logged\ out ]]; then
            logout_time=$(date -d "$timestamp" "+%s")

            # Calculate session time
            session_time=$((logout_time - login_time))

            # Update total time spent by user
            user_times["$user"]=$((user_times["$user"] + session_time))
        fi
    fi

    # Extract script usage counts
    if [[ $line =~ (FIFO|LIFO)\ Usage:\ ([0-9]+)\ times ]]; then
        script="${BASH_REMATCH[1]}"
        count="${BASH_REMATCH[2]}"
        script_counts["$script"]=$((script_counts["$script"] + count))
    fi
done < Usage.txt

# Display total time spent by each user
echo "Total time spent by each user:"
for user in "${!user_times[@]}"; do
    echo "$user: $(seconds_to_time ${user_times["$user"]})"
done

echo

# Ranking of users based on overall usage time
echo "Ranking of users based on overall usage time:"
rank=1
for user in $(printf "%s\n" "${!user_times[@]}" | sort -nr -k2); do
    echo "$rank. $user: $(seconds_to_time ${user_times["$user"]})"
    ((rank++))
done

echo

# Find most popular script executed
most_popular_script=""
max_count=0
for script in "${!script_counts[@]}"; do
    if (( script_counts["$script"] > max_count )); then
        most_popular_script="$script"
        max_count=${script_counts["$script"]}
    fi
done

echo "Most popular script executed: $most_popular_script: $max_count times"
echo

# Find most popular script overall
most_popular_script_overall=$(printf "%s\n" "${!script_counts[@]}" | sort -nr -k2 | head -n1)
echo "Most popular script overall: $most_popular_script_overall: ${script_counts["$most_popular_script_overall"]} times"