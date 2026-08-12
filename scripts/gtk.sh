#!/usr/bin/env bash

set -e

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${BASEDIR}" || {
  echo "Error: Could not change to script directory. Exiting."
  exit 1
}

# GTK themes
echo "Untarring and copying GTK themes..."
mkdir -p "${HOME}/.local/share/themes" || {
  echo "Error: Could not create ~/.local/share/themes. Exiting."
  exit 1
}

# Function to extract and copy themes
extract_and_copy_themes() {
  local archive_file=$1
  local extract_dir="${BASEDIR}/../assets/themes/extracted_temp" # Temporary extraction dir

  echo "Extracting ${archive_file}..."
  mkdir -p "${extract_dir}" || {
    echo "Error: Could not create temporary extraction directory. Exiting."
    return 1
  }

  local full_archive_path="${BASEDIR}/../assets/themes/${archive_file}"

  if [[ ! -f "$full_archive_path" ]]; then
    echo "Error: Theme archive not found: ${full_archive_path}. Skipping."
    return 1
  fi

  if [[ "$archive_file" == *.zip ]]; then
    unzip -q "$full_archive_path" -d "${extract_dir}" || {
      echo "Error: Failed to unzip ${archive_file}."
      return 1
    }
  elif [[ "$archive_file" == *.tar.xz || "$archive_file" == *.tar ]]; then
    tar -xvf "$full_archive_path" -C "${extract_dir}" || {
      echo "Error: Failed to untar ${archive_file}."
      return 1
    }
  else
    echo "Error: Unrecognized archive format for ${archive_file}. Skipping."
    return 1
  fi

  # Find the top-level directory inside the extracted content
  local top_level_dir
  top_level_dir=$(find "${extract_dir}" -maxdepth 1 -mindepth 1 -type d -print -quit)

  if [[ -n "$top_level_dir" ]]; then
    echo "Copying extracted content from ${top_level_dir} to ${HOME}/.local/share/themes/..."
    cp -r "${top_level_dir}" "${HOME}/.local/share/themes/" || {
      echo "Error: Failed to copy extracted theme to ~/.local/share/themes/."
      return 1
    }
  else
    echo "Warning: Could not find a single top-level directory in ${extract_dir}. Copying all contents directly."
    cp -r "${extract_dir}"/* "${HOME}/.local/share/themes/" || {
      echo "Error: Failed to copy extracted theme to ~/.local/share/themes/."
      return 1
    }
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
extract_and_copy_themes "adw-gtk3.tar.xz"

# Configure adw-gtk3 GTK4 integration for Matugen colors.css
setup_adw_gtk3_matugen() {
  local target_local="${HOME}/.local/share/themes"
  mkdir -p "$target_local" "${HOME}/.config/gtk-4.0"

  local adw_dir="${target_local}/adw-gtk3/gtk-4.0"

  if [[ -d "$adw_dir" ]]; then
    echo "Configuring Matugen colors.css integration for adw-gtk3 in $adw_dir..."
    touch "$HOME/.config/gtk-4.0/colors.css"
    ln -sf "$HOME/.config/gtk-4.0/colors.css" "$adw_dir/colors.css"

    for css_file in "$adw_dir/gtk.css" "$adw_dir/gtk-dark.css"; do
      if [[ -f "$css_file" ]] && ! grep -q 'colors.css' "$css_file"; then
        echo '@import url("colors.css");' >> "$css_file"
      fi
    done

    ln -sf "$adw_dir/gtk.css" "$HOME/.config/gtk-4.0/gtk.css"
    ln -sf "$adw_dir/gtk-dark.css" "$HOME/.config/gtk-4.0/gtk-dark.css"
    ln -sf "$adw_dir/assets" "$HOME/.config/gtk-4.0/assets"
    ln -sf "$adw_dir/libadwaita.css" "$HOME/.config/gtk-4.0/libadwaita.css"
    ln -sf "$adw_dir/libadwaita-tweaks.css" "$HOME/.config/gtk-4.0/libadwaita-tweaks.css"
  fi
}

setup_adw_gtk3_matugen

echo "All GTK themes processed."
echo "--- Script execution complete ---"
