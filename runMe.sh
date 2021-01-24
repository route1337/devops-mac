#!/bin/bash
#
# Project:: macOS DevOps Configurator
#
# Copyright 2020, Route 1337, LLC, All Rights Reserved.
#
# Maintainers:
# - Matthew Ahrenstein: matthew@route1337.com
#
# See LICENSE
#

# Only permit root to run this script
if [[ "$(id -u)" -ne 0 ]]; then
        echo 'This script must be run by root' >&2
        exit 1
fi

echo "This script will configure macOS 10.15+ for DevOps."
echo "You will be prompted for your password during several steps!"
read -p "Press [ENTER] to install and configure this Mac for development use!"

# Apple approved way to get the currently logged in user (Thanks to Froger from macadmins.org and https://developer.apple.com/library/content/qa/qa1133/_index.html)
ConsoleUser="$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')"

### INSTALL XCODE ###
# Check to see if we have XCode already
echo "Installing XCode Command Line Tools if needed..."
checkForXcode=$( pkgutil --pkgs | grep com.apple.pkg.CLTools_Executables | wc -l | awk '{ print $1 }' )

# If XCode is missing we will install the Command Line tools only as that's all Homebrew needs
if [[ "$checkForXcode" != 1 ]]; then
  macos_vers=$(sw_vers -productVersion | awk -F "." '{print $2}')
  # This temporary file prompts the 'softwareupdate' utility to list the Command Line Tools
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  # Verify softwareupdate installs only the latest XCode (Original code from https://github.com/rtrouton/rtrouton_scripts)
  if [[ "$macos_vers" -ge 15 ]]; then
     cmd_line_tools=$(softwareupdate -l | awk '/\*\ Label: Command Line Tools/ { $1=$1;print }' | sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | cut -c 9-)
  elif [[ "$macos_vers" -gt 9 ]] && [[ "$macos_vers" -lt 14 ]]; then
     cmd_line_tools=$(softwareupdate -l | awk '/\*\ Command Line Tools/ { $1=$1;print }' | grep "$macos_vers" | sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | cut -c 2-)
  elif [[ "$macos_vers" -eq 9 ]]; then
     cmd_line_tools=$(softwareupdate -l | awk '/\*\ Command Line Tools/ { $1=$1;print }' | grep "Mavericks" | sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | cut -c 2-)
  fi
  if (( $(grep -c . <<<"$cmd_line_tools") > 1 )); then
     cmd_line_tools_output="$cmd_line_tools"
     cmd_line_tools=$(printf "$cmd_line_tools_output" | tail -1)
  fi

  softwareupdate -i "$cmd_line_tools"

  rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  /usr/bin/xcode-select --switch /Library/Developer/CommandLineTools
fi
### END INSTALL XCODE ###

### INSTALL HOMEBREW ###
echo "Checking if Homebrew is installed..."
if test ! "$(sudo -u ${ConsoleUser} which brew)"; then
    echo "Installing Homebrew..."
    /bin/mkdir -p /usr/local/bin
    /bin/chmod u+rwx /usr/local/bin
    /bin/chmod g+rwx /usr/local/bin
    /bin/mkdir -p /usr/local/etc /usr/local/include /usr/local/lib /usr/local/sbin /usr/local/share /usr/local/var /usr/local/opt /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var/homebrew /usr/local/var/homebrew/linked /usr/local/Cellar /usr/local/Caskroom /usr/local/Homebrew /usr/local/Frameworks
    /bin/chmod 755 /usr/local/share/zsh /usr/local/share/zsh/site-functions
    /bin/chmod g+rwx /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/sbin /usr/local/share /usr/local/var /usr/local/opt /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var/homebrew /usr/local/var/homebrew/linked /usr/local/Cellar /usr/local/Caskroom /usr/local/Homebrew /usr/local/Frameworks
    /bin/chmod 755 /usr/local/share/zsh /usr/local/share/zsh/site-functions
    /usr/sbin/chown ${ConsoleUser} /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/sbin /usr/local/share /usr/local/var /usr/local/opt /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var/homebrew /usr/local/var/homebrew/linked /usr/local/Cellar /usr/local/Caskroom /usr/local/Homebrew /usr/local/Frameworks
    /usr/bin/chgrp admin /usr/local/bin /usr/local/etc /usr/local/include /usr/local/lib /usr/local/sbin /usr/local/share /usr/local/var /usr/local/opt /usr/local/share/zsh /usr/local/share/zsh/site-functions /usr/local/var/homebrew /usr/local/var/homebrew/linked /usr/local/Cellar /usr/local/Caskroom /usr/local/Homebrew /usr/local/Frameworks
    /bin/mkdir -p /Users/${ConsoleUser}/Library/Caches/Homebrew
    /bin/chmod g+rwx /Users/${ConsoleUser}/Library/Caches/Homebrew
    /usr/sbin/chown ${ConsoleUser} /Users/${ConsoleUser}/Library/Caches/Homebrew
    /bin/mkdir -p /Library/Caches/Homebrew
    /bin/chmod g+rwx /Library/Caches/Homebrew
    /usr/sbin/chown ${ConsoleUser} /Library/Caches/Homebrew
    sudo -H -u ${ConsoleUser} /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    echo "Disabling Homebrew analytics..."
    sudo -H -iu ${ConsoleUser} /usr/local/bin/brew analytics off
else
    echo "Homebrew already installed."
fi
### END INSTALL HOMEBREW ###

### INSTALL AND RUN ANSIBLE ###
echo "Checking if Ansible is installed..."
if test ! "$(sudo -u ${ConsoleUser} which ansible)"; then
    echo "Installing Ansible..."
    sudo -H -u ${ConsoleUser} brew install ansible
else
    echo "Ansible already installed"
fi

echo "Deleting old versions of roles..."
rm -rf ansible/roles/ahrenstein* ansible/roles/route1337*
echo "Pulling new versions of dependency roles..."
sudo -H -u ${ConsoleUser} ansible-galaxy install -r ansible/roles/requirements.yml -p ./ansible/roles
echo "Done."

echo "Running the Ansible playbook mac-devops.yml"
sudo -H -u ${ConsoleUser} /usr/local/bin/ansible-playbook -i ansible/local.inventory ansible/mac-devops.yml
###END INSTALL AND RUN ANSIBLE ###

### FINAL TWEAKS ###
echo "Searching for and installing any available macOS updates..."
softwareupdate -ia
### END FINAL TWEAKS ###

echo "This Mac is now ready for DevOps!"
