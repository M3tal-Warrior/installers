#!/bin/bash

# ================================= Copyright =================================
# Version 1.01 (2013-08-08), Copyright (C) 2011-2013
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

# =================================== Main ====================================
# This script reads your settings in an existing minecraft init script and
# writes a new one while asking you about your settings for new features. It is
# also part of the installer, where it asks you about all settings. Do not
# change anything in here as the script might cease working properly if you do.
# ALL CHANGES WILL BE OVERWRITTEN DURING UPDATES!

# The version statement keeps track of all scripts and changes therein. It has
# nothing to do with the minecraft version you're running.
# DON'T CHANGE THIS NUMBER!
AC_VERSION="1.40"
AC_DATE="2013-09-08"

# Variables used by the script:
# TEMPPATH
#   Runtime generated path for all scripts and changes until applied. Will be 
#   deleted in the very end by last_rites.sh
# INITNAME
#   Name of the init determined either by mcinstall.sh or the calling script. It 
#   will be checked back whether it being the first init script in the server 
#   config file. 
# INIT_PARENT
#   Name of the main init determined either by mcinstall.sh or the calling 
#   script. It is by definition the first file named in the server config file 
#   and determines all script family related parameters for all other init
#   files created by this script.
# MCUSERNAME
#   Name of the user that hosts the minecraft server. It is strongly recommended
#   that this is NOT the user who proceeds the final (root-dependend) steps of 
#   the update process.
# SUDOER
#   Name of the user who is used for the final (root-dependend) steps of the
#   update process.
# INSTALL
#   Two possible values:
#     0   Script will act as if there was no previous file or, if a previous file
#         is found, assume the set options in the previous file ($INITNAME) might
#         be flawed and thus will bring up the repair option. It will then not
#         skip any option, if 'repair' is chosen
#     1   Script will act as if the previous file (if any, see UPDATE) has correct
#         settings (i. e. doesn't bring up the 'repair' dialog) and skip the 
#         questioning for the USER and SUDOER variables (because they are to be 
#         given by either the invocating files or the INIT_PARENT).
# UPDATE
#   Two possible values:
#     0   
#     1   

# ------------------------------- Pre section ---------------------------------

cd /etc/init.d

# Greeting message
if [ "$MODE" != "install" ]
  then
    echo "
Welcome to the flight '$INITNAME' to version $AC_VERSION! I'll be your pilot 
on the flight, so stay calm, buckle up, don't smoke and enjoy your journey 
with M3tal_Warrior Mineways.
"
  else
    echo "
Welcome to flight 'add_another_server_today'! I'll be your pilot on the flight, 
so stay calm, buckle up, don't smoke and enjoy your journey with M3tal_Warrior 
Mineways.
"
fi

# ------------------------------- Read section --------------------------------
# This reads all old setting lines into seperate variables to properly write 
# the new init script afterwards.

if [ -f $INITNAME ]
  then 
    AC_INIT=$(cat $INITNAME)
    # This corrects user generated single quotes into double quotes, which will 
    # processed by bash a different and for our purpose more useful way.
    if echo "$AC_INIT" | grep "'" > /dev/null
      then AC_INIT=$(echo "$AC_INIT"|sed "s/'/#/g"|sed 's/#/"/g')
    fi
fi
# Prepares the init parent, which by nature will already be 'pure'. For
# more info read the wiki page.
if [ "$INITNAME" = "$INIT_PARENT" ]
  then AC_INIT_PARENT=$AC_INIT
  else AC_INIT_PARENT=$(cat $TEMPPATH/$INIT_PARENT)
