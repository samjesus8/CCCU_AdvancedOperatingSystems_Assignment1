# Advanced Operating Systems (U14553) - Report

- Author - Samuel Jesuthas - sj481@canterbury.ac.uk
- Date Due - 20th March 2024 (2 PM)

## Bash ’n Sims

- In this report, I will outline my implementation of the menu system proposed by the assignment brief. Each section will explain how the specified feature was implemented and the reasoning for such an implementation.

## Menu.sh

### Display menu on clear screen

```bash
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

            # Log date/time user logged in
            login_time="$(date +"%Y-%m-%d %H:%M:%S")"

            # Clear screen before showing menu
            clear
            Menu
            break
        fi
```

- After the username & password has been validated & simdata has been checked, we can execute `clear` to clear the terminal display before executing `Menu()`.

### Exit via "bye" and Y/n confirmation on exit

```bash
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

                    # Log overall usage to Usage.txt when logging out
                    logout_time="$(date +"%Y-%m-%d %H:%M:%S")"
                    log

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
```
- When the BYE case is triggered, it asks for a Y/n input by simply using `read` into a confirmation variable `confirmexit`. We can then use simple if statements to check if the user typed in Y/n.

- The variable `uppercase_input` converts the entire input into upper-case using `tr`. This means that no matter how the user types "bye", it will always trigger the "BYE" case.

### Return to main menu after Simulation

```bash
        1) clear
            echo "Starting FIFO simulation..."
            echo

            # Clear screen before starting
            sleep 5
            clear

            # Execute FIFO.sh
            sh FIFO.sh $uname
            echo

            # Increment usage count by 1
            fifo_usage_count=$((fifo_usage_count + 1))

            # Once execution is finished, return to main menu
            Menu
            ;;

        # 2. LIFO
        2) clear
            echo "Starting LIFO simulation..."
            echo
        
            sleep 5
            clear
            
            # Execute LIFO.sh
            sh LIFO.sh $uname
            echo

            # Increment usage count by 1
            lifo_usage_count=$((lifo_usage_count + 1))

            # Return to menu once execution is finished
            Menu
            ;;
```

- Once the execution of FIFO.sh/LIFO.sh is complete, we can execute the `Menu()` method to bring back the menu.

### Usage of colour in the menu system

```bash
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

    # For Regular Users only
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
```

- We can use the `-e` parameter when using `echo`, which enables escape sequences. This allows us to implement color in the string we are trying to output.

- For example, `\033` begins colour modifications, `31m` changes the color to red, and then we can use `\033` at the end to mark the end of the modification. **(Ramuglia, 2023)**

### Validation of Login details

```bash
# Use grep to search UPP.txt quietly for the credentials based on regular expression
grep -q "^$uname:$pass:" UPP.txt
```

- We can use `grep` to search the `UPP.txt` file for the username & password that was input by the user at the start of the program. After `uname` & `pass` were inputted, the `Verify_Credentials()` method is executed. This will return a boolean output, 1 meaning a valid user existing, and 0 meaning no user exists.

### Loading animation

```bash
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
```

- The loading animation is played when you login & logout of the program

- We have a few local variables: 
    - `type` is a parameter determining which animation we should play, since we have one for login and logout
    - `chars` is a string representing the different frames of our login animation
    - `delay` is the time between each frame
    - `i` will be used as an iteration variable to go between each character in `chars`

- This loading animation is played for 3 seconds to simulate a realistic loading time

## Admin.sh

### Creating Users

```bash
UserCreate() {
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
```

- **Process**:
    - Admin inputs username, password, and PIN.
    - Checks if the username already exists in the system.
    - Validates the password:
        - Must be exactly 5 characters long.
        - Admin confirms the password for security.
    - Validates the PIN:
        - Must be exactly 3 digits long.
        - Must contain only numeric characters.
    - Admin confirms the details entered.
    - If confirmed (Y/n), the user details are stored in UPP.txt.

- **Validation**:
    - Username:
        - Checked for existence in UPP.txt using `grep`.
    - Password:
        - Exactly 5 characters long.
        - Case-insensitive input achieved through `read -s`.
    - PIN:
        - Exactly 3 digits long.
        - Numeric characters only.

- **Storage**:
    - User details (username, password, PIN) are appended to UPP.txt upon confirmation.

### Modifying Users

```bash
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
        current_usertype=$(echo "$user_details" | cut -d: -f4)

        while true; do
            # Reload user details (whenever modification has been performed)
            user_details=$(grep "^$username:" UPP.txt)
            current_password=$(echo "$user_details" | cut -d: -f2)
            current_pin=$(echo "$user_details" | cut -d: -f3)
            current_usertype=$(echo "$user_details" | cut -d: -f4)

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

                        # If existing username doesn't match with user input, ask them for valid username
                        if [ "$current_username" != "$username" ]; then
                            echo "Incorrect current username. Please try again!!!"
                            continue
                        fi

                        # Ask for new username
                        echo -n "Enter new username: "
                        read new_username
                        echo

                        # Check if new username input already exists
                        if grep -q "^$new_username:" UPP.txt; then
                            echo "Username '$new_username' already exists. Please choose a different username!!!"
                            continue
                        fi

                        # Create a temporary file to store modified contents
                        temp_file=$(mktemp)

                        # Replace username in UPP.txt
                        grep -v "^$username:" UPP.txt > UPP_temp.txt && mv UPP_temp.txt UPP.txt
                        echo "$new_username:$current_password:$current_pin:$current_usertype" >> UPP.txt

                        echo "Username changed successfully!!!"
                        break
                    done
                    ;;

                2)  # Modify Password - Similar Code
                    ;;

                3)  # Modify PIN - Similar Code
                    ;;

                4)  # Exit
                    sleep 1
                    clear

                    # Return to break out of all loops rather than using break function
                    return
                    ;;

                *)  echo "Invalid option. Please try again!!!";;
            esac
        done
    done
}
```

