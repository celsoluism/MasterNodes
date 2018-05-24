#!/bin/bash
#Info: Install or Update MasterNode Daemons, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#TODO: to run you need to use ./Install.sh from MasterNodes folder.

#--------------------------------------------- COIN INFORMATION --------------------------------------------
# CONFIG ABOUT COIN
COIN_NAME=Stannum
COLATERAL=1000
CONFIG_FILE=stannum.conf

# ALWAYS START WITH ~/ AND DEFAULT COIN FOLDER
CONFIG_FOLDER=~/.stannumcore
COIN_DAEMON=stannumd
COIN_CLI=stannum-cli
COIN_TX=stannum-tx
COIN_QT=
MAX_CONNECTIONS=30
LOGINTIMESTAMPS=1
COIN_PORT=23403
RPC_PORT=12454

# FILE WITH NODES IN MASTERNODE INSTALL FOLDER
FILE_NODES=~/MasterNodes/stannumcore/stannumcore_nodes.txt

# LINK TO DOWNLOAD DAEMON
COIN_TGZ_ZIP='https://github.com/stannumcoin/stannum/releases/download/Release/precompile_linux.tar.gz'
# SET FOLDER IF UNZIP DAEMON IS ON SUBFOLDER?
COIN_SUBFOLDER=
# SET $(echo 'tar -xvzf *.gz') IF FILE IS TAR.GZ OR $(echo 'unzip -o *.zip'  TO ZIP FILE.)
COIN_TAR_UNZIP=$(echo 'tar -xvf *.gz')

# LINK TO DOWNLOAD BLOCKCHAIN
LINK_BLOCKCHAIN=
# SET FOLDER IF UNZIP BLOCKCHAIN IS ON SUBFOLDER?
BLOCKCHAIN_SUBFOLDER=data
# SET $(echo 'tar -xvzf *.gz') IF FILE IS TAR.GZ OR $(echo 'unzip -o *.zip'  TO ZIP FILE.)
BLOCKCHAIN_TAR_UNZIP=$(echo 'unzip -o *.zip')

# TO CONFIG
COIN_PATH=/usr/local/bin/
TMP_FOLDER=~/temp_masternodes


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
	echo "+-------------------------------------------------------------------------------->>"
	echo "| $1"
	echo "+--------------------------------------------<<<"
}

error() {
	message "An error occured, you must fix it to continue!"
	exit 1
}


function prepare_dependencies() { #TODO: add error detection
   PS3='Need to Install Depedencies and Libraries'
   echo -e "Prepare the system to install ${GREEN}$COIN_NAME master node.${NC}"
   echo -e "If prompted enter password of current user!"
      sudo apt-get -y update >/dev/null 2>&1
      DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
      DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
      sudo apt install -y software-properties-common >/dev/null 2>&1
      echo -e "${GREEN}Adding bitcoin PPA repository"
      sudo apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
      echo -e "Installing required packages, it may take some time to finish.${NC}"
      sudo apt-get -y update >/dev/null 2>&1
      sudo apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
      build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
      libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
      libminiupnpc-dev libgmp3-dev ufw pkg-config libevent-dev  libdb5.3++>/dev/null 2>&1 
      sudo apt-get install -y libzmq3-dev
   if [ "$?" -gt "0" ];
      then
      echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
      echo "sudo apt-get update"
      echo "sudo apt -y install software-properties-common"
      echo "sudo apt-add-repository -y ppa:bitcoin/bitcoin"
      echo "sudo apt-get update"
      echo "sudo apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
            libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git curl libdb4.8-dev \
            bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw fail2ban pkg-config libevent-dev"
      exit 1
   fi
   clear
}

