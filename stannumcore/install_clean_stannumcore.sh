#!/bin/sh
#Info: Install or Update MasterNode Daemons, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#TODO: to run you need to use ./Install.sh from MasterNodes folder.

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
          echo "If you get any error close this installer and restart install.sh with selected install dependences option!"
}

createswap() { #TODO: add error detection
	message "Creating 2GB temporary swap file...this may take a few minutes..."
	sudo dd if=/dev/zero of=/swapfile bs=1M count=2000
	sudo mkswap /swapfile
	sudo chown root:root /swapfile
	sudo chmod 0600 /swapfile
	sudo swapon /swapfile

	#make swap permanent
	sudo echo "/swapfile none swap sw 0 0" >> /etc/fstab
}

installstannumcore() { #TODO: add error detection
	message "Downloading stannumcore Daemon..."
  	cd ~
    mkdir ~/_coins
    mkdir ~/_coins/stannumcore
    cd ~/_coins/stannumcore
	  wget https://github.com/stannumcoin/stannum/releases/download/Release/precompile_linux.tar.gz
    unzip -o *.zip
    tar -xvf *.gz
    rm *.gz
    rm *.zip
    chmod +x *
    mkdir ~/.stannumcore
}

installing() {
        #TODO: squash relative path
	message "Installing stannumcore Daemon..."
        message "If asked enter password"
        stannum-cli stop
        pkill -f stannumd
	sudo cp -f ~/_coins/stannumcore/* /usr/local/bin
}

createconf() {
	#TODO: Can check for flag and skip this
	#TODO: Random generate the user and password

	message "Creating stannum.conf..."
	MNPRIVKEY="7faP7K1bBWYJt2MivDnTgEU3ZggSgteDuC4fSMkZiMowWS3Bmfn"
	CONFDIR=~/.stannumcore
	CONFILE=$CONFDIR/stannum.conf
	if [ ! -d "$CONFDIR" ]; then mkdir $CONFDIR; fi
	if [ $? -ne 0 ]; then error; fi

	mnip=$(curl -s https://api.ipify.org)
	rpcuser=$(date +%s | sha256sum | base64 | head -c 64 ; echo)
	rpcpass=$(openssl rand -base64 64)
	printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "listen=1" "server=1" "daemon=1" "maxconnections=30" "#rpcport=1271" "externalip=$mnip" "port=23403" "bind=$mnip" "masternode=1" "masternodeprivkey=$MNPRIVKEY" "masternodeaddr=$mnip:23403" > $CONFILE
        message "Closing stannumcore Daemon"
        stannum-cli stop
        sleep 15s
        pkill -f stannumd
        pkill stannumd
        sleep 10

        message "Starting stannumcore Daemon"
        stannumd
        sleep 15s

        SNCADDRESS=$(stannum-cli getaddressesbyaccount '' )
        message "Send exactly 1000SNC to this address: $SNCADDRESS wait complete 1 confirmation and back here"
        message "No continue if have no confirmation, is to much important!"
        echo -n "after 1 confirmation press key [ENTER] to continue..."
        read var_name
 
        message "Wait 10 seconds for daemon to load..."
        sleep 20s
        MNPRIVKEY=$(stannum-cli masternode genkey)
	stannum-cli stop
	message "wait 10 seconds for deamon to stop..."
        sleep 10s
        stannum-cli stop
        message "Closing stannumcore Daemon"
        sleep 10s
        pkill -f stannumd
        pkill stannumd
        sleep 10s
	sudo rm $CONFILE
	message "Updating stannum.conf..."
        printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "listen=1" "server=1" "daemon=1" "maxconnections=256" "#rpcport=11995" "externalip=$mnip" "port=23403" "bind=$mnip" "masternode=1" "masternodeprivkey=$MNPRIVKEY" "masternodeaddr=$mnip:23403" > $CONFILE

}

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
        ./menu_stannumcore.sh
	exit 0
}

install() {
	prepdependencies
	createswap
	installstannumcore
	installing $1
	createconf
	success
}

#main
#default to --without-gui
install --without-gui

