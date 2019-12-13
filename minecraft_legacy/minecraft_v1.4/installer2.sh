#!/bin/bash

################### M3tal_Warriors Minecraft Server Installer #################
# Installs the M3tal_Warrior_Server_Startup_Script, which in fact is a whole
# server maintenance package.

# ================================= Copyright =================================
# Version 1.00 (2012-11-08), Copyright (C) 2011-2012
# Author: M3tal_Warrior (http://www.minecraftwiki.net/wiki/User:M3tal_Warrior)

#   This script is free software: you can redistribute it and/or modify it 
#   under the terms of the GNU General Public License as published by the 
#   Free Software Foundation, either version 3 of the License, or any later 
#   version.
#   This program is distributed in the hope that it will be useful, but 
#   WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
#   or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License 
#   for more details.

#   As this is only a script, theres no copy of the GNU General Public License 
#   distributed along with this script.
#   See <http://www.gnu.org/licenses/> for the licence text.

clear
echo "################## M3tal_Warriors Minecraft Server Installer ##################
Installs the M3tal_Warrior_Server_Startup_Script, which in fact is a whole
server maintenance package.
"
INSTALL="1"
UPDATE="0"
INST_NOOB="0"
SCRIPT_UPDATEURL="http://mcserver.blacksky-dev.com/scripts"
TEMPPATH=/dev/shm/mc_update.tmp

INST_USER=`whoami`
if cat /etc/group | grep "sudo" | grep "$MCUSERNAME" > /dev/null
  then INST_USER="sudoer"
fi
if [ `whoami` = "root" -o "$INST_USER" = "sudoer" ]
  then
    echo "OK, you're root/sudoer, let's go!"
  else
    echo "BEWARE: For this installer you need SUDO rights! Do you have them? (y/n)"
    read INST_CHOICE
    INST_REDO="1"
    while [ "$INST_REDO" = "1" ]
      do
        case $INST_CHOICE in
          y)
            echo "All right, let's do it!"
            INST_REDO="0"
            ;;
          n)
            echo "Sorry pal, we need them desperately. Invocate the script from a user with SUDO
rights."
            exit 1
            ;;
          *)
            INST_NOOB=$(( $INST_NOOB + 1 ))
            echo "You don't seem to find y or n on your keyboard - you're sure it's a good idea
to install a server without even basic computer skills? (y/n)"
            read INST_CHOICE
            case $INST_CHOICE in
              y)
                echo "Well, we live and learn... So, do you have SUDO rights?"
                read INST_CHOICE
                ;;
              n)
                echo "You're right, it's not a good idea. But I trust you will find some other servers
very amusing too."
                exit 1
                ;;
              *)
                echo "I wonder how you were even able to run the script. No server for you, pal! Try
having fun at other servers where you don't put yourself at risk..."
                exit 1
                ;;
            esac
            ;;
        esac
      done
fi
echo "Is this by chance an update from some previous script? (y/n)"
read INST_CHOICE
INST_REDO="1"
while [ "$INST_REDO" = "1" ]
  do
    case $INST_CHOICE in
      y)
        echo "Fine, I'll try to spare you some work, if I'm able to."
        INST_REDO="1"
        while [ "$INST_REDO" = "1" ]
          do
            echo "Do you want me trying to read your old settings in? (y/n)"
            read INST_CHOICE
            case $INST_CHOICE in
              y)
                echo "Okey-doke!
"
                UPDATE="1"
                INST_REDO="0"
                ;;
              n)
                echo "Basicly new install then - as you wish!
"
                UPDATE="0"
                INST_REDO="0"
                ;;
              *)
                echo "Man, that is neither y nor n. Learn reading your keyboard!
"
                INST_NOOB=$(( $INST_NOOB + 1 ))
                INST_REDO="1"
                ;;
            esac
          done
        ;;
      n)
        echo "Well, could have been, could it? Nevermind...
"
        UPDATE="0"
        INST_REDO="0"
        ;;
      *)
        echo "You are not a typewriting chimp, are you?
"
        INST_NOOB=$(( $INST_NOOB + 1 ))
        INST_REDO="1"
        ;;
    esac
  done

echo "
First a little introduction what we're gonna do:
  1. Create or select a user to run the minecraft server
  2. Download the scripts and configs
  3. Download your desired server
  4. Installing everything
  5. Starting the whole thing