function prepare_node() { #TODO: add error detection
	echo -e "Downloading ${GREEN}$COIN_NAME ${NC} Daemon..."
  	mkdir $TMP_FOLDER >/dev/null 2>&1
        cd $TMP_FOLDER
	mkdir installnode
	cd $TMP_FOLDER/installnode
	wget $COIN_TGZ_ZIP
        $COIN_TAR_UNZIP
        rm *.gz >/dev/null 2>&1
        rm *.zip >/dev/null 2>&1
	   if [ -d "$TMP_FOLDER/installnode/$COIN_SUBFOLDER" ]; then cd $TMP_FOLDER/installnode/$COIN_SUBFOLDER && strip $COIN_DAEMON $COIN_CLI $COIN_TX $COIN_QT ; fi
	   if [ $? -ne 0 ]; then strip $COIN_DAEMON $COIN_CLI $COIN_TX $COIN_QT ; fi
	compile_error
	   if [ -d "$TMP_FOLDER/installnode/$COIN_SUBFOLDER" ]; then cd $TMP_FOLDER/installnode/$COIN_SUBFOLDER && chmod +x * && sudo cp -f * /usr/local/bin ; fi
	   if [ $? -ne 0 ]; then cd $TMP_FOLDER/installnode && chmod +x * && sudo cp -f * /usr/local/bin ; fi
    clear
}

