#!/bin/bash
#Info: Install or Update MasterNode Daemons, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#TODO: to run you need to use ./Install.sh from MasterNodes folder.

#--------------------------------------------- COIN INFORMATION --------------------------------------------
# CONFIG ABOUT COIN
COIN_NAME=stannum
COLATERAL=1000SNC
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
# STANNUM DONT WORK WITH DEFAULT RPCPORT, USE ANY OTHER RPCPORT
RPC_PORT=23404
LISTEN_ONION=0
STAKING=0

# CHECK BOLEANS
USE_BIND=y
USE_ADDR=y
USE_SENTINEL=n

# SENTINEL CONFIGURATIONS
SENTINEL_REPO='https://github.com/omegacoinnetwork/sentinel.git'

# FILE WITH NODES IN MASTERNODE INSTALL FOLDER
FILE_NODES=~/MasterNodes/stannumcore/stannumcore_nodes.txt

# LINK TO DOWNLOAD DAEMON
COIN_TGZ_ZIP='https://github.com/stannumcoin/stannum/releases/download/Release/precompile_linux.tar.gz'
# SET FOLDER IF UNZIP DAEMON IS ON SUBFOLDER?
COIN_SUBFOLDER=

# LINK TO DOWNLOAD BLOCKCHAIN
LINK_BLOCKCHAIN=
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
       	  sudo apt-get -y update
	  clear
	  echo -e "${GREEN}Start install dependences!${NC}"
          echo -e "If prompted enter password of current user!"
	  echo -e "Installing required packages, it may take some time to finish.${NC}"
	  sudo apt-get -y upgrade >/dev/null 2>&1
	  sudo apt-get -y dist-upgrade >/dev/null 2>&1
	  sudo apt-get install -y nano htop git >/dev/null 2>&1
	  sudo apt-get install -y software-properties-common >/dev/null 2>&1
	  sudo apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev >/dev/null 2>&1

          clear
	  echo -e "${GREEN}Start install libss!${NC}"
          echo -e "If prompted enter password of current user!"
	  echo -e "Installing required packages, it may take some time to finish.${NC}"
          sudo apt-get install -y libboost-all-dev
	  sudo apt-get install -y libevent-dev >/dev/null 2>&1
	  sudo apt-get install -y libminiupnpc-dev >/dev/null 2>&1
	  sudo apt-get install -y autoconf >/dev/null 2>&1
	  sudo apt-get install -y automake unzip >/dev/null 2>&1
	  sudo add-apt-repository  -y  ppa:bitcoin/bitcoin >/dev/null 2>&1
	  sudo apt-get -y update >/dev/null 2>&1
	  sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
	  
	  clear
          echo -e "${GREEN}Updating system!${NC}" 
          echo -e "If prompted enter password of current user!"
	  echo -e "Installing required packages, it may take some time to finish.${NC}"
	  sudo apt-get -y update >/dev/null 2>&1
	  sudo apt-get -y upgrade >/dev/null 2>&1
	  sudo apt-get -y dist-upgrade >/dev/null 2>&1
	  sudo apt-get install -y unzip >/dev/null 2>&1
      
      clear
      PS3='Need to Install Libraries'
      echo -e "Prepare the system to install ${GREEN}$COIN_NAME master node.${NC}"
     		sudo apt-get update >/dev/null 2>&1
		DEBIAN_FRONTEND=noninteractive apt-get update > /dev/null 2>&1
		DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" -y -qq upgrade >/dev/null 2>&1
		sudo apt install -y software-properties-common >/dev/null 2>&1
		echo -e "${GREEN}Adding bitcoin PPA repository"
		sudo apt-add-repository -y ppa:bitcoin/bitcoin >/dev/null 2>&1
		echo -e "Installing required packages, it may take some time to finish.${NC}"
		sudo apt-get update >/dev/null 2>&1
		sudo apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" make software-properties-common \
		build-essential libtool autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev libboost-program-options-dev \
		libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git wget pwgen curl libdb4.8-dev bsdmainutils libdb4.8++-dev \
		libminiupnpc-dev libgmp3-dev ufw python-virtualenv unzip >/dev/null 2>&1
		sudo apt-get install -y libzmq3-dev >/dev/null 2>&1
		clear
		if [ "$?" -gt "0" ];
		  then
			echo -e "${RED}Not all required packages were installed properly. Try to install them manually by running the following commands:${NC}\n"
			echo "apt-get update"
			echo "apt -y install software-properties-common"
			echo "apt-add-repository -y ppa:bitcoin/bitcoin"
			echo "apt-get update"
			echo "apt install -y make build-essential libtool software-properties-common autoconf libssl-dev libboost-dev libboost-chrono-dev libboost-filesystem-dev \
		libboost-program-options-dev libboost-system-dev libboost-test-dev libboost-thread-dev sudo automake git pwgen curl libdb4.8-dev \
		bsdmainutils libdb4.8++-dev libminiupnpc-dev libgmp3-dev ufw fail2ban python-virtualenv unzip libzmq3-dev"
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
	