fi
# Script stuff
MCUSERNAME=`echo "$AC_INIT_PARENT" | grep "USERNAME=" | cut -d '"' -f 2 -s`
SUDOER=`echo "$AC_INIT_PARENT" | grep "SUDOER=" | cut -d '"' -f 2 -s`
MAINTAIN_SCRIPT_PATH=`echo "$AC_INIT_PARENT" | grep "MAINTAIN_SCRIPT_PATH=" | cut -d '"' -f 2 -s`
MAINTAIN_SCRIPT_NAME=`echo "$AC_INIT_PARENT" | grep "MAINTAIN_SCRIPT_NAME=" | cut -d '"' -f 2 -s`
CONFIG_PATH=`echo "$AC_INIT_PARENT" | grep "CONFIG_PATH=" | cut -d '"' -f 2 -s`
CMDGRID_CONF=`echo "$AC_INIT_PARENT" | grep "CMDGRID_CONF=" | cut -d '"' -f 2 -s`
CMDGRID_PATH=`echo "$AC_INIT_PARENT" | grep "CMDGRID_PATH=" | cut -d '"' -f 2 -s`
UPDATE_CONF=`echo "$AC_INIT_PARENT" | grep "UPDATE_CONF=" | cut -d '"' -f 2 -s`
UPDATER=`echo "$AC_INIT_PARENT" | grep "UPDATER=" | cut -d '"' -f 2 -s`
AUTOCONF=`echo "$AC_INIT_PARENT" | grep "AUTOCONF=" | cut -d '"' -f 2 -s`
SERVERS_CONF=`echo "$AC_INIT_PARENT" | grep "SERVERS_CONF=" | cut -d '"' -f 2 -s`
SCRIPT_BACKUPPATH=`echo "$AC_INIT_PARENT" | grep "SCRIPT_BACKUPPATH=" | cut -d '"' -f 2 -s`
# Server stuff
SERVERTYPE=`echo "$AC_INIT" | grep "SERVERTYPE=" | cut -d '"' -f 2 -s`
UPDATE_PATH=`echo "$AC_INIT" | grep "UPDATE_PATH=" | cut -d '"' -f 2 -s`
SERVICE=`echo "$AC_INIT" | grep "SERVICE=" | cut -d '"' -f 2 -s`
SERVERPATH=`echo "$AC_INIT" | grep "SERVERPATH=" | cut -d '"' -f 2 -s`
BACKUPPATH=`echo "$AC_INIT" | grep "BACKUPPATH=" | cut -d '"' -f 2 -s`
CPU_COUNT=`echo "$AC_INIT" | grep "CPU_COUNT=" | cut -d '"' -f 2 -s`
MIN_SERVER_RAM=`echo "$AC_INIT" | grep "MIN_SERVER_RAM=" | cut -d '"' -f 2 -s`
MAX_SERVER_RAM=`echo "$AC_INIT" | grep "MAX_SERVER_RAM=" | cut -d '"' -f 2 -s`
JVM_OPTIONS=`echo "$AC_INIT" | grep "JVM_OPTIONS=" | cut -d '"' -f 2 -s`
USE_RAMFS=`echo "$AC_INIT" | grep "USE_RAMFS=" | cut -d '"' -f 2 -s`
USE_RAMDIR=`echo "$AC_INIT" | grep "USE_RAMDIR=" | cut -d '"' -f 2 -s`
INVOCATION=`echo "$AC_INIT" | grep "INVOCATION=" | cut -d '"' -f 2 -s`
# This is just a compatibility feature for very old versions of the script
if [ "$SERVERTYPE" = "Bukkit" ]
  then SERVERTYPE="BUKKIT"
fi
if [ "$SERVERTYPE" = "Vanilla" ]
  then SERVERTYPE="VANILLA"
fi

# ------------------------------- Query section -------------------------------
# This asks for all settings to be set if they can't be read out of the old 
# init script.

AC_REDO="1"
AC_RETURN="1"
while [ "$AC_REDO" = "1" ]
  do
    if [ "$AC_RETURN" = "1" ]
      then
        # This asks the user for level of detail for install/update
        echo "You have the choice of several different levels of detail. 
These are your options:

(1) Automatic update/install
    I'm fine with the default/determined settings. Don't ask me anything!
    This won't entirely work when installing parallel servers.
(2) Standard update/install
    I'd like to only see the standard settings and being able to change them
    if I like. Everything else is to be as it was before or default.
(3) Advanced update/install
    I'd like to see the advanced settings too and being able to change them
    if I like. Only expert settings are to be as they were before or default.
(4) Expert update/install
    Clatu Verata Nectarine! Nothing can stop me! Give me my Boomstick and 
    bring 'em on!"
        if [ "$INSTALL" != "1" ]
          then echo "(5) Repair
    I've done something terrible - please give me more options..."
        fi
    fi
    AC_RETURN="0"
    read AC_CHOICE
    clear
    case $AC_CHOICE in
      1)
        echo "Using suggested values, no prompting..."
        AC_DETAIL="1"
        AC_REPAIR="0"
        AC_REDO="0"
        ;;
      2)
        echo "Prompt only for standard settings..."
        AC_DETAIL="2"
        AC_REPAIR="0"
        AC_REDO="0"
        ;;
      3)
        echo "Prompt for advanced settings..."
        AC_DETAIL="3"
        AC_REPAIR="0"
        AC_REDO="0"
        ;;
      4)
        echo "You have been warned, Ash!"
        AC_DETAIL="4"
        AC_REPAIR="0"
        AC_REDO="0"
        ;;
      5)
        # This asks the user for level of detail for repair
        echo "OK, man, we can do that from scratch. 
These are your options:

(1) Automatic repair
    I'm fine with the default settings. I don't want to mess things up again!
(2) Standard repair
    I'd like to only see the standard settings as they are, what the default is
    and being able to choose manually. Reset everything else to default.
