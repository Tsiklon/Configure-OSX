# Damien's OS X Installation Setup

## Description
 This is an attempt to automate redeploying the software i use daily in OS X should i move to a new machine.

 Making use of a fairly simple shell script this will:
 - Generate a new SSH Key
 - Install the xcode command line tools (preferably without prompting)
 - Install `ansible`
 - Install `brew`
 - Playbook 1: Use `ansible` to Install packages from `brew`, and `brew cask`
 - Playbook 2: Clone dotfiles repo - move dotfiles into place.
 - Set up a number of quality of life `Defaults` settings

## Instructions
 - Install Xcode from the appstore.
 - run the Shell Script.

 if this is a brand new system - pass the 'all' flag to it.
 - `configure-osx.sh all`

## Options
 - ssh - Generate new SSH Key
 - xcode - install xcode
 - defaults - set custom defaults
 - software - install software packages using ansible and homebrew
 - dotfiles - pull basic dotfiles and public keys (TBC) from github

## Playbooks
Should you wish to run any of the individual tasks in the playbooks - the tasks are tagged to accommodate this.
### packages.yml
 - xquartz - install xquartz - (hard dependency for the rest of the brew packages)
 - brew-pack - install all named homebrew packages
 - brew-cask - install all named homebrew casks
   
### dotfiles.yml
 - git-config - set global git config
 - dot-files - clone dotfiles repos, creating directories where appropriate
