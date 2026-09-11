#!/bin/bash
set -e

# 终端样式颜色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${GREEN}=== Installing Niri + DankMaterialShell (Desktop Only) ===${RESET}"

# 1. 仅安装合成器、XWayland、Portal、DMS 外壳及图形登录管理器
echo -e "${YELLOW}Installing compositor, shell, portals, and display manager...${RESET}"
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
    qt6-declarative \
    qt6-svg \
    sddm

# 2. 复制并初始化 Niri 配置文件，屏蔽默认的 Waybar
echo -e "${YELLOW}Configuring Niri config.kdl...${RESET}"
mkdir -p "$HOME/.config/niri"

CONFIG_PATH="$HOME/.config/niri/config.kdl"
if [ ! -f "$CONFIG_PATH" ]; then
    if [ -f "/usr/share/doc/niri/config.kdl" ]; then
        cp /usr/share/doc/niri/config.kdl "$CONFIG_PATH"
        echo "Copied default config.kdl template."
    else
        echo -e "${RED}[WARNING] Template /usr/share/doc/niri/config.kdl not found.${RESET}"
    fi
fi

# 如果配置中包含 waybar 自启项，将其注释掉（避免与 DMS 顶栏冲突）
if [ -f "$CONFIG_PATH" ]; then
    sed -i 's|spawn-at-startup "waybar"|// spawn-at-startup "waybar"|g' "$CONFIG_PATH"
fi

# 3. 将 DMS 绑定到 niri.service，使其随桌面环境启动
echo -e "${YELLOW}Binding DMS shell service to niri.service...${RESET}"
if systemctl --user list-unit-files | grep -q "dms"; then
    systemctl --user add-wants niri.service dms.service || true
fi

# 4. 启用 SDDM 显示管理器
echo -e "${YELLOW}Enabling SDDM display manager...${RESET}"
sudo systemctl enable sddm.service

echo
echo -e "${GREEN}=== Niri Desktop Setup Completed! ===${RESET}"
echo "Next step: Run 4-software.sh to set up audio (PipeWire), fonts, terminal, and apps."
