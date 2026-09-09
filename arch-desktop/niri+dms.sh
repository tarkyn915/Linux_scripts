#!bin/bash

# 1. 按照官网推荐安装全部包
sudo pacman -Syu --needed --noconfirm \
    niri \
    xwayland-satellite \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-gtk \
    alacritty \
    dms-shell-niri \
    matugen \
    cava \
    qt6-multimedia-ffmpeg \
	gdm

# 2. 复制默认配置并屏蔽与 DMS 冲突的 Waybar
mkdir -p ~/.config/niri
[ ! -f ~/.config/niri/config.kdl ] && cp /usr/share/doc/niri/config.kdl ~/.config/niri/config.kdl
sed -i 's/spawn-at-startup "waybar"/\/\/ spawn-at-startup "waybar"/' ~/.config/niri/config.kdl

# 3. 官网推荐方式：绑定 systemd 用户服务自动托管 DMS
systemctl --user add-wants niri.service dms

# 4. 启用 GDM 图形登录管理器
sudo systemctl enable gdm.service