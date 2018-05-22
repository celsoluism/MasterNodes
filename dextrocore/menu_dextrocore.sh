#!/bin/sh
#Info: Install or Update MasterNode Daemons, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#TODO: to run you need to use ./Install.sh from MasterNodes folder.

HEIGHT=15
WIDTH=60
CHOICE_HEIGHT=4
BACKTITLE="Created By PerfilConectado.NET"
TITLE="Masternode Installer And Update"
MENU="Choose one of the following options:"

OPTIONS=(1 "Install DextroCore Masternode"
         2 "Update DextroCore Masternode"
		 3 "Install Libraries and Dependences..."
         4 "Quit")

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
            echo "You select Install DextroCore..."
            ./dextrocore/install_dextrocore.sh
            ;;
		2)  
		    echo "You chose Update DextroCore MasterNode..."
		    ./dextrocore/update_dextrocore.sh
		    ;;
        3)
            echo "You select to Install Libraries and Dependences..."
            ./dependences/install_dependences.sh
            ;;
        4)
            echo "You chose Quit!"
            echo "Access https://PerfilConectado.NET"
            echo "Thankyou!"
            ;;
esac


