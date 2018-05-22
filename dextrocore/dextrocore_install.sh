#!/bin/bash
#Info: Install or Update MasterNode Daemons, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#TODO: to run you need to use ./Install.sh from MasterNodes folder.

COINNAME=dextrocore
CONFFILE=dextro.conf

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


prepdependencies() { #TODO: add error detection
PS3='Need to Install Depedencies and Libraries'
sudo apt install -y unzip
          echo "If you get any error close this installer and restart install.sh with selected install dependences option!"
}

installdextro() { #TODO: add error detection
	message "Downloading DextroCore Daemon..."
  	cd ~
    mkdir ~/_coins
    mkdir ~/_coins/dextrocore
    cd ~/_coins/dextrocore
	  wget https://github.com/celsoluism/coins-daemons/raw/master/linux_dextrocore.zip
    unzip -o *.zip
    tar -xvf *.gz
    rm *.gz
    rm *.zip
    chmod +x *
    mkdir ~/.dextro
}

installing() {
        #TODO: squash relative path
	message "Installing DextroCore Daemon..."
        message "If asked enter password"
        dextro-cli stop
        sudo cp -f ~/_coins/dextrocore/* /usr/local/bin
}

createconf() {
	#TODO: Can check for flag and skip this
	#TODO: Random generate the user and password

	message "Creating dextro.conf..."
	MNPRIVKEY="6JKhdudXtLxevoys6ipfpfizbBsCew2iLSBFrE3dUkvLhedQXct"
	CONFDIR=~/.dextro
	CONFILE=$CONFDIR/dextro.conf
	if [ ! -d "$CONFDIR" ]; then mkdir $CONFDIR; fi
	if [ $? -ne 0 ]; then error; fi

	mnip=$(curl -s https://api.ipify.org)
	rpcuser=$(date +%s | sha256sum | base64 | head -c 64 ; echo)
	rpcpass=$(openssl rand -base64 64)
	printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "listen=1" "server=1" "daemon=1" "maxconnections=30" "rpcport=1271" "externalip=$mnip" "port=39320" "bind=$mnip" "masternode=1" "masternodeprivkey=$MNPRIVKEY" "masternodeaddr=$mnip:39320" > $CONFILE
        
	message "Closing Dextro Daemon"
        dextro-cli stop
        sleep 25s
        
        message "Starting Dextro Daemon"
        dextrod
        sleep 15s

        DXOADDRESS=$(dextro-cli getaddressesbyaccount '' )
        message "Send exactly 1000DXO to this address: $DXOADDRESS wait complete 1 confirmation and back here"
        message "No continue if have no confirmation, is to much important!"
        echo -n "after 1 confirmation press key [ENTER] to continue..."
        read var_name
 
        message "Wait 10 seconds for daemon to load..."
        sleep 20s
        MNPRIVKEY=$(dextro-cli masternode genkey)
	dextro-cli stop
	message "wait 10 seconds for deamon to stop..."
        sleep 10s
        dextro-cli stop
        message "Closing Dextro Daemon"
        sleep 10s
        sleep 10s
	sudo rm $CONFILE
	message "Updating $CONFFILE..."
        printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "listen=1" "server=1" "daemon=1" "maxconnections=256" "rpcport=11995" "externalip=$mnip" "port=39320" "bind=$mnip" "masternode=1" "masternodeprivkey=$MNPRIVKEY" "masternodeaddr=$mnip:39320" > $CONFILE

}

success() {
        sleep 5s
        cat ~/MasterNodes/dextrocore/dextrocore_nodes.txt >> ~/.dextro/dextro.conf
        sleep 2s
        message "Starting Dextro Daemon"
	dextrod
        sleep 15s
        message "Wait 60 seconds to sync masternode"
        sleep 60s
        clear
	message "SUCCESS! Your DextroCore has started. Masternode.conf setting below..."
	message "MN $mnip:39320 $MNPRIVKEY TXHASH INDEX"
        TXOUTPUTS=$(dextro-cli masternode outputs )
        message "Copy outputs bellow and modify ~/.dextro/masternode.conf following TXHASH and INDEX"
        message " Outputs: $TXOUTPUTS " 
        
        message "check if 'dextro-cli getinfo' work, if no work need to restart install or install dependences"
        dextro-cli getinfo
        echo -n "after 1 confirmation press key [ENTER] to continue..."
        read var_name
        ./dextrocore/dextrocore_menu.sh
	exit 0
}

install() {
	prepdependencies
	installdextro
	installing $1
	createconf
	success
}

#main
#default to --without-gui
install --without-gui

