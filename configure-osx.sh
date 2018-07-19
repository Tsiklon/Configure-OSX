#!/usr/bin/env bash
##
## Script to install and configure OS X to my liking.
##
## v0.1 - 2018 - Damien Nugent 
##

## Variables
ssh_key_loc="/Users/$(LOGNAME)/.ssh/id_rsa"

## Functions - onoe/odie is liberally borrowed from brew.sh
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

ssh(){
if [[ -x "/usr/bin/ssh-keygen" ]]; then
  if [[ ! -f "$ssh_key_loc" ]]; then
    echo "Generating New SSH Key - You will be prompted for a password"
    /usr/bin/ssh-keygen -t rsa 
    ssh-add
  else
    echo "SSH Key found: $(ls "$ssh_key_loc")"
  fi 
else
 odie <<EOS
SSH keygen not installed - wut?
EOS
fi
}

xcode() {
if [[ -x "/usr/bin/xcode-select" ]]; then
  echo "Installing xcode command line tools - expect a GUI prompt"
  /usr/bin/xcode-select --install

#  echo "Installing Xcode Command Line Tools - via software update"
#  touch "/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress"
#  /usr/sbin/softwareupdate -i "$(softwareupdate -l |
#  grep "\*.*Command Line" |
#  head -n 1 | awk -F"*" '{print $2}' |
#  sed -e 's/^ *//' |
#  tr -d '\n')" --verbose
else 
  odie <<EOS
Install xcode + confirm xcode-select is present in /usr/bin/
EOS
fi
}

software(){
if [[ -x "/usr/bin/easy_install" ]]; then
  echo "Installing Ansible - Please Ensure that the Xcode Command Line tools have been installed first"
  sudo /usr/bin/easy_install pip
  sudo pip install ansible
   if [[ $? -eq 1 ]]; then
    odie <<EOS
Failed to install Ansible
EOS
    fi
else
  odie <<EOS
easy_install not present - D:
EOS
fi

if [[ $(ping -c 1 raw.githubusercontent.com > /dev/null 2&>1) -eq 0 ]]; then
  if [[ $(ping -c 1 github.com > /dev/null 2&>1) -eq 0 ]]; then
    echo "Installing Homebrew"
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  else
    odie <<EOS
Unable to ping github.com - required to install brew.
EOS
  fi
else
  odie <<EOS 
Unable to successfully ping 'raw.githubusercontent.com' to pull down the brew install script
EOS
fi

echo "Installing useful packages and casks from brew"
/usr/local/bin/ansible-playbook -i hosts packages.yml
}

dotfiles() {
echo "Pulling Dotfiles from git"
/usr/local/bin/ansible-playbook -i hosts dotfiles.yml
}

defaults(){
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
    software
    dotfiles
    defaults
    ;;
  
  'ssh')
    ssh
    ;;

  'xcode')
    xcode
    ;;
  
  'defaults')
    defaults
    ;;

  'software')
    software
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