(3) Advanced repair
    I'd like to see the atm advanced settings and their default and being able
    to choose manually. Only expert settings are to be set to default.
(4) Expert repair
    Hey, wait a minute... Everything is cool! I said the words - I did!
(5) Return to previous
    Oh, wrong book."
        AC_REDO="1"
        while [ "$AC_REDO" = "1" ]
          do
            read AC_CHOICE
            clear
            case $AC_CHOICE in
              1)
                echo "Using suggested values, no prompting..."
                AC_DETAIL="1"
                AC_REPAIR="1"
                AC_REDO="0"
                ;;
              2)
                echo "Prompt only for standard settings..."
                AC_DETAIL="2"
                AC_REPAIR="1"
                AC_REDO="0"
                ;;
              3)
                echo "Prompt for advanced settings..."
                AC_DETAIL="3"
                AC_REPAIR="1"
                AC_REDO="0"
                ;;
              4)
                echo "Did you say the words right THIS time?"
                AC_DETAIL="4"
                AC_REPAIR="1"
                AC_REDO="0"
                ;;
              5)
                AC_REDO="0"
                AC_RETURN="1"
                ;;
              *)
                echo "Five fingers - five options. Now try again:"
                echo ""
                AC_REDO="1"
                ;;
            esac
          done
        if [ "$AC_RETURN" = "1" ]
          then AC_REDO="1"
        fi
        ;;
      *)
        echo "Numbers, pal - you should be able to read them. Now try again:"
        echo ""
        AC_REDO="1"
        ;;
    esac
  done

# This sanitizes the input
ac_sanitize() {
  if [ "$AC_PATH" = "1" ]
    then 
      echo "New value (paths will be created if not existing):"
      read -e AC_SETTING
      if [ "$AC_SETTING" = "" -o "$AC_SETTING" = "$AC_DEFAULT" ]
        then
          echo "Using default value."
          AC_SETTING="$AC_DEFAULT"
          AC_REDO="0"
        else
          AC_SETTING=${AC_SETTING%/}
          AC_SETTING=$(echo "$AC_SETTING"|sed 's#$PWD#°°°°°#g'|sed "s#°°°°°#$PWD#g")
          AC_SETTING=$(echo "$AC_SETTING"|sed 's#$HOME#°°°°°#g'|sed "s#°°°°°#/home/$MCUSERNAME#g")
          if [ ${AC_SETTING:0:1} != "$" -a ${AC_SETTING:0:1} != "/" ]
            then 
              if [ "$PWD" != "/dev/shm" ]
                then 
                  AC_SETTING="$PWD/$AC_SETTING"
                  AC_REDO="0"
                else
                  echo "Installing in a directory within the RAMFS is a stupid idea. If you want the
server to run from RAMFS, there will be an extra option lateron for that."
                  AC_REDO="1"
              fi
          fi
          if [ ${AC_SETTING:0:1} = "/" ]
            then
              AC_REDO="0"
          fi
      fi
    else 
      echo "New value$AC_OPTIONTEXT:"
      read AC_SETTING
      if [ "$AC_SETTING" = "" -o "$AC_SETTING" = "$AC_DEFAULT" ]
        then
          echo "Using default value."
          AC_SETTING="$AC_DEFAULT"
          AC_REDO="0"
        else
          case $AC_OPTIONS in
            0)
              echo "I see no way to verify if this works - you are sure this is ok?"
              echo "(BE CAREFUL: It may render some previous settings useless.)"
              echo "Type capital 'YES' if you are sure this works:"
              read AC_CHOICE
              case $AC_CHOICE in
                YES) 
                  AC_REDO="0"
                  ;;
                *)
                  AC_REDO="1"
                  ;;
              esac
              ;;
            2)
              case $AC_SETTING in
                $AC_OPTION1)
                  AC_REDO="0"
                  ;;
                $AC_OPTION2)
                  AC_REDO="0"
                  ;;
                *)
                  echo "Only $AC_OPTION1 or $AC_OPTION2 are available!"
                  AC_REDO="1"
                  ;;
              esac
              ;;
            6)
              case $AC_SETTING in
                $AC_OPTION1)
                  AC_REDO="0"
                  ;;
                $AC_OPTION2)
                  AC_REDO="0"
                  ;;
                $AC_OPTION3)
                  AC_REDO="0"
                  ;;
                $AC_OPTION4)
                  AC_REDO="0"
                  ;;
                $AC_OPTION5)
                  AC_REDO="0"
                  ;;
                $AC_OPTION6)
                  AC_REDO="0"
                  ;;
                *)
                  echo "$AC_SETTING is no available option (see wiki)!"
                  AC_REDO="1"
                  ;;
              esac
              ;;
            # CPU core setting
            C)
              if [[ "$AC_SETTING" -ge "1" && "$AC_SETTING" -le "$AC_MAXCORES" ]]
                then AC_REDO="0"
                else
                  echo "Wrong number of CPU cores set!"
                  AC_REDO="1"
              fi
              ;;
            # RAM usage setting
            R)
              case ${AC_SETTING: -1} in
                M)
                  AC_SETTING_C=`echo "${AC_SETTING%?}*1024" | bc`
                  ;;
                G)
                  AC_SETTING_C=`echo "${AC_SETTING%?}*1048576" | bc`
                  ;;
                *)
                  AC_SETTING_C="!"
                  ;;
              esac
              case ${MIN_SERVER_RAM: -1} in
                M)
                  MIN_SERVER_RAM_C=`echo "${MIN_SERVER_RAM%?}*1024" | bc`
                  ;;
                G)
                  MIN_SERVER_RAM_C=`echo "${MIN_SERVER_RAM%?}*1048576" | bc`
                  ;;
                *)
                  MIN_SERVER_RAM_C="0"
                  ;;
              esac
              if [ "$AC_SETTING_C" = "!" ]
                then
                  echo "$AC_SETTING is no appropriate amount of RAM."
                  AC_REDO="1"
                else
                  RAM_C=`echo "$AC_MAXRAM>$AC_SETTING_C" | bc`
                  if [ "$RAM_C" = "1" ]
                    then AC_REDO="0"
                    else 
                      echo "You don't have enough RAM for that!"
                      AC_REDO="1"
                  fi
                  RAM_C=`echo "$MIN_SERVER_RAM_C>$AC_SETTING_C" | bc`
                  if [ "$RAM_C" = "1" ]
                    then
                      echo "MIN_SERVER_RAM can't be more than MAX_SERVER_RAM!"
                      AC_REDO="1"
                  fi
              fi
              ;;
            # Directory setting
            D)
              cd /dev/shm
              if [ -f "$AC_SETTING" ]
                then
                  echo "There's a file of that name! No way!"
                  AC_REDO="1"
                else AC_REDO="0"
              fi
              ;;
            # Name setting
            N)
              AC_REDO="0"          
              ;;
          esac
      fi
  fi
}

