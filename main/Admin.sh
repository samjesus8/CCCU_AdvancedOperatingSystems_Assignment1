#!/bin/sh

# User Creation
UserCreate(){
    local username=$1 # Username to store
    local PIN=$2
    password=""

    # Creating user
    sudo adduser --disabled-password $username

    # Prompt for password and store it
    sudo chpasswd

    # Check if the file exists, if not, create it
    if [ ! -f "UPP.txt" ]; then
        touch "UPP.txt"
    fi

    # Append the username, password, and PIN to the file
    echo "$username:$password:$PIN" >> "UPP.txt"
}

# Call the UserCreate function if arguments are passed
if [ "$1" = "UserCreate" ]; then
    UserCreate "$2" "$3" "$4"
fi