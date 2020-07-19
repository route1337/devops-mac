macOS DevOps Configurator
=========================
This repository contains scripts and Ansible roles to configure macOS 10.15+ for DevOps usage.  

MDM
---
This repository is tested against machines enrolled in MDM with a configuration profile that whitelists kexts from the
following vendor IDs:

| Vendor Name  | Team ID         | KEXT IDs                               |
|--------------|-----------------|----------------------------------------|
| Oracle       | VB5E2TV963      | (ALL)                                  |
| VMware       | EG7KH642X6      | (ALL)                                  |
| Google       | EQHXZ8M8AV      | com.google.drivefs.filesystems.dfsfuse |
| Intel        | Z3L495V9L4      | (ALL)                                  |

If these are not whitelisted ahead of running `sudo ./runMe.sh`, you may have to approve kexts as prompts come up,
and then retry the script. This is due to some of the Homebrew casks that get installed.

Requirements
------------
To configure a machine you must have the following:

1. macOS Catalina (10.15.0) or later (This may work on earlier versions but it's untested)
2. The account you're using must be an Admin
3. Internet access

How To Run
----------
1. Execute `sudo ./runMe.sh` as the user you will use your Mac with.
    1. You will be prompted for your Mac user password several times in Terminal and via GUI.

TO DOs
------
Just a few things left to do:

1. ansible role for gems via rbenv
2. Custom Mouse and Trackpad settings

What will be done
-----------------
When you execute `sudo ./runMe.sh` the following tasks are performed:

1. Install XCode Command Line Tools
2. Install Homebrew
3. Install Ansible using Homebrew
4. Run the Ansible role [mac_setup](https://galaxy.ansible.com/ahrenstein/mac_setup) on the local machine
5. Search for and install any available macOS updates

Third Party Tools
-----------------
We use a few third party tools to make this work. This is the list of tools used:

1. [Ansible](http://www.ansible.com/) (LICENSE: GPLv3)
2. [Homebrew](https://brew.sh/) (LICENSE: BSD 2-Clause "Simplified" License)

Limitations
------------

1. Due to the requirement for the password to be entered a few times this is not totally unattended

Testing
-------
This project is manually tested in a clean install of macOS in VMware Fusion.  
