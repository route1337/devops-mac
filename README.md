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
4. Run the Ansible playbook [mac-devops.yml](ansible/mac-devops.yml) on the local machine
5. Search for and install any available macOS updates

What will Ansible do?
---------------------
This playbook includes the following roles:

1. homebrew
    1. Configure these taps
        1. parera10/csshx
        2. ahrenstein/homebrew-taps
    2. Install this list of Homebrew packages
        1. ansible-lint
        2. awscli
        3. parera10/csshx/csshx
        4. docker
        5. docker-machine
        6. docker-machine-driver-vmware
        7. git
        8. git-crypt
        9. git-flow
        10. git-lfs
        11. gnu-sed
        12. kubernetes-cli
        13. minikube
        14. packer
        15. qemu
        16. rbenv
        17. ruby-build
        18. saml2aws-duo
        19. sshfs
        20. telnet
        21. terraform
        22. vfuse
        23. watch
        24. wget
    3. Install this list of Homebrew casks
        1. aerial
        2. cryptomator
        3. docker
        4. google-drive-file-stream
        5. gpg-suite
        6. intellij-idea
        7. osxfuse
        8. profilecreator
        9. vagrant
        10. vagrant-vmware-utility
        11. virtualbox
        12. viscosity
        13. vmware-fusion
2. profile-common
    1. Create the following common directories
        1. `~/Code` with 700 permissions
        2. `~/Protected` with 700 permissions
        3. Clone [VagrantBoxes](https://github.com/route1337/VagrantBoxes) to `~/Vagrant`
        4. `~/Scratch` with 700 permissions
3. dot-files (#TODO)
    1. Deploys custom `~/.zshrc`
    2. Deploys `~/.csshrc` (Configured to run csshX from a second Thunderbolt display)
    3. Deploys `~/.gitconfig` (PGP signing and LFS with variables prompted at run time)
    4. Deploys `~/.vimrc`
    5. Deploys `~/.ansible.cfg`
    6. Deploys `~/.gnupg/gpg-agent.conf` and `~/.gpg-agent-info` (Used for [SSH via YubiKey](https://www.route1337.com/tutorials/using-a-yubikey-4-and-gpg-for-ssh-on-a-mac/))
4. thefuck
    1. Install thefuck from Homebrew
    2. Deploy [custom thefuck rules](https://github.com/ahrenstein/thefuck-rules)
6. mac-tweaks
    1. Ensure current user's screen shots are saved to /Scratch
    2. Re-enable holding a key down to repeat the character
    3. Set keyboard tab stops to "All controls"
    4. Change Notification Center's default notification timeout to 7 seconds
    5. Disable automatic capitalization, smart dashes, and smart quotes
    6. Disable autocorrect (Apps like Pages might still have their own)
    7. Set measurement units to Metric
    8. Set the temperature unit to Celsius
    9. Disable .DS_Store files on network volumes
    10. Deploy my custom Terminal and set it as the default

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
