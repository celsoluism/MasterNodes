#!/bin/bash
#Info: Install or Update MasterNode Daemons, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#TODO: to run you need to use ./Install.sh from MasterNodes folder.

#--------------------------------------------- COIN INFORMATION --------------------------------------------
# CONFIG ABOUT COIN
COIN_NAME=fxrate
COLATERAL=1000FXR
CONFIG_FILE=fxrate.conf
 
# ALWAYS START WITH ~/. AND DEFAULT COIN FOLDER
CONFIG_FOLDER=~/.fxratecore
COIN_DAEMON=fxrated
COIN_CLI=fxrate-cli
COIN_TX=fxrate-tx
COIN_QT=fxrate-qt
MAX_CONNECTIONS=30
LOGINTIMESTAMPS=1
COIN_PORT=34222
RPC_PORT=34766
LISTEN_ONION=0
STAKING=0

# CHECK BOLEANS
USE_BIND=y
USE_ADDR=y
USE_SENTINEL=n

# SENTINEL CONFIGURATIONS
SENTINEL_REPO='https://github.com/omegacoinnetwork/sentinel.git'

# FILE WITH NODES IN MASTERNODE INSTALL FOLDER
FILE_NODES=~/MasterNodes/fxrate/fxrate_nodes.txt

# LINK TO DOWNLOAD DAEMON
COIN_TGZ_ZIP='https://github.com/fxrate/fxratecoin/releases/download/1.0.0.1/FXRateCoin_v1.0.0.1_linux.zip'
# SET FOLDER IF UNZIP DAEMON IS ON SUBFOLDER?
COIN_SUBFOLDER=linux

# DOWNLOAD BLOCKCHAIN?
DOWNLOAD_BLOCKCHAIN=n
# LINK TO DOWNLOAD BLOCKCHAIN
LINK_BLOCKCHAIN='https://github.com/modcrypto/brofist/releases/download/1.0.2.12/brofist_blocks_88595.zip'
# SET FOLDER IF UNZIP BLOCKCHAIN IS ON SUBFOLDER?
BLOCKCHAIN_SUBFOLDER=data
 
# TO CONFIG
COIN_PATH=/usr/local/bin/
TMP_FOLDER=~/temp_masternodes
HOME_FOLDER=$(echo $HOME)
ALIAS=$(echo $HOSTNAME)
HOME_USER=$(echo $USER)

# DONT TOUCH
COIN_ZIP=$(echo $COIN_TGZ_ZIP | awk -F'/' '{print $NF}')
NODEIP=$(curl -s4 icanhazip.com)

#SET COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

#-------------------------------------------- LETS START ----------------------------------------

noflags() {
    echo "??????????????????????????????????????"
    echo "Usage: ./install.sh"
    echo "Example: ./install.sh"
    echo "??????????????????????????????????????"
    exit 1
}

message() {
	echo -e "+-------------------------------------------------------------------------------->>"
	echo -e "| $1"
	echo -e "+--------------------------------------------<<<"
}

error() {
	message "An error occured, you must fix it to continue!"
	exit 1
}

function install_dependences() {
    echo -e "${GREEN}Start install dependences!${NC}"
    echo -e "If prompted enter password of current user!"
	  echo -e "Installing required packages, it may take some time to finish.${NC}"
   	  sudo apt install zip >/dev/null 2>&1
		if [ "$?" -gt "0" ];
		  then
			echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
			  echo " sudo apt install zip"
		 exit 1
		fi
   clear
}

	function install_swap_file {
		echo -e "Checking if swap space is needed."
		PHYMEM=$(free -g|awk '/^Mem:/{print $2}')
		SWAP=$(free -g|awk '/^Swap:/{print $2}')
		if [ "$PHYMEM" -lt "2" ] && [ -n "$SWAP" ]
		  then
			echo -e "${GREEN}Server is running with less than 2G of RAM without SWAP, creating 2G swap file.${NC}"
			cd /
			sudo swapoff -a
			sudo touch /mnt/swap.img
			sudo chmod 755 /mnt/swap.img
			sudo dd if=/dev/zero of=/mnt/swap.img bs=1024 count=2097152
			sudo mkswap /mnt/swap.img
    		        sudo swapon /mnt/swap.img
			sudo echo "/mnt/swap.img none swap sw 0 0" | sudo tee -a /etc/fstab
			sudo sysctl vm.swappiness=60
			sudo free
			sleep 6s
		else
		  echo -e "${GREEN}Server running with at least 2G of RAM, no swap needed.${NC}"
		fi
		clear
    }
	
