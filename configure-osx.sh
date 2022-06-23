#!/usr/bin/env bash
##
## Script to install and configure OS X to my liking.
##
## v0.1 - 2018 - Damien Nugent 
##

## Variables
ssh_key_loc="/Users/$(LOGNAME)/.ssh/id_rsa"

## Boilerplate Useful Functions
onoe() {
  if [[ -t 2 ]] # check whether stderr is a tty.
  then
    echo -ne "\033[4;31mError\033[0m: " >&2 # highlight Error with underline and red color
  else
    echo -n "Error: " >&2
  fi
  if [[ $# -eq 0 ]]
  then
    /bin/cat >&2
  else
    echo "$*" >&2
  fi
}

odie() {
  onoe "$@"
  exit 1
}

program_exist() {
  if [[ ! -x $(command -v "${1}" ) ]]; then
    odie "program '${1}' - not exist - grug unhappy"
  fi
}

remote_host_access() {
  nc_exist=$(command -v nc)
  if [[ -n $nc_exist ]]; then 
    if [[ ! $(nc -vz "${1}" 443 -w 1 > /dev/null ) -eq 0 ]]; then 
      odie "unable to connect to ${1} on port 443 - exiting" 
    fi
  else 
    if [[ ! $(ping -c 1 "${1}" > /dev/null ) -eq 0 ]]; then
      odie "unable to ping ${1} - exiting"
    fi
  fi
  unset nc_exist
}

## Actual Useful Functions
ssh(){
  program_exist "ssh-keygen"
  if [[ ! -f "$ssh_key_loc" ]]; then
    echo "Generating New SSH Key - You will be prompted for a password"
    ssh-keygen -t rsa 
    ssh-add
  else
    echo "SSH Key found: $(ls "$ssh_key_loc")"
  fi 
}

xcode() {
  program_exist "xcode-select"
  echo "Installing xcode command line tools - expect a GUI prompt"
  xcode-select --install

#  echo "Installing Xcode Command Line Tools - via software update"
#  touch "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
#  /usr/sbin/softwareupdate -i "$(softwareupdate -l |
#  grep "\*.*Command Line" |
#  head -n 1 | awk -F"*" '{print $2}' |
#  sed -e 's/^ *//' |
#  tr -d '\n')" --verbose
}

inst_ansible() {
  program_exist "pip3"
  echo "Installing Ansible - Please Ensure that the Xcode Command Line tools have been installed first"
  pip3 install --upgrade pip
  pip3 install ansible
  if [[ $? -eq 1 ]]; then
    odie "Failed to install Ansible"
  fi
}

inst_brew() {
  remote_host_access "raw.githubusercontent.com"
  remote_host_access "github.com"
  echo "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

inst_packages() {
  program_exist "ansible-playbook"
  echo "Installing useful packages and casks from brew"
  ansible-playbook -i hosts packages.yml
}


inst_software(){
  inst_ansible
  inst_brew
  inst_packages
}

dotfiles() {
  echo "Pulling Dotfiles from git"
  ansible-playbook -i hosts dotfiles.yml
}

set_defaults(){
  echo "Adjusting NSGlobalDomain Settings"
  /usr/bin/defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1 ### Sidebar Icon size
  
  echo "Adjusting Finder settings"
  /usr/bin/defaults write com.apple.finder AppleShowAllFiles -bool true
  /usr/bin/defaults write com.apple.finder ShowStatusBar -bool true
  /usr/bin/defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  /usr/bin/defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
  /usr/bin/defaults write com.apple.finder CreateDesktop -bool false
  /usr/bin/defaults write com.apple.finder DisableAllAnimations -bool true
  
  echo "Disabling Mouse Acceleration"
  /usr/bin/defaults write .GlobalPreferences com.apple.mouse.scaling -1
  
  echo "Restarting Finder"
  killall "Finder" > /dev/null 2>&1
}

case "$1" in 
  'all')
    ssh
    xcode
    inst_software
    dotfiles
    set_defaults
    ;;
  
  'ssh')
    ssh
    ;;

  'xcode')
    xcode
    ;;
  
  'defaults')
    set_defaults
    ;;

  'software')
    inst_software
    ;;

  'dotfiles')
    dotfiles
    ;;
  
  *)
    echo "Usage: $0 all|ssh|xcode|defaults|software|dotfiles

ssh - Generate new SSH Key 
xcode - install xcode 
defaults - set custom defaults
software - install software packages using ansible and homebrew
dotfiles - pull basic dotfiles and public keys from github"
    exit 1
    ;;
esac
