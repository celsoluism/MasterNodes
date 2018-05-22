#!/bin/bash
#Info: Install or Update MasterNode Daemons, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#TODO: to run you need to use ./Install.sh from MasterNodes folder.

sudo apt-get install -y build-essential libtool autotools-dev autoconf pkg-config libssl-dev
sudo apt-get install -y libboost-all-dev
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get -y update
sudo apt-get install -y libdb4.8-dev libdb4.8++-dev
sudo apt-get install -y libminiupnpc-dev

./menu_dextrocore.sh