# This processes all settings queries
ac_settings() {
  if [[ "$AC_SKIP" = "1" && "$AC_SETTING" = "" ]]
    then AC_SETTING="$AC_DEFAULT"
    else
      if [ "$AC_SETTING" = "" ]
        then 
          echo ""
          AC_REDO="1"
          while [ "$AC_REDO" = "1" ]
            do
              echo "$AC_SETTINGNAME is not yet configured. The default value is:
$AC_DEFAULT
Do you wish to change it? (y/n)"
              read AC_CHOICE
              case $AC_CHOICE in
                y)
                  ac_sanitize
                  ;;
                n)
                  AC_REDO="0"
                  AC_SETTING="$AC_DEFAULT"
                  ;;
                *)
                  echo "Only y or n are appropriate answers."
                  echo ""
                  AC_REDO="1"
                  ;;
              esac
            done
        else
          if [ "$AC_REPAIR" = "1" ]
            then
              echo ""
              AC_REDO="1"
              while [ "$AC_REDO" = "1" ]
                do
                  echo "Setting in question: $AC_SETTINGNAME"
                  echo "(o) Keep old setting: $AC_SETTING"
                  echo "(d) Set to default setting: $AC_DEFAULT"
                  echo "(c) Change it to something different."
                  echo "Your choice (o/d/c):"
                  read AC_COICE
                  case $AC_CHOICE in
                    o)
                      AC_REDO="0"
                      ;;
                    d)
                      AC_REDO="0"
                      AC_SETTING="$AC_DEFAULT"
                      ;;
                    c)
                      while [ "$AC_REDO" = "1" ]
                        do
                          ac_sanitize
                        done
                      ;;
                    *)
                      echo "Only (o)ld, (d)efault or (c)hange are appropriate answers."
                      echo ""
                      AC_REDO="1"
                      ;;
                  esac
                done
          fi
      fi
  fi
}

