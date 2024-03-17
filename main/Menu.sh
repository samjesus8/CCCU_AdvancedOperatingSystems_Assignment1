#!/bin/sh

# Declare usertype outside of methods because we will be using it for various purposes
usertype=""

# Menu Display & Select
Menu() {
    echo -e "\033[33mMain Menu\033[0m"
    echo "========================================="
    echo -e "\033[32m1. FIFO\033[0m"
    echo -e "\033[32m2. LIFO\033[0m"

	# For Admin Users only
    if [ "$usertype" = "admin" ]; then
        echo -e "\033[32m3. Admin Menu\033[0m"
        echo -e "\033[32m4. Change Password\033[0m"
    fi

    # Display option 3 for regular users
    if [ "$usertype" = "user" ]; then
        echo -e "\033[32m3. Change Password\033[0m"
    fi

    echo "========================================="
    echo -e "\033[31mType in BYE to logout & exit the program\033[0m"
    echo
    echo "Please Enter Selection:"
    read Sel
    MenuSel $Sel
}

# Menu case
MenuSel() {
    # Convert menu input into ALL uppercase
    uppercase_input=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    
    case $uppercase_input in
        1) clear
            echo "Starting FIFO simulation..."
            echo

            # Clear screen before starting
            sleep 5
            clear

            # Execute FIFO.sh
            sh FIFO.sh $uname
            echo

            # Once execution is finished, return to main menu
            Menu
            ;;
        
        2) clear
            echo "Starting LIFO simulation..."
            echo
        
            sleep 5
            clear
            
            # Execute LIFO.sh
            sh LIFO.sh $uname
            echo

            # Return to menu once execution is finished
            Menu
            ;;
        
		# Execute Admin.sh if the user logged, in is an admin
        3) if [ "$usertype" = "admin" ]; then
               clear
               sh Admin.sh
           else
               echo
           fi

            # Otherwise if its a normal user, execute Change Password
            if [ "$usertype" = "user" ]; then
                clear
                UserChangePassword
            else
                echo
            fi
           ;;
        
        # Execute Change Password if the user logged in, is an admin
        4) if [ "$usertype" = "admin" ]; then
                clear
                UserChangePassword
            else
                echo
            fi
            ;;
        
        BYE) while true; do
                echo "Do you really want to exit??? (Y/n)"
                read confirmexit

                # Verify if user really wants to exit
                if [ $confirmexit = "Y" ] || [ $confirmexit = "y" ]; then
                    # Play exit loading animation
                    loading_animation "exit" &
                    loading_pid=$!
                    sleep 3

                    kill $loading_pid
                    wait $loading_pid 2>/dev/null

                    # Clear screen before shutting down program
                    clear
                    exit
                    break
                elif [ $confirmexit = "N" ] || [ $confirmexit = "n" ]; then
                    # If user says no, clear the screen and go back to menu
                    clear
                    Menu
                    break
                else
                    echo
                fi
            done
            ;;

        *) echo "Invalid Selection!!!"
        
        sleep 1
        Menu;;
    esac
}

GenerateSimData(){
    # Implicit path to the simdata file
    sim_data_path="$(pwd)/simdata/simdata_$uname.txt"

    # Check if sim-data exists, if not create it
    if [ ! -f "$sim_data_path" ]; then
        touch $sim_data_path
        echo "$sim_data_path dosen't exist. Creating new data-set..."

        for ((i=0; i<10; i++)); do
            # Generate a random number between 0 and 99
            random_number=$(printf "B%02d" $((RANDOM % 100)))
            # Append the random number to the file
            echo -n "$random_number, " >> "$sim_data_path"
        done

        echo >> $sim_data_path
    fi

    # Ask user if they want to modify their sim-data
    echo -n "Would you like to edit your simdata (Y/n) "
    read sim_confirmation

    if [ $sim_confirmation = "Y" ] || [ $sim_confirmation = "y" ]; then
        # Edit the file
        echo "Editing file: simdata_$uname.txt"
        echo "Please enter 10 entries from B0 to B99 (separated by comma-spaces):"

        read -p "Data: " entries

        # Validate entries
        valid_entries=true
        IFS=', ' read -r -a entry_array <<< "$entries"
        if [ "${#entry_array[@]}" -ne 10 ]; then
            valid_entries=false
        else
            for entry in "${entry_array[@]}"; do
                if [[ ! "$entry" =~ ^B[0-9][0-9] ]]; then
                    valid_entries=false
                    break
                fi
            done
        fi

        if [ "$valid_entries" = false ]; then
            echo "Invalid input. Please enter exactly 10 entries from B0 to B99."
        else
            echo "$entries" > "$sim_data_path"
            echo "Entries successfully updated in simdata_$uname.txt"
        fi

    elif [ $sim_confirmation = "N" ] || [ $sim_confirmation = "n" ]; then
        echo

    else
        echo "Please enter 'Y' to change simdata or 'n' to proceed to main menu!!!"
    fi
}

UserChangePassword(){
    # Ask for current password
    echo -n "Enter your current password: "
    read -s current_password
    echo

    # Verify current password
    if grep -q "^$uname:$current_password:" UPP.txt; then
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
                    sed -i "s/^$uname:$current_password:/$uname:$new_password:/" UPP.txt
                    echo "Password changed successfully!!!"
                    break
                else
                    echo "Passwords do not match! Please try again!!!"
                fi
            else
                echo "New password must be exactly 5 characters long. Please try again!!!"
            fi
        done
    else
        echo "Incorrect password!!!"
    fi

    # Return to main menu
    sleep 1
    clear
    Menu
}

Verify_Credentials() {
    # Use grep to search UPP.txt quietly for the credentials based on regular expression
    grep -q "^$uname:$pass:" UPP.txt
}

loading_animation() {
    local type=$1 # Input for animation type
    local chars="/-\|" # Chars for the animation frames
    local delay=0.1 # Delay between each frame
    local i=0 # Index for chars

    while true; do
        if [ "$type" = "load" ]; then
            printf "\rLoading... %c" "${chars:$i:1}"
        fi

        if [ "$type" = "exit" ]; then
            printf "\rShutting Down... %c" "${chars:$i:1}"
        fi

        sleep $delay

        # Update value of i to next index in char string
        i=$(( (i + 1) % ${#chars} ))
    done
}

# ==========================
# = PROGRAM STARTING POINT =
# ==========================

# Clear terminal before starting program
clear

while true; do
    # Enter Credentials
    echo -n "Username: "
    read uname

    echo -n "Password: "
    read -s pass

    echo

    # Verify the Credentials
    Verify_Credentials

    if Verify_Credentials; then
        # If successful login, set usertype and show menu
        if [ $? -eq 0 ]; then
            while IFS=: read -r username password pin user_type _; do
                if [ "$uname" = "$username" ]; then
                    usertype="$user_type"
                    break
                fi
            done < "UPP.txt"

            # Play loading animation
            loading_animation "load" &
            loading_pid=$!  # Save the PID of the loading animation process
            sleep 3 # Simulate loading for 3 seconds

            # Stop the loading animation
            kill $loading_pid   # Stop the loading animation process
            wait $loading_pid 2>/dev/null # Suppress error message if the process has already finished

            # Prompt for simdata changes
            clear
            GenerateSimData

            # Clear screen before showing menu
            clear
            Menu
            break
        fi
    else
        # Login failed so ask the user to input valid credentials again
        clear
        echo -e "\033[31mLogin Failed!!!\033[0m"
        echo
    fi
done