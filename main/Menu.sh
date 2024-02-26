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


#####################
### RUNNING CODE ####
#####################

# Enter username/password
echo -n "Username: "
read uname

echo -n "Password: "
read pass

# Verify they are correct

# Show menu
while true;do
	Menu
done