function install_blockchain() {
  echo -e "Wait some time, installing blockchain!"
  mkdir $TMP_FOLDER >/dev/null 2>&1
  mkdir $TMP_FOLDER/tmp_blockchain
  cd $TMP_FOLDER/tmp_blockchain
  wget -q $LINK_BLOCKCHAIN
  $BLOCKCHAIN_TAR_UNZIP >/dev/null 2>&1
  cp -rvf $TMP_FOLDER/tmp_blockchain/$BLOCKCHAIN_SUBFOLDER/* $CONFIG_FOLDER >/dev/null 2>&1
  cd ~ - >/dev/null 2>&1
  clear
}

function enable_firewall() {
  echo -e "Installing and setting up firewall to allow ingress on port ${GREEN}$COIN_PORT${NC}"
  sudo ufw allow $COIN_PORT/tcp comment "$COIN_NAME MN port" >/dev/null
  sudo ufw allow ssh comment "SSH" >/dev/null 2>&1
  sudo ufw limit ssh/tcp >/dev/null 2>&1
  sudo ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
}

function temp_config() {
   #TODO: squash relative path
        rm $CONFIG_FOLDER/masternode.conf >/dev/null 2>&1
	echo -e "Create Temporary Configs..."
        echo -e "If asked enter password"
        $COIN_CLI stop  >/dev/null 2>&1
	sleep 10s
	sudo rm $CONFIG_FOLDER/$CONFIG_FILE >/dev/null 2>&1
	echo "rpcuser=temp" >> $CONFIG_FOLDER/$CONFIG_FILE
	echo "rpcpassword=temp" >> $CONFIG_FOLDER/$CONFIG_FILE
	cat $FILE_NODES >> $CONFIG_FOLDER/$CONFIG_FILE
   clear
}

function create_configs() {
	#TODO: Can check for flag and skip this
	#TODO: Random generate the user and password
        
	rm $CONFIG_FOLDER/$CONFIG_FILE >/dev/null 2>&1
	message "Creating $CONFIG_FILE..."
	TEMPMNPRIVKEY="7faP7K1bBWYJt2MivDnTgEU3ZggSgteDuC4fSMkZiMowWS3Bmfn"
		
	if [ ! -d "$CONFIG_FOLDER" ]; then mkdir $CONFIG_FOLDER; fi
	if [ $? -ne 0 ]; then error; fi

	mnip=$(curl -s https://api.ipify.org)
	rpcuser=$(date +%s | sha256sum | base64 | head -c 64 ; echo)
	rpcpass=$(openssl rand -base64 46)
	printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "listen=1" "server=1" "daemon=1" "maxconnections=$MAX_CONNECTIONS" "logintimestamps=$LOGINTIMESTAMPS" "rpcport=$RPC_PORT" "externalip=$mnip:$COIN_PORT" "port=$COIN_PORT" "bind=$mnip:$COIN_PORT" "masternode=1" "masternodeprivkey=$TEMPMNPRIVKEY" >  $CONFIG_FOLDER/$CONFIG_FILE
	cat $FILE_NODES >> $CONFIG_FOLDER/$CONFIG_FILE
	
        message "Closing stannumcore Daemon"
        $COIN_CLI stop  >/dev/null 2>&1
        sleep 15s
        
	message "Starting stannumcore Daemon"
        $COIN_DAEMON --reindex
        sleep 15s
	echo -e "Wait $COIN_NAME Daemon load wallet."
	sleep 30s

        COIN_ADDRESS=$($COIN_CLI getaddressesbyaccount '' )
        message "Send exactly $COLATERAL to this address: $COIN_ADDRESS wait complete 1 confirmation and back here"
        message "No continue if have no confirmation, is to much important!"
        echo -n "after 1 confirmation press key [ENTER] to continue..."
        read var_name
 
        message "Wait 10 seconds for daemon to load..."
        sleep 20s
        MNPRIVKEY=$($COIN_CLI masternode genkey)
	$COIN_CLI stop  >/dev/null 2>&1
	message "wait 10 seconds for deamon to stop..."
        sleep 10s
        $COIN_CLI stop >/dev/null 2>&1
        message "Closing $COIN_NAME Daemon"
        sleep 10s
        sudo rm $CONFIG_FILE >/dev/null 2>&1
	message "Updating $CONFIG_FILE..."
        printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "listen=1" "server=1" "daemon=1" "maxconnections=$MAX_CONNECTIONS" "logintimestamps=$LOGINTIMESTAMPS" "rpcport=$RPC_PORT" "externalip=$mnip:$COIN_PORT" "port=$COIN_PORT" "bind=$mnip:$COIN_PORT" "masternode=1" "masternodeprivkey=$MNPRIVKEY" >  $CONFIG_FOLDER/$CONFIG_FILE
	if [ ! -d "$TMP_FOLDER" ]; then mkdir $TMP_FOLDER; fi
	if [ $? -ne 0 ]; then error; fi
	echo -e "Save masternode private key"
	echo $MNPRIVKEY >> $TMP_FOLDER/$COIN_NAME.masternodeprivkey.txt
	cat $FILE_NODES >> $CONFIG_FOLDER/$CONFIG_FILE
	clear
}

function install_service() {
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

function checks() {
if [[ $(lsb_release -d) != *16.04* ]]; then
  echo -e "${RED}You are not running Ubuntu 16.04. Installation is cancelled.${NC}"
  exit 1
fi

if [ -n "$(pidof $COIN_DAEMON)" ] || [ -e "$COIN_DAEMOM" ] ; then
  echo -e "${RED}$COIN_NAME is already installed.${NC}"
  exit 1
fi
}


# ----------------------------- CONGRATULATIONS ---------------------------------
function last_commits() {
        echo -e "Commit lasts configs of $COIN_NAME Daemon!"
        sleep 2s
        echo -e "Starting $COIN_NAME Daemon"
	$COIN_DAEMON >/dev/null 2>&1
        sleep 15s
        message "Wait 120 seconds to $COIN_NAME start sync"
        sleep 120s
        clear

        echo "Checking $COIN_NAME sync progress"
        $COIN_CLI getinfo
        echo -e "Obs: Only work if you have send ${GREEN}$COLATERAL${NC} to address ${GREEN}$COIN_ADDRESS ${NC}of ${GREEN}$COIN_NAME ${NC}and alrely get ${GREEN}1 confirmation!${NC}" 
	echo -e " "
	echo -e " " 
	echo -e "If like try to create masternode.conf you can wait sync complete or "
	echo -n "Press key [ENTER] to continue and create it manualy..."
        read var_name
        sleep 2s
	clear

        TXOUTPUTS=$($COIN_CLI masternode outputs )
        echo -e "If have send ammount $COLATERAL and get 1 confirmed to the $COIN_ADDRESS the OUTPUTS show now:"
	echo -e "Obs: $COIN_NAME need to be sync completed!"
        echo -e " "
	echo -e " "
	echo -e "Outputs: $TXOUTPUTS "
	echo -e " "
	echo -e " "
	echo -e "If show none you need to create masternode.conf manualy"
	sleep 10s
clear        
}

function success() {
        if [ ! -e "~/$TMP_FOLDER/txouts.txt" ]; then rm ~/$TMP_FOLDER/txouts.txt; fi
        if [ $? -ne 0 ]; then clear; fi
	
TXID_INDEX=$($COIN_CLI masternode outputs)
TX_OUTPUTS=$(echo $TXID_INDEX  |  sed 's/"//g' | sed 's/{//g' |  sed 's/}//g' |  sed 's/://g')

MN_PRIVKEY=$(head -n 1 $TMP_FOLDER/$COIN_NAME.masternodeprivkey.txt)

        if [ ! -e "~/$COIN_NAME.txt" ]; then rm ~/$COIN_NAME.txt; fi
        if [ $? -ne 0 ]; then clear; fi

 echo "SUCCESS! Your ${GREE}$COIN_NAME ${CN}has started. All your configs are"
 # TO SHOW
 echo -e "Obs: All informations are saved in /home/userfolder/$COIN_NAME.txt or in /root/$COIN_NAME.txt if run as root!"
 echo -e "================================================================================================================================" 
 echo -e "$COIN_NAME Masternode is up and running listening on port ${RED}$COIN_PORT${NC}." 
 echo -e "Configuration file is: ${RED}$CONFIG_FOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "NODE_IP:PORT ${RED}$NODEIP:$COIN_PORT ${NC}"
 echo -e "MASTERNODE PRIVATEKEY is: ${RED} $MN_PRIVKEY ${NC}"
 echo -e "MASTERNODE file: $CONFIG_FOLDER/masternode.conf"
 echo -e "MASTERNODE configuration bellow:"
 echo -e "MN $NODEIP:$COIN_PORT $MN_PRIVKEY $TX_OUTPUTS"
 echo -e "Please check ${RED}$COIN_NAME${NC} is running with the following command: ${GREEN}systemctl status $COIN_NAME.service${NC}" 
 echo -e "================================================================================================================================" 

# TO FILE
 echo -e "================================================================================================================================" >> ~/$COIN_NAME.txt
 echo -e "$COIN_NAME Masternode is up and running listening on port ${RED}$COIN_PORT${NC}." >> ~/$COIN_NAME.txt
 echo -e "Configuration file is: $CONFIG_FOLDER/$CONFIG_FILE" >> ~/$COIN_NAME.txt
 echo -e "Start: systemctl start $COIN_NAME.service$" >> ~/$COIN_NAME.txt
 echo -e "Stop: systemctl stop $COIN_NAME.service$" >> ~/$COIN_NAME.txt
 echo -e "NODE_IP:PORT $NODEIP:$COIN_PORT" >> ~/$COIN_NAME.txt
 echo -e "MASTERNODE PRIVATEKEY is: $MN_PRIVKEY$" >> ~/$COIN_NAME.txt
 echo -e "MASTERNODE file: $CONFIG_FOLDER/masternode.conf " >> ~/$COIN_NAME.txt
 echo -e "MASTERNODE configuration bellow:" >> ~/$COIN_NAME.txt
 echo -e "MN $NODEIP:$COIN_PORT $MN_PRIVKEY $TX_OUTPUTS" >> ~/$COIN_NAME.txt
 echo -e "Please check $COIN_NAME$ is running with the following command: systemctl status $COIN_NAME.service" >> ~/$COIN_NAME.txt
 echo -e "================================================================================================================================" >> ~/$COIN_NAME.txt

# TO MASTERNODE CONFIG FILE

        if [ ! -e "$CONFIG_FOLDER/masternode.conf" ]; then rm $CONFIG_FOLDER/masternode.conf; fi
        if [ $? -ne 0 ]; then echo -e "masternode.conf created!" ; fi

 printf "%s\n" "# Masternode config file" "# Format: alias IP:port masternodeprivkey collateral_output_txid collateral_output_index" "# Example: mn1 127.0.0.2:23403 93HaYBVUCYjEMeeH1Y4sBGLALQZE1Yc1K64xiqgX37tGBDQL8Xg 2bcd3c84c84f87eaa86e4e56834c92927a07f9e18718810b92e0d0324456a67c 0" "MN $NODEIP:$COIN_PORT $MN_PRIVKEY $TX_OUTPUTS" >  $CONFIG_FOLDER/masternode.conf
 
 # CLEAR TEMP FOLDER
 sudo rm -rf $TMP_FOLDER/* >/dev/null 2>&1
}

install() {
        checks
        prepare_dependencies
	prepare_node
	install_blockchain
	enable_firewall
	temp_config
	create_configs
	install_service
	last_commits
	success
}

#main
#default to --without-gui
clear
install --without-gui