[Press ENTER to proceed]"
read INST_CHOICE
clear
echo "---------------------------- Step 1 - User creation ----------------------------"
echo "What name do you prefer for the minecraft user (default: 'minecraft')? 
Be careful, as the name must match the Debian naming conditions (just numbers 
and small letters, no space nor symbols)
"
INST_REDO="1"
while [ "$INST_REDO" = "1" ]
  do
    echo "[Press ENTER to use default]"
    read MCUSERNAME
    echo ""
    if [ "$MCUSERNAME" = "" ]
      then MCUSERNAME="minecraft"
    fi
    if cat "/etc/passwd" | cut -d ':' -f 1 -s | grep -iw "$MCUSERNAME" > /dev/null
      then
        if cat /etc/group | grep "sudo" | grep "$MCUSERNAME" > /dev/null
          then SUDOER="yes"
          else SUDOER=""
        fi
        if [ "$UPDATE" = "1" ]
          then
            echo "User accepted."
            INST_REDO="0"
          else
            echo "User $MCUSERNAME already exists. Do you really want to use it? (y/n)" 
            read INST_CHOICE
            echo ""
            case $INST_CHOICE in
              y)
                echo "All right. Depending on your further decisions and system configuration this 
might or might not be a problem."
                INST_REDO="0"
                ;;
              n)
                echo "Chose different name:"
                INST_REDO="1"
                ;;
              *)
                INST_NOOB=$(( $INST_NOOB + 1 ))
                echo "Remember: Only y or n are available options. I don't see how $INST_CHOICE is
to be seen as such...
"
                echo "Now, what username do you want to use for the minecraft server?"
                INST_REDO="1"
                ;;
            esac
        fi 
        if [ "$INST_REDO" = "0" ]
          then
            if [ "$SUDOER" = "yes" ]
              then
                echo "This user has sudo rights! It is strongly advised not to use a sudoer for
running a server application."
                INST_REDO="1"
                while [ "$INST_REDO" = "1" ]
                  do
                    echo "Do you really want to use this sudo user? (y/n)"
                    read INST_CHOICE
                    echo ""
                    case $INST_CHOICE in
                      y)
                        echo "OK, hope that doesn't spoil your security."
                        SUDOER="yes"
                        INST_REDO="0"
                        ;;
                      n)
                        echo "Good, let's use/create another user then:"
                        SUDOER=""
                        INST_REDO="0"
                        ;;
                      *)
                        INST_NOOB=$(( $INST_NOOB + 1 ))
                        echo "Too much choices for you?"
                        echo ""
                        INST_REDO="1"
                        ;;
                    esac
                  done
                if [ "$SUDOER" = "" ]
                  then
                    INST_REDO="1"
                fi
              else
                INST_REDO="1"
                while [ "$INST_REDO" = "1" ]
                  do
                    echo "Is this user able to work as root via sudo? (y/n)"
                    read INST_CHOICE
                    echo ""
                    case $INST_CHOICE in
                      y)
                        echo "OK, hope that doesn't spoil your security."
                        SUDOER="yes"
                        INST_REDO="0"
                        ;;
                      n)
                        echo "Good, on update occations the script will provide you a neat package then."
                        SUDOER="no"
                        INST_REDO="0"
                        ;;
                      *)
                        INST_NOOB=$(( $INST_NOOB + 1 ))
                        echo "I smell hard work here..."
                        echo ""
                        INST_REDO="1"
                        ;;
                    esac
                  done
            fi
        fi
      else 
        if [ "$INST_NOOB" -lt "2" ] 
          then
            echo "Do you wish to use any specific options for adduser? (just hit ENTER for none)"
            read INST_ADDUSEROPTIONS
          else 
            INST_ADDUSEROPTIONS=""
        fi
        if [ -d /home/$MCUSERNAME ]
          then 
            echo ""
            sudo mv /home/$MCUSERNAME /home/$MCUSERNAME.old
            echo "Users home folder was oddly already existing - did a backup!"
        fi
        echo ""
        echo "Installing user..."
        if [ "$INST_ADDUSEROPTIONS" = "" ]
          then sudo adduser $MCUSERNAME
          else sudo adduser $MCUSERNAME $INST_ADDUSEROPTIONS
        fi
        INST_RETURN="$?"
        echo ""
        if [ "$INST_RETURN" = "0" ]
          then 
            echo "User created!"
            INST_REDO="0"
            SUDOER="no"
          else
            echo "Something went wrong during user creation. Try again!"
            echo "Type desired name for minecraft user:"
            echo ""
            INST_REDO="1"
            INST_NOOB=$(( $INST_NOOB + 1 ))
        fi
    fi
  done
echo "
[Press ENTER to proceed]"
read INST_CHOICE
clear
echo "---------------------- Step 2 - Download scripts & configs ---------------------
"

