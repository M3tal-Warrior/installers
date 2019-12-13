

# ---------------------------- Download subsection ----------------------------
# Does the download, critical and integrity checking







# Writing the file sections of last_rites.sh
mc_updt_prepare() {
  UPDT_CHANGES=$(( $UPDT_CHANGES + 1 ))
  echo "sudo chown root:root \$TEMPPATH/$UPDT_NEWFILE
sudo chmod $MOD \$TEMPPATH/$UPDT_NEWFILE
if [ -f $UPDT_OLDPATH/$UPDT_OLDFILE ]
  then sudo mv $UPDT_OLDPATH/$UPDT_OLDFILE \$TEMPPATH/$UPDT_OLDFILE.old
fi
sudo mv \$TEMPPATH/$UPDT_NEWFILE $UPDT_OLDPATH/$UPDT_OLDFILE" >> last_rites.sh
  echo "$UPDT_OLDFILE prepared for update."
}

# Skips further action if file couldn't be downloaded
mc_updt_manage() {
  mc_updt_download
  if [ "$UPDT_ERROR" = "0" ]
    then
      mc_updt_select
      if [ "$UPDT_NONE" = "0" ]
        then mc_updt_prepare
      fi
  fi
}

# ----------------------------- Update subsection -----------------------------
# These parts do the update itself and write last_rites.sh.

# Controls the preparation of init files
mc_updt_init() {
  cd $TEMPPATH
  export TEMPPATH
  export LASTRITES
  export INIT_PARENT
  export INITNAME
  

  
}

# It only checks for a new version of updater.sh
mc_updt_step1() {
  mc_updt_path
  # Checking for update URLs file
  cd $CONFIG_PATH
  if [ "$URL_UPDATE_CONF" = "" ]
    then
      if [ -f $UPDATE_CONF ]
        then 
        else
          echo "Can't find $UPDATE_CONF! Can't find download locations without! Aborting..."
          exit 1
      fi
  fi
  # Getting new update URLs file
  cd $TEMPPATH
  UPDT_PATH="$CONFIG_PATH"
  UPDT_FILE="$UPDATE_CONF"
  UPDT_TYPE="config"
  UPDT_URL="$URL_UPDATE_CONF"
  mc_updt_download
  mc_updt_critical
  # Grep in freshly downloaded URLs config file for URL of updater.sh
  URL_UPDATER=`cat "$UPDT_NEWPATH/$UPDT_NEWFILE" | grep "UPDATER" | cut -d '"' -f 2 -s`
  # Getting autoconf.sh URL for step 2.
  
  # Getting new updater
  cd $TEMPPATH
  if [ "$UPDATER" = "" ]
    then UPDATER="updater.sh"
  fi
  UPDT_PATH="$CONFIG_PATH"
  UPDT_FILE="$UPDATER"
  UPDT_TYPE="core"
  UPDT_URL="$URL_UPDATER"
  mc_updt_download
  mc_updt_critical
  if [ -f $CONFIG_PATH/$UPDATER ]
    then mc_updt_integrity
    else UPDT_NONE="0"
  fi
  # Preparing step 2
  if [ "$UPDT_NONE" = "0" ]
    then
      export URL_AUTOCONF
      UPDT_STEP="2"
      mv $TEMPPATH/$UPDT_NEWFILE /dev/shm/$UPDATER
      rm -rf $TEMPPATH
      TEMPPATH=""
      bash -c /dev/shm/$UPDATER
      exit 0
    else 
      rm -rf $TEMPPATH
      TEMPPATH=""
  fi
}

# Downloads all files and writes last_rites.sh, if necessary.
# Step 1 ensures this is only processed by the newest updater.sh, either
# downloaded or already in the config directory.
mc_updt_step2() {
  mc_updt_path
  cd $TEMPPATH


VERSIONCHECK!!!!


  # Processing invocating init file as parent
  while [ ! -f /etc/init.d/$INITNAME ]
    do 
      echo "Invocating init script not found. Provide its name:"
      read INITNAME
    done
  INIT_PARENT="$INITNAME"

  mc_updt_init
  


  # Downloading everything; writing last_rites.sh on the way
  
  
  
  
  
}


UPDT_ERROR="0"
UPDT_CHANGES="0"

case $UPDT_STEP in
  1)
    mc_updt_step1
    mc_updt_step2
    ;;
  2)
    mc_updt_step2
    ;;
  *)
    mc_updt_step3
    echo "Binaries updated."
    exit 0
    ;;
esac
mc_updt_step3
echo "All update actions completed."
exit 0


