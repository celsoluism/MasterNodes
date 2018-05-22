
#!/bin/sh
#Info: Install or Update MasterNode Daemons, Masternode based on privkey.
#PerfilConectado.NET MasterNodes Installer
#TODO: to run you need to use ./Install.sh from MasterNodes folder.

HEIGHT=15
WIDTH=60
CHOICE_HEIGHT=6
BACKTITLE="Backtitle here"
TITLE="Updates need to compile local new version of that coin selected."
MENU="Choose one of the following options:"

OPTIONS=(1 "Check updates for OmegaCoin..."
         2 "Check update for DextroCore..."
         3 "Back to first menu"
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
            echo "Check and Update OmegaCoin"
            ./updates/menu_updates.sh
            ;;
        2)
            echo "Check and Update DextroCoin"
            ./install.sh
            ;;
        3)
            echo "Back to first menu"
            ./install.sh
            ;;
        4)
            echo "Quit"
            ;;
esac
