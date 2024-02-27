#!/bin/bash

Menu(){
    echo "Admin Menu"
    echo "1. Create User"
    echo "2. Delete User"
    echo "3. Modify User"
    echo "4. Exit"
    read Selection
    MenuSelect $Selection
}

MenuSelect(){
    uppercase_input=$(echo "$1" | tr '[:lower:]' '[:upper:]')

    case $uppercase_input in
        1) UserCreate;;

        4) exit;;

        *) echo "Invalid option"
           sleep 1
           Menu;;
    esac
}

# User Creation
UserCreate(){
    while true; do
        # Prompt for username
        echo "Please enter Username: "
        read username

        while true; do
            # Prompt for password and store it
            echo "Please enter password: "
            read password

            if [ ${#password} -eq 5 ]; then
                echo "Password length is 5."
                break
            else
                echo "Password must be exactly 5 characters long!"
                continue
            fi
        done

        while true; do
            # Prompt for PIN and store it
            echo "Please enter PIN: "
            read PIN

            if [[ $PIN =~ ^[0-9]{3}$ ]]; then
                echo "PIN length is 3."
                break
            else
                echo "PIN must be exactly 3 digits and must contain valid integers!"
                continue
            fi
        done
        break
    done

    # Check if the file exists, if not, create it
    if [ ! -f "UPP.txt" ]; then
        touch "UPP.txt"
    fi

    # Append the username, password, and PIN to the file
    echo "$username:$password:$PIN:user" >> "UPP.txt"
}

ChangePassword(){
    echo "Change Password"
}

while true; do
    Menu
done
