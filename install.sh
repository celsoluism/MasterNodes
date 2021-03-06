
#!/bin/bash
#Info: Installs MasterNode Coins Daemons much automated possible, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#Tested OS: 16.04
#TODO: make script less "ubuntu" or add other linux flavors
#TODO: dont run as root and run withou sudo privilegies.
#TODO: if prompted need to enter password of sudo user.
VERSION=$(cat "changelog.md" | grep -n ^ | grep ^1: | cut -d: -f2)

chmod +x rebase.sh
cp -f rebase.sh ~

#SET COLORS
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

HEIGHT=20
WIDTH=60
CHOICE_HEIGHT=10
BACKTITLE="Created By PerfilConectado.NET - $VERSION "
TITLE="Masternode Installer And Update"
MENU="Choose one of the following options:"

OPTIONS=( 1 "Apeiron"
         2 "Brofist"
         3 "DextroCore"
         4 "DynamoPay..."
	 5 "FXRate"
	 6 "OmegaCoin"
	 7 "Essence"
	 8 "StannumCoin"
	 9 "QuixCoin"
	 10 "Chronon"
         11 "Install Libraries and Dependences..."
         0 "Quit")
 
CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear

case $CHOICE in
	1) echo "You chose Apeiron"
	   ./apeiron/apeiron_menu.sh
	   ;;
	
	2) 
	    echo "You chose Brofist"
	    ./brofist/brofist_menu.sh
	    ;;	
        3)
	    echo "You chose DextroCore..."
            ./dextrocore/dextrocore_menu.sh
            ;;
        4)  
	    echo "You chose DynamoPay..."
            ./dynamopay/dynocore_menu.sh
            ;;
	5)    
	    echo "You chose FXRate..."
            ./fxrate/fxrate_menu.sh
            ;;
	6)    
	    echo "You chose OmegaCoin..."
            ./omegacoin/omegacoin_menu.sh
            ;;
        7)  
	    echo "You chose Essence Coin..."
            ./essence/essence_menu.sh
            ;;
        8)  
	    echo "You chose StannumCoin..."
            ./stannumcore/stannumcore_menu.sh
            ;;
        9)
            echo "You chose QuixCoin"
            ./quix/quix_install.sh
	    ;;
	10) 
	    echo "You choise Chronon"
	    ./chronon/chronon_install.sh
	    ;;
 	11)
            echo "You chose Install Libraries and Dependences"
            ./dependences/install_dependences.sh
	    ;;
	0)
            echo "You chose Quit!"
            echo "Access https://PerfilConectado.NET"
            echo "Thankyou!"
            ;;
esac