# Checking for file integrity with diff and version comparison
mc_updt_integrity() {
  if `diff $UPDT_OLDPATH/$UPDT_OLDFILE $UPDT_NEWPATH/$UPDT_NEWFILE > /dev/null`
    then
      echo "File up to date."
      if [ "$UPDT_NEWFILE" != "updateurls.conf" ]
        then 
          # This is the exception for installing a new server
          if [ "$UPDT_NEWFILE" != "autoconf.sh" -a "$AUTOCONF_VCHECK" != "0" ]
            then rm $UPDT_NEWPATH/$UPDT_NEWFILE
          fi
      fi
    else
      UPDT_OLDVERSION=`cat "$UPDT_OLDPATH/$UPDT_OLDFILE" | grep -m 1 "VERSION=" | cut -d '"' -f 2 -s`
      UPDT_NEWVERSION=`cat "$UPDT_NEWPATH/$UPDT_NEWFILE" | grep -m 1 "VERSION=" | cut -d '"' -f 2 -s`
      UPDT_VERSION_C=`echo "$UPDT_NEWVERSION>$UPDT_OLDVERSION" | bc`
      if [ "$UPDT_VERSION_C" = "1" ]
        then
          echo "Preparing update..."
        else
          UPDT_VERSION_C=`echo "$UPDT_NEWVERSION==$UPDT_OLDVERSION" | bc`
          echo "Downloaded version number of 
$UPDT_FILE"
          if [ "$UPDT_VERSION_C" = "1" ]
            then echo "is IDENTICAL, but the files are different!"
            else echo "is OLDER - that should be IMPOSSIBLE!"
          fi
          echo "This might indicate a security breach or unauthorized manipulation. 
Update halted for you to investigate...
[ Press ENTER to continue ]"
          read UPDT_HALT
          echo "Preparing replace..."
      fi
      mc_updt_prepare
  fi
}

# Processes download and presence checks

    bin)
      # Server - the binary
      if `diff $UPDT_OLDPATH/$UPDT_OLDFILE $UPDT_NEWPATH/$UPDT_NEWFILE > /dev/null`
        then
          echo "File up to date."
          rm $UPDT_NEWPATH/$UPDT_NEWFILE
        else
          echo "Processing update..."
          UPDT_CHANGES=$(( $UPDT_CHANGES + 1 ))
      fi
      ;;


# Preparing environment and crucial files

  # Reading freshly downloaded config for maintenance and autoconfig script
  # Downloading new maintenance script
  cd $TEMPPATH
  UPDT_PATH="$MAINTAIN_SCRIPT_PATH"
  UPDT_FILE="$MAINTAIN_SCRIPT_NAME"
  UPDT_TYPE="core"
  UPDT_URL="$URL_MAINTAIN_SCRIPT"
  mc_updt_download
  mc_updt_critical
  if [ -f $TEMPPATH/server_control ]
    then chmod a+x $TEMPPATH/server_control
  fi
  # Downloading new autoconf script
  cd $TEMPPATH
  UPDT_PATH="$CONFIG_PATH"
  UPDT_FILE="$AUTOCONF"
  UPDT_TYPE="core"
  UPDT_URL="$URL_AUTOCONF"
  mc_updt_download
  mc_updt_critical
  if [ -f $TEMPPATH/autoconf.sh ]
    then
      if [ -f $CONFIG_PATH/server.list ]
      # Invocating autoconf script
      chmod a+x $TEMPPATH/autoconf.sh
      export INITNAME
      export NEWINIT="init.new"
      export INSTALL
      export UPDATE="1"
      export MCUSERNAME
      export SUDOER
      export TEMPPATH
      bash -c $TEMPPATH/autoconf.sh
      INST_RETURN="$?"
      echo ""
      case $INST_RETURN in
        0) 
          echo "Initscript created."
          echo ""
          UPDT_INIT="1"  
          # Parsing new init script for a modified temporary initializer for 
          # update step 2
          echo "#!/bin/bash" > $TEMPPATH/mod_init.sh
          chmod a+x $TEMPPATH/mod_init.sh
          cat "$TEMPPATH/$NEWINIT" | grep -A 100 "# General settings" | grep -B 100 "Install invocation" >> $TEMPPATH/mod_init.sh
          echo "export TEMPPATH=\"$TEMPPATH\"
export INITNAME=\"$INITNAME\"
export UPDT_STEP=\"2\"
export UPDT_CHANGES=\"$UPDT_CHANGES\"
bash -c \"\$TEMPPATH/server_control update\"
UPDT_RETURN=\"$?\"
if [ \"$UPDT_RETURN\" != \"0\" ]
  then 
    exit 1
fi
exit 0" >> $TEMPPATH/mod_init.sh
          ;;
        2)
          # This applies when autoconf.sh detects an up to date init file
          UPDT_INIT="0"
          ;;
        *)
          echo "Something went terribly wrong during the procedure - can't continue!"
          echo ""
          exit 1
          ;;
      esac
    else UPDT_INIT="0"
  fi
} 

