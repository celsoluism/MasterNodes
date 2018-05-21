
#!/bin/bash
#Version 0.0.1.3
#Info: Installs MasterNode Coins Daemons, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#Tested OS: 16.04
#TODO: make script less "ubuntu" or add other linux flavors

HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="Created By PerfilConectado.NET"
TITLE="Masternode Installer And Update"
MENU="Choose one of the following options:"

OPTIONS=(1 "Install Masternodes from zero..."
         2 "Check and Update Masternodes..."
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
            echo "You select Install Masternodes from zero..."
            ./install_clean.sh
            ;;
        2)
            echo "You select Check and Update Masternodes..."
            ./install_updates.sh
            ;;

        3)  
            ./dependences/install_dependences.sh
            ;;
        4)
            echo "You chose Quit!"
            echo "Access https://PerfilConectado.NET"
            echo "Thankyou!"
            ;;
esac
