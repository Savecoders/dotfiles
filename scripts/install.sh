#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e
# Enable a debug trace (useful for debugging, can be commented out for production)
# set -x

# Get the directory where the script is located, and change to it.
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${BASEDIR}" || { echo "Error: Could not change to script directory. Exiting."; exit 1; }

# Function to ask the user for confirmation before executing a command or function.
ask_user() {
    local message=$1
    local func_to_call=$2 # Now takes a function name

    while true; do
        read -r -p "${message} [Y/n] " input

        case $(echo "$input" | tr '[:upper:]' '[:lower:]') in # Convert input to lowercase for robust comparison
            y|yes)
                echo "Okay, executing command!"
                # Check if the function exists before calling
                if type -t "$func_to_call" | grep -q 'function'; then
                    "$func_to_call"
                else
                    echo "Error: Function '$func_to_call' not found. Skipping."
                fi
                break
                ;;
            n|no)
                echo "Okay, skipping!"
                break
                ;;
            *)
                echo "Invalid input... Please enter Y or n."
                ;;
        esac
    done
}

# Generic function to clone a git repository.
# It handles cleaning up the cloned directory if needed.
clone_repo_temp() {
    local repo_url=$1
    local temp_dir_name=$(basename "$repo_url" .git) # Extract name from URL

    echo "Cloning ${repo_url} into temporary directory: ${temp_dir_name}..."
    if ! git clone "${repo_url}" "${temp_dir_name}"; then
        echo "Error: Failed to clone ${repo_url}. Exiting."
        exit 1
    fi
    echo "Cloning complete."
}

# Function to copy contents and then clean up the source if it was temporary.
copy_and_cleanup() {
    local source_path=$1
    local dest_path=$2
    local remove_source=$3 # true/false to remove the source directory after copy

    echo "Copying ${source_path} to ${dest_path}..."
    mkdir -p "${dest_path}" || { echo "Error: Could not create destination directory ${dest_path}. Exiting."; exit 1; }
    if ! cp -r "${source_path}" "${dest_path}"; then
        echo "Error: Failed to copy ${source_path} to ${dest_path}. Exiting."
        exit 1
    fi
    echo "Copy complete."

    if [[ "$remove_source" == "true" ]]; then
        echo "Cleaning up temporary source directory: ${source_path}"
        rm -rf "${source_path}"
    fi
}

# --- Specific Installation/Configuration Functions ---

