#!/bin/bash

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
    echo "Please Enter Selection:"
    read Sel
    MenuSel $Sel
}

# Menu case
MenuSel() {
    uppercase_input=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    
    case $uppercase_input in
        1) sh FIFO.sh;;
        
        2) sh LIFO.sh;;
        
		# Only execute Admin.sh if the user logged in is an admin
        3) if [ "$usertype" = "admin" ]; then
               sh Admin.sh
           else
               echo
           fi

            if [ "$usertype" = "user" ]; then
                UserChangePassword
            else
                echo
            fi
           ;;
        
        BYE) loading_animation "exit" &  # Run the loading animation in the background
                loading_pid=$!       # Save the PID of the loading animation process
                sleep 3              # Simulate loading for 3 seconds

                # Stop the loading animation
                kill $loading_pid    # Stop the loading animation process
                wait $loading_pid 2>/dev/null # Suppress error message if the process has already finished
                exit
                ;;

        *) echo "Invalid Selection"
        
        sleep 1
        Menu;;
    esac
}

UserChangePassword(){
    echo "Change Password"
}

Verify_Credentials() {
    grep -q "^$uname:$pass:" UPP.txt
}

loading_animation() {
    local type=$1
    local chars="/-\|"
    local delay=0.1
    local i=0

    while true; do
        if [ "$type" = "load" ]; then
            printf "\rLoading... %c" "${chars:$i:1}"
        fi

        if [ "$type" = "exit" ]; then
            printf "\rShutting Down... %c" "${chars:$i:1}"
        fi

        sleep $delay
        ((i = (i + 1) % ${#chars}))
    done
}

# ==========================
# = PROGRAM STARTING POINT =
# ==========================

# Verify Credentials
while true; do
    # Enter Username
    echo -n "Username: "
    read uname

    # Enter Password
    echo -n "Password: "
    read -s pass

    echo

    # Verify Credentials
    Verify_Credentials

    if Verify_Credentials; then
        echo "Login Success"
    else
        echo "Login Failed"
    fi

    # If successful login, set usertype and show menu
    if [ $? -eq 0 ]; then
        while IFS=: read -r username password pin usertype _; do
            if [ "$uname" = "$username" ]; then
                echo "User type set to: $usertype"
                usertype="$usertype"
                break
            fi
        done < "UPP.txt"

        loading_animation "load" &  # Run the loading animation in the background
        loading_pid=$!       # Save the PID of the loading animation process
        sleep 3              # Simulate loading for 3 seconds

        # Stop the loading animation
        kill $loading_pid    # Stop the loading animation process
        wait $loading_pid 2>/dev/null # Suppress error message if the process has already finished

        # Clear screen before showing menu
        clear

        Menu
        break
    fi
done