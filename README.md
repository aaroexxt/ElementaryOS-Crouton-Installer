# ElementaryOS-Crouton-Installer
Automatically installs ElementaryOS onto a chromebook with crouton.

Installation - Crosh (On Chromebook)
Press Ctrl+Alt+T to launch crosh.
Type in shell and press enter (your chromebook needs to be in developer mode)
Paste:
```
echo "Downloading installer..."; sudo rm ~/Downloads/installelementary.sh && echo "Deleted previous installer version" || echo "No previous installer file found"; sudo curl -o ~/Downloads/installelementary.sh https://raw.githubusercontent.com/aaroexxt/ElementaryOS-Crouton-Installer/master/installelementary.sh; echo "Running installer..."; sudo bash ~/Downloads/installelementary.sh;
```