# Default settings
ACD_MCUSERNAME='minecraft'
ACD_SUDOER='no'
ACD_MAINTAIN_SCRIPT_PATH='/home/$MCUSERNAME/serverscript'
ACD_MAINTAIN_SCRIPT_NAME='server_control'
ACD_CONFIG_PATH='$MAINTAIN_SCRIPT_PATH/scriptconf'
ACD_CMDGRID_CONF='commandgrid.conf'
ACD_CMDGRID_PATH='$CONFIG_PATH/cmdgrid'
ACD_UPDATE_CONF='updateurls.conf'
ACD_UPDATER='updater.sh'
ACD_AUTOCONF='autoconf.sh'
ACD_SERVERS_CONF='servers.conf'
ACD_SCRIPT_BACKUPPATH='$MAINTAIN_SCRIPT_PATH/backups'
ACD_SERVERTYPE='VANILLA'
ACD_UPDATE_PATH='/home/$MCUSERNAME/mc_update_bin'
ACD_SERVICE='minecraft_server.jar'
ACD_SERVERPATH='/home/$MCUSERNAME/server'
ACD_BACKUPPATH='/home/$MCUSERNAME/backup'
ACD_CPU_COUNT='1'
ACD_MIN_SERVER_RAM='500M'
ACD_MAX_SERVER_RAM='2G'
ACD_JVM_OPTIONS='nogui'
ACD_USE_RAMFS='no'
ACD_USE_RAMDIR='$INITNAME'
ACD_INVOCATION='java -Xmx$MAX_SERVER_RAM -Xms$MIN_SERVER_RAM -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=$CPU_COUNT -XX:+AggressiveOpts -jar $SERVICE $JVM_OPTIONS'

# Basic settings
if [ "$AC_DETAIL" = "1" -o "$INITNAME" != "$INIT_PARENT" ]
  then AC_SKIP="1"
fi
if [ "$INSTALL" != "1" ]
  then
    # Minecraft hosting user & sudoer rights of it
    AC_SETTINGNAME="Minecraft user (BE CAREFUL!)"
    AC_PATH="0"
    AC_DEFAULT="$ACD_MCUSERNAME"
    AC_SETTING="$MCUSERNAME"
    AC_OPTIONS="N"
    ac_settings
    MCUSERNAME="$AC_SETTING"
    AC_SETTINGNAME="Sudoer"
    AC_DEFAULT="$ACD_SUDOER"
    AC_SETTING="$SUDOER"
    AC_PATH="0"
    AC_OPTIONS="2"
    AC_OPTIONTEXT=" ('yes' or 'no')"
    AC_OPTION1="yes"
    AC_OPTION2="no"
    ac_settings
    SUDOER="$AC_SETTING"
fi
# Path to maintain script
AC_SETTINGNAME="Path to main script"
AC_PATH="1"
AC_DEFAULT="$ACD_MAINTAIN_SCRIPT_PATH"
AC_SETTING="$MAINTAIN_SCRIPT_PATH"
ac_settings
MAINTAIN_SCRIPT_PATH="$AC_SETTING"
# Name of maintain script
AC_SETTINGNAME="Name of main script"
AC_PATH="0"
AC_DEFAULT="$ACD_MAINTAIN_SCRIPT_NAME"
AC_SETTING="$MAINTAIN_SCRIPT_NAME"
AC_OPTIONTEXT=""
AC_OPTIONS="N"
ac_settings
MAINTAIN_SCRIPT_NAME="$AC_SETTING"
# Path to config files
AC_SETTINGNAME="Path to config files"
AC_PATH="1"
AC_DEFAULT="$ACD_CONFIG_PATH"
AC_SETTING="$CONFIG_PATH"
ac_settings
CONFIG_PATH="$AC_SETTING"
# Name of CommandGrid config file
AC_SETTINGNAME="CommandGrid config file name"
AC_PATH="0"
AC_DEFAULT="$ACD_CMDGRID_CONF"
AC_SETTING="$CMDGRID_CONF"
AC_OPTIONTEXT=""
AC_OPTIONS="N"
ac_settings
CMDGRID_CONF="$AC_SETTING"
# Path to commandgrid files
AC_SETTINGNAME="Path to CommandGrid user files"
AC_PATH="1"
AC_DEFAULT="$ACD_CMDGRID_PATH"
AC_SETTING="$CMDGRID_PATH"
ac_settings
CMDGRID_PATH="$AC_SETTING"
# Name of UpdateURLs config file
AC_SETTINGNAME="URLs config filename"
AC_PATH="0"
AC_DEFAULT="$ACD_UPDATE_CONF"
AC_SETTING="$UPDATE_CONF"
AC_OPTIONTEXT=""
AC_OPTIONS="N"
ac_settings
UPDATE_CONF="$AC_SETTING"
# Name of Updater script
AC_SETTINGNAME="Updater script name"
AC_PATH="0"
AC_DEFAULT="$ACD_UPDATER"
AC_SETTING="$UPDATER"
AC_OPTIONTEXT=""
AC_OPTIONS="N"
ac_settings
UPDATER="$AC_SETTING"
# Name of AutoConfig script
AC_SETTINGNAME="AutoConfig script name"
AC_PATH="0"
AC_DEFAULT="$ACD_AUTOCONF"
AC_SETTING="$AUTOCONF"
AC_OPTIONTEXT=""
AC_OPTIONS="N"
ac_settings
AUTOCONF="$AC_SETTING"
# Name of servers config file
AC_SETTINGNAME="Server list filename"
AC_PATH="0"
AC_DEFAULT="$ACD_SERVERS_CONF"
AC_SETTING="$SERVERS_CONF"
AC_OPTIONTEXT=""
AC_OPTIONS="N"
ac_settings
SERVERS_CONF="$AC_SETTING"
# Path for script backup
AC_SETTINGNAME="Backup path for scripts"
AC_PATH="1"
AC_DEFAULT="$ACD_SCRIPT_BACKUPPATH"
AC_SETTING="$SCRIPT_BACKUPPATH"
ac_settings
SCRIPT_BACKUPPATH="$AC_SETTING"

