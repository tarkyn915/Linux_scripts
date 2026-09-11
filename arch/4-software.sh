#!/usr/bin/env bash
set -e

# 终端样式定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${GREEN}=== Setting up Base Audio, Fonts, Terminal, Yay & Input Method ===${RESET}"
echo

# 1. 检查运行权限（必须以非 root 普通用户运行）
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}[ERROR] Do not run this script as root! Please run as your regular user with sudo access.${RESET}"
    exit 1
fi

# 2. 安装通用底层、yay 与常用软件
echo -e "${YELLOW}Installing packages (yay, pipewire, fonts, terminal, fcitx5)...${RESET}"
sudo pacman -Syu --needed --noconfirm \
    yay \
    pipewire \
    wireplumber \
    pipewire-pulse \
    pipewire-alsa \
    pipewire-jack \
    pavucontrol \
    ttf-jetbrains-mono-nerd \
    noto-fonts-cjk \
    noto-fonts-emoji \
    wqy-microhei \
    alacritty \
    kitty \
    nautilus \
    gvfs \
    gvfs-mtp \
    file-roller \
    fcitx5 \
    fcitx5-gtk \
    fcitx5-qt \
    fcitx5-configtool \
    fcitx5-pinyin-zhwiki \
    fcitx5-chinese-addons \
    fcitx5-rime \
    rime-ice

# 3. 配置 yay 走清华大学 AUR 镜像源
echo -e "${YELLOW}Configuring yay AUR mirror...${RESET}"
yay --aururl "https://aur.tuna.tsinghua.edu.cn" --save

# 4. 启用 PipeWire 用户级音频服务
echo -e "${YELLOW}Enabling PipeWire audio user services...${RESET}"
systemctl --user enable --now pipewire.service wireplumber.service pipewire-pulse.service 2>/dev/null || true

# 5. 配置 Fcitx5 全局环境变量
echo -e "${YELLOW}Configuring Fcitx5 environment variables (/etc/environment)...${RESET}"
sudo tee -a /etc/environment > /dev/null << 'EOF'

# Fcitx5 Input Method Configuration
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus
EOF

# 6. 配置 Fcitx5 默认加载 Rime (雾凇拼音)
echo -e "${YELLOW}Initializing Fcitx5 user profile...${RESET}"
mkdir -p "$HOME/.config/fcitx5"
cat << 'EOF' > "$HOME/.config/fcitx5/profile"
[Groups/0]
Name=Default
Default Layout=us
DefaultIM=rime

[Groups/0/Items/0]
Name=keyboard-us
Layout=

[Groups/0/Items/1]
Name=rime
Layout=

[GroupOrder]
0=Default
EOF

# 7. 刷新系统字体缓存
echo -e "${YELLOW}Updating font cache...${RESET}"
fc-cache -fv > /dev/null

echo
echo -e "${GREEN}=== Software Setup Complete! ===${RESET}"
echo "Notes:"
echo "1. 'yay' is installed from archlinuxcn and configured with Tsinghua AUR mirror."
echo "2. Audio (PipeWire) user services are now running."
echo "3. Fcitx5 + rime-ice setup is ready. Log out or reboot to apply environment variables."