install_git_submodules() {
    echo "Installing Git submodules..."
    # For layout-machi
    clone_repo_temp https://github.com/xinhaoyuan/layout-machi.git
    copy_and_cleanup layout-machi/* ../config/awesome/modules/layout-machi/ true

    # For bling
    clone_repo_temp https://github.com/BlingCorp/bling.git
    copy_and_cleanup bling/* ../config/awesome/modules/bling/ true

    # For simpleTheme-zsh-theme
    clone_repo_temp https://github.com/Savecoders/simpleTheme-zsh-theme.git
    copy_and_cleanup simpleTheme-zsh-theme/* ../misc/zsh/simpleTheme-zsh-theme/ true
    echo "Git submodule installation complete."
}

install_paru() {
    echo "Installing paru AUR helper..."
    echo "This requires sudo password."
    if ! sudo pacman -S --needed base-devel; then
        echo "Error: Failed to install base-devel. Exiting."
        exit 1
    fi

    clone_repo_temp https://aur.archlinux.org/paru.git
    (cd paru && makepkg -si) || { echo "Error: Failed to build and install paru. Exiting."; exit 1; }
    rm -rf paru
    echo "paru installation complete."
}

install_packages_from_list() {
    local package_list="${BASEDIR}/needed.list"
    if [[ ! -f "$package_list" ]]; then
        echo "Error: Package list file not found at ${package_list}. Skipping package installation."
        return 1
    fi
    echo "Installing packages from ${package_list} using paru..."
    # Ensure paru is installed before trying to use it
    if ! command -v paru &> /dev/null; then
        echo "Error: 'paru' command not found. Please install paru first. Skipping package installation."
        return 1
    fi
    paru -S --noconfirm --needed - <"${package_list}" || { echo "Error: Failed to install packages from ${package_list}."; return 1; }
    echo "Package installation complete."
}

install_zsh_ohmyzsh() {
    echo "Installing Zsh and Oh My Zsh..."
    if ! command -v zsh &> /dev/null; then
        echo "Zsh is not installed. Installing Zsh first..."
        # Using pacman for Zsh, assuming Arch Linux
        sudo pacman -S --noconfirm --needed zsh || { echo "Error: Failed to install zsh. Exiting."; exit 1; }
    fi

    # Check if Oh My Zsh is already installed
    if [[ -d "${HOME}/.oh-my-zsh" ]]; then
        echo "Oh My Zsh is already installed. Skipping re-installation."
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" || { echo "Error: Failed to install Oh My Zsh. Exiting."; exit 1; }
    fi
    echo "Zsh and Oh My Zsh installation complete."
}

# --- Main Script Execution ---

# Ask for Git submodule installation
ask_user "Are you getting errors when installing git submodules? (This will re-clone and copy them)" "install_git_submodules"

# Ask for paru installation
ask_user "Do you want to install paru (AUR helper)?" "install_paru"

# Ask for package installation from needed.list
ask_user "Do you want to install all packages from needed.list? (Requires paru)" "install_packages_from_list"

# Ask for Zsh and Oh My Zsh installation
ask_user "Do you want to install zsh and ohmyzsh?" "install_zsh_ohmyzsh"

echo "--- Post-installation Configuration ---"

# Enable and start MPD service (requires sudo)
echo "Enabling and starting mpd.service..."
sudo systemctl enable mpd.service || echo "Warning: Failed to enable mpd.service. Check logs."
sudo systemctl start mpd.service || echo "Warning: Failed to start mpd.service. Check logs."
echo "MPD service configured."

# Copy config files
echo "Copying config files to ~/.config/..."
mkdir -p "${HOME}/.config/" || { echo "Error: Could not create ~/.config/. Exiting."; exit 1; }
cp -r "${BASEDIR}/../config/"* "${HOME}/.config/" || { echo "Error: Failed to copy config files. Exiting."; exit 1; }
echo "Config files copied."

# Copy misc resources
echo "Copying misc Zsh resources..."
mkdir -p "${HOME}/.oh-my-zsh/themes/" || { echo "Error: Could not create ~/.oh-my-zsh/themes/. Exiting."; exit 1; }
cp -r "${BASEDIR}/../misc/zsh/Savior-zsh-theme/"* "${HOME}/.oh-my-zsh/themes/" || { echo "Error: Failed to copy Savior-zsh-theme. Exiting."; exit 1; }
cp "${BASEDIR}/../misc/zsh/.zshrc" "${HOME}/.zshrc" || { echo "Error: Failed to copy .zshrc. Exiting."; exit 1; }
echo "Misc Zsh resources copied."

# Fonts
echo "Copying fonts..."
mkdir -p "${HOME}/.local/share/fonts/" || { echo "Error: Could not create ~/.local/share/fonts/. Exiting."; exit 1; }
cp -r "${BASEDIR}/../misc/fonts/"* "${HOME}/.local/share/fonts/" || { echo "Error: Failed to copy fonts. Exiting."; exit 1; }
# Refresh font cache after copying fonts
fc-cache -fv || echo "Warning: Failed to refresh font cache."
echo "Fonts copied and cache refreshed."

# Wallpapers
echo "Copying Wallpapers..."
mkdir -p "${HOME}/Pictures/Wallpapers" || { echo "Error: Could not create ~/Pictures/Wallpapers. Exiting."; exit 1; }
cp -r "${BASEDIR}/../misc/wallpapers/"* "${HOME}/Pictures/Wallpapers" || { echo "Error: Failed to copy wallpapers. Exiting."; exit 1; }
echo "Wallpapers copied."

# icons
echo "Untarring and copying icons..."
mkdir -p "${HOME}/.icons" || { echo "Error: Could not create ~/.icons. Exiting."; exit 1; }

# Function to extract and copy icons
extract_and_copy_icons() {
    local tar_file=$1
    local extract_dir="${BASEDIR}/../misc/icons/extracted_temp" # Temporary extraction dir

    echo "Extracting ${tar_file}..."
    mkdir -p "${extract_dir}" || { echo "Error: Could not create temporary extraction directory. Exiting."; return 1; }
    if [[ "$tar_file" == *.zip ]]; then
        unzip -q "${BASEDIR}/../misc/icons/${tar_file}" -d "${extract_dir}" || { echo "Error: Failed to unzip ${tar_file}."; return 1; }
    elif [[ "$tar_file" == *.tar.xz || "$tar_file" == *.tar ]]; then
        tar -xvf "${BASEDIR}/../misc/icons/${tar_file}" -C "${extract_dir}" || { echo "Error: Failed to untar ${tar_file}."; return 1; }
    else
        echo "Error: Unrecognized archive format for ${tar_file}. Skipping."
        return 1
    fi

    # Find the top-level directory inside the extracted content
    local top_level_dir
    # This assumes the archive extracts into a single top-level directory (e.g., 'Tela')
    top_level_dir=$(find "${extract_dir}" -maxdepth 1 -mindepth 1 -type d -print -quit)

    if [[ -n "$top_level_dir" ]]; then
        echo "Copying extracted content from ${top_level_dir} to ${HOME}/.icons/..."
        cp -r "${top_level_dir}" "${HOME}/.icons/" || { echo "Error: Failed to copy extracted icons to ~/.icons/."; return 1; }
    else
        echo "Warning: Could not find a single top-level directory in ${extract_dir}. Copying all contents directly."
        cp -r "${extract_dir}"/* "${HOME}/.icons/" || { echo "Error: Failed to copy extracted icons to ~/.icons/."; return 1; }
    fi

    echo "Cleaning up temporary extraction directory: ${extract_dir}"
    rm -rf "${extract_dir}"
    echo "Finished processing ${tar_file}."
}

# Call the function for each icon archive
extract_and_copy_icons "01-Tela.tar.xz"
extract_and_copy_icons "01-WhiteSur.tar.xz"
extract_and_copy_icons "Mkos-Big-Sur.tar.tar.xz"

echo "All icons processed."

# GTK themes
echo "Untarring and copying GTK themes..."
mkdir -p "${HOME}/.themes" || { echo "Error: Could not create ~/.themes. Exiting."; exit 1; }

# Function to extract and copy themes
extract_and_copy_themes() {
    local archive_file=$1
    local extract_dir="${BASEDIR}/../misc/themes/extracted_temp" # Temporary extraction dir

    echo "Extracting ${archive_file}..."
    mkdir -p "${extract_dir}" || { echo "Error: Could not create temporary extraction directory. Exiting."; return 1; }

    local full_archive_path="${BASEDIR}/../misc/themes/${archive_file}"

    if [[ ! -f "$full_archive_path" ]]; then
        echo "Error: Theme archive not found: ${full_archive_path}. Skipping."
        return 1
    fi

    if [[ "$archive_file" == *.zip ]]; then
        unzip -q "$full_archive_path" -d "${extract_dir}" || { echo "Error: Failed to unzip ${archive_file}."; return 1; }
    elif [[ "$archive_file" == *.tar.xz || "$archive_file" == *.tar ]]; then
        tar -xvf "$full_archive_path" -C "${extract_dir}" || { echo "Error: Failed to untar ${archive_file}."; return 1; }
    else
        echo "Error: Unrecognized archive format for ${archive_file}. Skipping."
        return 1
    fi

    # Find the top-level directory inside the extracted content
    local top_level_dir
    top_level_dir=$(find "${extract_dir}" -maxdepth 1 -mindepth 1 -type d -print -quit)

    if [[ -n "$top_level_dir" ]]; then
        echo "Copying extracted content from ${top_level_dir} to ${HOME}/.themes/..."
        cp -r "${top_level_dir}" "${HOME}/.themes/" || { echo "Error: Failed to copy extracted theme to ~/.themes/."; return 1; }
    else
        echo "Warning: Could not find a single top-level directory in ${extract_dir}. Copying all contents directly."
        cp -r "${extract_dir}"/* "${HOME}/.themes/" || { echo "Error: Failed to copy extracted theme to ~/.themes/."; return 1; }
    fi

    echo "Cleaning up temporary extraction directory: ${extract_dir}"
    rm -rf "${extract_dir}"
    echo "Finished processing ${archive_file}."
}

# Call the function for each GTK theme archive
extract_and_copy_themes "Colloid.tar.xz"
extract_and_copy_themes "WhiteSur-Dark-solid.tar.xz"
extract_and_copy_themes "Colloid-Everforest.tar.xz"
extract_and_copy_themes "Colloid-Nord.tar.xz"
extract_and_copy_themes "Gruvbox-Dark-BL-LB.zip"
extract_and_copy_themes "Colloid-Gruvbox.tar.xz"

echo "All GTK themes processed."
echo "--- Script execution complete ---"
