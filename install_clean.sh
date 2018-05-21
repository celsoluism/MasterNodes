
#!/bin/sh
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

OPTIONS=(1 "Install OmegaCoin"
         2 "Install DextroCore"
         3 "Back to firs menu"
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
            echo "Install OmegaCoin"
            ./omegacoin/menu_install_clean_omegacoin.sh
            ;;
        2)
            echo "Install DextroCore"
            ./dextrocore/menu_install_clean_dextro.sh
            ;;
        3)  
            echo "You chose backup to first menu"
            ./install.sh
            ;;
        3)  
            echo "You chose Quit!"
            echo "Access https://PerfilConectado.NET"
            echo "Thankyou!"
            ;;
esac

