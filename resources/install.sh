#!/usr/bin/env bash

set -e

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${BASEDIR}"

ask_user() {
    local message=$1
    local command=$2

    while true; do
        read -r -p "${message} [Y/n] " input

        case $input in
            [yY][eE][sS]|[yY])
                echo "Okay, executing command!"
                eval "${command}"
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
}

clone_and_copy() {
    local repo=$1
    local source_dir=$2
    local dest_dir=$3

    git clone "${repo}"
    cp -r "${source_dir}" "${dest_dir}"
}

install_packages() {
    local package_list=$1

    paru -S --noconfirm - < "${package_list}" --needed
}

ask_user "are you getting errors when installing git submodules?" "
    clone_and_copy https://github.com/xinhaoyuan/layout-machi.git layout-machi/* ../config/awesome/modules/layout-machi/
    clone_and_copy https://github.com/BlingCorp/bling.git bling/* ../config/awesome/modules/bling/
    clone_and_copy https://github.com/Savecoders/simpleTheme-zsh-theme simpleTheme-zsh-theme/* ../misc/zsh/simpleTheme-zsh-theme
"

ask_user "Do you want to install paru?" "
    sudo pacman -S --needed base-devel
    clone_and_copy https://aur.archlinux.org/paru.git paru
    cd paru
    makepkg -si
    cd ..
    rm -rf paru
"

ask_user "Do you want to install all packages from needed.list?" "
    install_packages ${BASEDIR}/needed.list
"

ask_user "Do you want to install zsh and ohmyzsh?" "
    sh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\"
"

# enable services
systemctl enable mpd.service
systemctl start mpd.service

# copy config files
echo "Copying config files..."
cp -r ../config/* ~/.config/

# copy misc resources
echo "Copying misc resources..."
cp -r ../misc/zsh/Savior-zsh-theme/* ~/.oh-my-zsh/themes/
cp -r ../misc/zsh/.zshrc ~

# Fonts
echo "Copying fonts..."
mkdir ~/.local/share/fonts/
cp -r ../misc/fonts/* ~/.local/share/fonts/

# lightdm
# cp -r ~/Dev/MyConfig/dotfiles/config/lightdm/* /usr/share/lightdm-webkit/themes/

# Wallpapers
echo "Copying Wallpapers..."
mkdir -p ~/Pictures/Wallpapers && cp -r ../misc/wallpapers/* ~/Pictures/Wallpapers

# icons
echo "Untarring icons..."
tar -xvf ../misc/icons/01-Tela.tar.xz -C ../misc/icons/
tar -xvf ../misc/icons/01-WhiteSur.tar.xz -C ../misc/icons/
tar -xvf ../misc/icons/Mkos-Big-Sur.tar.tar.xz -C ../misc/icons/
echo "Copying icons..."
mkdir -p ~/.icons && cp -r ../misc/icons/* ~/.icons

# GTK themes
echo "Untarring GTK themes..."
tar -xvf ../misc/themes/Colloid.tar.xz -C ../misc/themes/
tar -xvf ../misc/themes/WhiteSur-Dark-solid.tar -C ../misc/themes/
unzip ../misc/themes/Gruvbox-Dark-BL-LB.zip -d ../misc/themes/
echo "Copying GTK themes..."
mkdir -p ~/.themes && cp -r ../misc/themes/* ~/.themes