# Kickin for values that aren't determined by the init parent file and are
# wished for self determined setting by user.
if [ "$AC_DETAIL" != "1" ]
  then AC_SKIP=""
fi
# Server type
AC_SETTINGNAME="Server type"
AC_PATH="0"
AC_DEFAULT="$ACD_SERVERTYPE"
AC_SETTING="$SERVERTYPE"
AC_OPTIONS="6"
AC_OPTIONTEXT=" (See Wiki for available options)"
AC_OPTION1="BUKKIT"
AC_OPTION2="BUKKIT_BETA"
AC_OPTION3="BUKKIT_DEV"
AC_OPTION4="VANILLA"
AC_OPTION5="VANILLA_SNAPSHOT"
AC_OPTION6="CUSTOM"
ac_settings
SERVERTYPE="$AC_SETTING"
# Directory for updates (only for custom servers)
if [ "$SERVERTYPE" = "CUSTOM" ]
  then
    AC_SETTINGNAME="Update directory"
    AC_PATH="1"
    AC_DEFAULT="$ACD_UPDATE_PATH"
    AC_SETTING="$UPDATE_PATH"
    AC_OPTIONS="D"
    AC_OPTIONTEXT=""
    ac_settings
    UPDATE_PATH="$AC_SETTING"
fi
# Name of server binary
AC_SETTINGNAME="Server binary name"
AC_PATH="0"
AC_DEFAULT="$ACD_SERVICE"
AC_SETTING="$SERVICE"
AC_OPTIONTEXT=""
AC_OPTIONS="N"
ac_settings
SERVICE="$AC_SETTING"

# For a parallel install of a new server this condition is true in any case, for
# the next two values HAVE to be set to something different than in the parent.
if [ "$INITNAME" != "$INIT_PARENT" -a "$AC_INIT" = "" ]
  then 
    AC_SKIP=""
    echo "Be careful when setting the next two paths; using default values might screw
your other server! We're talking about $INITNAME now:"
fi
# Path to server files
AC_SETTINGNAME="Path to server"
AC_PATH="1"
AC_DEFAULT="$ACD_SERVERPATH"
AC_SETTING="$SERVERPATH"
ac_settings
SERVERPATH="$AC_SETTING"
# Path for server backups
AC_SETTINGNAME="Backup path for server"
AC_PATH="1"
AC_DEFAULT="$ACD_BACKUPPATH"
AC_SETTING="$BACKUPPATH"
ac_settings
BACKUPPATH="$AC_SETTING"

# Advanced settings
if [ "$AC_DETAIL" -le "2" ]
  then AC_SKIP="1"
fi
# Number of CPU cores
AC_SETTINGNAME="Used CPU cores"
AC_PATH="0"
AC_DEFAULT="$ACD_CPU_COUNT"
AC_SETTING="$CPU_COUNT"
AC_OPTIONS="C"
AC_MAXCORES=$(grep -m 1 "siblings" /proc/cpuinfo)
if [ "$AC_MAXCORES" = "" ]
  then AC_MAXCORES="1"
  else AC_MAXCORES=${AC_MAXCORES: -1}
