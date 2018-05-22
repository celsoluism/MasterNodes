#!/bin/bash

cd ~
echo "****************************************************************************"
echo "* Omagecoincore-0.12.5.1-linux64 VPS Updater script by Natizyskunk@Github. *"
echo "*                                                                          *"
echo "*      Inspired by the omagecoincore-0.12.5.1-linux64 Updated GUIDE        *"
echo "*          by click2install#9625 from Omegacoin Official Discord.          *"
echo "****************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

echo "Do you really want to update omegacoincore wallet (no if you did it before)? [y/n]"
read DOSETUP

if [[ $DOSETUP =~ y ]] ; 
then
  TMP_FOLDER=$(mktemp -d)
  CONFIG_FILE='omegacoin.conf'
  CONFIGFOLDER="/root/.omegacoincore"
  COIN_DAEMON='omegacoind'
  COIN_CLI='omegacoin-cli'
  COIN_PATH='/usr/bin/'
  COIN_ZIP='https://github.com/omegacoinnetwork/omegacoin/releases/download/0.12.5.1/omagecoincore-0.12.5.1-linux64.zip'
  COIN_NAME='Omegacoin'
  COIN_PORT=7777

  NODEIP=$(curl -s4 icanhazip.com)

  RED='\033[0;31m'
  GREEN='\033[0;32m'
  NC='\033[0m'


  function stop_daemon {
    omegacoin-cli stop
  }

  function remove_binaries {
    sudo rm -f /usr/bin/*omega*
  }

  function download_node() {
    echo -e "Preparing to download ${GREEN}$COIN_NAME${NC} binary files."
    cd "$TMP_FOLDER" >/dev/null 2>&1
    wget -q $COIN_ZIP
    sudo apt-get install unzip
    unzip omagecoincore-0.12.5.1-linux64.zip -d .
    chmod 775 ./*omega*
    rm -f omagecoincore-0.12.5.1-linux64.zip
    chmod 775 ./$COIN_DAEMON
    chmod 775 ./$COIN_CLI
    cp $COIN_DAEMON $COIN_CLI $COIN_PATH
    cd - >/dev/null 2>&1
    rm -rf "$TMP_FOLDER" >/dev/null 2>&1
    clear
  }

  function backup_old_config() {
    cd /root/
    cp -r .omegacoincore/ .omegacoincore-backup/
  }

  function remove_old_config() {
    cd /root/
    cd .omegacoincore/
    rm -rf /tmp_omegacoin_backup
    mkdir /tmp_omegacoin_backup && mv omegacoin.conf masternode.conf wallet.dat /tmp_omegacoin_backup/
    rm .lock
    rm -rf *
    mv /path/sourcefolder/*
    mv /tmp_omegacoin_backup/* .
    rm -rf /tmp_omegacoin_backup/
  }

  function restart_daemon() {
    omegacoind -daemon
    sleep 10
  }

  function check_status() {
    omegacoin-cli getinfo
  }

  function checks() {
    if [[ $(lsb_release -d) != *16.04* ]]; then
      echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
      exit 1
    fi

    if [[ $EUID -ne 0 ]]; then
       echo -e "${RED}$0 must be run as root.${NC}"
       exit 1
    fi
  }

  function important_information() {
    echo
    echo -e "================================================================================================================================"
    echo -e "$COIN_NAME Masternode is up and running listening on port ${RED}$COIN_PORT${NC}."
    echo -e "Configuration file is: ${RED}$CONFIGFOLDER/$CONFIG_FILE${NC}"
    echo -e "Start: ${RED}COIN_DAEMON -daemon${NC}"
    echo -e "Stop: ${RED}$COIN_CLI stop${NC}"
    echo -e "VPS_IP:PORT ${RED}$NODEIP:$COIN_PORT${NC}"
    echo -e "Please check ${RED}$COIN_NAME${NC} daemon is running with the following command: ${RED}$COIN_CLI masternode status${NC}"
    echo -e "Also check ${RED}$COIN_NAME${NC} daemon info with the following command: ${RED}$COIN_CLI getinfo${NC}"
    echo -e "Can Also check ${RED}$COIN_NAME${NC} masternode sync status with the following command: ${RED}$COIN_CLI mnsync status${NC}"
    echo -e "================================================================================================================================"
  }

  function setup_node() {
    stop_daemon 
    remove_binaries
    download_node
    backup_old_config
    remove_old_config
    restart_daemon
    check_status
    important_information
  }


  ##### Main #####
  clear

  checks
  setup_node
else
  echo "Update has been aborted !"
fi
