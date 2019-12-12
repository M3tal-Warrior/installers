#!/bin/bash

# ================================= Copyright =================================
# Version 1.1 (2013-01-25), Copyright (C) 2011-2013
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
AC_VERSION="1.3"
AC_DATE="2012-11-14"

# Greeting message
echo "
Welcome to the init script writer! I'll be your pilot on the flight, so stay
calm, buckle up, don't smoke and enjoy your journey with M3tal_Warrior Mineways.
"

# --------------------------- System status checks ----------------------------
# This checks if it's an update or a new install

if [ "$NEWINIT" = "" ]
  then NEWINIT="init"
fi
if [ "$INITNAME" = "" ]
  then INITNAME="minecraft"
fi
cd /etc/init.d
if [ "$INSTALL" != "1" -o "$UPDATE" = "1" ]
  then
    # Probing for (previous) init scripts
    if [ -f $INITNAME ]
      then 
        echo "Initscript detected."
        AC_INSTCHECK="TRUE"
      else
        AC_REDO="1"
        while [ "$AC_REDO" = "1" ]
          do
            echo "Do you use a previous version of M3tal_Warriors server startup script? (y/n)"
            read AC_CHOICE
            echo ""
            case $AC_CHOICE in
              y)
                echo "Provide its name:"
                read INITNAME
                echo ""
                while [ "$AC_REDO" = "1" ]
                  do
                    if [ -f $INITNAME -a "$INITNAME" != "" ]
                      then 
                        echo "Thanks, got it!"
                        AC_REDO="0"
                        AC_INSTCHECK="TRUE"
                      else 
                        echo "Sorry, file not found! Try again or type 'EXIT' to cancel file selection:"
                        read INITNAME
                        echo ""
                        if [ "$INITNAME" = "EXIT" ]
                          then
                            AC_REDO="0"
                            INITNAME="minecraft"
                            AC_INSTCHECK="FALSE"
                        fi
                    fi
                  done
                ;;
              n)
                echo "Sorry, can't really use any other script."
                AC_REDO="0"
                INITNAME="minecraft"
                AC_INSTCHECK="FALSE"
                ;;
              *)
                echo "Only y or n are appropriate answers.
"
                AC_REDO="1"
                ;;
            esac
          done
    fi
    AC_CHOICE=""
    # Probing for initscript fitness
    if [ "$AC_INSTCHECK" = "TRUE" ]
      then 
        echo "Checking script integrity..."
        if cat $INITNAME | grep "Author: M3tal_Warrior" > /dev/null
          then 
            AC_INSTCHECK="TRUE"
            echo "Capital! You will only be asked for new settings, if you so wish." 
          else 
            AC_INSTCHECK="FALSE"
            echo "Sorry, this script doesn't fit the updating requirements."
            echo "You have to provide all settings by hand (in case you wish to change them)."
        fi
    fi
    # Probing for version & update needs
    if [ "$AC_INSTCHECK" = "TRUE" ]
      then
        if cat $INITNAME | grep "# Version $AC_VERSION ($AC_DATE), Copyright (C) " > /dev/null
          then
            echo "Initscript up to date."
            if [ "$INSTALL" != "1" ] 
              then
                # This is written to perform the vital task of the initupdater.sh
                # in an update where the init file is not changed.
                echo "#!/bin/bash
export INSTALL='2'
export TEMPPATH=\"$TEMPPATH\"
bash -c /etc/init.d/$INITNAME
exit 0" > $TEMPPATH/mc_initupdater.sh
                chmod a+x $TEMPPATH/mc_initupdater.sh
                exit 2
              else INSTALL="2"
            fi
        fi
    fi
  else
    AC_INSTCHECK="FALSE"
    INITNAME="minecraft"
fi

# ------------------------------- Read section --------------------------------
# This reads all old setting lines into seperate variables to properly write 
# the new init script afterwards.

