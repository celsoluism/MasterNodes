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

OPTIONS=(1 "Install StannumCore Masternode"
         2 "Update StannumCore MasterNode"
         3 "Install Libraries and Dependences..."
	 4 "Testing New Installer (PLEASE DONT USE!)"
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
            echo "You select Install StannumCore..."
            ./stannumcore/stannumcore_install.sh
            ;;
        2)  echo "You chose Update StannumCore"
	    ./stannumcore/stannumcore_update.sh
	    ;;
	3)
            echo "You select to Install Libraries and Dependences..."
            ./stannumcore/stannumcore_dependences.sh
            ;;
	4)
            echo "PLEASE CANCEL..."
	    sleep 5s
            ./stannumcore/stannumcore_install_new.sh
            ;;
        5)
            echo "You chose Quit!"
            echo "Access https://PerfilConectado.NET"
            echo "Thankyou!"
            ;;
esac


