#!/bin/sh

#Menu Display & Select
Menu()
{
	echo "\033[37;44mMake your selection or type bye to exit:\033[0m"
	echo "\033[32m1. FIFO\033[0m"
	echo "\033[32m2. LIFO\033[0m"
	echo "\033[31mType in BYE to logout & exit the program\033[0m"
	echo "Please Enter Selection:"
	read Sel
	MenuSel $Sel
}

#Menu case
MenuSel()
{
	uppercase_input=$(echo "$1" | tr '[:lower:]' '[:upper:]')
	
	case $uppercase_input in
		1) sh FIFO.sh;;
		
		2) sh LIFO.sh;;
		
		BYE) exit;;

		*) echo "Invalid Selection"
		
		sleep 1
		Menu;;
	esac
}

Verify_Credentials(){
	local uname=$1
    local pass=$2

    # Read UPP.txt line by line
    while IFS=: read -r username password _; do
        # Check if the provided username matches the one in the file
        if [ "$uname" = "$username" ]; then
            # Check if the provided password matches the one in the file
            if [ "$pass" = "$password" ]; then
                echo "Login successful!"
                return 0  # Successful login
            else
                echo "Incorrect password!"
                return 1  # Incorrect password
            fi
        fi
    done < "UPP.txt"

    echo "Username not found!"
    return 2  # Username not found
}


#####################
### RUNNING CODE ####
#####################

while true; do
    # Enter Username
    echo -n "Username: "
    read uname

    # Enter Password
    echo -n "Password: "
    read pass

    echo

    # Verify Credentials
    Verify_Credentials "$uname" "$pass"
	
    # If successful login, show menu
    if [ $? -eq 0 ]; then
        Menu
        break
    fi
done