if [ "$AC_INSTCHECK" = "TRUE" ]
  then 
    AC_INIT=$(cat $INITNAME)
    # This corrects user generated single quotes into double quotes, which will 
    # processed by bash a different and for our purpose more useful way.
    if echo "$AC_INIT" | grep "'" > /dev/null
      then
        AC_INIT=$(echo "$AC_INIT"|sed "s/'/#/g"|sed 's/#/"/g')
    fi
    MAINTAIN_SCRIPT_PATH=`echo "$AC_INIT" | grep "MAINTAIN_SCRIPT_PATH=" | cut -d '"' -f 2 -s`
    MAINTAIN_SCRIPT_NAME=`echo "$AC_INIT" | grep "MAINTAIN_SCRIPT_NAME=" | cut -d '"' -f 2 -s`
    CONFIG_PATH=`echo "$AC_INIT" | grep "CONFIG_PATH=" | cut -d '"' -f 2 -s`
    CMDGRID_CONF=`echo "$AC_INIT" | grep "CMDGRID_CONF=" | cut -d '"' -f 2 -s`
    UPDATE_CONF=`echo "$AC_INIT" | grep "UPDATE_CONF=" | cut -d '"' -f 2 -s`
    AUTOCONF=`echo "$AC_INIT" | grep "AUTOCONF=" | cut -d '"' -f 2 -s`
    MCUSERNAME=`echo "$AC_INIT" | grep "USERNAME=" | cut -d '"' -f 2 -s`
    SUDOER=`echo "$AC_INIT" | grep "SUDOER=" | cut -d '"' -f 2 -s`
    SERVERTYPE=`echo "$AC_INIT" | grep "SERVERTYPE=" | cut -d '"' -f 2 -s`
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
    if [ "$SERVERTYPE" = "Bukkit" ]
      then SERVERTYPE="BUKKIT"
    fi
    if [ "$SERVERTYPE" = "Vanilla" ]
      then SERVERTYPE="VANILLA"
    fi
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
        AC_INSTALL="1"
        AC_REPAIR="0"
        AC_REDO="0"
        ;;
      2)
        echo "Prompt only for standard settings..."
        AC_INSTALL="2"
        AC_REPAIR="0"
        AC_REDO="0"
        ;;
      3)
        echo "Prompt for advanced settings..."
        AC_INSTALL="3"
        AC_REPAIR="0"
        AC_REDO="0"
        ;;
      4)
        echo "You have been warned, Ash!"
        AC_INSTALL="4"
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
                AC_INSTALL="1"
                AC_REPAIR="1"
                AC_REDO="0"
                ;;
              2)
                echo "Prompt only for standard settings..."
                AC_INSTALL="2"
                AC_REPAIR="1"
                AC_REDO="0"
                ;;
              3)
                echo "Prompt for advanced settings..."
                AC_INSTALL="3"
                AC_REPAIR="1"
                AC_REDO="0"
                ;;
              4)
                echo "Did you say the words right THIS time?"
                AC_INSTALL="4"
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
        echo "Five fingers - five options. Now try again:"
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
            C)
              if [[ "$AC_SETTING" -ge "1" && "$AC_SETTING" -le "$AC_MAXCORES" ]]
                then AC_REDO="0"
                else
                  echo "Wrong number of CPU cores set!"
                  AC_REDO="1"
              fi
              ;;
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
            D)
              cd /dev/shm
              if [ -f "$AC_SETTING" ]
                then
                  echo "There's a file of that name! No way!"
                  AC_REDO="1"
                else AC_REDO="0"
              fi
              ;;
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
ACD_MAINTAIN_SCRIPT_PATH='/home/$MCUSERNAME'
ACD_MAINTAIN_SCRIPT_NAME='server_control'
ACD_CONFIG_PATH='$MAINTAIN_SCRIPT_PATH/scriptconf'
ACD_CMDGRID_CONF='commandgrid.conf'
ACD_UPDATE_CONF='updateurls.conf'
ACD_AUTOCONF='autoconf.sh'
ACD_SERVERTYPE='VANILLA'
ACD_SERVICE='minecraft_server.jar'
ACD_SERVERPATH='$MAINTAIN_SCRIPT_PATH/server'
ACD_BACKUPPATH='$MAINTAIN_SCRIPT_PATH/backup'
ACD_CPU_COUNT=1
ACD_MIN_SERVER_RAM='500M'
ACD_MAX_SERVER_RAM='2G'
ACD_JVM_OPTIONS='nogui'
ACD_USE_RAMFS='no'
ACD_USE_RAMDIR='minecraft'
ACD_INVOCATION='java -Xmx$MAX_SERVER_RAM -Xms$MIN_SERVER_RAM -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=$CPU_COUNT -XX:+AggressiveOpts -jar $SERVICE $JVM_OPTIONS'

