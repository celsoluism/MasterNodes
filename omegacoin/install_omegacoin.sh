
#!/bin/sh
#Version 0.0.1.3
#Info: Installs MasterNode Daemons, Masternode based on privkey and txid.
#DextroCore MasterNode
#Tested OS: 16.04
#TODO: make script less "ubuntu" or add other linux flavors
#TODO: need sudo group on user account to run script (i.e. no run as root and no use sudo in comand line)
#TODO: add specific dependencies depending on build option (i.e. gui requires QT4)
#TODO: enter password sudo if required!
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

installnode() { #TODO: add error detection
	message "Downloading OmegaCoin Daemon..."
  	cd ~
    mkdir ~/_coins
    mkdir ~/_coins/omegacoin
    cd ~/_coins/omegacoin
	  wget https://github.com/omegacoinnetwork/omegacoin/releases/download/0.12.5.1/omagecoincore-0.12.5.1-linux64.zip
    unzip -o *.zip
    tar -xvf *.gz
    rm *.gz
    rm *.zip
    chmod +x *
    mkdir ~/.omegacoincore
}

installing() {
        #TODO: squash relative path
	message "Installing DextroCore Daemon..."
        message "If asked enter password"
        omegacoin-cli stop
        pkill -f omegacoindd
	sudo cp -f ~/_coins/omegacoin/* /usr/local/bin
}

createconf() {
	#TODO: Can check for flag and skip this
	#TODO: Random generate the user and password

	message "Creating omegacoin.conf..."
	MNPRIVKEY="5Cs9f178iwrt7TW47nYSPfUg6UZ3wWMv5UeGkadjBr7oog3asHV"
	CONFDIR=~/.omegacoincore
	CONFILE=$CONFDIR/omegacoin.conf
	if [ ! -d "$CONFDIR" ]; then mkdir $CONFDIR; fi
	if [ $? -ne 0 ]; then error; fi

	mnip=$(curl -s https://api.ipify.org)
	rpcuser=$(date +%s | sha256sum | base64 | head -c 64 ; echo)
	rpcpass=$(openssl rand -base64 64)
	printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "listen=1" "server=1" "daemon=1" "maxconnections=30" "rpcport=7778" "externalip=$mnip" "port=7777" "bind=$mnip" "masternode=1" "masternodeprivkey=$MNPRIVKEY" "masternodeaddr=$mnip:7777" > $CONFILE
        message "Closing OmegaCoin Daemon"
        omegacoin-cli stop
        sleep 15s
        pkill -f omegacoind
        pkill omegacoind
        sleep 10

        message "Starting OmegaCoin Daemon"
        omegacoind
        sleep 15s

        OMEGAADDRESS=$(omegacoin-cli getaddressesbyaccount '' )
        message "Send exactly 1000OMEGA to this address: $OMEGAADDRESS wait complete 1 confirmation and back here"
        message "No continue if have no confirmation, is to much important!"
        echo -n "after 1 confirmation press key [ENTER] to continue..."
        read var_name
 
        message "Wait 10 seconds for daemon to load..."
        sleep 20s
        MNPRIVKEY=$(omegacoin-cli masternode genkey)
	omegacoin-cli stop
	message "wait 10 seconds for deamon to stop..."
        sleep 10s
        omegacoin-cli stop
        message "Stopping Daemon"
        sleep 10s
        pkill -f omegacoind
        pkill omegacoind
        sleep 10s
	sudo rm $CONFILE
	message "Updating Omegacoin.conf..."
        printf "%s\n" "rpcuser=$rpcuser" "rpcpassword=$rpcpass" "rpcallowip=127.0.0.1" "listen=1" "server=1" "daemon=1" "maxconnections=30" "rpcport=7778" "externalip=$mnip" "port=7777" "bind=$mnip" "masternode=1" "masternodeprivkey=$MNPRIVKEY" "masternodeaddr=$mnip:7777" > $CONFILE

}

success() {
        sleep 5s
        cat ~/MasterNodes/omegacoin/omegacoinnodes.txt >> ~/.omegacoincore/omegacoin.conf
        sleep 2s
        message "Starting Daemon"
	omegacoind
        sleep 15s
        message "Wait 60 seconds to sync masternode"
        sleep 60s
        clear
	message "SUCCESS! Your OmegaCoin has started. Masternode.conf setting below..."
	message "MN $mnip:39320 $MNPRIVKEY TXHASH INDEX"
        TXOUTPUTS=$(omegacoin-cli masternode outputs )
        message "Copy outputs bellow and modify ~/.omegacoin/masternode.conf following TXHASH and INDEX"
        message " Outputs: $TXOUTPUTS " 
        
        message "check if 'omegacoin-cli getinfo' work, if no work need to restart install or install dependences"
        omegacoin-cli getinfo
        echo -n "If all completed press key [ENTER] to continue..."
        read var_name
        ./install_omegacoin.sh
	exit 0
}

install() {
	prepdependencies
	createswap
	installnode
	installing $1
	createconf
	success
}

#main
#default to --without-gui
install --without-gui

