#!/bin/bash
echo "~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-";
echo "Welcome to the ElementaryOS automated installer script V1, by Aaron Becker.";
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
    echo "ENTERED CHROOT";
    echo "Updating apt-get";
    sudo apt-get update;
    echo "Installing required packages to begin installation";
    sudo apt-get install -y python-software-properties software-properties-common;
    echo "Adding ElementaryOS repos";
    sudo add-apt-repository -y ppa:elementary-os/stable;
    sudo add-apt-repository -y ppa:elementary-os/os-patches;
    sudo add-apt-repository -y ppa:versable/elementary-update;
    echo "Adding graphics driver patch repos...";
    sudo add-apt-repository -y https://download.01.org/gfx/ubuntu/16.04/main;
    echo "Adding more driver patch repos...";
    wget –no-check-certificate https://download.01.org/gfx/RPM-GPG-KEY-ilg -O – | sudo apt-key add –
    wget –no-check-certificate https://download.01.org/gfx/RPM-GPG-KEY-ilg-2 -O – | sudo apt-key add –
    echo "Updating apt-get";
    sudo apt-get update;
    echo "Installing elementary-desktop (this might take a while)...";
    sudo apt-get install -y elementary-desktop;
    sudo apt-get install -y gtk2-engines-pixbuf;
    sudo apt-get install -y elementary-tweaks;
    sudo apt-get install -y xserver-xorg-lts-raring;
    echo "Installing graphics driver patches...";
    sudo apt-get install -y --install-recommends linux-generic-lts-quantal xserver-xorg-lts-quantal libgl1-mesa-glx-lts-quantal;
    sudo apt-get install mesa-utils;
    sudo apt-get upgrade;
    echo "Appling distribution update...";
    sudo apt-get -y dist-upgrade;
    echo "Intel graphics info";
    glxinfo | grep "OpenGL version" || echo "error with graphics";
    sudo apt-get install curl;

    echo "Done installing elementary-desktop.";
    echo "EXITING CHROOT";
    exit;
}

chrootpartb() {
    echo "ENTERED CHROOT";
    cd /usr/bin;
    echo "copying startxfce script"
    sudo cp startxfce4 startelementary;
    echo "replacing line with proper reference to xinit_pantheon"
    sudo sed -i 's/\/etc\/xdg\/xfce4\/xinitrc $CLIENTRC $SERVERRC/\/usr\/bin\/xinit_pantheon/' startelementary;
    echo "adding xinit_pantheon starter"
    sudo touch xinit_pantheon;
    echo "#!/bin/sh" | sudo tee -a xinit_pantheon;
    echo '/usr/sbin/lightdm-session "gnome-session --session=pantheon"' | sudo tee -a xinit_pantheon;
    sudo chmod +x xinit_pantheon;
    sudo chown root:root xinit_pantheon;
    echo "EXITING CHROOT";
    exit;
}

crosh() {
    pause "Is this script (name unchanged) in your downloads folder? (If no, exit using ctrl+c and fix, else press enter)";
    #crosh part 1
    echo "Grabbing latest version of crouton installer...";
    sudo wget -O ~/Downloads/crouton https://goo.gl/fd3zc;
    echo "Creating chroot... (make sure that crouton is located in ~/Downloads/crouton)";
    (cd ~/Downloads/ && echo "Cd command ran successfully") || (cd /home/chronos/user/Downloads/ && echo "backup cd command run") || echo "Couldn't CD into downloads directory."; exit 1;
    sudo sh crouton -t xfce,keyboard,extension -n elementary;
    echo "Chroot created. Entering chroot.";
    sudo enter-chroot -n elementary -u root sh ~/Downloads/installelementary.sh a #switch to chroot
    echo "Outside of chroot. Continuing installation.";
    #crosh part 2
    sudo cp /usr/local/bin/startxfce4 /usr/local/bin/startelementary;
    cd /usr/local/bin/;
    sudo sed -i 's/startxfce4/startelementary/' startelementary;
    sudo enter-chroot -n elementary -u root sh ~/Downloads/installelementary.sh b #reenter chroot
    echo "Setup done."
    pause "Press enter to launch ElementaryOS!";
    echo "Launching...";
    sudo startelementary;
    echo "ElementaryOS setup script terminating. Hope it worked ;)"
}

if [ "$1" = "a" ]
then chrootparta
elif [ "$1" = "b" ]
then chrootpartb
else crosh
fi