fi
AC_OPTIONTEXT=" (min. 1, max. $AC_MAXCORES)"
ac_settings
CPU_COUNT="$AC_SETTING"
# Min/Max RAM
AC_SETTINGNAME="Minimal server RAM"
AC_PATH="0"
AC_DEFAULT="$ACD_MIN_SERVER_RAM"
AC_SETTING="$MIN_SERVER_RAM"
AC_OPTIONS="R"
AC_MAXRAM=$(grep MemTotal /proc/meminfo | awk '{print $2}')
AC_AVRAM=$(grep MemFree /proc/meminfo | awk '{print $2}')
AC_OPTIONTEXT=" ($AC_MAXRAM KB total ($AC_AVRAM KB free); format is '1500M' for 1.5 GB or '2G' for 2 GB)"
ac_settings
MIN_SERVER_RAM="$AC_SETTING"
AC_SETTINGNAME="Maximal server RAM"
AC_DEFAULT="$ACD_MAX_SERVER_RAM"
AC_SETTING="$MAX_SERVER_RAM"
ac_settings
MAX_SERVER_RAM="$AC_SETTING"
# RAMFS
AC_SETTINGNAME="USE_RAMFS"
AC_PATH="0"
AC_DEFAULT="$ACD_USE_RAMFS"
AC_SETTING="$USE_RAMFS"
AC_OPTIONS="2"
AC_OPTION1="yes"
AC_OPTION2="no"
AC_OPTIONTEXT=" ('yes' or 'no')"
ac_settings
USE_RAMFS="$AC_SETTING"
if [ "$USE_RAMFS" = "yes" ]
  then
    AC_SETTINGNAME="USE_RAMDIR"
    AC_PATH="0"
    AC_DEFAULT="$ACD_USE_RAMDIR"
    AC_SETTING="$USE_RAMDIR"
    AC_OPTIONS="D"
    AC_OPTIONTEXT=" (just the name of the folder without path)"
    ac_settings
    USE_RAMDIR="$AC_SETTING"
fi

# Expert settings
if [ "$AC_DETAIL" = "3" ]
  then AC_SKIP="1"
fi
# NoGUI setting
AC_SETTINGNAME="JVM settings"
AC_PATH="0"
AC_DEFAULT="$ACD_JVM_OPTIONS"
AC_SETTING="$JVM_OPTIONS"
AC_OPTIONS="0"
AC_OPTIONTEXT=""
ac_settings
JVM_OPTIONS="$AC_SETTING"
# Java invocation
AC_SETTINGNAME="INVOCATION"
AC_PATH="0"
AC_DEFAULT="$ACD_INVOCATION"
AC_SETTING="$INVOCATION"
AC_OPTIONS="0"
AC_OPTIONTEXT=" (This may render some settings useless!)"
ac_settings
INVOCATION="$AC_SETTING"

# =============================== Write section =============================== 
cd $TEMPPATH
# Because Bukkit and other servers use mysql for some plugins, it has to be
# started prior to the server.
if [ "$SERVERTYPE" = "VANILLA" ]
  then AC_SETTING='$local_fs $remote_fs'
  else AC_SETTING='$local_fs $remote_fs mysql'
fi

# This writes the new initscript to a temporary location.
echo "#!/bin/bash

### BEGIN INIT INFO
# Provides:   minecraft
# Required-Start: $AC_SETTING
# Required-Stop:  $AC_SETTING
# Should-Start:   \$network
# Should-Stop:    \$network
# Default-Start:  2 3 4 5
# Default-Stop:   0 1 6
# Short-Description:    Minecraft server
# Description:    Invocates the minecraft server maintenance script
### END INIT INFO

# ================================= Copyright =================================
# Version $AC_VERSION ($AC_DATE), Copyright (C) 2011-2013
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


# ================================= Settings ==================================
# Here you can change almost everything for the script to fill your needs.
# For information on the possible settings view the commented script at 
# http://www.minecraftwiki.net/wiki/User:M3tal_Warrior/Server_Scripts

# Script settings
MCUSERNAME=\"$MCUSERNAME\"
SUDOER=\"$SUDOER\"
MAINTAIN_SCRIPT_PATH=\"$MAINTAIN_SCRIPT_PATH\"
MAINTAIN_SCRIPT_NAME=\"$MAINTAIN_SCRIPT_NAME\"
CONFIG_PATH=\"$CONFIG_PATH\"
CMDGRID_CONF=\"$CMDGRID_CONF\"
CMDGRID_PATH=\"$CMDGRID_PATH\"
UPDATE_CONF=\"$UPDATE_CONF\"
UPDATER=\"$UPDATER\"    
AUTOCONF=\"$AUTOCONF\"
SERVERS_CONF=\"$SERVERS_CONF\"
SCRIPT_BACKUPPATH=\"$SCRIPT_BACKUPPATH\"

# Server settings
SERVERTYPE=\"$SERVERTYPE\"" > $INITNAME
if [ "$SERVER" = "CUSTOM" ]
  then echo "UPDATE_PATH=\"$UPDATE_PATH\"" >> $INITNAME
fi
echo "SERVICE=\"$SERVICE\"
SERVERPATH=\"$SERVERPATH\"
BACKUPPATH=\"$BACKUPPATH\"
CPU_COUNT=\"$CPU_COUNT\"
MIN_SERVER_RAM=\"$MIN_SERVER_RAM\"
MAX_SERVER_RAM=\"$MAX_SERVER_RAM\"
USE_RAMFS=\"$USE_RAMFS\"
USE_RAMDIR=\"$USE_RAMDIR\"
JVM_OPTIONS=\"$JVM_OPTIONS\"
INVOCATION=\"java -Xmx\$MAX_SERVER_RAM -Xms\$MIN_SERVER_RAM -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=\$CPU_COUNT -XX:+AggressiveOpts -jar \$SERVICE \$JVM_OPTIONS\"

