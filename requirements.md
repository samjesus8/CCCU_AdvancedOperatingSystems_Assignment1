# Assignment Breakdown

## Main
- Simple menu system, where you can execute 2 bash scripts (`FIFO.sh` or `LIFO.sh`)
- Once execution is finished, return to main menu
- BYE (or bye) will exit the program

## User System
- In a `UPP.db` file, we need to have an admin script that can create & store username, password & PIN
- This script must also possess ability to manage users (Create, Delete, Modify)
- Creating/Deleting users can ONLY be done by admin, whilst changing password can be done by anyone
- Every user MUST be unique. No usernames can have the same name (Implement a check for this)
- When executing this script, it must verify the password and PIN by asking the user to enter it twice

### Passwords
- Passwords MUST be 5 characters long. No smaller or bigger sizes
- PIN MUST be a 3 digit number

## Simulation Scripts

- This is down to individual research on what FIFO and LIFO is
- Simulation data is required in order to execute these scripts:
    - Check if a `simdata_samueljesuthas.job` file exists. If not, create one
    - Load in pre-defined sim data (Which is a queue of 10 bytes), or ask the user to enter in their own set
    - Once everything is set, pass it onto the script and begin execution

## Logging

### User Activity
- MUST keep a log of user activity (Store in `Usage.db` file):
    - Who is logged in?
    - When did they log in (Date & Time)?
    - How long were they logged in for?
    - Which scripts were executed, if any?

### Admin Statistics
- There must also be an Admin script where they can view important statistics about each user:
    - Total time spent by a User
    - Most popular script executed
    - Most popular script overall
    - Ranking of users based on the overall usage time of the system

## Write-up

- A write-up of around 800 words is also to be provided
- Explain how to code works and if it has met the requirements