echo "OmegaCoin MasterNode Installer!"
echo 
echo "By PerfilConectado.NET"

cd OmegaCoin
mkdir ~/_masternodes
mkdir ~/_masternodes/omegacoin
cp * ~/_masternodes/omegacoin
cd ~/_masternodes/omegacoin
chmod +x *
unzip *.zip
chmod +x *

sudo cp * /usr/local/bin

omegacoind -daemon

echo "WAIT 1 MINUTE!"
sleep 65

omegacoin-cli stop

clear
echo "OmegaCoin Masternode Installed!"
echo "To Complete all configures Check:"
echo "PerfilConectado.net/MasterNodes/OmegaCoin"
