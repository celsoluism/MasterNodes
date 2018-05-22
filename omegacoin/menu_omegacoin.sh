#!/bin/bash
#Info: Install or Update MasterNode Daemons, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#TODO: to run you need to use ./Install.sh from MasterNodes folder.

HEIGHT=15
WIDTH=60
CHOICE_HEIGHT=4
BACKTITLE="Created By PerfilConectado.NET"
TITLE="Masternode Installer And Update"
MENU="Choose one of the following options:"

OPTIONS=(1 "Install Clean OmegaCoin"
         2 "Update OmegaCoin"
		 3 "Install Dependeces"
         4 "Back to firs menu"
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
            echo "Install Clean OmegaCoin"
            ./omegacoin/install_clean_omegacoin.sh
            ;;
        2)
            echo "Update OmegaCoin"
            ./omegacoin/update_omegacoin.sh
            ;;
		3)  
		    echo "Install Dependences"
			./omegacoin/install_dependences_omegacoin.sh
			;;
        4)  
            echo "You chose backup to first menu"
            ./install.sh
            ;;
        5)  
            echo "You chose Quit!"
            echo "Access https://PerfilConectado.NET"
            echo "Thankyou!"
            ;;
esac

