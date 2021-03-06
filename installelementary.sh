#!/bin/bash
echo "~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-";
echo "Welcome to the ElementaryOS automated installer script V13, by Aaron Becker.";
echo "This script will install ElementaryOS, Xfce and Kde desktop environments on your chromebook running crouton.";
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
    printf "${YELLOW}ENTERED CHROOT${NC}\n";
    printf "${YELLOW}Updating apt-get and adding additional repos...${NC}\n";
    sudo add-apt-repository https://download.01.org/gfx/ubuntu/14.04/main
    wget --no-check-certificate https://download.01.org/gfx/RPM-GPG-KEY-ilg -O - | sudo apt-key add -
    wget --no-check-certificate https://download.01.org/gfx/RPM-GPG-KEY-ilg-2 -O - | sudo apt-key add -
    sudo apt-get update;
    printf "${YELLOW}Installing required packages to begin installation${NC}\n";
    sudo apt-get install -y python-software-properties software-properties-common;
    printf "${YELLOW}Adding ElementaryOS repos${NC}\n";
    sudo add-apt-repository -y ppa:elementary-os/stable;
    sudo add-apt-repository -y ppa:elementary-os/os-patches;
    sudo add-apt-repository -y ppa:versable/elementary-update;
    printf "${YELLOW}Adding graphics driver patch repos...${NC}\n";
    sudo add-apt-repository -y https://download.01.org/gfx/ubuntu/16.04/main;
    printf "${YELLOW}Adding more driver patch repos...${NC}\n";
    wget –no-check-certificate https://download.01.org/gfx/RPM-GPG-KEY-ilg -O – | sudo apt-key add –
    wget –no-check-certificate https://download.01.org/gfx/RPM-GPG-KEY-ilg-2 -O – | sudo apt-key add –
    printf "${YELLOW}Updating apt-get${NC}\n";
    sudo apt-get update;
    printf "${YELLOW}Installing elementary-desktop (this might take a while)...${NC}\n";
    sudo apt-get install -y --allow-unauthenticated elementary-desktop;
    sudo apt-get install -y --allow-unauthenticated gtk2-engines-pixbuf;
    sudo apt-get install -y --allow-unauthenticated elementary-tweaks;
    sudo apt-get install -y xserver-xorg-lts-raring;
    sudo apt-get install -y python-software-properties ttf-ubuntu-font-family ubuntu-settings;
    printf "${YELLOW}Installing extra small programs (this might take a while)...${NC}\n";
    sudo apt-get install -y unace p7zip-rar sharutils rar unrar arj lunzip lzip nano uget hardinfo libavcodec-extra ttf-mscorefonts-installer;
    sudo apt-get install -y ttf-ubuntu-font-family;
    sudo apt-get install -y software-center;
    printf "${YELLOW}Installing graphics driver patches...${NC}\n";
    sudo apt-get install -y --install-recommends linux-generic-lts-quantal xserver-xorg-lts-quantal libgl1-mesa-glx-lts-quantal;
    sudo apt-get install -y mesa-utils;
    sudo apt-get upgrade;
    printf "${YELLOW}Appling distribution update...${NC}\n";
    sudo apt-get -y dist-upgrade;
    printf "${YELLOW}Intel graphics info${NC}";
    glxinfo | grep "OpenGL version" || printf "${RED}Error displaying graphics version: There might be a problem with the installation${NC}\n";
    sudo apt-get install -y curl;

    printf "${YELLOW}Done installing elementary-desktop.${NC}\n";
    printf "${YELLOW}EXITING CHROOT${NC}\n";
    exit;
}

