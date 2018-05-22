#!/bin/sh
#Info: Install or Update MasterNode Daemons, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#TODO: to run you need to use ./Install.sh from MasterNodes folder.

cd ~/.omegacoincore
sleep 2
rm *get_queue_position*
wget https://raw.githubusercontent.com/Natizyskunk/omegacoin/master/contrib/masternodes-tools/get_queue_position.sh
sleep 5
bash get_queue_position.sh $1
