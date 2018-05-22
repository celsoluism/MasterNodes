#!/bin/sh
#Info: Install or Update MasterNode Daemons, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#TODO: to run you need to use ./Install.sh from MasterNodes folder.

echo "PREPARING TO INSTALL LIBRARIES!"
echo "TO CONTINUE ONLY WAIT TO START..."
echo "TO CANCEL PRESS CTRL+C."
sleep 10

mkdir prepare_libs_temp
cp prepare_libs.sh ~

sudo apt-get -y update
sudo apt-get -y install build-essential libtool autotools-dev automake pkg-config libssl-dev libevent-dev bsdmainutils
sudo apt-get -y install libboost-all-dev
sudo apt-get -y install libqrencode-dev
sudo apt-get -y install build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool ncurses-dev unzip git python python-zmq zlib1g-dev wget bsdmainutils automake libboost-all-dev libssl-dev libprotobuf-dev protobuf-compiler libqt4-dev libqrencode-dev libdb++-dev ntp ntpdate vim software-properties-common curl libcurl4-gnutls-dev cmake clang
sudo apt-get -y install libqt5gui5 libqt5core5a libqt5dbus5 qttools5-dev qttools5-dev-tools libprotobuf-dev protobuf-compiler
sudo apt-get -y install g++-4.9
sudo apt-get -y install python-software-properties software-properties-common
sudo apt-get -y install python-dev python-devel
sudo apt-get -y install php-dev
sudo apt-get -y install libminiupnpc-dev
sudo apt-get -y install libcurl4-openssl-dev
sudo apt-get -y install bjam
sudo add-apt-repository -y ppa:bitcoin/bitcoin
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install libdb4.8-dev libdb4.8++-dev
sudo apt-get -y install libevent-dev
sudo apt-get -y install libdb5.3++
sudo apt-get -y install libkrb5-dev
curl -sL https://deb.nodesource.com/setup | sudo bash -
sudo apt-get -y install nodejs
sudo apt-get -y install git pyqt4-dev-tools python-pip python-dev python-slowaes
sudo pip install pyasn1 pyasn1-modules pbkdf2 tlslite qrcode

echo "deb http://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-stable/Debian_9.0/ ./" >> /etc/apt/sources.list
cd ~
mkdir prepare_libs_temp/libzmq3
cd prepare_libs_temp/libzmq3
wget https://download.opensuse.org/repositories/network:/messaging:/zeromq:/release-stable/Debian_9.0/Release.key -O- | sudo apt-key add
sudo apt-get -y install libzmq3-dev
sudo apt-get install -y libminiupnpc-dev libzmq3-dev libevent-pthreads-2.0-5

sudo aptitude install -y liblas-c3
export LD_LIBRARY_PATH=/usr/local/lib



clear
echo "LIBRARIES INSTALLED!"
echo "IF ONE DONT WORK TRY TO INSTALL ./prepare_lib.sh MORE ONE TIME!"
echo
echo
echo "ACCESS: HTTPS://PERFILCONECTADO.NET"

bash install.sh