chrootpartb() {
    printf "${YELLOW}ENTERED CHROOT${NC}\n";
    cd /usr/bin;
    printf "${YELLOW}copying startxfce script${NC}\n"
    sudo cp startxfce4 startelementary;
    printf "${YELLOW}replacing line with proper reference to xinit_pantheon${NC}\n"
    sudo sed -i 's/\/etc\/xdg\/xfce4\/xinitrc $CLIENTRC $SERVERRC/\/usr\/bin\/xinit_pantheon/' startelementary;
    printf "${YELLOW}adding xinit_pantheon starter${NC}\n"
    sudo touch xinit_pantheon;
    echo "#!/bin/sh" | sudo tee -a xinit_pantheon;
    echo '/usr/sbin/lightdm-session "gnome-session --session=pantheon"' | sudo tee -a xinit_pantheon;
    printf "${YELLOW}Changing permissions for starters...${NC}\n"
    sudo chmod +x xinit_pantheon;
    sudo chown root:root xinit_pantheon;
    printf "${YELLOW}Changing a few important settings...${NC}\n"
    sudo apt-get purge -y gnome-keyring;
    sudo apt-get install -y kwin;
    printf "${YELLOW}Installing git...${NC}\n"
    sudo apt-get install -y git;
     printf "${YELLOW}Installing nodejs...${NC}\n"
    sudo apt-get install -y curl;
    curl — silent — location https://deb.nodesource.com/setup_0.12 | sudo bash -
    sudo apt-get install -y nodejs;
    npm config set prefix '~/.npm-packages'
    echo 'export PATH="$PATH:$HOME/.npm-packages/bin"' >> ~/.bashrc
    printf "${YELLOW}Installing sublime-text3...${NC}\n"
    sudo apt-get install -y software-properties-common python-software-properties;
    sudo add-apt-repository ppa:webupd8team/sublime-text-3 -y;
    sudo apt-get update -y;
    sudo apt-get install -y sublime-text-installer;
    sudo apt-get install -y nautilus;
    printf "${YELLOW}Installing apache server...${NC}\n"
    printf "${GREEN}To use, cd into directory and type 'php -S localhost:8000'. To use MYSQL, type 'sudo /usr/sbin/mysqld' ${NC}\n"
    sudo apt-get install -y apache2;
    sudo apt-get install -y mysql-server libapache2-mod-auth-mysql php5-mysql
    sudo mysql_install_db
    sudo add-apt-repository -y ppa:ondrej/php5
    sudo apt-get -y update
    sudo apt-get install -y php5 php5-mhash php5-mcrypt php5-curl php5-cli php5-mysql php5-gd php5-intl php5-xsl;
    printf "${YELLOW}Installing more developer software...${NC}\n"
    sudo apt-get install -y unzip gimp imagemagick filezilla build-essential;
    printf "${YELLOW}Installing Steam...${NC}"
    wget http://media.steampowered.com/client/installer/steam.deb;
    sudo apt-get install -y gdebi-core;
    sudo gdebi steam.deb;
    printf "${YELLOW}EXITING CHROOT${NC}\n";
    exit;
}

crosh() {
    #crosh part 1
    (cd ~/Downloads/ && echo "CD command ran successfully") || ( (cd /home/chronos/user/Downloads/ && echo "Warning: Backup CD command run") || echo "Error: Couldn't CD into downloads directory."; exit 1;)
    echo -e "${BLUE}Grabbing latest version of crouton installer...${NC}";
    (sudo rm ~/Downloads/crouton; echo "Deleted previous version of crouton installer") || (sudo rm /home/chronos/user/Downloads/crouton; echo "Deleted previous version of crouton installer with WARNING: Backup command")
    sudo wget -O ~/Downloads/crouton https://goo.gl/fd3zc || (sudo wget -O /home/chronos/user/Downloads/crouton https://goo.gl/fd3zc && echo "Warning: Backup command for downloading crouton run";)
    echo -e "${BLUE}Creating chroot named 'elementary'...${NC}";
    sudo sh crouton -t kde,xfce,keyboard,extension -n elementary || (sudo sh /home/chronos/user/Downloads/crouton -t kde,xfce,keyboard,extension -n elementary && echo "Warning: Backup command for making chroot run");
    echo -e "${BLUE}Chroot created. Entering chroot.${NC}";
    sudo enter-chroot -n elementary -u root sh ~/Downloads/installelementary.sh a #switch to chroot
    echo -e "${BLUE}Outside of chroot. Continuing installation.${NC}";
    #crosh part 2
    echo -e "${BLUE}Copying start scripts (chroot side)${NC}";
    sudo cp /usr/local/bin/startxfce4 /usr/local/bin/startelementary;
    cd /usr/local/bin/;
    echo -e "${BLUE}Adding references to internal startup scripts${NC}";
    sudo sed -i 's/startxfce4/startelementary/' startelementary;
    sudo sed -i 's/startxfce4/startcinnamon/' startcinnamon;
    echo -e "${BLUE}Reentering chroot.${NC}";
    sudo enter-chroot -n elementary -u root sh ~/Downloads/installelementary.sh b #reenter chroot
    echo -e "${GREEN}Setup done successfully.\n~-~-~-~-~-~-~-~-\n${BLUE}If you want to start Linux Mint, type:\n${LIGHTPURPLE}sudo startcinnamon\n${BLUE}If you want to start ElementaryOS, type:\n${LIGHTPURPLE}sudo startelementary${GREEN}\n~-~-~-~-~-~-~-~-${NC}"
    
    pause "Press enter to launch ElementaryOS!";
    echo "Launching...";
    sudo startelementary;
    echo -e "${GREEN}ElementaryOS setup script terminating. Hope it worked ;)${NC}"
}

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
LIGHTPURPLE='\033[1;35m'
NC='\033[0m' # No Color

if [ "$1" = "a" ]
then chrootparta
elif [ "$1" = "b" ]
then chrootpartb
else crosh
fi
