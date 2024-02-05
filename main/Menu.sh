#!/bin/sh

#This is skel code

#Menu Display & Select
Menu()
{
echo "Make your selection or type bye to exit:" 
echo "1 for FIFO"
echo "2 for LIFO"
echo "BYE for exit"
echo "Please Enter Selection:"
read Sel
MenuSel $Sel
}



#Menu case
MenuSel()
{

case $1 in
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

#Store username in global var
echo "Please Enter Username"
read Uname

while true;do
	Menu
done
