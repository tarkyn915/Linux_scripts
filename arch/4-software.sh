#!/usr/bin/env bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${GREEN}=== Setting up Base Audio, Terminal, Yay & Input Method ===${RESET}"
echo

# 1. 检查是否为普通用户运行
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}[ERROR] Do not run this script as root! Please run as your regular user.${RESET}"
    exit 1
fi

# 2. 移除 jack2，避免后续安装 pipewire-jack 时因交互确认被 abort
if pacman -Qq jack2 &>/dev/null; then
    echo -e "${YELLOW}==> Removing jack2 to allow pipewire-jack installation...${RESET}"
    sudo pacman -Rdd --noconfirm jack2
fi

# 3. 安装完整软件包列表（字体已在 3-desktop 阶段装好）
echo -e "${YELLOW}==> 1. Installing all packages...${RESET}"
sudo pacman -Syu --needed --noconfirm \
    yay \
    pipewire \
    wireplumber \
    pipewire-pulse \
    pipewire-alsa \
    pipewire-jack \
    pavucontrol \
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
    rime-ice \
    git \
    stow \
    firefox

# 4. 配置 Rime 官方推荐雾凇拼音补丁
echo -e "${YELLOW}==> 2. Configuring Rime default.custom.yaml...${RESET}"
RIME_DIR="$HOME/.local/share/fcitx5/rime"
mkdir -p "$RIME_DIR"

cat << 'EOF' > "$RIME_DIR/default.custom.yaml"
patch:
  __include: rime_ice_suggestion:/
  __patch:
    key_binder/bindings/+:
      - { when: paging, accept: comma, send: Page_Up }
      - { when: has_menu, accept: period, send: Page_Down }
EOF

# 5. 配置 Fcitx5 默认激活 Rime 方案
echo -e "${YELLOW}==> 3. Setting up fcitx5 profile...${RESET}"
FCITX5_CONFIG_DIR="$HOME/.config/fcitx5"
mkdir -p "$FCITX5_CONFIG_DIR"

cat << 'EOF' > "$FCITX5_CONFIG_DIR/profile"
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

# 6. 清理可能残留的输入法环境变量，保持系统原生行为
sudo sed -i '/GTK_IM_MODULE/d' /etc/environment 2>/dev/null || true
sudo sed -i '/QT_IM_MODULE/d' /etc/environment 2>/dev/null || true
sudo sed -i '/XMODIFIERS/d' /etc/environment 2>/dev/null || true

# 7. 重启 Fcitx5 触发雾凇拼音部署
echo -e "${YELLOW}==> 4. Deploying Rime schema...${RESET}"
killall fcitx5 2>/dev/null || true
fcitx5 -d >/dev/null 2>&1 || true

echo -e "${GREEN}=== All software and rime-ice setup complete! ===${RESET}"
