#!/bin/sh

Menu(){
    echo -e "\033[33mAdministrator Menu\033[0m"
    echo "========================================="
    echo -e "\033[32m1. Create User\033[0m"
    echo -e "\033[32m2. Modify User\033[0m"
    echo -e "\033[32m3. Delete User\033[0m"
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
        2) clear
            UserModify;;

        # 3. Delete User
        3) clear
            UserDelete;;

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

        # Check if username already exists
        if grep -q "^$username:" UPP.txt; then
            echo "Username '$username' already exists. Please enter a different username!!!"
            echo
            continue
        fi
        
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
                    echo "Passwords do not match! Please try again!!!"
                    echo
                    continue
                fi              
            else
                echo
                echo "Password must be exactly 5 characters long!!!"
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
                    echo "PIN numbers do not match. Please try again!!!"
                    echo
                    continue
                fi
            else
                echo
                echo "PIN must be exactly 3 digits and must contain valid integers!!!"
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

UserModify() {
    while true; do
        # Prompt for username to modify
        echo -n "Username: "
        read username
        echo

        # Check if username exists
        if ! grep -q "^$username:" UPP.txt; then
            echo "User '$username' does not exist. Please enter a valid username."
            continue
        fi

        # Get user's current details
        user_details=$(grep "^$username:" UPP.txt)
        current_password=$(echo "$user_details" | cut -d: -f2)
        current_pin=$(echo "$user_details" | cut -d: -f3)

        while true; do
            # Reload User Details
            user_details=$(grep "^$username:" UPP.txt)
            current_password=$(echo "$user_details" | cut -d: -f2)
            current_pin=$(echo "$user_details" | cut -d: -f3)

            # Display options
            echo "Select property to modify:"
            echo "1. Username"
            echo "2. Password"
            echo "3. PIN"
            echo "4. Exit"
            echo

            # Prompt for user's choice
            read -p "Enter your choice: " choice
            echo

            case $choice in
                1)  # Modify username
                    while true; do
                        echo -n "Enter your current username: "
                        read current_username
                        echo

                        if [ "$current_username" != "$username" ]; then
                            echo "Incorrect current username. Please try again!!!"
                            continue
                        fi

                        echo -n "Enter new username: "
                        read new_username
                        echo

                        if grep -q "^$new_username:" UPP.txt; then
                            echo "Username '$new_username' already exists. Please choose a different username!!!"
                            continue
                        fi

                        # Replace username in UPP.txt
                        sed -i "s/^$username:/$new_username:/" UPP.txt
                        echo "Username changed successfully!!!"
                        break
                    done
                    ;;

                2)  while true; do
                        # Prompt for current password
                        echo -n "Enter your current password: "
                        read -s current_password_input
                        echo

                        # Verify current password
                        if [ "$current_password_input" != "$current_password" ]; then
                            echo "Incorrect password!!!"
                            continue                      
                        else
                            break
                        fi
                    done

                    while true; do
                        # Prompt for new password
                        echo -n "Enter your new password (5 characters long): "
                        read -s new_password
                        echo

                        # Check if new password is exactly 5 characters long
                        if [ ${#new_password} -eq 5 ]; then
                            # Prompt to confirm new password
                            echo -n "Confirm your new password: "
                            read -s confirm_password
                            echo

                            # Check if new passwords match
                            if [ "$new_password" = "$confirm_password" ]; then
                                # Update password in UPP.txt
                                sed -i "s/^$username:$current_password:/$username:$new_password:/" UPP.txt
                                echo "Password changed successfully!!!"
                                break
                            else
                                echo "Passwords do not match! Please try again!!!"
                            fi
                        else
                            echo "New password must be exactly 5 characters long. Please try again!!!"
                        fi
                    done
                    ;;

                3)  # Modify PIN
                    echo -n "Enter your current PIN: "
                    read current_pin_input
                    echo

                    if [ "$current_pin_input" != "$current_pin" ]; then
                        echo "Incorrect current PIN. Please try again!!!"
                        continue
                    fi

                    while true; do
                        echo -n "Enter new PIN (3 digits): "
                        read new_pin
                        echo

                        echo -n "Confirm new PIN: "
                        read confirm_pin
                        echo

                        if [ "$new_pin" != "$confirm_pin" ]; then
                            echo "PINs do not match. Please try again!!!"
                            continue
                        fi

                        if [[ $new_pin =~ ^[0-9]{3}$ ]]; then
                            # Update PIN in UPP.txt
                            sed -i "s/^$username:$current_password:$current_pin:/$username:$current_password:$new_pin:/" UPP.txt
                            echo "PIN changed successfully!!!"
                            break
                        else
                            echo "PIN must be exactly 3 digits and must contain valid integers!!!"
                            continue
                        fi
                    done
                    ;;

                4)  # Exit
                    sleep 1
                    clear
                    return
                    ;;

                *)  echo "Invalid option. Please try again!!!";;
            esac
        done
    done
}

UserDelete() {
    while true; do
        # Prompt for username to delete
        echo -n "Enter the username of the user you wish to delete: "
        read username
        echo

        # Check if username exists
        if ! grep -q "^$username:" UPP.txt; then
            echo "User '$username' does not exist. Please enter a valid username!!!"
            continue
        fi

        # Get user's details
        user_details=$(grep "^$username:" UPP.txt)
        current_pin=$(echo "$user_details" | cut -d: -f3)

        # Prompt for PIN
        echo -n "Enter the PIN for user '$username': "
        read entered_pin
        echo

        # Check if entered PIN matches
        if [ "$entered_pin" != "$current_pin" ]; then
            echo "Incorrect PIN for user '$username'. Please try again!!!"
            continue
        fi

        # Confirm deletion
        echo -n "Are you sure you want to delete user '$username'? (Y/n)"
        read confirm_delete
        echo

        if [ "$confirm_delete" = "Y" ] || [ "$confirm_delete" = "y" ]; then
            # Delete user from UPP.txt
            sed -i "/^$username:/d" UPP.txt
            echo "User '$username' deleted successfully!!!"
            break
        elif [ "$confirm_delete" = "N" ] || [ "$confirm_delete" = "n" ]; then
            echo "User deletion cancelled!!!"
            break
        else
            echo "Invalid input. Please enter 'Y' to confirm deletion or 'n' to cancel."
        fi
    done
}

while true; do
    Menu
done
