# MCOMD3PST – Advanced Operating Systems - Assignment 1

- Author: Samuel Jesuthas
- Due Date: 20th March 2024 (2PM)

## About

- This assignment focuses on creating a simple menu system using Bash. In the menu, you will be able to execute simulations of FIFO & LIFO on a pre-determined set of data which will be generated upon login

- In order to use this repository, please ensure you have VS Code or equivalent IDE installed on your computer before cloning. You can also run these scripts on any Linux terminal or Git Bash terminal

- To execute this program, you must execute `Menu.sh`, which is the entry point for this application
    - You can do so by opening up a linux/bash terminal and entering the following command

        ```
        sh Menu.sh
        ```
    - If the script does not execute, you might have to make it an executable first

        ```
        chmod -x Menu.sh
        chmod -x Admin.sh
        chmod -x FIFO.sh
        chmod -x LIFO.sh
        ```
    - This program was developed in a Windows environment, so chances are if you are running this in a Linux environment, the program may glitch or behave buggy on execution. To fix this, you can use a tool called `dos2unix`

        ```
        sudo apt-get install dos2unix

        dos2unix Menu.sh Admin.sh FIFO.sh LIFO.sh UPP.txt Usage.txt
        ```