function backup_configs() {
   echo "Stop Service (work if you have installed with ./rebase.sh)"
   sudo systemctl stop brofist.service >/dev/null 2>&1
   sleep 10s
   sudo systemctl stop $COIN_NAME.service 
   $COIN_CLI stop  >/dev/null 2>&1
   echo "Wait $COIN_NAME daemon stop"
   sleep 15s
   if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ] ; then
      pkill brofistd >/dev/null 2>&1
      killall brofistd >/dev/null 2>&1
   fi
   sleep 5s
   if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ] ; then
       echo -e "${RED}$COIN_NAME is already run with other command, you need to stop daemon before start update.${NC}"
    exit 1
   fi
   sleep 3s
   clear
   echo -e "Making backup of ${GREEN}$COIN_NAME ${NC} Wallet and Files..."  
   mkdir $TMP_FOLDER >/dev/null 2>&1
   mkdir $TMP_FOLDER/backup_files >/dev/null 2>&1
   cp -f $CONFIG_FOLDER/*.conf $TMP_FOLDER/backup_files  >/dev/null 2>&1
   cp -f $CONFIG_FOLDER/wallet.dat $TMP_FOLDER/backup_files  >/dev/null 2>&1
   cp -rf $CONFIG_FOLDER/backups $TMP_FOLDER/backup_files  >/dev/null 2>&1
   cd $CONFIG_FOLDER
   FILE_BACKUP=$(echo $(date +"%Y-%m-%d")_$(date +"%H-%M-%S"))
   zip -r backup_"$COIN_NAME"_"$FILE_BACKUP".zip *.conf wallet.dat >/dev/null 2>&1
   cp backup_"$COIN_NAME"_*.zip $HOME_FOLDER
   cp backup_"$COIN_NAME"_*.zip $TMP_FOLDER/backup_files
   rm backup_"$COIN_NAME"_*.zip
   cd ~
   clear
}

function update_node() { #TODO: add error detection
	echo -e "Preparing to update ${GREEN}$COIN_NAME ${NC} Daemon..."
	mkdir $CONFIG_FOLDER
    mkdir $TMP_FOLDER >/dev/null 2>&1
    cd $TMP_FOLDER
	mkdir updatenode >/dev/null 2>&1
	cd $TMP_FOLDER/updatenode
	wget $COIN_TGZ_ZIP
    clear
    echo -e "uncompressing file"
	if [[ $COIN_TGZ_ZIP == *.gz ]]; then
	   cd $TMP_FOLDER/updatenode
     tar -xf  *.gz >/dev/null 2>&1
    fi
    if [[ $COIN_TGZ_ZIP == *.zip ]]; then
       cd $TMP_FOLDER/updatenode
	   unzip  *.zip >/dev/null 2>&1
    fi
    cd $TMP_FOLDER/updatenode
	rm *.gz >/dev/null 2>&1
	rm *.zip >/dev/null 2>&1
		RM_COINS=$(echo $COIN_PATH/$COIN_DAEMON $COIN_CLI $COIN_TX $COIN_QT)
    sudo rm -f $RM_COINS
    if [ -d "$TMP_FOLDER/updatenode/$COIN_SUBFOLDER" ]; then cd $TMP_FOLDER/updatenode/$COIN_SUBFOLDER && strip $COIN_DAEMON $COIN_CLI $COIN_TX $COIN_QT ; fi
	    if [ $? -ne 0 ]; then strip $COIN_DAEMON $COIN_CLI $COIN_TX $COIN_QT ; fi
	compile_error
	if [ -d "$TMP_FOLDER/updatenode/$COIN_SUBFOLDER" ]; then cd $TMP_FOLDER/updatenode/$COIN_SUBFOLDER && chmod +x * && sudo cp -f * /usr/local/bin ; fi
	if [ $? -ne 0 ]; then cd $TMP_FOLDER/updatenode && chmod +x * && sudo cp -f * /usr/local/bin ; fi
	clear
}

function update_blockchain() {
   echo -e "Wait some time, update blockchain!"
  if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ] ; then
       echo -e "${RED}$COIN_NAME is already run with other command, you need to stop daemon before start update.${NC}"
    exit 1
  fi
  cd $CONFIG_FOLDER 
  #if [[ $UPDATE_BLOCKCHAIN == yes ]] || [[ $UPDATE_BLOCKCHAIN == YES ]] || [[ $UPDATE_BLOCKCHAIN == y ]] || [[ $UPDATE_BLOCKCHAIN == Y ]] ; then 
  cd $CONFIG_FOLDER && sudo rm -rf blocks chainstate .lock db.log debug.log fee_estimates.dat governance.dat mncache.dat mnpayments.dat netfulfilled.dat peers.dat database >/dev/null 2>&1
  #fi
  mkdir $TMP_FOLDER >/dev/null 2>&1
  mkdir $TMP_FOLDER/tmp_blockchain >/dev/null 2>&1
  cd $TMP_FOLDER/tmp_blockchain
  if [[ $UPDATE_BLOCKCHAIN == yes ]] || [[ $UPDATE_BLOCKCHAIN == YES ]] || [[ $UPDATE_BLOCKCHAIN == y ]] || [[ $UPDATE_BLOCKCHAIN == Y ]] ; then 
  wget -q $LINK_BLOCKCHAIN
  fi
  if [[ $LINK_BLOCKCHAIN == *.gz ]]; then
   cd $TMP_FOLDER/tmp_blockchain
   tar -xf  *.gz >/dev/null 2>&1
  fi
  if [[ $LINK_BLOCKCHAIN == *.zip ]]; then
   cd $TMP_FOLDER/tmp_blockchain
   unzip  *.zip >/dev/null 2>&1
  fi
  mkdir $CONFIG_FOLDER >/dev/null 2>&1
  if [ -d "$TMP_FOLDER/tmp_blockchain/$BLOCKCHAIN_SUBFOLDER" ]; then cp -rvf $TMP_FOLDER/tmp_blockchain/$BLOCKCHAIN_SUBFOLDER/* $CONFIG_FOLDER >/dev/null 2>&1 ; fi
	if [ $? -ne 0 ]; then cp -rvf $TMP_FOLDER/tmp_blockchain/* $CONFIG_FOLDER >/dev/null 2>&1 ; fi
  rm -rf $TMP_FOLDER/tmp_blockchain/*
  cd ~ - >/dev/null 2>&1
  clear
}

function rollback_configs() {
  echo -e "${GREEN}Back with your wallet and cofigurations${NC}"
  cp -f $TMP_FOLDER/backup_files/*.conf $CONFIG_FOLDER
  cp -f $TMP_FOLDER/backup_files/wallet.dat $CONFIG_FOLDER
  
  if [ ! -f $CONFIG_FOLDER/$CONFIG_FILE ] || [ ! -f $CONFIG_FOLDER/masternode.conf ] || [ ! -f $CONFIG_FOLDER/wallet.dat ]; then 
  unzip -o $TMP_FOLDER/backup_files/backup_'$COIN_NAME'*.zip $CONFIG_FOLDER
  fi
  if [ ! -f $CONFIG_FOLDER/$CONFIG_FILE ] || [ ! -f $CONFIG_FOLDER/masternode.conf ] || [ ! -f $CONFIG_FOLDER/wallet.dat ]; then 
  configfile_error
  exit 1
  fi
  sed -i '/addnode/d' $CONFIG_FOLDER/$CONFIG_FILE
  sed -i '/--- blockchain/d' $CONFIG_FOLDER/$CONFIG_FILE
  cat $FILE_NODES >> $CONFIG_FOLDER/$CONFIG_FILE
  clear
 }
	
function install_service() {
  clear   
  echo -e "${GREEN}Install Service ${NC}"
   	if [ ! -d "$TMP_FOLDER" ]; then mkdir $TMP_FOLDER; fi
	if [ $? -ne 0 ]; then error; fi
  cat << EOF > $TMP_FOLDER/$COIN_NAME.service
[Unit]
Description=$COIN_NAME service
After=network.target

[Service]
User=root
Group=root

Type=forking
#PIDFile=$CONFIG_FOLDER/$COIN_NAME.pid

ExecStart=$COIN_PATH$COIN_DAEMON -daemon -conf=$CONFIG_FOLDER/$CONFIG_FILE -datadir=$CONFIG_FOLDER
ExecStop=-$COIN_PATH$COIN_CLI -conf=$CONFIG_FOLDER/$CONFIG_FILE -datadir=$CONFIG_FOLDER stop

Restart=always
PrivateTmp=true
TimeoutStopSec=60s
TimeoutStartSec=10s
StartLimitInterval=120s
StartLimitBurst=5

[Install]
WantedBy=multi-user.target
EOF

  sudo cp $TMP_FOLDER/$COIN_NAME.service /etc/systemd/system/

  sudo systemctl daemon-reload
  sleep 3
  sudo systemctl start $COIN_NAME.service
  sudo systemctl enable $COIN_NAME.service >/dev/null 2>&1

  if [[ -z "$(ps axo cmd:100 | egrep $COIN_DAEMON)" ]]; then
    echo -e "${RED}$COIN_NAME is not running${NC}, please investigate. You should start by running $"
    echo -e "${GREEN}systemctl start $COIN_NAME.service"
    echo -e "systemctl status $COIN_NAME.service"
    echo -e "less /var/log/syslog${NC}"
    exit 1
  fi
  sleep 10s
  clear
}

# -------------------------------- GLOBAL CHECKS --------------------------------
function compile_error() {
if [ "$?" -gt "0" ];
 then
  echo -e "${RED}Failed to compile $COIN_NAME. Please investigate.${NC}"
  exit 1
fi
}

function check_linux_ver() {
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
  echo -e "${RED}If like to reinstall please use '$COIN_CLI stop' and restart ./rebase.sh.${NC}"
  echo -e "${RED}Remembr: It will remove all your configuration of the $COIN_NAME and create a new.${NC}"
  exit 1
fi
}

function check_daemon() {
if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ] ; then
  echo -e "${RED}$COIN_NAME is already run with other command, you need to stop daemon before start update.${NC}"
  exit 1
fi
}

function configfile_error() {
    clear
    echo -e " "
	echo -e "${RED}Error in create $CONFIG_FILE roll back! ${NC}"
	echo -e " "
	echo -e "Try use this command:"
	echo -e " "
	echo -e " unzip -o $TMP_FOLDER/backup_files/backup_'$COIN_NAME'*.zip $HOME_FOLDER/$CONFIG_FOLDER "
	echo -e " "
    echo -e "and restart $COIN_NAME daemon"
	sleep 10s
	install_service
	exit 0
}

# ----------------------------- CONGRATULATIONS ---------------------------------
function last_commits() {
        echo -e " "
        echo -e "Commit lasts configs of $COIN_NAME Daemon!"
	$COIN_DAEMON -daemon >/dev/null 2>&1
	sleep 15s
	
	GET_INFO=$($COIN_CLI getinfo)
	GET_MNSYNC=$($COIN_CLI mnsync status)
	GET_LISTCONF=$($COIN_CLI masternode list-conf)
        TXOUTPUTS=$($COIN_CLI masternode outputs )
        echo -e " "
        message "Preparing $COIN_NAME Daemon to work."
	    
        sleep 10s
        echo -e "${GREEN} $GET_INFO ${NC}"
        message "Wait 120 seconds to $COIN_NAME start sync"
        sleep 120s
        clear
        message "Checking $COIN_NAME sync progress"
        echo -e "${GREEN} $GET_INFO ${NC}"
	echo -e " "
	echo -e "If no show information any problem during update!" 
	echo -e " "
	sleep 3s
    echo -e "If update work without any error at now you see you txid and index bellow:"
	echo -e "${RED}Obs: $COIN_NAME need to be sync completed!${NC}"
    echo -e " "
	echo -e "Check outputs: "
	echo -e "Outputs: ${GREEN} $TXOUTPUTS ${NC}" 
	echo -e " "
	sleep 10s
    echo -e "Checking masternode sync"
	echo -e "${GREEN} $GET_MNSYNC ${NC}"
	echo -e " " 
	echo -e "If show 999 your maternode is full sync" 
	echo -e " "
	echo -e "Checking if your masternode is listed"
	echo -e "${GREEN} $GET_LISTCONF ${NC}"
	echo -e " "
	echo -e "If show none information you need 15 minutes or more at listed"
    sleep 10s
	clear
}

function success() {

# TO MASTERNODE CONFIG FILE

 # TO SHOW
 echo -e "SUCCESS! Your ${GREEN}$COIN_NAME ${NC}has started. All your configs are"
 echo -e " "
 message "${GREEN}CONGRATULATIONS, YOUR MASTERNODE IS INSTALLED AND CONFIGURED! ${NC}"
 echo -e "================================================================================================================================" 
 echo -e "$COIN_NAME Masternode is up and running listening on port ${RED}$COIN_PORT${NC}." 
 echo -e "Configuration file is: ${RED}$CONFIG_FOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
 #echo -e "NODE_IP:PORT ${RED}$NODEIP:$COIN_PORT ${NC}"
 #echo -e "MASTERNODE PRIVATEKEY is: ${RED} $MN_PRIVKEY ${NC}"
 echo -e "MASTERNODE file: $CONFIG_FOLDER/masternode.conf"
 #echo -e "MASTERNODE configuration, copy this line bellow and paste in your windows wallet masternode file:"
 #echo -e "$ALIAS $NODEIP:$COIN_PORT $MN_PRIVKEY $TX_OUTPUTS"
 echo -e "Please check ${RED}$COIN_NAME${NC} is running with the following command: ${GREEN}systemctl status $COIN_NAME.service${NC}" 
 echo -e "================================================================================================================================" 
 echo -e " "
 echo -e "================================================================================================================================" 
 echo -e "A copy of MASTERNODE file ${GREEN}$CONFIG_FOLDER/masternode.conf${NC} and"
 echo -e "a copy of CONFIG file ${GREEN}$CONFIG_FOLDER/$CONFIG_FILE ${NC}"
 echo -e "are saved in ${GREEN}$HOME_FOLDER/$COIN_NAME_backup_DATE_TIME.txt${NC}"
 echo -e "================================================================================================================================" 

 # CLEAR TEMP FOLDER
 sudo rm -rf cache
 sudo rm -rf $TMP_FOLDER/* >/dev/null 2>&1
 last_check
 exit 0
}

function last_check() {
    if [ ! -f $CONFIG_FOLDER/$CONFIG_FILE ] || [ ! -f $CONFIG_FOLDER/masternode.conf ] || [ ! -f $CONFIG_FOLDER/wallet.dat ]; then 
    clear
    echo -e " "
	echo -e "${RED}Error in create $CONFIG_FILE roll back! ${NC}"
	echo -e " "
	echo -e "Try use this command:"
	echo -e " "
	echo -e " unzip -o $TMP_FOLDER/backup_files/backup_'$COIN_NAME'*.zip $HOME_FOLDER/$CONFIG_FOLDER "
	echo -e " "
    echo -e "and restart $COIN_NAME daemon"
	sleep 3s
	fi
	exit 0
	exit 1
	}
	
install() {
    install_dependences 
	#install_swap_file
    backup_configs
    update_node
	update_blockchain
	rollback_configs
	#install_service
	last_commits
	success
	last_check
	exit 0
}

#main
#default to --without-gui
cd $HOME_FOLDER
sudo rm -rf $TMP_FOLDER/*
clear
install --without-gui

