#!/bin/bash

# install.sh
# Installs a dedicated Counter Strike Source server in a way that honors the 
# FHS (Filesystem Hierarchy Standard) and grants minimal permissions to the
# hosting user, as to minimize the impact of potential security flaws in the
# software on security of system and network.


# ================================= Copyright =================================
# Version 0.1 (2019-12-03), Copyright (C) 2019
# Author: Metal_Warrior
# Coauthors: -

#   This program is free software: you can redistribute it and/or modify it 
#   under the terms of the GNU General Public License as published by the 
#   Free Software Foundation, either version 3 of the License, or any later 
#   version.
#   This Program is distributed in the hope that it will be useful, but 
#   WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
#   or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License 
#   for more details.

#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see <http://www.gnu.org/licenses/>.

#   On Debian systems, the full text of the GNU General Public License
#   version 3 can be found in the file 
#     `/usr/share/common-licenses/GPL-3'


# ================================= Variables =================================

# Default name of executing user
CI_USER_DEFAULT="cssource"


# ================================= Functions =================================

ci_setvars() {
# Default home of executing user
CI_HOME_DEFAULT="/var/lib/$CI_USER"
# Default install directory (root writable only)
CI_INSTALLDIR_DEFAULT="/opt/$CI_USER"
# Default log directory
CI_LOGDIR_DEFAULT="/var/log/$CI_USER"
# Default temp directory
CI_TMPDIR_DEFAULT="/tmp/$CI_USER"
}


# =============================== Prerequisites ===============================

# We're setting the path variable anew because some systems have that wrong
PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

# Check if being root
if [ "$(whoami)" != "root" ]
  then
    echo "You must execute this script as root."
    exit 1
fi

# Tell the user what we're doing
echo "Update the system and install dependencies..."
sleep 1

# Add 32 bit architecture, which is necessary for Steam
dpkg --add-architecture i386

# Update and upgrade all packages
apt-get update -qq && apt-get dselect-upgrade

# Install dependencies
apt-get install lib32gcc1 libc6-i386 steamcmd
if [ "$?" = "1" ]
  then
    echo "these packages are critical - without them there's no install of CS:S!"
    exit 1
  else
    # Empty the screen
    clear
fi


# =================================== Main ====================================

# Tell the user what I mean when talking about defaults
echo -e "You can change all defaults to your desire, but they're compliant with FHS and\nthus I don't advise to do so without pressing reasons.\nSimple pressing ENTER will use the defaults.\n"

# Create user
echo -e "\nChange the username of the server host (default: $CI_USER_DEFAULT)"
read CI_USER
CI_USER="${CI_USER:-$CI_USER_DEFAULT}"
# Reset all variables to reflect the users name
ci_setvars
echo -e "\nChange the users writable directory (default: $CI_HOME_DEFAULT)"
read CI_HOME
CI_HOME="${CI_HOME:-$CI_HOME_DEFAULT}"
# Create directory in case it contains nonexisting parents
mkdir -p "$CI_HOME"
if ! adduser --system "$CI_USER" --home "$CI_HOME" 2>/dev/null
  then
    echo "User could not be created. Continue anyway? (y/N)"
    read RESPONSE
    if [ "$RESPONSE" != "y" -a "$RESPONSE" != "Y" ]
      then
        echo "Abort by user."
        exit 1
    fi
fi

# Create install dir
echo -e "\nChange the install directory (default: $CI_INSTALLDIR_DEFAULT)"
read CI_INSTALLDIR
CI_INSTALLDIR=${CI_INSTALLDIR:-$CI_INSTALLDIR_DEFAULT}
# Create directory in case it contains nonexisting parents
mkdir -p "$CI_INSTALLDIR"

# Reset HOME to push .steam to the home directory of the user
HOME="$CI_HOME"
# Get CS:S
echo "Downloading CS:S..."
sleep 1
if ! /usr/games/steamcmd +login anonymous +force_install_dir "$CI_INSTALLDIR" +app_update 232330 validate +quit
  then
    echo "Steamcmd exited with code $? - we abort here!"
    exit 1
  else
    clear
fi

# Tell the user
echo "Correcting wrong permissions..."

# Correct all file modes
find "$CI_HOME" -type f -exec chmod a-x {} \;
chmod a+x "$CI_HOME/.steam/steamcmd/steamcmd.sh"
chmod a+x "$CI_HOME/.steam/steamcmd/linux32/steamcmd"
chmod a+x "$CI_HOME/.steam/steamcmd/linux32/steamerrorreporter"
chmod a+x "$CI_HOME/.steam/steamcmd/siteserverui/linux64/siteserverui"
find "$CI_INSTALLDIR" -type f -exec chmod a-x {} \;
chmod a+x "$CI_INSTALLDIR/srcds_linux"
chmod a+x "$CI_INSTALLDIR/srcds_run"
chmod a+x "$CI_INSTALLDIR/bin/vpk_linux32"

