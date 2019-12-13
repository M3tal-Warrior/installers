#!/bin/bash

# ================================= Copyright =================================
# Version 1.1 (2013-12-26), Copyright (C) 2011-2013
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

VERSION="1.1"

# ================================== Overview =================================
# This script now handles the complete updating process of the script, its
# children/subfiles and the possible multiple invocation scripts which it 
# searches for in $SERVERS_CONF. It too controls the creating of new servers.
# Motto of the whole script family is: 
# One script to rule them all, 
# one script to find them, 
# one script to bring them all 
# and to the shell bind them.

# ==================================== Code ===================================

# ---------------------------- Preparation section ----------------------------
# Does everything needed for the update process to begin download & replacement

LASTRITES="/dev/shm/last_rites.sh"

mc_updt_variables() {
  cd $TEMPPATH
  # Includes everything from the invocating init script
  # The grep roundtrip is made to leave out all commands.
  if [ -f $INIT_SOURCE ]
    then
      grep -B 100 "= Script invocation =" $INIT_SOURCE > init.tmp
      source init.tmp
      rm -f init.tmp
  fi
}
# Creating temporary update path
mc_updt_path() {
  if [ "$TEMPPATH" = "" ]
    then
      TEMPPATH=/dev/shm/mc_update.tmp.`date "+%Y.%m.%d_%H.%M"`
      echo "Removing files that shouldn't be there anyway, to ensure secure environment..."
      rm -rf $TEMPPATH
      if [ -d $TEMPPATH ]
        then 
          echo "Something is weird here - check your environment for security breaches!"
          exit 1
      fi
      mkdir $TEMPPATH
  fi
}

# Downloading and reading the (new) URL config file
mc_updt_readurls() {
  cd $TEMPPATH
  URL_UPDATE_CONF=`cat "$CONFIG_PATH/$UPDATE_CONF" | grep "UPDATE_CONF" | cut -d '"' -f 2 -s`
  wget -q $URL_UPDATE_CONF
  UPDATE_CONF=`basename $URL_UPDATE_CONF`
  URL_AUTOCONF=`cat "$UPDATE_CONF" | grep "AUTOCONF" | cut -d '"' -f 2 -s`
  URL_CMDGRID_CONF=`cat "$UPDATE_CONF" | grep "CMDGRID_CONF" | cut -d '"' -f 2 -s`
  URL_MAINTAIN_SCRIPT=`cat "$UPDATE_CONF" | grep "MAINTAIN_SCRIPT" | cut -d '"' -f 2 -s`
}


# ----------------------------- Last Rites section ----------------------------
# This contains every writing action to last_rites.sh in this script
# It also keeps track (with UPDT_CHANGES) of additions to the file and thus
# its necessity in the end.

