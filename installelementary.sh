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
trap 'abort' 0;
chrootparta() {
    echo "ENTERED CHROOT";
    echo "Updating apt-get";
    sudo apt-get update;
    echo "Installing required packages to begin installation";
    sudo apt-get install -y python-software-properties software-properties-common;
    echo "Adding ElementaryOS repos";
    sudo add-apt-repository -y ppa:elementary-os/stable;
    sudo add-apt-repository -y ppa:elementary-os/os-patches;
    echo "Updating apt-get";
    sudo apt-get update;
    echo "Installing elementary-desktop (this might take a while)...";
    sudo apt-get install -y elementary-desktop;
    sudo apt-get install -y gtk2-engines-pixbuf;
    echo "Done installing elementary-desktop.";
    echo "EXITING CHROOT";
    exit;
}

chrootpartb() {
    echo "ENTERED CHROOT";
    cd /usr/bin;
    echo "copying startxfce script"
    sudo cp startxfce4 startelementary;
    n=10;
    echo "deleting $n lines from startelementary"
    sudo sed -i "1,$n{d}" startelementary;
    echo "adding xinit_pantheon starter"
    echo "exec $prog /usr/bin/xinit_pantheon" | sudo tee -a startelementary > /dev/null/;
    echo "creating xinit_pantheon script";
    sudo touch xinit_pantheon;
    echo "#!/bin/sh" | sudo tee -a startelementary > /dev/null/;
    echo '/usr/sbin/lightdm-session "gnome-session –session=pantheon"' | sudo tee -a startelementary > /dev/null/;
    sudo chmod +x xinit_pantheon;
    sudo chown root:root xinit_pantheon;
    echo "EXITING CHROOT";
    exit;
}

crosh() {
    pause "Is the crouton installer in your downloads folder? (If no, exit using ctrl+c and fix, else press enter)";
    pause "Is this script (name unchanged) in your downloads folder? (If no, exit using ctrl+c and fix, else press enter)";
    #crosh part 1
    echo "Creating chroot... (make sure that crouton is located in ~/Downloads/crouton)";
    sudo sh ~/Downloads/crouton -t xfce,keyboard,extension -n elementary;
    echo "Chroot created. Entering chroot.";
    sudo enter-chroot -n elementary -u root sh ~/Downloads/installelementary.sh a #switch to chroot
    #crosh part 2
    sudo cp /usr/local/bin/startxfce4 /usr/local/bin/startelementary;
    cd /usr/local/bin/;
    sed -i '$d' startelementary;
    echo "exec startelementary" >> startelementary;
    sudo enter-chroot -n elementary -u root sh ~/Downloads/installelementary.sh b #reenter chroot
    echo "Setup done."
    pause "Press enter to launch ElementaryOS!";
    echo "Launching...";
    sudo startelementary;
    echo "ElementaryOS setup script terminating."
}

if [ "$1" = "a" ]
then chrootparta
elif [ "$1" = "b" ]
then chrootpartb
else crosh
fi

trap : 0