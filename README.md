### Debian-Based

```
sudo apt install awesome fonts-roboto rofi i3lock xclip qt5-style-plugins materia-gtk-theme lxappearance  xfce4-power-manager pnmixer network-manager-applet -y
wget -qO- https://git.io/papirus-icon-theme-install | sh
```

*Note: compton is used instead of picom*

#### Arch-Based

```
yay -S awesome rofi i3lock-fancy xclip ttf-roboto materia-gtk-theme lxappearance pnmixer xfce4-power-manager -y
wget -qO- https://git.io/papirus-icon-theme-install | sh
```

### Clone the configuration

```
git clone https://github.com/bloc67/material-awesome.git ~/.config/awesome
```

### Set the themes

Start `lxappearance` to active the **icon** theme and **GTK** theme
Note: for cursor theme, edit `~/.icons/default/index.theme` and `~/.config/gtk3-0/settings.ini`, for the change to also show up in applications run as root, copy the 2 files over to their respective place in `/root`.

### 4) Same theme for Qt/KDE applications and GTK applications, and fix missing indicators

First install `qt5-style-plugins` (debian) | `qt5-styleplugins` (arch) and add this to the bottom of your `/etc/environment`

```bash
XDG_CURRENT_DESKTOP=Unity
QT_QPA_PLATFORMTHEME=gtk2
```

The first variable fixes most indicators (especially electron based ones!), the second tells Qt and KDE applications to use your gtk2 theme set through lxappearance.