- **Process**:
    - Admin inputs the username of the user to modify.
    - Options for modification are presented: username, password, PIN, or exit.
    - For each modification option:
        - Admin verifies current credentials.
        - Admin inputs new details if applicable.
        - Changes are validated and updated in UPP.txt.

- **Username Modification**:
    - Admin verifies the current username.
    - Admin inputs the new username.
    - New username is checked for existence.
    - If validated, the username is updated in UPP.txt.

- **Password and PIN Modification**:
    - Similar process to username modification.
    - Admin verifies the current password/PIN.
    - Admin inputs the new password/PIN.
    - New password/PIN is validated and updated in UPP.txt.

### Deleting Users

```bash
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
```
- Admin inputs the username of the user to delete.
- Verification is done to check if the username exists in the system.
- Admin inputs the PIN associated with the user for confirmation.
- If the entered PIN matches the user's PIN:
    - Admin is prompted for confirmation to delete the user.
- Admin confirms deletion with 'Y' or cancels with 'n'.
- If confirmed:
    - User is removed from UPP.txt.

## FIFO.sh & LIFO.sh

### FIFO.sh

```bash
# Username passed as a parameter so we can import correct file
uname="$1"

sim_data_path="$(pwd)/simdata/simdata_$uname.txt"

# Check if the simdata file exists
if [ ! -f "$sim_data_path" ]; then
    echo "Error: Simdata file not found for user '$uname'!!!"
    exit 1
fi

# Read the simdata file line by line
while IFS= read -r line; do
    # Split the line into individual bytes
    set -- $(echo "$line" | tr ', ' '\n')
    for byte; do
        echo "Processing byte: $byte"
    done
done < "$sim_data_path"
```

- Checks if the simulation data file exists for the specified user.
- Reads each line of the file and processes each byte individually, maintaining the order.
- Outputs the processed byte.

### LIFO.sh

```bash
# Read the simdata file line by line and store the lines in an array
lines=()
while IFS= read -r line; do
    lines+=("$line")
done < "$sim_data_path"

# Process each line in reverse order
for ((i=${#lines[@]}-1; i>=0; i--)); do
    # Store each byte in an array
    bytes=$(echo "${lines[i]}" | tr ',' '\n')

    # Process each byte in reverse order
    for byte in $(echo "$bytes" | sed '1!G;h;$!d'); do
        # Remove any non-numeric characters
        byte=$(echo "$byte" | tr -cd '0-9')

        # Output the processed byte
        echo "Processing byte: B$byte"
    done
done
```

- Checks if the simulation data file exists for the specified user.
- Reads each line of the file and stores them in an array.
- Processes each line in reverse order, then processes each byte within each line in reverse order.
- Outputs the processed byte.

## Admin_Statistics.sh

- Before the data is shown, the program will extract the relevant data from the Usage.txt
    - Timestamps, usernames, and calculates session times for users
    - Usage counts for FIFO and LIFO scripts.

### Getting total time spent by user

```bash
# Display total time spent by each user
echo "Total time spent by each user:"
echo "$user_times" | while IFS= read -r item; do
    user=$(echo "$item" | cut -d ':' -f1)
    time=$(echo "$item" | cut -d ':' -f2)
    echo "$user: $(seconds_to_time $time)"
done
```

- Here, we `while` loop through each user and `echo` each user's total time spent logged into the system

### Ranking of users

```bash
# Ranking of users based on overall usage time
echo "Ranking of users based on overall usage time:"
echo "$user_times" | sort -nr -k2 | while IFS= read -r item; do
    user=$(echo "$item" | cut -d ':' -f1)
    time=$(echo "$item" | cut -d ':' -f2)
    echo "$user: $(seconds_to_time $time)"
done
```

- Similar code to total time, however we are sorting through each user's total time and displaying them from highest - lowest

### Most used Simulation

```bash
# Find the most popular script
most_popular_script=""
if [ $fifo_count -gt $lifo_count ]; then
    most_popular_script="FIFO"
else
    most_popular_script="LIFO"
fi

echo "Most popular script executed: $most_popular_script: $((fifo_count + lifo_count)) times"
```

- We can loop through each user in the Usage.txt and keep a track of how many times they used FIFO and LIFO in each session. Then we can total these up and see which one is highest, therefore the most used simulation

# References

- Ramuglia, G. (2023) Bash colors: Color codes and syntax cheat sheet, Linux Dedicated Server Blog. Available at: https://ioflood.com/blog/bash-color/ (Accessed: 18 March 2024). 