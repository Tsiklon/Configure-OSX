# Damien's OS X Installation Setup

## Description
 This is an attempt to automate redeploying the software i use daily in OS X should i move to a new machine.

 Making use of a fairly simple shell script this will:
 - Generate a new SSH Key
 - Install the xcode command line tools (preferably without prompting)
 - Install Ansible
 - Install Brew
 - Temporarily Enable SSH server
 - Playbook 1: Use Ansible to Install packages from brew, and brew\_cask
 - Playbook 2: Clone dotfiles repo - move dotfiles into place.
 - Disable SSH server

## Instructions
 - Install Xcode from the appstore.
 - run the Shell Script.