function prepare_node() { #TODO: add error detection
	echo -e "Downloading ${GREEN}$COIN_NAME ${NC} Daemon..."
  	mkdir $TMP_FOLDER >/dev/null 2>&1
        cd $TMP_FOLDER
	mkdir installnode >/dev/null 2>&1
	cd $TMP_FOLDER/installnode
	wget $COIN_TGZ_ZIP
        echo -e "uncompressing file"
	if [[ $COIN_TGZ_ZIP == *.gz ]]; then
	   cd $TMP_FOLDER/installnode
           tar -xf  *.gz >/dev/null 2>&1
        fi
        if [[ $COIN_TGZ_ZIP == *.zip ]]; then
       	   cd $TMP_FOLDER/installnode
	   unzip  *.zip >/dev/null 2>&1
        fi
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
  cd $CONFIG_FOLDER && sudo rm -rf blocks chainstate .lock db.log debug.log fee_estimates.dat governance.dat mncache.dat mnpayments.dat netfulfilled.dat peers.dat database >/dev/null 2>&1
  mkdir $TMP_FOLDER >/dev/null 2>&1
  mkdir $TMP_FOLDER/tmp_blockchain
  cd $TMP_FOLDER/tmp_blockchain
  wget -q $LINK_BLOCKCHAIN
  $BLOCKCHAIN_TAR_UNZIP >/dev/null 2>&1
  mkdir $CONFIG_FOLDER >/dev/null 2>&1
  if [ -d "$TMP_FOLDER/tmp_blockchain/$BLOCKCHAIN_SUBFOLDER" ]; then cp -rvf $TMP_FOLDER/tmp_blockchain/$BLOCKCHAIN_SUBFOLDER/* $CONFIG_FOLDER >/dev/null 2>&1 ; fi
	if [ $? -ne 0 ]; then cp -rvf $TMP_FOLDER/tmp_blockchain/* $CONFIG_FOLDER >/dev/null 2>&1 ; fi
  cd ~ - >/dev/null 2>&1
  clear
}

function enable_firewall() {
  echo -e "Installing and setting up firewall to allow ingress on port ${GREEN}$COIN_PORT${NC}"
  sudo ufw allow $COIN_PORT comment "$COIN_NAME MN port" >/dev/null
  sudo ufw allow $RPC_PORT comment "$COIN_NAME MN RPC port" >/dev/null
  sudo ufw allow ssh comment "SSH" >/dev/null 2>&1
  sudo ufw limit ssh/tcp >/dev/null 2>&1
  sudo ufw default allow outgoing >/dev/null 2>&1
  echo "y" | ufw enable >/dev/null 2>&1
  clear
}

function create_configs() {
	#TODO: Can check for flag and skip this
	#TODO: Random generate the user and password
        echo -e "Preparing to create config files."
	
	if [ ! -d "$TMP_FOLDER" ]; then mkdir $TMP_FOLDER; fi
	if [ $? -ne 0 ]; then error; fi
	
	sudo systemctl stop $COIN_NAME.service >/dev/null 2>&1
        $COIN_CLI stop >/dev/null 2>&1
	sleep 10s
	message "Closing $COIN_NAMEe Daemon"
        sleep 10s
	
	sudo rm $CONFIG_FOLDER/masternode.conf >/dev/null 2>&1
	sudo rm $CONFIG_FOLDER/$CONFIG_FILE >/dev/null 2>&1
	
	message "Creating $CONFIG_FILE..."
	TEMPMNPRIVKEY="5CA13pAP9TNTrQKVPLjY8ZuhDE7rZULf2tdv7Q3CC5uxtCjm3KY"
		
	if [ ! -d "$CONFIG_FOLDER" ]; then mkdir $CONFIG_FOLDER; fi
	if [ $? -ne 0 ]; then error; fi

	mnip=$(curl -s https://api.ipify.org)
	BIND_IP=$mnip:$COIN_PORT
	if [[ $USE_BIND == Y ]] || [[ $USE_BIND == y ]]; then
	CHECK_BIND=$(echo bind=$BIND_IP)
	fi
	if [[ $USE_ADDR == Y ]] || [[ $USE_ADDR == y ]]; then
	CHECK_ADDR=$(echo bind=$BIND_IP)
	fi
	rpcuser=$(date +%s | sha256sum | base64 | head -c 24 ; echo)
	rpcpass=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
	printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "listen=1" "server=1" "daemon=1" "maxconnections=$MAX_CONNECTIONS" "logintimestamps=$LOGINTIMESTAMPS" "rpcport=$RPC_PORT" "listenonion=$LISTEN_ONION" "staking=$STAKING" "externalip=$mnip:$COIN_PORT" "port=$COIN_PORT" "$CHECK_BIND" "$CHECK_ADDR" >  $CONFIG_FOLDER/$CONFIG_FILE
	sudo rm $TMP_FOLDER/$CONFIG_FILE  >/dev/null 2>&1
	cp $CONFIG_FOLDER/$CONFIG_FILE $TMP_FOLDER
	cat $FILE_NODES >> $CONFIG_FOLDER/$CONFIG_FILE
	
        sleep 2s
	message "Starting $COIN_NAME Daemon"
        $COIN_DAEMON
        sleep 15s
	echo -e "Wait $COIN_NAME Daemon load wallet."
	sleep 30s
        
	GET_ADDRESS=$($COIN_CLI getaddressesbyaccount '' )
        COIN_ADDRESS=$(echo $GET_ADDRESS | sed 's/\"//g' | sed 's/\[//g' |  sed 's/\]//g' )
        message "Send exactly ${GREEN}$COLATERAL ${NC} to this address:${GREEN} $COIN_ADDRESS ${NC}wait complete ${GREEN} 1 confirmation ${NC}, check it in explorer and back here" 
        echo -e "Obs.: Wait 1 confirmation is necessary to create masternode file with all informations or continue now and will create partial file. "
        echo -n "Press key [ENTER] to continue..."
        read var_name
 
        message "Wait 10 seconds for daemon to load..."
        sleep 10s
        MNPRIVKEY=$($COIN_CLI masternode genkey)
	$COIN_CLI stop  >/dev/null 2>&1
	message "Wait daemon stop..."
        sleep 10s
        message "Closing $COIN_NAME Daemon"
        sleep 10s
        sudo rm $CONFIG_FOLDER/$CONFIG_FILE >/dev/null 2>&1
	message "Updating $CONFIG_FILE..."
        printf "%s\n" "masternode=1" "masternodeprivkey=$MNPRIVKEY" >>  $TMP_FOLDER/$CONFIG_FILE
	cat $FILE_NODES >> $TMP_FOLDER/$CONFIG_FILE
	cp -f $TMP_FOLDER/$CONFIG_FILE $CONFIG_FOLDER
	
	if [ ! -d "$TMP_FOLDER" ]; then mkdir $TMP_FOLDER; fi
	if [ $? -ne 0 ]; then error; fi
	echo -e "Save masternode private key"
	echo $MNPRIVKEY >> $TMP_FOLDER/$COIN_NAME.masternodeprivkey.txt
	clear
	if [ -d "$TMP_FOLDER/$CONFIG_FILE" ]; then install_service ; fi
	if [ $? -ne 0 ]; then configfile_error ; fi
	sleep 5s
}

function configfile_error() {
        echo -e " "
	echo -e "${RED}Error in create $CONFIG_FILE! ${NC}"
	echo -e " "
	echo -e "Installer will try to repair!"
	sleep 10s
	create_configs
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
  echo -e "${RED}If like to reinstall please use '$COIN_CLI stop' and restart ./rebase.sh.${NC}"
  echo -e "${RED}Remembr: It will remove all your configuration of the $COIN_NAME and create a new.${NC}"
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
	$COIN_DAEMON -daemon >/dev/null 2>&1
        sleep 15s
        message "Wait 120 seconds to $COIN_NAME start sync"
        sleep 120s
        clear

        message "Checking $COIN_NAME sync progress"
        GET_INFO=$(echo $COIN_CLI getinfo)
	echo -e "${GREEN} $GET_INFO ${NC}"
	
	message "Preparing masternode.conf file."
        echo -e "Obs: Only work if you have send ${GREEN}$COLATERAL${NC} to address ${GREEN}$COIN_ADDRESS ${NC}of ${GREEN}$COIN_NAME ${NC}and alrely get ${GREEN}1 confirmation!${NC}" 
	echo -e " "
	echo -e " " 
	echo -e "To create masternode.file ${GREEN}$COIN_DAEMON${NC} need ${GREEN}full sync${NC}"
	echo -e "To check it you need to open a new ssh conection and check using this command:"
	echo -e " " 
	echo -e " $COIN_CLI getinfo "
	echo -e " " 
	echo -e "Or you can press [ENTER] now and continue without complete masternode.conf if sync is not completed!" 
	echo -e "Obs.: You need to edit $CONF_FOLDER/masternode.conf and insert TXID INDEX after install complete and reboot server."
	echo -e " " 
	echo -n "Press key [ENTER] to continue..."
        read var_name
        sleep 2s
	clear

        TXOUTPUTS=$($COIN_CLI masternode outputs )
        echo -e "If you have send ammount $COLATERAL and get 1 confirmed to the $COIN_ADDRESS the OUTPUTS show now:"
	echo -e "Obs: $COIN_NAME need to be sync completed!"
        echo -e " "
	echo -e " "
	echo -e "Outputs: ${GREEN} $TXOUTPUTS ${NC}" 
	echo -e " "
	echo -e " "
	echo -e "If show none you need to complete informations in $CONFIG_FOLDER/masternode.conf manualy (TXID and INDEX)"
	sleep 10s
clear        
}

function install_sentinel() {
  SENTINELPORT=$[10001+$COIN_PORT]
  cd $HOME_FOLDER  >/dev/null 2>&1
  sudo rm -rf $HOME_FOLDER/sentinel_$COIN_NAME  #>/dev/null 2>&1
  echo -e "${GREEN}Install sentinel.${NC}"
  sudo apt-get install virtualenv >/dev/null 2>&1
  git clone $SENTINEL_REPO $HOME_FOLDER/sentinel_$COIN_NAME  >/dev/null 2>&1
  cd $HOME_FOLDER/sentinel_$COIN_NAME
  sed -i 's/#'$COIN_NAME'_conf/omegacoin_conf/g' $HOME_FOLDER/sentinel_$COIN_NAME/sentinel.conf
  sed -i "s/username/$HOME_USER/g" $HOME_FOLDER/sentinel_$COIN_NAME/sentinel.conf
  virtualenv ./venv
  ./venv/bin/pip install -r requirements.txt
  sed -i "s/19998/7777/g" $HOME_FOLDER/sentinel_$COIN_NAME/venv/bin/py.test  $HOME_FOLDER/sentinel_$COIN_NAME/test/unit/test_dash_config.py
  CRON_LINE="* * * * * cd $HOME_FOLDER/sentinel_$COIN_NAME && ./venv/bin/python bin/sentinel.py >> $HOME_FOLDER/sentinel.log >/dev/null 2>&1"
  (crontab -u $HOME_USER -l; echo "$CRON_LINE" ) | crontab -u $HOME_USER -
  (crontab -u $HOME_USER -l; echo "$CRON_LINE" ) | sudo crontab -u root -
  sudo chown -R $HOME_USER: $HOME_FOLDER/
  sudo chown -R $HOME_USER: $HOME_FOLDER/sentinel_$COIN_NAME
  ./venv/bin/py.test ./test
  echo -e "If show a ${GREEN} green massage${NC} all is ok, but if show ${RED}red message${NC} you config have a error or not all dependences installed!"
  echo -e "Getting ${RED}red${NC} message try first remove # from $HOME_FOLDER/sentinel_$COIN_NAME/sentinel.conf"
  echo -e "If dont work after remove # try reboot system"
  echo -e "Wait install continue..."
  sleep 20s
  clear
}

function success() {
TXID_INDEX=$($COIN_CLI masternode outputs)
TX_OUTPUTS=$(echo $TXID_INDEX  |  sed 's/"//g' | sed 's/{//g' |  sed 's/}//g' |  sed 's/://g')
MN_PRIVKEY=$(head -n 1 $TMP_FOLDER/$COIN_NAME.masternodeprivkey.txt)

# TO MASTERNODE CONFIG FILE
if [ ! -e "$CONFIG_FOLDER/masternode.conf" ]; then rm $CONFIG_FOLDER/masternode.conf; fi
        if [ $? -ne 0 ]; then echo -e "masternode.conf created!" ; fi
 printf "%s\n" "# Masternode config file" "# Format: alias IP:port masternodeprivkey collateral_output_txid collateral_output_index" "# Example: mn1 127.0.0.2:23403 93HaYBVUCYjEMeeH1Y4sBGLALQZE1Yc1K64xiqgX37tGBDQL8Xg 2bcd3c84c84f87eaa86e4e56834c92927a07f9e18718810b92e0d0324456a67c 0" "$ALIAS $NODEIP:$COIN_PORT $MN_PRIVKEY $TX_OUTPUTS" >  $CONFIG_FOLDER/masternode.conf
 
 # TO SHOW
 echo -e "SUCCESS! Your ${GREEN}$COIN_NAME ${NC}has started. All your configs are"
 echo -e " "
 echo -e "Obs: All informations are saved in $HOME_FOLDER/$COIN_NAME.txt !"
 echo -e " "
 message "${GREEN}CONGRATULATIONS, YOUR MASTERNODE IS INSTALLED AND CONFIGURED! ${NC}"
 echo -e "================================================================================================================================" 
 echo -e "$COIN_NAME Masternode is up and running listening on port ${RED}$COIN_PORT${NC}." 
 echo -e "Configuration file is: ${RED}$CONFIG_FOLDER/$CONFIG_FILE${NC}"
 echo -e "Start: ${RED}systemctl start $COIN_NAME.service${NC}"
 echo -e "Stop: ${RED}systemctl stop $COIN_NAME.service${NC}"
 echo -e "NODE_IP:PORT ${RED}$NODEIP:$COIN_PORT ${NC}"
 echo -e "MASTERNODE PRIVATEKEY is: ${RED} $MN_PRIVKEY ${NC}"
 echo -e "MASTERNODE file: $CONFIG_FOLDER/masternode.conf"
 echo -e "MASTERNODE configuration, copy this line bellow and paste in your windows wallet masternode file:"
 echo -e "$ALIAS $NODEIP:$COIN_PORT $MN_PRIVKEY $TX_OUTPUTS"
 echo -e "Please check ${RED}$COIN_NAME${NC} is running with the following command: ${GREEN}systemctl status $COIN_NAME.service${NC}" 
 echo -e "================================================================================================================================" 
 echo -e " "
 echo -e "================================================================================================================================" 
 echo -e "A copy of MASTERNODE file ${GREEN}$CONFIG_FOLDER/masternode.conf${NC} and"
 echo -e "a copy of CONFIG file ${GREEN}$CONFIG_FOLDER/$CONFIG_FILE ${NC}"
 echo -e "are saved in ${GREEN}$HOME_FOLDER/$COIN_NAME.txt${NC}"
 echo -e "================================================================================================================================" 

# TO COINFILE TXT
        if [ -e "$HOME_FOLDER/$COIN_NAME.txt" ]; then rm $HOME_FOLDER/$COIN_NAME.txt; fi
        if [ $? -ne 0 ]; then clear; fi
 echo -e "================================================================================================================================" >> ~/$COIN_NAME.txt
 echo -e "$COIN_NAME Masternode is up and running listening on port $COIN_PORT." >> ~/$COIN_NAME.txt
 echo -e "Configuration file is: $CONFIG_FOLDER/$CONFIG_FILE" >> ~/$COIN_NAME.txt
 echo -e "Start: systemctl start $COIN_NAME.service" >> ~/$COIN_NAME.txt
 echo -e "Stop: systemctl stop $COIN_NAME.service" >> ~/$COIN_NAME.txt
 echo -e "NODE_IP:PORT $NODEIP:$COIN_PORT" >> ~/$COIN_NAME.txt
 echo -e "MASTERNODE PRIVATEKEY is: $MN_PRIVKEY" >> ~/$COIN_NAME.txt
 echo -e "MASTERNODE file: $CONFIG_FOLDER/masternode.conf " >> ~/$COIN_NAME.txt
 echo -e "MASTERNODE configuration bellow:" >> ~/$COIN_NAME.txt
 echo -e "$ALIAS $NODEIP:$COIN_PORT $MN_PRIVKEY $TX_OUTPUTS" >> ~/$COIN_NAME.txt
 echo -e "Please check $COIN_NAME$ is running with the following command: systemctl status $COIN_NAME.service" >> ~/$COIN_NAME.txt
 echo -e "================================================================================================================================" >> ~/$COIN_NAME.txt
 echo -e " " >> ~/$COIN_NAME.txt
 echo -e "Copy of MASTERNODE file: $CONFIG_FOLDER/masternode.conf" >> ~/$COIN_NAME.txt
 echo -e "================================================================================================================================"  >> ~/$COIN_NAME.txt
 cat "$CONFIG_FOLDER/masternode.conf" >> ~/$COIN_NAME.txt
 echo -e "================================================================================================================================"  >> ~/$COIN_NAME.txt
 echo -e " " >> ~/$COIN_NAME.txt
 echo -e "Copy of CONFIG file: $CONFIG_FOLDER/$CONFIG_FILE" >> ~/$COIN_NAME.txt
 echo -e "================================================================================================================================"  >> ~/$COIN_NAME.txt
 cat "$CONFIG_FOLDER/$CONFIG_FILE" >> ~/$COIN_NAME.txt
 echo -e "================================================================================================================================"  >> ~/$COIN_NAME.txt
 


 # CLEAR TEMP FOLDER
 sudo rm -rf cache
 sudo rm -rf $TMP_FOLDER/* >/dev/null 2>&1
}

install() {
        checks
        install_dependences 
	install_swap_file
	prepare_node
	install_blockchain
	enable_firewall
	create_configs
	install_service
	last_commits
	if [[ $USE_SENTINEL == Y ]] || [[ $USE_SENTINEL == y ]]; then
	install_sentinel
	fi
	success
}

#main
#default to --without-gui
clear
install --without-gui