# Preparing update of all files
mc_updt_step2() {
  # Environment checks
  if [ ! -d $TEMPPATH ]
    then
      echo "TEMPPATH couldn't be found! Aborting..."
      exit 1
    else cd $TEMPPATH
  fi
  if [ ! -x mc_updater.sh ]
    then
      echo "mc_updater.sh couldn't be found or isn't executable! Aborting..."
      cd
      rm -rf $TEMPPATH
      exit 1
  fi
  if [ ! -f updateurls.conf ]
    then
      echo "UpdateURLs config file couldn't be found! Aborting..."
      cd
      rm -rf $TEMPPATH
      exit 1
  fi
  # Reading in update urls of user modifiable files
  URL_CMDGRID_CONF=`cat "updateurls.conf" | grep "CMDGRID_CONF" | cut -d '"' -f 2 -s`

  # Getting files
  UPDT_PATH="$CONFIG_PATH"
  UPDT_FILE="$CMDGRID_CONF"
  UPDT_TYPE="edit"
  UPDT_URL="$URL_CMDGRID_CONF"
  mc_updt_download

  # Writing last sections of mc_updater.sh
  cat $TEMPPATH/mc_updater.part >> $TEMPPATH/mc_updater.sh
  rm -f $TEMPPATH/mc_updater.part
  echo "echo \"All script files updated!\"
cd
export INSTALL='3'
bash -c /etc/init.d/$INITNAME
exit 0" >> $TEMPPATH/mc_updater.sh
  # Writing cleaner & checkup script mc_lastrites.sh
  echo "#!/bin/bash
TEMPPATH=\"$TEMPPATH\"
 /dev/shm/mc_lastrites.sh
  chmod a+x /dev/shm/mc_lastrites.sh
  if [ "$UPDT_CHANGES" = "0" ]
    then
      echo "All scripts up to date."
      rm -r $TEMPPATH
      rm /dev/shm/mc_lastrites.sh
      UPDT_RETURN="0"
  elif [ "$SUDOER" = "yes" ]
    then
      bash -c $TEMPPATH/mc_initupdater.sh
      UPDT_RETURN="$?"
    else 
      echo "Please provide user with root/sudo permission to update script files:"
      read UPDT_USER
      su $UPDT_USER -c "$TEMPPATH/mc_initupdater.sh"
      UPDT_RETURN="$?"
  fi

  # Writes an update starter script if something goes wrong in the last step.
  if [ "$UPDT_RETURN" != "0" ]
    then 
      echo "#!/bin/bash
bash -c $TEMPPATH/mc_initupdater.sh
if [ \"\$?\" != \"0\" ]
  then
    echo \"There is no way to do these operations without sudoer rights! Aborting...\"
    exit 1
fi
echo \"Proceeding with binaries...\"
if [ \"\$USER\" != \"root\" -a \"\$USER\" != \"$MCUSERNAME\" ]
  then echo \"Password asked for is the user password of $MCUSERNAME.\"
fi
bash -c \"/etc/init.d/$INITNAME binupdate\"
rm /dev/shm/mc_startupdate.sh
rm 
exit 0" > /dev/shm/mc_startupdate.sh
      chmod a+x /dev/shm/mc_startupdate.sh
      echo "Something went wrong! Aborting..."
      echo "To resume this update by a sudoer user go to /dev/shm and invocate 
mc_startupdate.sh. It will do the rest as if nothing went wrong."
      exit 1
    else echo "Proceeding with binaries..."
  fi
}

# Doing all binaries
mc_updt_step3() {
  UPDT_CHANGES="0"
  TEMPPATH=/dev/shm/mc_update.tmp.`date "+%Y.%m.%d_%H.%M"`
  mkdir -p $TEMPPATH
  cd $CONFIG_PATH
  URL_SERVICE=`cat "$UPDATE_CONF" | grep "$SERVERTYPE" | cut -d '"' -f 2 -s`
  # Workaround for Mojang deleting the static link to the server bin.
  if [ "$SERVERTYPE" = "VANILLA" ]
    then
      cd $TEMPPATH
        fi
  # Downloading server binary
  UPDT_PATH="$MCPATH"
  UPDT_FILE="$SERVICE"
  UPDT_TYPE="bin"
  UPDT_URL="$URL_SERVICE"
  mc_updt_download
  if [ "$UPDT_CHANGES" != "0" ]
    then
      mc_check
      if [ "$CHECK" ]
        then 
          mc_stop
          mc_saveback
      fi
      mc_backup
      mv $UPDT_NEWPATH/$UPDT_NEWFILE $UPDT_OLDPATH/$UPDT_OLDFILE
      mc_start
    echo "Server binary successfully updated and started."
  fi
  rm -rf $TEMPPATH
}