# Basic settings
if [ "$AC_INSTALL" = "1" ]
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
AC_SETTINGNAME="MAINTAIN_SCRIPT_PATH"
AC_PATH="1"
AC_DEFAULT="$ACD_MAINTAIN_SCRIPT_PATH"
AC_SETTING="$MAINTAIN_SCRIPT_PATH"
ac_settings
MAINTAIN_SCRIPT_PATH="$AC_SETTING"
# Name of maintain script
AC_SETTINGNAME="MAINTAIN_SCRIPT_NAME"
AC_PATH="0"
AC_DEFAULT="$ACD_MAINTAIN_SCRIPT_NAME"
AC_SETTING="$MAINTAIN_SCRIPT_NAME"
AC_OPTIONTEXT=""
AC_OPTIONS="N"
ac_settings
MAINTAIN_SCRIPT_NAME="$AC_SETTING"
# Path to config files
AC_SETTINGNAME="CONFIG_PATH"
AC_PATH="1"
AC_DEFAULT="$ACD_CONFIG_PATH"
AC_SETTING="$CONFIG_PATH"
ac_settings
CONFIG_PATH="$AC_SETTING"
# Name of CommandGrid config file
AC_SETTINGNAME="CommandGrid config name"
AC_PATH="0"
AC_DEFAULT="$ACD_CMDGRID_CONF"
AC_SETTING="$CMDGRID_CONF"
AC_OPTIONTEXT=""
AC_OPTIONS="N"
ac_settings
CMDGRID_CONF="$AC_SETTING"
# Name of UpdateURLs config file
AC_SETTINGNAME="UpdateURLs config name"
AC_PATH="0"
AC_DEFAULT="$ACD_UPDATE_CONF"
AC_SETTING="$UPDATE_CONF"
AC_OPTIONTEXT=""
AC_OPTIONS="N"
ac_settings
UPDATE_CONF="$AC_SETTING"
# Name of AutoConfig script
AC_SETTINGNAME="AutoConfig script name"
AC_PATH="0"
AC_DEFAULT="$ACD_AUTOCONF"
AC_SETTING="$AUTOCONF"
AC_OPTIONTEXT=""
AC_OPTIONS="N"
ac_settings
AUTOCONF="$AC_SETTING"
# Server type
AC_SETTINGNAME="Server type"
AC_PATH="0"
AC_DEFAULT="$ACD_SERVERTYPE"
AC_SETTING="$SERVERTYPE"
AC_OPTIONS="2"
AC_OPTIONTEXT=" ('BUKKIT' or 'VANILLA')"
AC_OPTION1="BUKKIT"
AC_OPTION2="VANILLA"
ac_settings
SERVERTYPE="$AC_SETTING"
# Name of server binary
AC_SETTINGNAME="Server binary name"
AC_PATH="0"
AC_DEFAULT="$ACD_SERVICE"
AC_SETTING="$SERVICE"
AC_OPTIONTEXT=""
AC_OPTIONS="N"
ac_settings
SERVICE="$AC_SETTING"
# Path to server files
AC_SETTINGNAME="SERVERPATH"
AC_PATH="1"
AC_DEFAULT="$ACD_SERVERPATH"
AC_SETTING="$SERVERPATH"
ac_settings
SERVERPATH="$AC_SETTING"
# Path for server backups
AC_SETTINGNAME="BACKUPPATH"
AC_PATH="1"
AC_DEFAULT="$ACD_BACKUPPATH"
AC_SETTING="$BACKUPPATH"
ac_settings
BACKUPPATH="$AC_SETTING"

# Advanced settings
if [ "$AC_INSTALL" = "2" ]
  then AC_SKIP="1"
fi
# Number of CPU cores
AC_SETTINGNAME="Used CPU cores"
AC_PATH="0"
AC_DEFAULT="$ACD_CPU_COUNT"
AC_SETTING="$CPU_COUNT"
AC_OPTIONS="C"
AC_MAXCORES=$(cat /proc/cpuinfo | grep -m 1 "siblings")
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
AC_MAXRAM=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
AC_AVRAM=$(cat /proc/meminfo | grep MemFree | awk '{print $2}')
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
if [ "$AC_INSTALL" = "3" ]
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
# Because Bukkit uses mysql for PermissionsEx and other plugins, it has to be
# started prior to the server.
if [ "$SERVERTYPE" = "VANILLA" ]
  then AC_SETTING='$local_fs $remote_fs'
  else AC_SETTING='$local_fs $remote_fs mysql'
fi

# This writes the new initscript to a temporary location.
echo "#!/bin/bash
# /etc/init.d/$INITNAME

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
# Version $AC_VERSION ($AC_DATE), Copyright (C) 2011-2012
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

# General settings
MCUSERNAME=\"$MCUSERNAME\"
SUDOER=\"$SUDOER\"
MAINTAIN_SCRIPT_PATH=\"$MAINTAIN_SCRIPT_PATH\"
MAINTAIN_SCRIPT_NAME=\"$MAINTAIN_SCRIPT_NAME\"
CONFIG_PATH=\"$CONFIG_PATH\"
CMDGRID_CONF=\"$CMDGRID_CONF\"
UPDATE_CONF=\"$UPDATE_CONF\"
AUTOCONF=\"$AUTOCONF\"
SERVERTYPE=\"$SERVERTYPE\"
SERVICE=\"$SERVICE\"
SERVERPATH=\"$SERVERPATH\"
BACKUPPATH=\"$BACKUPPATH\"

