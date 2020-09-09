# Description
This is an installer for CounterStrike Source dedicated headless servers running
Debian Buster. That usually should make it working for Ubuntu and Linux Mint too.

The default settings make sure nothing of importance is writable by anyone other than root, with the user running the server (default: cssource) having minimal privileges on the system (no login, no shell, no write permissions on binaries, configs and maps), with the exception of ban lists, low privilege download directories and temp files. 

The server will be installed as Systemd service (default: cssource.service) hooked to multi-user-target.wants, with Systemd managing restarts, temp directory permissions and limits.

# HowTo
Download the script (installer.sh) and run it as root. It installs all dependencies from system repositories (no extra repo or fishy download locations), installs the server, sets permissions and performs system integration.

# Ideas, suggestions, bug reports & more
Well, it's GitHub, so you may use pull requests and create issues as you see fit, right?
