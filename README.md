<!-- inspired by rxyhn's and AlphaTechnolog readme -->

<img
 align="center"
 src=".github/assets/Awesome/grubox/bar_editor.png"
 alt="Rice Preview"
/>

<br>

<!-- BADGES -->
<h1>
  <a href="#">
    <img alt="" align="left" src="https://img.shields.io/github/stars/Savecoders/dotfiles?color=1D1F22&labelColor=FF9CAC&style=for-the-badge"/>
  </a>
  <a href="#">
    <img alt="" align="right" src="https://badges.pufler.dev/visits/Savecoders/dotfiles?style=for-the-badge&color=7ddac5&logoColor=white&labelColor=7ddac5"/>
  </a>
</h1>

<h2 align="center" style="font-weight:mediun; padding:30px;">💻 My dotfiles for rice AwesomeWM</h2>

to my dotfiles!
Here are some details about my setup

<!-- INFORMATION -->

## <samp>🧰 **Information** </samp>

Here are some details about my setup:

- **OS:** [Arch Linux](https://archlinux.org/)
- **WM:** [awesome](https://github.com/awesomeWM/awesome) (Not Soported) and [Hyprland](https://wiki.hypr.land)
- **Terminal:** [kitty](https://sw.kovidgoyal.net/kitty/)
- **Shell:** [zsh](https://www.zsh.org/)
- **Application Launcher:** [rofi](https://github.com/davatorium/rofi)
- **Compositor:** [picom](https://github.com/yshui/picom)
- **Editor:** [neovim](https://github.com/neovim/neovim) | [vscode](https://github.com/microsoft/vscode) || [zed](https://zed.dev/)
- **System Font:** [SF Pro Display](https://github.com/sahibjotsagguSan-Francisco-Pro-Fonts)

<!-- Install dependencies-->

## <samp>🎢 **installation** </samp>

<b><h3>🌀 Clone this repository</h3></b>

```sh
git clone --recurse-submodules https://github.com/Savecoders/dotfiles.git
cd dotfiles && git submodule update --remote --merge
```

<b><h3>📥 Use the script</h3></b>

```sh
chmod +x resources/install.sh && ./resources/install.sh
```

> [!WARNING]  
> ⚠ Critical content demanding immediate user attention due to potential risks.

<details close>
    <summary>
        <samp><b>⁉ Error clone submodules?</b></samp>
    </summary>

In this case you need clone the submodules with repositories and move folders

```sh
mkdir dev && cd dev && git clone https://github.com/Savecoders/dotfiles.git
git clone https://github.com/xinhaoyuan/layout-machi.git
git clone https://github.com/BlingCorp/bling.git
git clone https://github.com/Savecoders/simpleTheme-zsh-theme
cp -r layout-machi/* dotfiles/config/awesome/modules/layout-machi/
cp -r bling/* dotfiles/config/awesome/modules/bling/
cp -r simpleTheme-zsh-theme/* dotfiles/misc/zsh/simpleTheme-zsh-theme
```

</details>

> [!IMPORTANT]  
> Do you want to install manually? Please continue with the manual installation.

<details close>
    <summary>
        <samp><b>Installation Manual Dotfiles</b></samp>
    </summary>

<b><h3>Install Dependencies</h3></b>

```sh
paru -Sy awesome-git picom-git kitty rofi  acpi acpid acpi_call upower \
jq inotify-tools xdotool xclip gpick ffmpeg blueman zsh-autosuggestions \
pamixer brightnessctl scrot redshift rainfall zsh-syntax-highlighting \
feh mpv mpd mpc mpdris2 ncmpcpp playerctl qtile tunar zsh --needed
```

<b><h3>Enable Services</h3></b>

```sh
systemctl --user enable mpd.service
systemctl --user start mpd.service
```

<b><h3>Clone this repository</h3></b>

```sh
git clone https://github.com/Savecoders/dotfiles.git
cd dotfiles
```

<b><h3> Use config</h3></b>

```sh
cp -r config/* ~/.config/
cp -r misc/fonts/* ~/.local/share/fonts/
cp -r misc/oh-my-zsh ~/.oh-my-zsh
cp -r misc/.zshrc ~
```

<b><h3> Use others rxfetch</h3></b>

```sh
cd neofetch && chmod +x singfetch
sudo cp -r singfetch /usr/bin/
```

<b><h3> Install ohmyzsh</h3></b>

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

</details>

### 🔵 AwesomeWM

<!-- Dark theme -->

#### Dark Theme Mode

<div align="center">
   <a href="#--------">
      <img src=".github/assets/Awesome/dark/image.png" alt="Rice dark theme Preview">
   </a>
</div>

<div align="center">
   <a href="#--------">
      <img src=".github/assets/Awesome/dark/terminals.png" alt="Rice dark theme Preview">
   </a>
</div>

<div align="center">
   <a href="#--------">
      <img src=".github/assets/Awesome/dark/bar_editor.png" alt="Rice dark theme Preview">
   </a>
</div>

#### Grubox Theme Mode

<!-- gruvbox theme -->
<div align="center">
   <a href="#--------">
      <img src=".github/assets/Awesome/grubox/image.png" alt="Rice dark theme Preview">
   </a>
</div>

<div align="center">
   <a href="#--------">
      <img src=".github/assets/Awesome/grubox/terminals.png" alt="Rice dark theme Preview">
   </a>
</div>

<div align="center">
   <a href="#--------">
      <img src=".github/assets/Awesome/grubox/bar_editor.png" alt="Rice dark theme Preview">
   </a>
</div>

#### Light Theme Mode

<!-- light theme -->
<div align="center">
   <a href="#--------">
      <img src=".github/assets/Awesome/light/image.png" alt="Rice dark theme Preview">
   </a>
</div>

<div align="center">
   <a href="#--------">
      <img src=".github/assets/Awesome/light/terminals.png" alt="Rice dark theme Preview">
   </a>
</div>

<div align="center">
   <a href="#--------">
      <img src=".github/assets/Awesome/light/bar_editor.png" alt="Rice dark theme Preview">
   </a>
</div>

### 🟢 QTile

<div align="center">
   <a href="#--------">
      <img src=".github/assets/Qtile/rice_dark.png" alt="Rice dark theme Preview">
   </a>
</div>

## Special Thanks

The dotfiles is based in
and the other parts of code is the others devs :)

- [Rayhan's](https://github.com/rxyhn) [Dotfiles](https://github.com/rxyhn/AwesomeWM-Dotfiles)
- [ChocolateBread799](https://github.com/ChocolateBread799) [Dotfiles](https://github.com/ChocolateBread799/dotfiles)

<!-- information about -->
<details close>
    <summary>
        <samp><b>Quetions</b></samp>
    </summary>

<br>

- **Fonts and icons**
  - as for fonts, the setup uses 4 fonts in total
    - _[SF Pro Display](https://github.com/sahibjotsagguSan-Francisco-Pro-Fonts)_ - my main ui font
    - _[Font Awesome 6 Free](https://fontawesome.com/download)_ - for icons the weather
    - _[JetBrainsMono NF](https://www.jetbrains.com/es-es/lp/mono/)_ - icons of signals
    - _[Cascadia Code](https://github.com/microsoft/cascadia-code)_ - Editor/terminal
  - in the tag config, using images for icons, the images They're in `awesome/icons/tag/`

<br>

- **custom theme?**
  - for dark, edit `theme/dark/dark.lua`
  - for light, edit `theme/light/light.lua`
  - agg display theme selection `theme/selection_theme.lua`

<br>

- **wallpapers and profile**
  - by default wallpapers are found by theme - example: `theme.wallpaper = gfs.get_configuration_dir() .. "wallpapers/hands.jpg"` - in wallpapers folder add new wallpapers `awesome/wallpapers` - replace existing wallpapers with new ones in: `"wallpapers/new_walpapers.jpg"`
    <br>

</details>

<details close>
    <summary>
        <samp><b>Modules in aplication</b></samp>
    </summary>
<br>

- **[Bling](https://blingcorp.github.io/bling/)**
  - use in Playerctl widget, layout

- **[Rubato](https://github.com/andOrlando/rubato)**
  - Create animation for aweosmeWM

- **[Better resize](https://github.com/JavaCafe01/dotfiles/blob/master/config/awesome/module/better-resize.lua)**
  - An improved method of resizing clients in the tiled layout, and maded by [javacafe01](https://github.com/JavaCafe01)

</details>

<details open>
    <summary>
        <samp><b>Installation bugs</b></samp>
    </summary>

<br>

- Installing to submodules git layout-machi
  - clone the repo [layout-achi](https://github.com/xinhaoyuan/layout-machi)
  - copy the content and page in ~/.config/awesome/modules/layout-machi

</details>
