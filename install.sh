
#!/bin/bash
#Version 0.0.1.6
#Info: Installs MasterNode Coins Daemons, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#Tested OS: 16.04
#TODO: make script less "ubuntu" or add other linux flavors
#TODO: dont run as root and run withou sudo privilegies.
#TODO: if prompted need to enter password of sudo user.

chmod +x rebase.sh
cp -f rebase.sh ~

HEIGHT=15
WIDTH=60
CHOICE_HEIGHT=4
BACKTITLE="Created By PerfilConectado.NET"
TITLE="Masternode Installer And Update"
MENU="Choose one of the following options:"

OPTIONS=(1 "OmegaCoin"
         2 "DextroCore..."
		 3 "StannumCoin"
         4 "Install Libraries and Dependences..."
         5 "Quit")

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
            echo "You chose OmegaCoin..."
            ./omegacoin/omegacoin_menu.sh
            ;;
        2)
            echo "You chose DextroCore..."
            ./dextrocore/dextrocore_menu.sh
            ;;
        3)  
		     echo "You chose StannumCoin..."
            ./stannumcore/stannumcore_menu.sh
            ;;
        4)
            echo "You chose Install Libraries and Dependences"
			./dependences/install_dependences.sh
		    ;;
		5)
            echo "You chose Quit!"
            echo "Access https://PerfilConectado.NET"
            echo "Thankyou!"
            ;;
esac
