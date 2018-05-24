#!/bin/bash
#Info: Install or Update MasterNode Daemons, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#TODO: to run you need to use ./Install.sh from MasterNodes folder.


# DONT TOUCH
COIN_NAME=OmegaCoin
COIN_DAEMON=omegacoind
CONFIG_FOLDER=~/.omegacoincore
COIN_PATH=/usr/local/bin/
TMP_FOLDER=~/temp_masternodes
NODEIP=$(curl -s4 icanhazip.com)
$HOMEFOLDER=$(echo $HOME)

#SET COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

#-------------------------------------------- LETS START ----------------------------------------
function checks() {
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
  echo -e "${RED}If like to reinstall please use '$COIN_CLI stop' and restart ./rebase.sh.${NC}"
  echo -e "${RED}Remembr: It will remove all your configuration of the $COIN_NAME and create a new.${NC}"
  exit 1
fi
if [ ! -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ] ; then
  echo -e "${RED}$COIN_NAME is not detected. Need to be installed and run.${NC}"
  echo -e "${RED}First install $COIN_NAME before install Sentinel.${NC}"
  exit 1
fi
if [ -d "$HOMEFOLDER/sentinel" ] || [ -d "$HOMEFOLDER/sentinel" ] && [ -d "$HOMEFOLDER/$CONFIG_FOLDER" ] ; then
  echo -e "${RED}SENTINEL is detected. Need to be stoped and remove folder '$HOMEFOLDER'/sentinel.${NC}"
  exit 1
fi
}

noflags() {
    echo "??????????????????????????????????????"
    echo "Usage: ./install.sh"
    echo "Example: ./install.sh"
    echo "??????????????????????????????????????"
    exit 1
}

message() {
	echo "+-------------------------------------------------------------------------------->>"
	echo "| $1"
	echo "+--------------------------------------------<<<"
}

error() {
	message "An error occured, you must fix it to continue!"
	exit 1
}

# ---------------------------------------- INSTALL ------------------------------------
function prepare_dependencies() { #TODO: add error detection
   PS3='Need to Install Depedencies and Libraries'
   echo -e "Prepare the system to install ${GREEN}$COIN_NAME master node.${NC}"
   echo -e "If prompted enter password of current user!"
   sudo apt-get -y update >/dev/null 2>&1  
   sudo apt-get -y install python-virtualenv
   if [ "$?" -gt "0" ];
      then
      echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
      echo "sudo apt-get -y update"
      echo " sudo apt-get -y install python-virtualenv"
      exit 1
   fi
   clear
}
   
function check_version() {   
   echo -e "Check if OmegaCoin is at least version 12.1 (120100)"
   omegacoin-cli getinfo | grep version
}

function install_sentinel() {
    cd $HOMEFOLDER
    git clone https://github.com/omegacoinnetwork/sentinel.git && cd sentinel
    virtualenv ./venv
    ./venv/bin/pip install -r requirements.txt
}

function configure_sentinel() {
    echo -e "Configuring sentinel and cronjob"

function cronjob_creator () {
          # usage: cronjob_creator '<interval>' '<command>'

            if [[ -z $1 ]] ;then
                printf " no interval specified\n"
            elif [[ -z $2 ]] ;then
                printf " no command specified\n"
            else
                CRONIN="/tmp/cti_tmp"
                crontab -l | grep -vw "$1 $2" > "$CRONIN"
                echo "$1 $2" >> $CRONIN
                crontab "$CRONIN"
            rm $CRONIN
            fi
}
cronjob_creator '* * * * * ' 'cd '$HOMEFOLDER'/sentinel_omegacoin && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1'
}

function testing_sentinel() {
      echo -e "Testing Sentinel"
      ./venv/bin/py.test ./test
}

function remove() {
      echo -e "${RED}Preparing to uninstall Sentinel${NC}"
      sudo rm -rvf $HOMEFOLDER/sentinel
      install
}
      
install() {
    checks
    check_version
    prepare_dependencies
    check_version
    install_sentinel
    configure_sentinel
    testing_sentinel
}

#main
#default to --without-gui
clear
install --without-gui