# Set logdir
echo -e "\nChange the log directory for the service (default: $CI_LOGDIR_DEFAULT)"
read CI_LOGDIR
CI_LOGDIR="${CI_LOGDIR:-$CI_LOGDIR_DEFAULT}"
mkdir -p "$CI_LOGDIR"
chown "$CI_USER" "$CI_LOGDIR"
# Set tempdir
echo -e "\nChange the temp directory for the service (default: $CI_TMPDIR_DEFAULT)"
read CI_TMPDIR
CI_TMPDIR="${CI_TMPDIR:-$CI_TMPDIR_DEFAULT}"

# Tell the user
echo "Introducing FHS compliance to Steam/CS:S..."

# Link files/directories to *NIX standard directories
# steam_appid.txt -> $HOME/
if [ -f "$CI_INSTALLDIR/steam_appid.txt" ]
  then
    mv "$CI_INSTALLDIR/steam_appid.txt" "$CI_HOME/"
fi
ln -s "$CI_HOME/steam_appid.txt" "$CI_INSTALLDIR/steam_appid.txt"
# cstrike download directory -> $HOME/
if [ -d "$CI_INSTALLDIR/cstrike/download" ]
  then
    mv "$CI_INSTALLDIR/cstrike/download" "$CI_HOME/"
  else
    mkdir -p "$CI_HOME/download"
fi
ln -s "$CI_HOME/download" "$CI_INSTALLDIR/cstrike/"
# cstrike downloadlists directory -> $HOME/
if [ -d "$CI_INSTALLDIR/cstrike/downloadlists" ]
  then
    mv "$CI_INSTALLDIR/cstrike/downloadlists" "$CI_HOME/"
  else
    mkdir -p "$CI_HOME/downloadlists"
fi
ln -s "$CI_HOME/downloadlists" "$CI_INSTALLDIR/cstrike/"
# Log directory -> /var/log/...
if [ -d "$CI_INSTALLDIR/cstrike/logs" ]
  then
    rm -r "$CI_INSTALLDIR/cstrike/logs"
fi
ln -s "$CI_LOGDIR" "$CI_INSTALLDIR/cstrike/logs"
# modelsounds.cache -> /tmp/...
if [ -f "$CI_INSTALLDIR/cstrike/modelsounds.cache" ]
  then
    mv "$CI_INSTALLDIR/cstrike/modelsounds.cache" "$CI_TMPDIR/"
fi
ln -s "$CI_TMPDIR/modelsounds.cache" "$CI_INSTALLDIR/cstrike/modelsounds.cache"
# banned_ip.cfg -> $HOME/bans/
mkdir -p "$CI_HOME/bans"
if [ -f "$CI_INSTALLDIR/cstrike/cfg/banned_ip.cfg" ]
  then
    mv "$CI_INSTALLDIR/cstrike/cfg/banned_ip.cfg" "$CI_HOME/bans/"
fi
ln -s "$CI_HOME/bans/banned_ip.cfg" "$CI_INSTALLDIR/cstrike/cfg/"
# banned_user.cfg -> $HOME/bans/
if [ -f "$CI_INSTALLDIR/cstrike/cfg/banned_user.cfg" ]
  then
    mv "$CI_INSTALLDIR/cstrike/cfg/banned_user.cfg" "$CI_HOME/bans/"
fi
ln -s "$CI_HOME/bans/banned_user.cfg" "$CI_INSTALLDIR/cstrike/cfg/"
# steamapps downloading directory -> /tmp/...     ### Probably unnecessary ###
if [ -d "$CI_INSTALLDIR/steamapps/downloading" ]
  then
    mv "$CI_INSTALLDIR/steamapps/downloading" "$CI_TMPDIR/"
fi
ln -s "$CI_TMPDIR/downloading" "$CI_INSTALLDIR/steamapps/downloading"
# shadercache directory -> /tmp/...               ### Probably unnecessary ###
if [ -d "$CI_INSTALLDIR/steamapps/shadercache" ]
  then
    mv "$CI_INSTALLDIR/steamapps/shadercache" "$CI_TMPDIR/"
fi
ln -s "$CI_TMPDIR/shadercache" "$CI_INSTALLDIR/steamapps/shadercache"
# temp directory -> /tmp/...                      ### Probably unnecessary ###
if [ -d "$CI_INSTALLDIR/steamapps/temp" ]
  then
    mv "$CI_INSTALLDIR/steamapps/temp" "$CI_TMPDIR/"
