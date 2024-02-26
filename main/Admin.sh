#!/bin/sh

Menu(){
    echo "Admin Menu"
    echo "1. Create User"
    echo "2. Exit"
    read Selection
    MenuSelect $Selection
}

MenuSelect(){
    uppercase_input=$(echo "$1" | tr '[:lower:]' '[:upper:]')

    case $uppercase_input in
        1) UserCreate;;

        2) exit;;

        *) echo "Invalid option"
           sleep 1
           Menu;;
    esac
}

# User Creation
UserCreate(){
    # Prompt for username
    echo "Please enter Username: "
    read username

    # Prompt for password and store it
    echo "Please enter password: "
    read password

    # Prompt for PIN and store it
    echo "Please enter PIN: "
    read PIN

    # Check if the file exists, if not, create it
    if [ ! -f "UPP.txt" ]; then
        touch "UPP.txt"
    fi

    # Append the username, password, and PIN to the file
    echo "$username:$password:$PIN" >> "UPP.txt"
}

while true; do
    Menu
done
