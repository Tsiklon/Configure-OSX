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