# Preparing head
mc_updt_lrprepare() {
  echo "#!/bin/bash
TEMPPATH=\"$TEMPPATH\"
LASTRITES=\"$LASTRITES\"
sudo echo \"Writing files...\"
if [ \"\$?\" != \"0\" ]
  then 
    echo \"No way updating script files without sudoer rights!\"
    rm -rf \$TEMPPATH
    rm -f \$LASTRITES
    exit 1
fi" > $LASTRITES
  chmod a+x $LASTRITES
  UPDT_CHANGES="0"
}

# Writing commands for replacing forwarded file
mc_updt_lrwrite() {
  if [ "$UPDT_NONE" != "1" ]
    then
      UPDT_CHANGES=$(( $UPDT_CHANGES + 1 ))
      echo "sudo chown root:root \$TEMPPATH/$UPDT_NEWFILE
sudo chmod $MOD \$TEMPPATH/$UPDT_NEWFILE
if [ -f $UPDT_OLDPATH/$UPDT_OLDFILE ]
  then sudo mv $UPDT_OLDPATH/$UPDT_OLDFILE \$TEMPPATH/$UPDT_OLDFILE.old
fi
sudo mv \$TEMPPATH/$UPDT_NEWFILE $UPDT_OLDPATH/$UPDT_OLDFILE" >> $LASTRITES
  fi
}

# Last actions of last_rites.sh, including backup and cleanup
mc_updt_lrtail() {
  if [ "$UPDT_CHANGES" != "0" ]
    then 
      # Backup to desired location, then recheck all files and directories and
      # starting the first server in the config file ('Parent' server)
      # Backup is skipped for install of new servers.
      if [ "$MODE" != "install" ]
        then echo "SCRIPTBACKUP=\"$SCRIPT_BACKUPPATH/scripts_\`date \"+%Y.%m.%d_%H.%M\"\`\" 
sudo mkdir -p \$SCRIPTBACKUP/cmdgrid
sudo mkdir -p \$SCRIPTBACKUP/scriptconf
sudo chmod -R a+x \$SCRIPTBACKUP
cd \$TEMPPATH
if [ -f $CMDGRID_CONF.old ]
  then sudo mv $CMDGRID_CONF.old \$SCRIPTBACKUP/scriptconf
fi
if [ -f $UPDATE_CONF.old ]
  then sudo mv $UPDATE_CONF.old \$SCRIPTBACKUP/scriptconf
fi
if [ -f $AUTOCONF.old ]
  then sudo mv $AUTOCONF.old \$SCRIPTBACKUP/scriptconf
fi
if [ -f $CONFIG_PATH/$UPDATER ]
  then 
    sudo mv $CONFIG_PATH/$UPDATER \$SCRIPTBACKUP/scriptconf/$UPDATER.old
fi
sudo cp /dev/shm/updater.sh $CONFIG_PATH/$UPDATER
sudo chown root:root $CONFIG_PATH/$UPDATER
sudo chmod a+x $CONFIG_PATH/$UPDATER
sudo cp $CMDGRID_PATH/* \$SCRIPTBACKUP/cmdgrid/
sudo mv \$TEMPPATH/* \$SCRIPTBACKUP/" >> $LASTRITES
      fi
      echo "cd /dev/shm
sudo rm -rf \$TEMPPATH
if [ -f $CONFIG_PATH/$SERVERS_CONF -a -f $MAINTAIN_SCRIPT_PATH/$MAINTAIN_SCRIPT_NAME ]
  then
    echo \"Reactors online...\"
    sleep 1
  else
    echo \"$SERVERS_CONF or $MAINTAIN_SCRIPT_NAME not found - Bail out! Bail out!\"
    exit 1
fi
if [ -f $CONFIG_PATH/$UPDATER -a -f $CONFIG_PATH/$UPDATE_CONF ]
  then
    echo \"Sensors online...\"
    sleep 1
  else
    echo \"$UPDATER or $UPDATE_CONF not found - Bail out! Bail out!\"
    exit 1
fi
if [ -f $CONFIG_PATH/$AUTOCONF -a -f $CONFIG_PATH/$CMDGRID_CONF ]
  then
    echo \"Weapons online...\"
    sleep 1
  else
    echo \"$AUTOCONF or $CMDGRID_CONF not found - Bail out! Bail out!\"
    exit 1
fi
if [ -f /etc/init.d/$INIT_PARENT ]
  then
    if sudo \"/etc/init.d/$INIT_PARENT start\" | grep \"started\" >> /dev/null
      then
        echo \"All systems nominal!\"
        sleep 1
      else 
        echo \"Systems failure - ! SERVER DOWN ! - state critical - Bail out! Bail out!\"
        exit 1
  else
    echo \"First init script  not found - Bail out! Bail out!\"
    exit 1
fi" >> $LASTRITES
      # Checking other servers in config and firing them up if desired.
      if [ -f $CONFIG_PATH/$SERVERS_CONF ]
        then AMOUNT=`grep -c : $CONFIG_PATH/$SERVERS_CONF`
        else AMOUNT="1"
      fi
      if [ "$AMOUNT" > "1" ]
        then
          echo "echo \"Establishing connection to lance comrades...\"
while read LINE
  do
    INITNAME=\`echo \$LINE | cut -d : -f 2 -s\`
    if [ \"\$INITNAME\" = \"\" -o \"\$INITNAME\" = \"$INIT_PARENT\" ]
      then continue
    fi
    if [ ! -f \"\$INITNAME\" ]
      then
        echo \"Can't get contact to \$INITNAME! Init sequence must be missing.\"
        continue
    fi
    if sudo \"/etc/init.d/\$INITNAME status\" | grep \"started\" >> /dev/null
      then
        echo \"[Radio (\$INITNAME)]:
Right at your side, lance leader - over.\"
        sleep 1
        continue
    fi
    REDO=\"1\"
    while [ \"\$REDO\" = \"1\" ]
      do
        echo \"Calling \$INITNAME to action, sir? (y/n)\"
        read CHOICE
        case \$CHOICE in
          y)
            if sudo \"/etc/init.d/\$INITNAME start\" | grep \"started\" >> /dev/null
              then
                echo \"[Radio (\$INITNAME)]:
Regrouping at your position, lance leader - over.\"
                sleep 1
                REDO=\"0\"
              else 
                echo \"[Radio (\$INITNAME)]:
*crackle* Having problems - can't start... dammit! Sorry, lance leader! *crack*\"
                sleep 1
                REDO=\"0\"
            fi
            ;;
          n)
            echo \"[Radio (\$INITNAME)]:
Understood - Staying in hangar until further instructions, lance leader. 
Over and out!\"
            sleep 1
            REDO=\"0\"
            ;;
          *)
            echo \"No appropriate choice, lance leader.\"
            ;;
        esac
      done
  done < \"$CONFIG_PATH/$SERVERS_CONF\"" >> $LASTRITES
      fi
      echo "echo \"Now everything lies in your hands again, lance leader!\"
mv $LASTRITES $SCRIPTBACKUP
    sleep 4
exit 0" >> $LASTRITES
    else 
      echo "All script files seem to be up to date."
      rm $LASTRITES 
  fi
}

# ------------------------ Download & checking section ------------------------

# Downloads files
mc_updt_download() {
  echo "Downloading $UPDT_FILE..."
  cd $TEMPPATH
  wget -q $UPDT_URL
  UPDT_NEWFILE=`basename $UPDT_URL`
  UPDT_OLDPATH="$UPDT_PATH"
  UPDT_OLDFILE="$UPDT_FILE"
  if [ "$UPDT_OLDFILE" = "" ]
    then UPDT_OLDFILE="$UPDT_NEWFILE"
  fi
  if [ ! -f $TEMPPATH/$UPDT_NEWFILE ]
    then
      echo "Couldn't download new version of $UPDT_OLDFILE - try again later!"
      UPDT_ERROR="1"
    else
      UPDT_ERROR="0" 
      echo "Done."
  fi
}

# Testing for update critical files - aborts if an error occured during download
mc_updt_critical() {
  if [ "$UPDT_ERROR" != "0" ]
    then 
      echo "Can't do stuff without that file! Aborting..."
      cd /dev/shm
      rm -rf $TEMPPATH
      rm -f $LASTRITES
      exit 1
  fi
}

# Checking for file integrity with diff and version comparison
mc_updt_integrity() {
  if [ -f $UPDT_OLDPATH/$UPDT_OLDFILE ]
    then 
      if `diff $UPDT_OLDPATH/$UPDT_OLDFILE $TEMPPATH/$UPDT_NEWFILE > /dev/null`
        then
          echo "File up to date."
          UPDT_NONE="1"
          rm -f $TEMPPATH/$UPDT_NEWFILE
        else
          UPDT_OLDVERSION=`cat "$UPDT_OLDPATH/$UPDT_OLDFILE" | grep -m 1 "VERSION=" | cut -d '"' -f 2 -s`
          UPDT_NEWVERSION=`cat "$UPDT_NEWPATH/$UPDT_NEWFILE" | grep -m 1 "VERSION=" | cut -d '"' -f 2 -s`
          UPDT_VERSION_C=`echo "$UPDT_NEWVERSION>$UPDT_OLDVERSION" | bc`
          if [ "$UPDT_VERSION_C" = "1" ]
            then
              UPDT_NONE="0"
            else
              UPDT_VERSION_C=`echo "$UPDT_NEWVERSION==$UPDT_OLDVERSION" | bc`
              echo "Downloaded version number of 
$UPDT_FILE"
              if [ "$UPDT_VERSION_C" = "1" ]
                then echo "is IDENTICAL, but the files are different!"
                else echo "is OLDER - that should be IMPOSSIBLE!"
              fi
              echo "This might indicate a security breach or unauthorized manipulation. Because of
this I've decided to replace it in the update process.
Update halted for you to investigate...
[ Press ENTER to continue ]"
              read UPDT_HALT
              UPDT_NONE="0"
          fi
      fi
  fi
}

# Selects type of check and security modes. Exception: Temporary stuff, binaries
mc_updt_select() {
  case $UPDT_TYPE in
    config)
      # Config files which are not to be edited by anyone,
      # i.e. updateurls.conf
      MOD="644"
      mc_updt_critical
      mc_updt_integrity
      ;;
    core)
      # Core files are autoconf.sh, and server_control
      MOD="755"
      mc_updt_critical
      mc_updt_integrity
      ;;
    edit)
      # All editable config files, i. e. commandgrid.conf and servers.conf
      MOD="644"
      UPDT_OLDVERSION=`cat "$UPDT_OLDPATH/$UPDT_OLDFILE" | grep -m 1 "VERSION=" | cut -d '"' -f 2 -s`
      UPDT_NEWVERSION=`cat "$UPDT_NEWPATH/$UPDT_NEWFILE" | grep -m 1 "VERSION=" | cut -d '"' -f 2 -s`
      UPDT_VERSION_C=`echo "$UPDT_NEWVERSION>$UPDT_OLDVERSION" | bc`
      if [ "$UPDT_VERSION_C" = "1" ]
        then
          echo "This seems to be a syntax update. Old files have to be converted manually."
          echo "[ Press ENTER to continue ]"
          read UPDT_HALT
          cp $UPDT_OLDPATH/$UPDT_OLDFILE $UPDT_OLDPATH/$UPDT_OLDFILE.old
          echo "Backup done."
          echo "Preparing update..."
          UPDT_NONE="0"
        else 
          rm $UPDT_NEWPATH/$UPDT_NEWFILE
          UPDT_NONE="1"
      fi
      ;;
    bin)
      # Server - the binary
      # Checking every single jar file in the download directory
      UPDT_CHANGES="0"
      find *.jar | while read FILE 
        do
          if `diff $FILE $SERVERPATH/$FILE > /dev/null`
            then UPDT_CHANGES=$(( $UPDT_CHANGES + 1 ))
          fi
        done
      if [ "$UPDT_CHANGES" = "0" ]
        then
          echo "Server up to date."
          rm -r "$TEMPPATH/*"
          continue
        else
          echo "There's a new update available for server $INITNAME."
          REDO="1"
          while [ "$REDO" = "1" ]
            do
              echo "Do you wish to install it?"
              read CHOICE
              if [ "$CHOICE" = "y" -o "$CHOICE" = "n" ]
                then REDO="0"
              fi
            done
          if [ $CHOICE = "n" ]
            then continue
          fi
          echo "Processing update..."          
      fi
      # Backup & stopping server
      /etc/init.d/$INITNAME backup
      /etc/init.d/$INITNAME stop
      if [ "$?" != "0" ]
        then
          echo "Skipping update of server $INITNAME."
          rm -rf $TEMPPATH/*
          continue
      fi
      # Checking & replacing every single file in the download directory (1 for 
      # all options except CUSTOM)
      find * | while read FILE 
        do
          if [ -d $FILE ]
            then 
              mkdir -p $SERVERPATH/$FILE
              continue
          fi
          mv $FILE $SERVERPATH/$FILE
        done
      rm -rf $TEMPPATH/*
      # Firing the server up again 
      /etc/init.d/$INITNAME start
      echo "Server binary for $INITNAME successfully updated."  
      ;;
  esac
}

# Updating init files
mc_updt_init() {
  if [ "$SERVERS_CONF" != "" -a -f $CONFIG_PATH/$SERVERS_CONF ]
    then
      INIT_PARENT=`head -n 1 $CONFIG_PATH/$SERVERS_CONF | cut -d : -f 2 -s`
      while read LINE
        do
          INITNAME=`echo $LINE | cut -d : -f 2 -s`
          if [ "$INITNAME" = "" ]
            then continue
          fi 
          UPDT_OLDVERSION=`grep -m 1 "# Version" "/etc/init.d/$INITNAME" | cut -d ' ' -f 3 -s`
          UPDT_NEWVERSION=`grep -m 1 "AC_VERSION=" "$TEMPPATH/$INITWRITER" | cut -d '"' -f 2 -s`
          if [ "$UPDT_OLDVERSION" != "$UPDT_NEWVERSION" ]
            then
              export INITNAME
              export INIT_PARENT
              export MODE
              export TEMPPATH
              export LASTRITES
              bash -c $INITWRITER
              UPDT_CHANGES=$(( $UPDT_CHANGES + 1 ))
          fi
        done < $CONFIG_PATH/$SERVERS_CONF
      AMOUNT=`grep -c : $CONFIG_PATH/$SERVERS_CONF`
      if [ "$AMOUNT" -ge "5" ]
        echo "Holy shit - you're collecting frequent flyer miles, do you?"
        sleep 2
      fi      
    else 
      INITNAME="$INIT_PARENT"
      export INITNAME
      export INIT_PARENT
      export MODE
      export TEMPPATH
      export LASTRITES
      bash -c $INITWRITER
  fi      
}

# =============================== Main section ================================

mc_updt_path
INIT_SOURCE="/etc/init.d/$INIT_PARENT"
mc_updt_variables

case MODE in
  script)
    mc_updt_readurls
    mc_updt_lrprepare
    # Downloading autoconf.sh for updating and registering the init scripts
    UPDT_PATH="$CONFIG_PATH"
    UPDT_FILE="$AUTOCONF"
    UPDT_TYPE="core"
    UPDT_URL="$URL_AUTOCONF"
    mc_updt_download
    mc_updt_select
    if [ "$UPDT_NONE" != "1" ]
      then
        INITWRITER="$UPDT_NEWFILE"
        chmod a+x $INITWRITER
        mc_updt_init
        # Updating all global variables (out of fresh INIT_PARENT file)
        # This time for reading in all new variables
        INIT_SOURCE="$TEMPPATH/$INIT_PARENT"
        mc_updt_variables
    fi
    mc_updt_lrwrite
    # Downloading server_control
    UPDT_PATH="$MAINTAIN_SCRIPT_PATH"
    UPDT_FILE="$MAINTAIN_SCRIPT_NAME"
    UPDT_TYPE="core"
    UPDT_URL="$URL_MAINTAIN_SCRIPT"
    mc_updt_download
    mc_updt_select
    mc_updt_lrwrite
    # Downloading updateurls.conf
    UPDT_PATH="$CONFIG_PATH"
    UPDT_FILE="$UPDATE_CONF"
    UPDT_TYPE="config"
    UPDT_URL="$URL_UPDATE_CONF"
    mc_updt_download
    mc_updt_select
    mc_updt_lrwrite
    # Downloading commandgrid.conf
    UPDT_PATH="$CONFIG_PATH"
    UPDT_FILE="$CMDGRID_CONF"
    UPDT_TYPE="edit"
    UPDT_URL="$URL_CMDGRID_CONF"
    mc_updt_download
    mc_updt_select
    mc_updt_lrwrite
    # Finishing last_rites.sh and execute it
    mc_updt_lrtail
  ;;
  bin)
    INIT_PARENT=`grep ":" $CONFIG_PATH/$SERVERS_CONF | head -n 1 | cut -d : -f 2 -s`
    while read LINE
      do
        INITNAME=`echo $LINE | cut -d : -f 2 -s`
        if [ "$INITNAME" = "" ]
          then continue
          else INIT_SOURCE="/etc/init.d/$INITNAME"
        fi
        echo "Processing $INITNAME..."
        mc_updt_variables
        if [ "$SERVERTYPE" != "CUSTOM" ]
          then
            URL_SERVICE=`grep "$SERVERTYPE" "$CONFIG_PATH/$UPDATE_CONF" | cut -d '"' -f 2 -s`
            cd $TEMPPATH
            wget -qO site.tmp $URL_SERVICE
            case $SERVERTYPE in
              BUKKIT_DEV)
                URL_SERVICE="http://dl.bukkit.org`grep -m 1 .jar site.tmp | cut -d '"' -f 2 -s`"
              ;;
              BUKKIT_BETA)
                URL_SERVICE="http://dl.bukkit.org`grep -m 1 .jar site.tmp | cut -d '"' -f 2 -s`"
              ;;
              BUKKIT)
                URL_SERVICE="http://dl.bukkit.org`grep -m 1 .jar site.tmp | cut -d '"' -f 2 -s`"
              ;;
              VANILLA)
                URL_SERVICE=`grep -m 1 -A 200 "<h2>Multiplayer Server</h2>" site.tmp | grep -m 1 "Linux" | cut -d '"' -f 6 -s`
              ;;
              VANILLA_SNAPSHOT)
                grep -m 1 -A 10000 "Minecraft [0-9].[0-9].[0-9] Pre-release</a></h2>" site.tmp > mp.tmp
                grep -m 1 -A 10000 "Minecraft Snapshot 1[3-9]w[0-5][0-9][a-g]</a></h2>" site.tmp > ms.tmp
                UPDT_MP=`stat -c %s mp.tmp`
                UPDT_MS=`stat -c %s ms.tmp`
                if [ "$UPDT_MP" > "$UPDT_MS" ]
                  then URL_SERVICE=`grep -m 1 "Server cross-platform jar:" mp.tmp | cut -d '"' -f 2 -s`
                  else URL_SERVICE=`grep -m 1 "Server cross-platform jar:" ms.tmp | cut -d '"' -f 2 -s`
                fi
                if [ "$URL_SERVICE" = "" ]
                  then continue
                fi
              ;;
            esac
            rm -rf $TEMPPATH/*
            # Downloading server binary
            UPDT_PATH="$MCPATH"
            UPDT_FILE="$SERVICE"
            UPDT_TYPE="bin"
            UPDT_URL="$URL_SERVICE"
            mc_updt_download
            mv $UPDT_NEWFILE $SERVICE  
          else
            UPDT_TYPE="bin"
            if [ -f $MAINTAIN_SCRIPT_PATH/custom_update.sh ]
              then include $MAINTAIN_SCRIPT_PATH/custom_update.sh
              else rsync -ahu $UPDATE_PATH/* $TEMPPATH/
            fi
        fi
        cd $TEMPPATH
        if [ `ls | grep -c [a-z]` = "0" ]
          then continue
        fi
        mc_updt_select
        rm -rf $TEMPPATH/*  
      done < $CONFIG_PATH/$SERVERS_CONF
    rm -rf $TEMPPATH
    exit 0
  ;;
  install)
    cd $TEMPPATH
    mc_updt_lrprepare
    INITWRITER="$CONFIG_PATH/$AUTOCONF"
    cat /etc/init.d/$INIT_PARENT > $INIT_PARENT
    export INITNAME
    export INIT_PARENT
    export MODE
    export TEMPPATH
    export LASTRITES
    bash -c $INITWRITER
    UPDT_CHANGES="1"
    mc_updt_lrtail
  ;;
esac
cd /dev/shm
if [ -f $LASTRITES ]
  then 
    echo "Provide user with sudo rights for last part of the process:"
    read CHOICE
    su $CHOICE -c $LASTRITES
  else
    echo "Nothing has changed since you last checked, so we don't need an update."
    rm -rf $TEMPPATH
fi
rm -f $UPDATER
exit 0
