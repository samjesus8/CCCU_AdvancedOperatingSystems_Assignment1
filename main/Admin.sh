#!/bin/sh

Menu(){
    echo -e "\033[33mAdministrator Menu\033[0m"
    echo "========================================="
    echo -e "\033[32m1. Create User\033[0m"
    echo -e "\033[32m2. Modify User\033[0m"
    echo -e "\033[32m2. Delete User\033[0m"
    echo "========================================="
    echo -e "\033[31m4. Exit\033[0m"
    read Selection
    MenuSelect $Selection
}

MenuSelect(){
    # Convert menu input into ALL uppercase
    uppercase_input=$(echo "$1" | tr '[:lower:]' '[:upper:]')

    case $uppercase_input in
        # 1. Create user
        1) clear
            UserCreate;;

        # 2. Modify User
        2) echo "2";;

        # 3. Delete User
        3) echo "3";;

        # Exit program
        4) echo "Closing..."
            clear
            exit;;

        *) echo "Invalid option"
           sleep 1
           Menu;;
    esac
}

UserCreate(){
    while true; do
        # Prompt for username
        echo -n "Please enter Username: "
        read username
        echo
        
        while true; do
            # Prompt for password and store it
            echo -n "Please enter Password: "
            read -s password

            if [ ${#password} -eq 5 ]; then
                # Confirm Password
                echo
                echo -n "Confirm Password: "
                read -s confirm_password

                if [ $password = $confirm_password ]; then
                    echo
                    echo
                    break
                else
                    echo
                    echo "Passwords do not match! Please try again."
                    echo
                    continue
                fi              
            else
                echo
                echo "Password must be exactly 5 characters long!"
                echo
                continue
            fi
        done

        while true; do
            # Prompt for PIN and store it
            echo -n "Please enter PIN: "
            read PIN

            if [[ $PIN =~ ^[0-9]{3}$ ]]; then
                # Confirm PIN
                echo -n "Confirm PIN: "
                read confirm_pin

                if [ $PIN = $confirm_pin ]; then
                    break
                else
                    echo
                    echo "PIN numbers do not match! Please try again."
                    echo
                    continue
                fi
            else
                echo
                echo "PIN must be exactly 3 digits and must contain valid integers!"
                echo
                continue
            fi
        done
        
        # Confirm details
        echo
        echo "Do you want to create this user??? (Y/n)"
        echo -e "Username: \033[33m$username\033[0m"
        echo -e "Password: \033[33m$password\033[0m"
        echo -e "PIN: \033[33m$PIN\033[0m"
        echo

        read usercreateconfirm

        if [ $usercreateconfirm = "Y" ] || [ $usercreateconfirm = "y" ]; then
            break
        elif [ $usercreateconfirm = "N" ] || [ $usercreateconfirm = "n" ]; then
            clear
            continue
        fi
    done

    # Check if the file exists, if not, create it
    if [ ! -f "UPP.txt" ]; then
        touch "UPP.txt"
    fi

    # Append the username, password, and PIN to the file
    echo "$username:$password:$PIN:user" >> "UPP.txt"

    clear
    echo "Successfully created user!!!"
    echo
}

while true; do
    Menu
done
