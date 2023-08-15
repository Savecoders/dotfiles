#!/usr/bin/env bash

set -e


BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${BASEDIR}"

while true
do
      read -r -p "are you getting errors when installing git submodules? [Y/n] " input

      case $input in
            [yY][eE][sS]|[yY])
                  echo "Okay, I install them for you!"
                  git clone https://github.com/xinhaoyuan/layout-machi.git
                  git clone https://github.com/BlingCorp/bling.git
                  git clone https://github.com/Savecoders/simpleTheme-zsh-theme
                  
                  cp -r layout-machi/* ../config/awesome/modules/layout-machi/
                  cp -r bling/* ../config/awesome/modules/bling/
                  cp -r simpleTheme-zsh-theme/* ../misc/zsh/simpleTheme-zsh-theme

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
                  paru -S --noconfirm - < ${BASEDIR}/needed.list --needed
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

while true
do
      read -r -p "Do you want to install zsh and ohmyzsh? [Y/n] " input

      case $input in
            [yY][eE][sS]|[yY])
                  echo Installing!
                  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
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
systemctl enable mpd.service
systemctl start mpd.service

# copy config files
echo "Copying config files..."
cp -r ../config/* ~/.config/

# copy misc resources
echo "Copying misc resources..."
cp -r ../misc/zsh/simpleTheme-zsh-theme/* ~/.oh-my-zsh/themes/
cp -r ../misc/zsh/.zshrc ~

# Fonts
echo "Copying fonts..."
cp -r ../misc/fonts/* ~/.local/share/fonts/

# lightdm
cp -r ~/Dev/MyConfig/dotfiles/config/lightdm/* /usr/share/lightdm-webkit/themes/

# Wallpapers
echo "Copying Wallpapers..."
mkdir -p ~/Pictures/Wallpapers && cp -r ../misc/wallpapers/* ~/Pictures/Wallpapers