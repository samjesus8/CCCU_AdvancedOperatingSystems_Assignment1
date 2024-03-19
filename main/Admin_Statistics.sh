#!/bin/sh

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

# Initialize variables
user_times=""
fifo_count=0
lifo_count=0

# Read from Usage.txt
while IFS= read -r line; do
    # Extract timestamp and username
    timestamp=$(echo "$line" | sed -n 's/.*\[\([^]]*\)].*/\1/p')
    user=$(echo "$line" | sed -n 's/.*Menu.sh - \([^ ]*\).*/\1/p')

    if [ -n "$timestamp" ] && [ -n "$user" ]; then
        if echo "$line" | grep -q 'has logged in'; then
            login_time=$(date -d "$timestamp" "+%s")
        elif echo "$line" | grep -q 'has logged out'; then
            logout_time=$(date -d "$timestamp" "+%s")

            # Calculate session time
            session_time=$((logout_time - login_time))

            # Update total time spent by user
            user_times="$user_times $user:$session_time"
        fi
    fi

    # Extract script usage counts
    if echo "$line" | grep -qE 'FIFO Usage: [0-9]+ times'; then
        count=$(echo "$line" | grep -oE '[0-9]+')
        fifo_count=$((fifo_count + count))
    elif echo "$line" | grep -qE 'LIFO Usage: [0-9]+ times'; then
        count=$(echo "$line" | grep -oE '[0-9]+')
        lifo_count=$((lifo_count + count))
    fi
done < Usage.txt

# Display total time spent by each user
echo "Total time spent by each user:"
echo "$user_times" | while IFS= read -r item; do
    user=$(echo "$item" | cut -d ':' -f1)
    time=$(echo "$item" | cut -d ':' -f2)
    echo "$user: $(seconds_to_time $time)"
done

echo

# Ranking of users based on overall usage time
echo "Ranking of users based on overall usage time:"
echo "$user_times" | sort -nr -k2 | while IFS= read -r item; do
    user=$(echo "$item" | cut -d ':' -f1)
    time=$(echo "$item" | cut -d ':' -f2)
    echo "$user: $(seconds_to_time $time)"
done

echo

# Find the most popular script
most_popular_script=""
if [ $fifo_count -gt $lifo_count ]; then
    most_popular_script="FIFO"
else
    most_popular_script="LIFO"
fi

echo "Most popular script executed: $most_popular_script: $((fifo_count + lifo_count)) times"