# ============================= Script invocation =============================
# Here the maintenance script is invocated within the proper user environment.

# ------------------------------ Variable export ------------------------------
# Do not change anything in here! It exports all settings for the maintenance 
# script to use them.

export INITNAME=\"\${0##*/}\"
export MCUSERNAME
export SUDOER
export MAINTAIN_SCRIPT_PATH
export MAINTAIN_SCRIPT_NAME
export CONFIG_PATH
export CMDGRID_CONF
export CMDGRID_PATH
export UPDATE_CONF
export UPDATER
export AUTOCONF
export SERVERS_CONF
export SCRIPT_BACKUPPATH
export SERVERTYPE" >> $INITNAME
if [ "$SERVER" = "CUSTOM" ]
  then echo "export UPDATE_PATH" >> $INITNAME
fi
echo "export SERVICE
export SERVERPATH
export BACKUPPATH
export USE_RAMFS
export USE_RAMDIR
export INVOCATION

# -------------------------------- Invocation ---------------------------------
if [ \`whoami\` = \"\$MCUSERNAME\" ] ; then
  bash -c \"\$MAINTAIN_SCRIPT_PATH/\$MAINTAIN_SCRIPT_NAME \$*\"
else
  su \$MCUSERNAME -c \"\$MAINTAIN_SCRIPT_PATH/\$MAINTAIN_SCRIPT_NAME \$*\"
fi
exit 0" >> $INITNAME

# Writing update script
# last_rites.sh does the final stuff - backup, updating script files and server
# directories as well as killing the temporary path and itself in the end. 
# Here all init file related stuff is written, and - if invocated to write or 
# update the first init file - the creation/update of the script directories.

# Includes everything from the new init script
# The grep roundtrip is made to leave out all commands.
grep -B 100 "= Script invocation =" $INITNAME > init.tmp
source init.tmp
rm -f init.tmp

# Updating paths (only if invocated for the parent file)
if [ "$INITNAME" = "$INIT_PARENT" ]
  then 
    echo "sudo mkdir -p $MAINTAIN_SCRIPT_PATH
sudo chown $MCUSERNAME:$MCUSERNAME $MAINTAIN_SCRIPT_PATH
sudo mkdir -p $CONFIG_PATH
sudo chown $MCUSERNAME:$MCUSERNAME $CONFIG_PATH
sudo mkdir -p $CMDGRID_PATH
sudo chown $MCUSERNAME:$MCUSERNAME $CMDGRID_PATH
sudo mkdir -p $SCRIPT_BACKUPPATH
sudo chown $MCUSERNAME:$MCUSERNAME $SCRIPT_BACKUPPATH
echo 'Script file directories updated.'
sudo touch \"$CONFIG_PATH/$SERVERS_CONF\"" >> $LASTRITES
fi
# Backing up (if existing init file was found); if not, creating directories
if [ "$AC_INIT" != "" ]
  then 
    echo "sudo mv /etc/init.d/$INITNAME \$TEMPPATH/init.$INITNAME.old
sudo chmod 644 \$TEMPPATH/init.$INITNAME.old" >> $LASTRITES
  else
    echo "sudo mkdir -p $SERVERPATH
sudo chown $MCUSERNAME:$MCUSERNAME $SERVERPATH
sudo mkdir -p $BACKUPPATH
sudo chown $MCUSERNAME:$MCUSERNAME $BACKUPPATH" >> $LASTRITES

    if [ "$SERVERTYPE" = "CUSTOM" ]
      then
        echo "sudo mkdir -p $UPDATE_PATH
        sudo chown root:root $UPDATE_PATH
        sudo chmod 775 $UPDATE_PATH" >> $LASTRITES
    fi
    echo "echo 'Directories for server \"$INITNAME\" created.'" >> $LASTRITES
fi
# Writing to etc/init.d and making sure the init file aka server is known by the
# servers config file
echo "sudo chown root:root \$TEMPPATH/$INITNAME
sudo chmod 755 \$TEMPPATH/$INITNAME
sudo mv \$TEMPPATH/$INITNAME /etc/init.d/$INITNAME
if ! grep \"$INITNAME\" \"$CONFIG_PATH/$SERVERS_CONF\" >> /dev/null
  then echo \"echo :$INITNAME: >> $CONFIG_PATH/$SERVERS_CONF\" | sudo bash
fi" >> $LASTRITES

# Farewell message to indicate proper script termination.
echo "We, the crew of flight '$INITNAME', hope you enjoyed our flight and we're
looking forward to seeing you again at M3tal_Warrior Mineways. Enjoy your stay!"
exit 0
