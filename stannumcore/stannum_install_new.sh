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
COIN_QT=stannum-qt
COIN_PORT=23403
RPC_PORT=12454

# FILE WITH NODES IN MASTERNODE INSTALL FOLDER
FILE_NODES=stannumcore/stannumcore_nodes.txt

# LINK TO DOWNLOAD DAEMON
COIN_TGZ_ZIP='https://github.com/stannumcoin/stannum/releases/download/Release/precompile_linux.tar.gz'
# SET FOLDER IF UNZIP DAEMON IS ON SUBFOLDER?
COIN_SUBFOLDER=
# SET $(echo 'tar -xvzf *.gz') IF FILE IS TAR.GZ OR $(echo 'unzip -o *.zip'  TO ZIP FILE.)
COIN_TAR_UNZIP=$(echo 'tar -xvf *.gz')

# LINK TO DOWNLOAD BLOCKCHAIN
COIN_BLOCKCHAIN=
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
STRIP_FILES=$(echo '$COIN_DAEMON $COIN_CLI $COIN_TX $COIN_QT')

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
	cd installnode
	$wget $COIN_TGZ_ZIP
    $COIN_TAR_UNZIP
    rm *.gz >/dev/null 2>&1
    rm *.zip >/dev/null 2>&1
	strip $STRIP_FILES
	compile_error
	chmod +x *
	sudo cp -f * /usr/local/bin
    clear
}

function install_blockchain() {
  echo -e "Wait some time, installing blockchain!"
  mkdir $TMP_FOLDER >/dev/null 2>&1
  mkdir $TMP_FOLDER/tmp_blockchain
  cd $TMP_FOLDER/tmp_blockchain
  wget -q $COIN_BLOCKCHAIN
  $BLOCKCHAIN_TAR_UNZIP >/dev/null 2>&1
  cp -rvf $TMP_FOLDER/tmp_blockchain/$BLOCKCHAIN_SUBFOLDER/* $CONFIG_FOLDER >/dev/null 2>&1
  cd ~ - >/dev/null 2>&1
  sudo rm -rf $TMP_FOLDER/* >/dev/null 2>&1
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
	echo -e "Create Temporary Configs..."
        echo -e "If asked enter password"
        $COIN_CLI stop
	sleep 10s
	sudo rm $CONFIG_FOLDER/$CONFIG_FILE
	echo "rpcuser=temp" >> $CONFIG_FOLDER/$CONFIG_FILE
	echo "rpcpassword=temp" >> $CONFIG_FOLDER/$CONFIG_FILE
	cat $FILE_NODES >> $CONFIG_FOLDER/$CONFIG_FILE
   clear
}

function create_configs() {
	#TODO: Can check for flag and skip this
	#TODO: Random generate the user and password
        
	rm $CONFIG_FOLDER/$CONFIG_FILE
	message "Creating $CONFIG_FILE..."
	MNPRIVKEY="7faP7K1bBWYJt2MivDnTgEU3ZggSgteDuC4fSMkZiMowWS3Bmfn"
	
	
	if [ ! -d "$CONFIG_FOLDER" ]; then mkdir $CONFIG_FOLDER; fi
	if [ $? -ne 0 ]; then error; fi

	mnip=$(curl -s https://api.ipify.org)
	rpcuser=$(date +%s | sha256sum | base64 | head -c 64 ; echo)
	rpcpass=$(openssl rand -base64 46)
	printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "listen=1" "server=1" "daemon=1" "maxconnections=30" "#rpcport=1271" "externalip=$mnip" "port=23403" "bind=$mnip:23403" "masternode=1" "masternodeprivkey=$MNPRIVKEY" >  $CONFIG_FOLDER/$CONFIG_FILE
	cat $FILE_NODES >> $CONFIG_FOLDER/$CONFIG_FILE
	
        message "Closing stannumcore Daemon"
        $COIN_CLI stop
        sleep 15s
        sleep 10

        message "Starting stannumcore Daemon"
        $COIN_DAEMON
        sleep 15s

        COIN_ADDRESS=$($COIN_CLI getaddressesbyaccount '' )
        message "Send exactly $COLATERAL to this address: $COIN_ADDRESS wait complete 1 confirmation and back here"
        message "No continue if have no confirmation, is to much important!"
        echo -n "after 1 confirmation press key [ENTER] to continue..."
        read var_name
 
        message "Wait 10 seconds for daemon to load..."
        sleep 20s
        MNPRIVKEY=$($COIN_CLI masternode genkey)
	$COIN_CLI stop
	message "wait 10 seconds for deamon to stop..."
        sleep 10s
        $COIN_CLI stop
        message "Closing $COIN_NAME Daemon"
        sleep 10s
        sudo rm $CONFIG_FILE
	message "Updating $CONFIG_FILE..."
        printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "listen=1" "server=1" "daemon=1" "maxconnections=256" "#rpcport=11995" "externalip=$mnip" "port=23403" "bind=$mnip:23403" "masternode=1" "masternodeprivkey=$MNPRIVKEY" >  $CONFIG_FOLDER/$CONFIG_FILE
	cat $FILE_NODES >> $CONFIG_FOLDER/$CONFIG_FILE
}

function install_service() {
  echo -e "Install Service"
   mkdir $TMP_FOLDER >/dev/null 2>&1
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
success() {
        sleep 5s
        cat ~/MasterNodes/stannumcore/stannumcore_nodes.txt >> ~/.stannumcore/stannum.conf
        sleep 2s
        message "Starting stannumcore Daemon"
	stannumd
        sleep 15s
        message "Wait 60 seconds to sync masternode"
        sleep 60s
        clear
	message "SUCCESS! Your stannumcore has started. Masternode.conf setting below..."
	message "MN $mnip:23403 $MNPRIVKEY TXHASH INDEX"
        TXOUTPUTS=$(stannum-cli masternode outputs )
        message "Copy outputs bellow and modify ~/.stannumcore/masternode.conf following TXHASH and INDEX"
        message " Outputs: $TXOUTPUTS " 
        
        message "check if 'stannum-cli getinfo' work, if no work need to restart install or install dependences"
        stannum-cli getinfo
        echo -n "after 1 confirmation press key [ENTER] to continue..."
        read var_name
        ./stannumcore/stannumcore_menu.sh
	exit 0
}

install() {
        checks
        $prepare_dependencies
	prepare_node
	install_blockchain
	enable_firewall
	temp_config
	create_configs
	install_service
	success
}

#main
#default to --without-gui
clear
install --without-gui

