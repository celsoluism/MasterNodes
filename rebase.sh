#!/bin/bash
#Info: Install or Update MasterNode Daemons most automated possible, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#TODO: to run you need to use ./rebase.sh .

#SET COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function dependences() {
cd ~
echo -q "${GREE}If prompted enter password to install dependences ${NC}"
sudo rm -rvf temp_masternodes >/dev/null 2>&1
sudo rm -rvf MasterNodes >/dev/null 2>&1
sudo apt install -y dialog  >/dev/null 2>&1
}

function run_installer() {
cd ~
git clone -q https://github.com/celsoluism/MasterNodes.git 
cd MasterNodes
chmod -R +x *
clear
./install.sh 
}

dependences
run_installer
