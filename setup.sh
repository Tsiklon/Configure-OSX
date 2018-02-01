#!/bin/bash
##
## Script to install and configure OS X to my liking.
##
## - 2018 - Damien Nugent 
##

## Functions - liberally borrowed from brew.sh
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

## Variables
ssh_key_loc="/Users/$(LOGNAME)/.ssh/id_rsa"
ssh_key_pub_loc="/Users/$(LOGNAME)/.ssh/id_rsa.pub"
command_line_tools=$(softwareupdate -l |
  grep "\*.*Command Line" |
  head -n 1 | awk -F"*" '{print $2}' |
  sed -e 's/^ *//' |
  tr -d '\n')


if [[ -x "/usr/bin/ssh-keygen" ]]
  if [[ ls -l "$ssh_key_loc" >/dev/null 2>&1 -eq 1 ]]
  then
    echo "Generating New SSH Key - You will be prompted for a password"
    /usr/bin/ssh-keygen -t rsa -N
  else
  if [[ ls -l "$ssh_key_pub_loc" >/dev/null 2>/dev/null -eq 1 ]]
  then
    echo "SSH Key found: $(ls $ssh_key_loc)"
  fi
fi 
EOS
else
 odie <<EOS
SSH keygen not installed - wut?
EOS
fi

if [[ -x "/usr/bin/xcode-select" ]]
##then 
##   echo "Installing xcode command line tools - expect a GUI prompt"
##  /usr/bin/xcode-select --install
then 
  echo "Installing Xcode Command Line Tools - via software update"
  touch "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
  /usr/sbin/softwareupdate -i "$command_line_tools" -v
else 
  odie <<EOS
Install xcode + confirm xcode-select is present in /usr/bin/
EOS
fi

if [[ -x "/usr/bin/easy_install" ]]
then 
  echo "Installing Ansible"
  /usr/bin/easy_install ansible;
else
  odie <<EOS
easy_install not present - D:
EOS
fi

if [[ ping -c 1 raw.githubusercontent.com -eq 0 ]]
then 
  if [[ ping -c 1 github.com -eq 0 ]]
  then
  echo "Installing Homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  else
  odie <<EOS
Unable to ping github.com - required to install brew.
EOS
else
  odie <<EOS 
Unable to successfully ping 'raw.githubusercontent.com' to pull down the brew install script
EOS

echo "Starting SSH to run Ansible"
sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
echo "installing useful packages from brew"
/usr/local/bin/ansible-playbook -i hosts packages.yml
echo "Pulling Dotfiles from git"
/usr/local/bin/ansible-playbook -i hosts dotfiles.yml
sudo launchctl unload -w /System/Library/LaunchDaemons/ssh.plist

echo "Adjusting NSGlobalDomain Settings"
/usr/bin/defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1 ### Sidebar Icon size

echo "Adjusting Finder settings"
/usr/bin/defaults write com.apple.finder AppleShowAllFiles = YES
/usr/bin/defaults write com.apple.finder ShowStatusBar -bool true
/usr/bin/defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
/usr/bin/defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
/usr/bin/defaults write com.apple.finder CreateDesktop -bool false
/usr/bin/defaults write com.apple.finder DisableAllAnimations -bool true

echo "Restarting Finder"
killall "Finder" >/dev/null 2>&1
