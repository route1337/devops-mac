#!/bin/bash
#
# Project:: macOS DevOps Configurator
#
# Copyright 2020, Route 1337, LLC, All Rights Reserved.
#
# Maintainers:
# - Matthew Ahrenstein: matthew@route1337.com
#
# Using MIT Licensed Code From:
# - "rtrouton": https://github.com/rtrouton
#
# See LICENSE
#

# Check if Apple Silicon
if [ "$(uname -m)" == "arm64" ]; then
	IS_ARM=1
	BREW_BIN_PATH="/opt/homebrew/bin"
  ConsoleUser="$( echo "show State:/Users/ConsoleUser" | scutil | awk '/Name :/ && ! /loginwindow/ { print $3 }' )"
else
	IS_ARM=0
	BREW_BIN_PATH="/usr/local/bin"
  ConsoleUser="$(/usr/bin/python -c 'from SystemConfiguration import SCDynamicStoreCopyConsoleUser; import sys; username = (SCDynamicStoreCopyConsoleUser(None, None, None) or [None])[0]; username = [username,""][username in [u"loginwindow", None, u""]]; sys.stdout.write(username + "\n");')"
fi

echo "This script will configure macOS 11+ for DevOps."
echo "You will be prompted for your password during several steps!"
read -p "Press [ENTER] to install and configure this Mac for development use!"

### INSTALL XCODE ###
### Script from rtrouton ###
# Source: https://github.com/ryangball/rtrouton_scripts/blob/main/rtrouton_scripts/install_xcode_command_line_tools/install_xcode_command_line_tools.sh

# Installing the latest Xcode command line tools on 10.9.x or higher
ignoreBeta="true"	# Setting to true will ignore beta. However, setting to false does not guarantee a beta is available.
# Save current IFS state
OLDIFS=$IFS
IFS='.' read osvers_major osvers_minor osvers_dot_version <<< "$(/usr/bin/sw_vers -productVersion)"
# restore IFS to previous state
IFS=$OLDIFS
cmd_line_tools_temp_file="/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"

if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -ge 9 ) || ( ${osvers_major} -ge 11 && ${osvers_minor} -ge 0 ) ]]; then

	# Create the placeholder file which is checked by the softwareupdate tool
	# before allowing the installation of the Xcode command line tools.

	touch "$cmd_line_tools_temp_file"

	# Identify the correct update in the Software Update feed with "Command Line Tools" in the name for the OS version in question.

	if [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -ge 15 ) || ( ${osvers_major} -ge 11 && ${osvers_minor} -ge 0 ) ]]; then
	   cmd_line_tools=$(softwareupdate -l | awk '/\*\ Label: Command Line Tools/ { $1=$1;print }' | sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | cut -c 9-)
	elif [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -gt 9 ) ]] && [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -lt 15 ) ]]; then
	   cmd_line_tools=$(softwareupdate -l | awk '/\*\ Command Line Tools/ { $1=$1;print }' | grep "$osvers_minor" | sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | cut -c 2-)
	elif [[ ( ${osvers_major} -eq 10 && ${osvers_minor} -eq 9 ) ]]; then
	   cmd_line_tools=$(softwareupdate -l | awk '/\*\ Command Line Tools/ { $1=$1;print }' | grep "Mavericks" | sed 's/^[[ \t]]*//;s/[[ \t]]*$//;s/*//' | cut -c 2-)
	fi

	# Check to see if the softwareupdate tool has returned more than one Xcode
	# command line tool installation option. If it has, use the last one listed
	# as that should be the latest Xcode command line tool installer.

	if (( $(grep -c . <<<"$cmd_line_tools") > 1 )); then
	   cmd_line_tools_output="$cmd_line_tools"
	   cmd_line_tools=$(printf "$cmd_line_tools_output" | tail -1)
	fi
	#Install the command line tools
	softwareupdate -i "$cmd_line_tools" --verbose
	# Remove the temp file
	if [[ -f "$cmd_line_tools_temp_file" ]]; then
	  rm "$cmd_line_tools_temp_file"
	fi
fi
### Script from rtrouton ###
### END INSTALL XCODE ###

### INSTALL HOMEBREW ###
echo "Checking if Homebrew is installed..."
if test ! "$(sudo -u ${ConsoleUser} which brew)"; then
    if [[ "$IS_ARM" == 0 ]];then
      echo "Installing x86_64 Homebrew..."
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
    else:
      echo "Installing arm64 Homebrew..."
      /bin/mkdir -p /opt/homebrew
      /bin/chmod u+rwx /opt/homebrew
      /usr/sbin/chown ${ConsoleUser} /opt/homebrew
    fi
    sudo -H -u ${ConsoleUser} /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    echo "Disabling Homebrew analytics..."
    sudo -H -iu ${ConsoleUser} ${BREW_BIN_PATH}/brew analytics off
else
    echo "Homebrew already installed."
fi
### END INSTALL HOMEBREW ###

### INSTALL AND RUN ANSIBLE ###
echo "Checking if Ansible is installed..."
if test ! "$(sudo -u ${ConsoleUser} which ansible)"; then
    echo "Installing Ansible..."
    sudo -H -u ${ConsoleUser} ${BREW_BIN_PATH}/brew install ansible
else
    echo "Ansible already installed"
fi

echo "Deleting old versions of roles..."
rm -rf ansible/roles/ahrenstein* ansible/roles/route1337*
echo "Pulling new versions of dependency roles..."
sudo -H -u ${ConsoleUser} ${BREW_BIN_PATH}/ansible-galaxy install -r ansible/roles/requirements.yml -p ./ansible/roles
echo "Done."

echo "Running the Ansible playbook mac-devops.yml"
sudo -H -u ${ConsoleUser} ${BREW_BIN_PATH}/ansible-playbook -i ansible/local.inventory ansible/mac-devops.yml
###END INSTALL AND RUN ANSIBLE ###

### FINAL TWEAKS ###
echo "Searching for and installing any available macOS updates..."
softwareupdate -ia
### END FINAL TWEAKS ###

echo "This Mac is now ready for DevOps!"
