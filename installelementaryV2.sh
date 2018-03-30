#!/bin/bash
echo "~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-";
echo "Welcome to the ElementaryOS automated installer script V9, by Aaron Becker.";
echo "This script will install ElementaryOS on your chromebook running crouton.";
echo "~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-";

abort()
{
    echo >&2 '
***************
*** ABORTED ***
***************
'
    echo "An error occurred :( Exiting..." >&2
    exit 1;
}

pause(){
   read -p "$*"
}

if [[ $(id -u) -ne 0 ]]
  then echo "Sorry, but it appears that you didn't run this script as root. Please run it as a root user!";
  exit 1;
fi
chrootparta() {
    echo -e "${YELLOW}ENTERED CHROOT${NC}";
    echo -e "${YELLOW}Updating apt-get${NC}";
    sudo apt-get update;
    echo -e "${YELLOW}Installing required packages to begin installation${NC}";
    sudo apt-get install -y python-software-properties software-properties-common;
    echo -e "${YELLOW}Adding ElementaryOS repos${NC}";
    sudo add-apt-repository -y ppa:elementary-os/stable;
    sudo add-apt-repository -y ppa:elementary-os/os-patches;
    sudo add-apt-repository -y ppa:versable/elementary-update;
    echo -e "${YELLOW}Adding graphics driver patch repos...${NC}";
    sudo add-apt-repository -y https://download.01.org/gfx/ubuntu/16.04/main;
    echo -e "${YELLOW}Adding more driver patch repos...${NC}";
    wget –no-check-certificate https://download.01.org/gfx/RPM-GPG-KEY-ilg -O – | sudo apt-key add –
    wget –no-check-certificate https://download.01.org/gfx/RPM-GPG-KEY-ilg-2 -O – | sudo apt-key add –
    echo -e "${YELLOW}Updating apt-get${NC}";
    sudo apt-get update;
    echo -e "${YELLOW}Installing elementary-desktop (this might take a while)...${NC}";
    sudo apt-get install -y elementary-desktop;
    sudo apt-get install -y gtk2-engines-pixbuf;
    sudo apt-get install -y elementary-tweaks;
    sudo apt-get install -y xserver-xorg-lts-raring;
    echo -e "${YELLOW}Installing graphics driver patches...${NC}";
    sudo apt-get install -y --install-recommends linux-generic-lts-quantal xserver-xorg-lts-quantal libgl1-mesa-glx-lts-quantal;
    sudo apt-get install mesa-utils;
    sudo apt-get upgrade;
    echo -e "${YELLOW}Appling distribution update...${NC}";
    sudo apt-get -y dist-upgrade;
    echo -e "${YELLOW}Intel graphics info${NC}";
    glxinfo | grep "OpenGL version" || echo -e "${RED}Error displaying graphics version: There might be a problem with the installation${NC}";
    sudo apt-get install curl;

    echo -e "${YELLOW}Done installing elementary-desktop.${NC}";
    echo -e "${YELLOW}EXITING CHROOT${NC}";
    exit;
}

chrootpartb() {
    echo -e "${YELLOW}ENTERED CHROOT${NC}";
    cd /usr/bin;
    echo -e "${YELLOW}copying startxfce script${NC}"
    sudo cp startxfce4 startelementary;
    echo -e "${YELLOW}replacing line with proper reference to xinit_pantheon${NC}"
    sudo sed -i 's/\/etc\/xdg\/xfce4\/xinitrc $CLIENTRC $SERVERRC/\/usr\/bin\/xinit_pantheon/' startelementary;
    echo -e "${YELLOW}adding xinit_pantheon starter${NC}"
    sudo touch xinit_pantheon;
    echo "#!/bin/sh" | sudo tee -a xinit_pantheon;
    echo '/usr/sbin/lightdm-session "gnome-session --session=pantheon"' | sudo tee -a xinit_pantheon;
    sudo chmod +x xinit_pantheon;
    sudo chown root:root xinit_pantheon;
    echo -e "${YELLOW}EXITING CHROOT${NC}";
    exit;
}

crosh() {
    pause "Is this script (name unchanged) in your downloads folder? (If no, exit using ctrl+c and fix, else press enter)";
    #crosh part 1
    (cd ~/Downloads/ && echo "CD command ran successfully") || ( (cd /home/chronos/user/Downloads/ && echo "Backup CD command run") || echo "Error: Couldn't CD into downloads directory."; exit 1;)
    echo -e "${BLUE}Grabbing latest version of crouton installer...${NC}";
    sudo wget -O crouton https://goo.gl/fd3zc;
    echo -e "${BLUE}Creating chroot... (make sure that crouton is located in ~/Downloads/crouton)${NC}";
    sudo sh crouton -t xfce,keyboard,extension -n elementary;
    echo -e "${BLUE}Chroot created. Entering chroot.${NC}";
    sudo enter-chroot -n elementary -u root sh ~/Downloads/installelementary.sh a #switch to chroot
    echo -e "${BLUE}Outside of chroot. Continuing installation.${NC}";
    #crosh part 2
    sudo cp /usr/local/bin/startxfce4 /usr/local/bin/startelementary;
    cd /usr/local/bin/;
    sudo sed -i 's/startxfce4/startelementary/' startelementary;
    sudo enter-chroot -n elementary -u root sh ~/Downloads/installelementary.sh b #reenter chroot
    echo -e "${GREEN}Setup done successfully.${NC}"
    pause "Press enter to launch ElementaryOS!";
    echo "Launching...";
    sudo startelementary;
    echo -e "${GREEN}ElementaryOS setup script terminating. Hope it worked ;)${NC}"
}

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

if [ "$1" = "a" ]
then chrootparta
elif [ "$1" = "b" ]
then chrootpartb
else crosh
fi