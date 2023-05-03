#!/usr/bin/env bash

set -e


BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${BASEDIR}"


while true
do
      read -r -p "Do you want to install paru? [Y/n] " input
 
      case $input in
            [yY][eE][sS]|[yY])
                  echo Installing!
		  sudo pacman -S --needed base-devel
		  git clone https://aur.archlinux.org/paru.git
		  cd paru
		  makepkg -si
		  cd ..
  		  rm -rf paru
                  break
                  ;;
            [nN][oO]|[nN])
                  echo "No Problem."
                  break
                  ;;
            *)
                  echo "Invalid input..."
                  ;;
      esac      
done

while true
do
      read -r -p "Do you want to install all packages from needed.list? [Y/n] " input

      case $input in
            [yY][eE][sS]|[yY])
                  echo Installing!
                  paru -Syu --needed --noconfirm - < ${BASEDIR}/needed.list
                  break
                  ;;
            [nN][oO]|[nN])
                  echo "Okay!"
                  break
                  ;;
            *)
                  echo "Invalid input..."
                  ;;
      esac
done

# enable services
systemctl --user enable mpd.service
systemctl --user start mpd.service

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended 

# copy config files
cp -r config/* ~/.config/
cp -r misc/fonts/* ~/.local/share/fonts/
cp -r misc/oh-my-zsh ~/.oh-my-zsh
cp -r misc/.zshrc ~

# Wallpapers
mkdir -p ~/Wallpapers && cp -r misc/wallpapers/* ~/Wallpapers