fi
ln -s "$CI_TMPDIR/temp" "$CI_INSTALLDIR/steamapps/temp"
# Circumvent .steam bug with steam_api
ln -s "steamcmd/linux32" "$CI_HOME/.steam/sdk32"

# Create an adminstrator maps folder
mkdir -p "$CI_INSTALLDIR/maps"

# Give the user permissions on its whole home directory, since we created a lot 
# of files as root there
chown -R "$CI_USER" "$CI_HOME"

# Tell the user
clear
echo -e "=== Server Setup ==="

# Get the server config
if wget -q https://raw.githubusercontent.com/M3tal-Warrior/installers/master/cssource/servercfg.template -O "$CI_INSTALLDIR/cstrike/cfg/server.cfg"
  then
    chmod 644 "$CI_INSTALLDIR/cstrike/cfg/server.cfg"
    # Ask for certain aspects of the server
    echo -e "\nProvide the name your gameserver will display in CS:S"
    read CI_SERVERNAME
    # Login password
    CI_LOGINPASSWD="$RANDOM$RANDOM$RANDOM$RANDOM"
    while [ "$CI_LOGINPASSWD" != "$CI_RETRY" ]
      do
        echo -e "\nGameserver login password? (leave empty to allow everyone)"
        read -s CI_LOGINPASSWD
        echo -e "\nConfirm password"
        read -s CI_RETRY
      done
    # Admin password
    CI_ADMINPASSWD="$RANDOM$RANDOM$RANDOM$RANDOM"
    while [ "$CI_ADMINPASSWD" != "$CI_RETRY" ]
      do
        echo -e "\n\nGameserver admin password? (do NOT leave empty!)"
        read -s CI_ADMINPASSWD
        echo -e "\nConfirm password"
        read -s CI_RETRY
        # Prevent an empty password here
        if [ "$CI_RETRY" = "" ]
          then
            CI_RETRY="yes, you set that password!"
        fi
      done
    # Rewrite the config template
    sed -i "s#CI_SERVERNAME#$CI_SERVERNAME#" "$CI_INSTALLDIR/cstrike/cfg/server.cfg"
    sed -i "s#CI_LOGINPASSWD#$CI_LOGINPASSWD#" "$CI_INSTALLDIR/cstrike/cfg/server.cfg"
    sed -i "s#CI_ADMINPASSWD#$CI_ADMINPASSWD#" "$CI_INSTALLDIR/cstrike/cfg/server.cfg"
    # Ask if there's a wish to edit the file
    echo -e "\nIt is advised to edit the config personally for further options.\nDo that now? (Y/n)"
    read RESPONSE
    if [ "$RESPONSE" != "n" -a "$RESPONSE" != "N" ]
      then
        vi "$CI_INSTALLDIR/cstrike/cfg/server.cfg"
    fi
  else
    echo "server.cfg template could not be downloaded, aborting..."
    exit 1
fi      

# Download the systemd unit file template
echo -e "\nInstalling CS:S as a service..."
# Avoid accidental overwriting of another unit file
CI_UNITNAME="$CI_USER"
while [ -f "/etc/systemd/system/$CI_UNITNAME.service" ]
  do
    echo "$CI_UNITNAME.service is already existing. Overwrite? (y/N)"
    read RESPONSE
    if [ "$RESPONSE" = "y" -o "$RESPONSE" = "Y" ]
      then
        rm "/etc/systemd/system/$CI_UNITNAME.service"
      else
        echo "Provide another name"
        read CI_UNITNAME
    fi
  done
# Download
if wget -q https://raw.githubusercontent.com/M3tal-Warrior/installers/master/cssource/systemd_unit.template -O /etc/systemd/system/$CI_UNITNAME.service
  then
    chmod 644 "/etc/systemd/system/$CI_UNITNAME.service"
    # Modify the template
    sed -i "s#CI_HOME#$CI_HOME#g" "/etc/systemd/system/$CI_UNITNAME.service"
    sed -i "s#CI_INSTALLDIR#$CI_INSTALLDIR#g" "/etc/systemd/system/$CI_UNITNAME.service"
    sed -i "s#CI_TMPDIR#$CI_TMPDIR#g" "/etc/systemd/system/$CI_UNITNAME.service"
    sed -i "s#CI_USER#$CI_USER#g" "/etc/systemd/system/$CI_UNITNAME.service"
    # Enable the service
    systemctl daemon-reload
    systemctl enable "$CI_UNITNAME"
    # Start the unit?
    echo -e "\nStart the server now? (Y/n)"
    read RESPONSE
    if [ "$RESPONSE" != "n" -a "$RESPONSE" != "N" ]
      then
        systemctl start "$CI_UNITNAME"
    fi
  else
    echo "Systemd unit template could not be downloaded, aborting..."
    exit 1
fi

echo "We're done!"
# This movie is over
exit 0