# Advanced settings
CPU_COUNT=\"$CPU_COUNT\"
MIN_SERVER_RAM=\"$MIN_SERVER_RAM\"
MAX_SERVER_RAM=\"$MAX_SERVER_RAM\"
USE_RAMFS=\"$USE_RAMFS\"
USE_RAMDIR=\"$USE_RAMDIR\"

# Expert settings
JVM_OPTIONS=\"$JVM_OPTIONS\"
INVOCATION=\"java -Xmx\$MAX_SERVER_RAM -Xms\$MIN_SERVER_RAM -XX:+UseConcMarkSweepGC -XX:+CMSIncrementalPacing -XX:ParallelGCThreads=\$CPU_COUNT -XX:+AggressiveOpts -jar \$SERVICE \$JVM_OPTIONS\"

# ============================= Script invocation =============================
# Since there was trouble with the user setting (being overridden by startup
# and such) and I splitted the script in an init script and a maintenance
# script. The latter is thus always invocated with the right user environment 
# and can be located anywhere in the system.

# ------------------------------ Variable export ------------------------------
# Do not change anything in here! It exports the relevant settings for the 
# maintenance script to use them.

export INITNAME=\"\${0##*/}\"
export MCUSERNAME
export SUDOER
export MAINTAIN_SCRIPT_PATH
export MAINTAIN_SCRIPT_NAME
export CONFIG_PATH
export CMDGRID_CONF
export UPDATE_CONF
export AUTOCONF
export SERVERTYPE
export SERVICE
export SERVERPATH
export BACKUPPATH
export USE_RAMFS
export USE_RAMDIR
export INVOCATION

# ---------------------------- Install invocation -----------------------------
# This is for installing and updating new scripts, not intended for manual use.

case \$INSTALL in
  1)
    bash -c \$TEMPPATH/mc_initupdater.sh
    exit 0
    ;;
  2)
    bash -c \$TEMPPATH/mc_updater.sh
    exit 0
    ;;
  3)
    bash -c /dev/shm/mc_lastrites.sh
    sudo rm -f /dev/shm/mc_lastrites.sh
    exit 0
    ;;
esac

# -------------------------------- Invocation ---------------------------------
if [ \`whoami\` = \"\$MCUSERNAME\" ] ; then
  bash -c \"\$MAINTAIN_SCRIPT_PATH/\$MAINTAIN_SCRIPT_NAME \$*\"
else
  su \$MCUSERNAME -c \"\$MAINTAIN_SCRIPT_PATH/\$MAINTAIN_SCRIPT_NAME \$*\"
fi
exit 0" > $NEWINIT

# Writing update scripts.
# mc_initupdate.sh is for backup and updating the init script and invocates the
# second update script (for almost everything else) in the end.
AC_OLDINITNAME="$INITNAME"
echo "#!/bin/bash
# $INITNAME" > $TEMPPATH/mc_initupdater.sh
if [ "$UPDATE" = "1" ]
  then 
    echo "sudo mv /etc/init.d/$AC_OLDINITNAME $TEMPPATH/initfile.old
sudo chmod 644 $TEMPPATH/initfile.old" >> $TEMPPATH/mc_initupdater.sh
fi
echo "sudo chown root:root $TEMPPATH/$NEWINIT
sudo chmod 755 $TEMPPATH/$NEWINIT
sudo mv $TEMPPATH/$NEWINIT /etc/init.d/$INITNAME
if [ \"\$?\" = \"1\" ]
  then exit 1
fi
echo 'Init script updated.'
export INSTALL='2'
export TEMPPATH=\"$TEMPPATH\"
bash -c /etc/init.d/$INITNAME
exit 0" >> $TEMPPATH/mc_initupdater.sh
chmod a+x $TEMPPATH/mc_initupdater.sh

# mc_updater.sh is updating all other directories and files after a backup
# Only a part of this file is written in here, others are written by the server
# maintenance file or (in case of new install) mcinstall.sh
echo "sudo mkdir -p \$MAINTAIN_SCRIPT_PATH
sudo chown $MCUSERNAME:$MCUSERNAME \$MAINTAIN_SCRIPT_PATH
sudo mkdir -p \$CONFIG_PATH
sudo chown $MCUSERNAME:$MCUSERNAME \$CONFIG_PATH
sudo mkdir -p \$SERVERPATH
sudo chown $MCUSERNAME:$MCUSERNAME \$SERVERPATH
sudo mkdir -p \$BACKUPPATH
sudo chown $MCUSERNAME:$MCUSERNAME \$BACKUPPATH
echo 'Directories updated.'" >> $TEMPPATH/mc_updater.sh

# Farewell message to indicate proper script termination.
echo "We hope you enjoyed our flight and we're looking forward to see you flying again
with M3tal_Warrior Mineways. Enjoy your stay! Goodbye!"

exit 0
