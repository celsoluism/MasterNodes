
#!/bin/bash
#Info: Installs MasterNode Coins Daemons much automated possible, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#Tested OS: 16.04
#TODO: make script less "ubuntu" or add other linux flavors
#TODO: dont run as root and run withou sudo privilegies.
#TODO: if prompted need to enter password of sudo user.
VERSION=v0.0.2.7

chmod +x rebase.sh
cp -f rebase.sh ~

#SET COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

HEIGHT=20
WIDTH=60
CHOICE_HEIGHT=6
BACKTITLE="Created By PerfilConectado.NET - $VERSION "
TITLE="Masternode Installer And Update"
MENU="Choose one of the following options:"

OPTIONS=(1 "Brofist"
         2 "OmegaCoin"
         3 "DextroCore..."
	 4 "StannumCoin"
         5 "Install Libraries and Dependences..."
         6 "Quit")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear

case $CHOICE in
        1) 
	    echo "You chose Brofist"
	    ./brofist/brofist_menu.sh
	    ;;	
        2)
            echo "You chose OmegaCoin..."
            ./omegacoin/omegacoin_menu.sh
            ;;
        3)
            echo "You chose DextroCore..."
            ./dextrocore/dextrocore_menu.sh
            ;;
        4)  
		     echo "You chose StannumCoin..."
            ./stannumcore/stannumcore_menu.sh
            ;;
        5)
            echo "You chose Install Libraries and Dependences"
            ./dependences/install_dependences.sh
	    ;;
	6)
            echo "You chose Quit!"
            echo "Access https://PerfilConectado.NET"
            echo "Thankyou!"
            ;;
esac
