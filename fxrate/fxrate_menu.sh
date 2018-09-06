#!/bin/bash
#Info: Install or Update MasterNode Daemons, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#TODO: to run you need to use ./Install.sh from MasterNodes folder.
VERSION=$(cat "changelog.md" | grep -n ^ | grep ^1: | cut -d: -f2)

COIN_NAME="FXRate"
INSTALLFILE=./fxrate/fxrate_install.sh
UPDATEFILE=./fxrate/fxrate_update.sh
DEPENDENCEFILE=./fxrate/fxrate_dependences.sh

HEIGHT=15
WIDTH=60
CHOICE_HEIGHT=4
BACKTITLE="Created By PerfilConectado.NET - $VERSION "
TITLE="Masternode Installer And Update"
MENU="Choose one of the following options:"

OPTIONS=(1 "Install $COIN_NAME MasterNode..."
         2 "Update $COIN_NAME MasterNode..."
	 3 "Install Pack of Libraries and Dependences..."
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
            echo "You select Install $COIN_NAME..."
            $INSTALLFILE
            ;;
        2)
            echo "You chose Update $COIN_NAME MasterNode..."
            $UPDATEFILE
            ;;
	3)  
	    echo "You select to Install a pack of Libraries and Dependences..."
	    $DEPENDENCEFILE
            ;;
        4)
            echo "You chose Quit!"
            echo "Access https://PerfilConectado.NET"
            echo "Thankyou!"
            ;;
esac
