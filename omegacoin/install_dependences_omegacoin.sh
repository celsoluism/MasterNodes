#!/bin/sh
#Info: Install or Update MasterNode Daemons, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#TODO: to run you need to use ./Install.sh from MasterNodes folder.

	  sudo apt-get -y update
	  sudo apt-get -y upgrade
	  sudo apt-get -y dist-upgrade
	  sudo apt-get install -y nano htop git
	  sudo apt-get install -y software-properties-common
	  sudo apt-get install -y build-essential libtool autotools-dev pkg-config libssl-dev
	  sudo apt-get install -y libboost-all-dev
	  sudo apt-get install -y libevent-dev
	  sudo apt-get install -y libminiupnpc-dev
	  sudo apt-get install -y autoconf
	  sudo apt-get install -y automake unzip
	  sudo add-apt-repository  -y  ppa:bitcoin/bitcoin
	  sudo apt-get -y update 
	  sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
	  sudo apt-get -y update
	  sudo apt-get -y upgrade
	  sudo apt-get -y dist-upgrade
