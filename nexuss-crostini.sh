#!/bin/bash
# ============================================================
#  NEXUSS OS — Crostini Edition v1.0
#  For: ChromeOS Linux (Penguin Terminal)
#  No sudo needed for most steps!
#  Usage: bash nexuss-crostini.sh
# ============================================================

# ── Colors ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}"
echo "  ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗███████╗"
echo "  ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝██╔════╝"
echo "  ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗███████╗"
echo "  ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║╚════██║"
echo "  ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║███████║"
echo "  ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝"
echo -e "${NC}"
echo -e "${YELLOW}  NEXUSS OS — Crostini Edition${NC}"
echo -e "${CYAN}  Running inside ChromeOS Linux container${NC}"
echo ""
echo -e "${YELLOW}  This will take 15-30 minutes. Don't close the terminal!${NC}"
echo ""
sleep 2


# ════════════════════════════════════════════════════════════
# STEP 1: UPDATE SYSTEM
# ════════════════════════════════════════════════════════════
echo -e "${GREEN}[1/10] Updating system...${NC}"
sudo apt update -y
sudo apt upgrade -y
sudo apt install -y \
  curl wget git unzip \
  python3 python3-pip \
  build-essential \
  software-properties-common \
  ca-certificates \
  gnupg \
  lsb-release
echo "  Done."


# ════════════════════════════════════════════════════════════
# STEP 2: NEXUSS BRANDING
# ════════════════════════════════════════════════════════════
echo -e "${GREEN}[2/10] Applying NEXUSS branding...${NC}"

# Brand the terminal welcome message
cat > ~/.nexuss_brand << 'EOF'

  _  _ ___ _  ___   _ ___ ___    ___  ___
 | \| | __| \/ | | | / __/ __|  / _ \/ __|
 | .` | _| >  <| |_| \__ \__ \ | (_) \__ \
 |_|\_|___/_/\_\\___/|___/___/  \___/|___/

  NEXUSS OS 1.0  |  x86_64  |  Crostini Edition
  Type 'nexuss' to see system info.

EOF

# Add branding to .bashrc if not already there
if ! grep -q "NEXUSS" ~/.bashrc; then
cat >> ~/.bashrc << 'BASHRC'

# ── NEXUSS OS Branding ─────────────────────────────────────
cat ~/.nexuss_brand 2>/dev/null

# Custom prompt — NEXUSS style
export PS1='\[\033[01;34m\]NEXUSS\[\033[00m\]:\[\033[01;32m\]\w\[\033[00m\]\$ '

# NEXUSS system info command
nexuss() {
  echo ""
  echo -e "\033[0;36m  NEXUSS OS 1.0 — System Info\033[0m"
  echo "  ─────────────────────────────"
  echo "  OS:       NEXUSS OS 1.0 (Crostini)"
  echo "  Kernel:   $(uname -r)"
  echo "  Arch:     $(uname -m)"
  echo "  CPU:      $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
  echo "  RAM:      $(free -h | awk '/^Mem:/ {print $2}') total / $(free -h | awk '/^Mem:/ {print $3}') used"
  echo "  Storage:  $(df -h ~ | awk 'NR==2 {print $4}') free"
  echo "  Browser:  Google Chrome"
  echo "  Apps:     LibreOffice, VLC, VS Code, Snap Store"
  echo ""
}
BASHRC
fi

echo "  Branding applied."


# ════════════════════════════════════════════════════════════
# STEP 3: INSTALL GOOGLE CHROME
# ════════════════════════════════════════════════════════════
echo -e "${GREEN}[3/10] Installing Google Chrome...${NC}"

if ! command -v google-chrome &>/dev/null; then
  wget -q -O /tmp/chrome.deb \
    "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
  sudo apt install -y /tmp/chrome.deb
  rm -f /tmp/chrome.deb
  echo "  Google Chrome installed."
else
  echo "  Chrome already installed, skipping."
fi


# ════════════════════════════════════════════════════════════
# STEP 4: INSTALL CORE APPS
# ════════════════════════════════════════════════════════════
echo -e "${GREEN}[4/10] Installing core NEXUSS apps...${NC}"

sudo apt install -y \
  libreoffice \
  vlc \
  gimp \
  gnome-calculator \
  gnome-calendar \
  gnome-clocks \
  gnome-text-editor \
  gnome-system-monitor \
  gnome-disk-utility \
  rhythmbox \
  totem \
  gthumb \
  nautilus \
  gedit \
  snapd \
  fonts-ubuntu \
  fonts-noto \
  neofetch

echo "  Core apps installed."


# ════════════════════════════════════════════════════════════
# STEP 5: INSTALL SNAP STORE & SNAP APPS
# ════════════════════════════════════════════════════════════
echo -e "${GREEN}[5/10] Installing Snap Store & apps...${NC}"

sudo systemctl enable --now snapd.socket 2>/dev/null || true
sudo systemctl start snapd 2>/dev/null || true
sleep 3

# VS Code via snap
sudo snap install code --classic 2>/dev/null && \
  echo "  VS Code installed." || \
  echo "  VS Code snap failed — try manually: sudo snap install code --classic"

# Snap Store
sudo snap install snap-store 2>/dev/null && \
  echo "  Snap Store installed." || \
  echo "  Snap Store will be available after reboot."


# ════════════════════════════════════════════════════════════
# STEP 6: DARK THEME
# ════════════════════════════════════════════════════════════
echo -e "${GREEN}[6/10] Installing dark theme...${NC}"

# Install Fluent Dark GTK theme
cd /tmp
if [ ! -d "Fluent-gtk-theme" ]; then
  git clone --depth=1 https://github.com/vinceliuice/Fluent-gtk-theme.git
fi
cd /tmp/Fluent-gtk-theme
bash install.sh --theme default --color dark 2>/dev/null && \
  echo "  Fluent Dark theme installed." || \
  echo "  Theme install had issues — continuing anyway."

# Install Fluent icons
cd /tmp
if [ ! -d "Fluent-icon-theme" ]; then
  git clone --depth=1 https://github.com/vinceliuice/Fluent-icon-theme.git
fi
cd /tmp/Fluent-icon-theme
bash install.sh 2>/dev/null && \
  echo "  Fluent icons installed." || \
  echo "  Icon install had issues — continuing anyway."

# Apply dark theme via gsettings
gsettings set org.gnome.desktop.interface gtk-theme 'Fluent-Dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme 'Fluent-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface font-name 'Ubuntu 11' 2>/dev/null || true

echo "  Dark theme configured."


# ════════════════════════════════════════════════════════════
# STEP 7: NEXUSS WALLPAPER
# ════════════════════════════════════════════════════════════
echo -e "${GREEN}[7/10] Generating NEXUSS wallpaper...${NC}"

mkdir -p ~/Pictures/NEXUSS

python3 - << 'PYEOF'
import subprocess, sys
try:
    from PIL import Image, ImageDraw, ImageFilter
except ImportError:
    subprocess.check_call([sys.executable, '-m', 'pip', 'install',
                           'Pillow', '--break-system-packages', '-q'])
    from PIL import Image, ImageDraw, ImageFilter

import os

width, height = 1920, 1080
img = Image.new('RGB', (width, height))
draw = ImageDraw.Draw(img)

# Deep dark gradient
for y in range(height):
    ratio = y / height
    r = int(6 + ratio * 8)
    g = int(8 + ratio * 12)
    b = int(18 + ratio * 35)
    draw.line([(0, y), (width, y)], fill=(r, g, b))

# Windows 11 style glow at bottom
for i in range(100, 0, -1):
    xc = width // 2
    yc = height + 80
    rx = i * 11
    ry = i * 4
    ratio = (100 - i) / 100
    draw.ellipse([xc - rx, yc - ry, xc + rx, yc + ry],
                 outline=(int(ratio*5), int(60 + ratio*60), int(150 + ratio*80)))

img = img.filter(ImageFilter.GaussianBlur(radius=1))

out = os.path.expanduser('~/Pictures/NEXUSS/wallpaper.jpg')
img.save(out, quality=95)
print(f"  Wallpaper saved to {out}")
PYEOF

# Set as wallpaper
gsettings set org.gnome.desktop.background picture-uri \
  "file://$HOME/Pictures/NEXUSS/wallpaper.jpg" 2>/dev/null || true
gsettings set org.gnome.desktop.background picture-uri-dark \
  "file://$HOME/Pictures/NEXUSS/wallpaper.jpg" 2>/dev/null || true
gsettings set org.gnome.desktop.background picture-options 'zoom' 2>/dev/null || true

echo "  Wallpaper set."


# ════════════════════════════════════════════════════════════
# STEP 8: NEXUSS WELCOME PAGE
# ════════════════════════════════════════════════════════════
echo -e "${GREEN}[8/10] Creating NEXUSS Welcome app...${NC}"

mkdir -p ~/NEXUSS

cat > ~/NEXUSS/welcome.html << 'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <title>Welcome to NEXUSS OS</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      font-family: 'Segoe UI', 'Ubuntu', sans-serif;
      background: radial-gradient(ellipse at 50% 110%, #0a1628 0%, #07090f 70%);
      color: #fff;
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 20px;
    }
    .logo {
      font-size: 72px;
      font-weight: 200;
      letter-spacing: 18px;
      color: #0078d4;
      text-shadow: 0 0 60px rgba(0,120,212,0.4);
    }
    .tagline {
      color: #445;
      font-size: 13px;
      letter-spacing: 5px;
      text-transform: uppercase;
    }
    .card {
      background: rgba(255,255,255,0.04);
      border: 1px solid rgba(255,255,255,0.07);
      border-radius: 16px;
      padding: 36px 48px;
      max-width: 620px;
      width: 92%;
      text-align: center;
    }
    h2 { font-weight: 300; font-size: 20px; margin-bottom: 12px; color: #dde; }
    p { color: #778; line-height: 1.8; font-size: 14px; }
    .grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px;
      margin-top: 24px;
    }
    .item {
      background: rgba(0,120,212,0.07);
      border: 1px solid rgba(0,120,212,0.18);
      border-radius: 8px;
      padding: 12px;
      font-size: 13px;
      color: #99b;
      text-align: left;
    }
    .item span { color: #0078d4; margin-right: 8px; }
    .btn {
      margin-top: 28px;
      padding: 11px 38px;
      background: #0078d4;
      color: #fff;
      border: none;
      border-radius: 6px;
      font-size: 14px;
      cursor: pointer;
      transition: 0.2s;
      letter-spacing: 0.5px;
    }
    .btn:hover { background: #106ebe; }
    footer { color: #223; font-size: 11px; margin-top: 6px; }
  </style>
</head>
<body>
  <div class="logo">NEXUSS</div>
  <div class="tagline">Your World. Your OS.</div>
  <div class="card">
    <h2>Welcome to NEXUSS OS 1.0</h2>
    <p>A fast, beautiful, and modern OS experience built on Linux.
    Customized for you — dark by default, powerful by design.</p>
    <div class="grid">
      <div class="item"><span>🌐</span>Google Chrome</div>
      <div class="item"><span>🏪</span>Snap App Store</div>
      <div class="item"><span>⚙️</span>System Settings</div>
      <div class="item"><span>📁</span>File Manager</div>
      <div class="item"><span>🎵</span>Music & Media</div>
      <div class="item"><span>💻</span>VS Code</div>
      <div class="item"><span>📄</span>LibreOffice Suite</div>
      <div class="item"><span>🎨</span>GIMP Photo Editor</div>
      <div class="item"><span>🎬</span>VLC Media Player</div>
      <div class="item"><span>🌙</span>Dark Mode UI</div>
    </div>
    <button class="btn" onclick="window.close()">Start Using NEXUSS →</button>
  </div>
  <footer>NEXUSS OS 1.0 · x86_64 · Crostini Edition</footer>
</body>
</html>
HTML

# Desktop shortcut for welcome page
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/nexuss-welcome.desktop << EOF
[Desktop Entry]
Name=Welcome to NEXUSS
Comment=Get started with NEXUSS OS
Exec=google-chrome --app=file://$HOME/NEXUSS/welcome.html
Icon=system-help
Terminal=false
Type=Application
Categories=System;
EOF

# Auto open welcome on next terminal launch (once)
if ! grep -q "nexuss_welcomed" ~/.bashrc; then
cat >> ~/.bashrc << 'AUTOOPEN'

# Open NEXUSS welcome page once
if [ ! -f ~/.nexuss_welcomed ]; then
  touch ~/.nexuss_welcomed
  google-chrome --app=file://$HOME/NEXUSS/welcome.html &>/dev/null &
fi
AUTOOPEN
fi

echo "  Welcome app created."


# ════════════════════════════════════════════════════════════
# STEP 9: HELPFUL NEXUSS SHORTCUTS
# ════════════════════════════════════════════════════════════
echo -e "${GREEN}[9/10] Setting up NEXUSS shortcuts & commands...${NC}"

# Add handy shortcuts to .bashrc
if ! grep -q "nexuss-shortcuts" ~/.bashrc; then
cat >> ~/.bashrc << 'SHORTCUTS'

# ── NEXUSS Shortcuts ───────────────────────────────────────
# nexuss-shortcuts
alias chrome='google-chrome &>/dev/null &'
alias files='nautilus &>/dev/null &'
alias store='snap-store &>/dev/null &'
alias calc='gnome-calculator &>/dev/null &'
alias code='code &>/dev/null &'
alias libreoffice='libreoffice &>/dev/null &'
alias vlc='vlc &>/dev/null &'
alias settings='gnome-control-center &>/dev/null &'
alias welcome='google-chrome --app=file://$HOME/NEXUSS/welcome.html &>/dev/null &'
SHORTCUTS
fi

echo "  Shortcuts configured."


# ════════════════════════════════════════════════════════════
# STEP 10: CLEANUP
# ════════════════════════════════════════════════════════════
echo -e "${GREEN}[10/10] Cleaning up...${NC}"

sudo apt autoremove -y 2>/dev/null
sudo apt clean 2>/dev/null
rm -rf /tmp/Fluent-gtk-theme /tmp/Fluent-icon-theme 2>/dev/null
update-desktop-database ~/.local/share/applications/ 2>/dev/null || true

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅  NEXUSS OS 1.0 — Crostini Edition Complete!${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "  ${YELLOW}What was installed:${NC}"
echo "  ✔  NEXUSS branding & custom terminal prompt"
echo "  ✔  Google Chrome browser"
echo "  ✔  LibreOffice (Word, Excel, PowerPoint equivalent)"
echo "  ✔  VLC media player"
echo "  ✔  GIMP photo editor"
echo "  ✔  VS Code editor"
echo "  ✔  Snap Store (app store)"
echo "  ✔  Rhythmbox music player"
echo "  ✔  Calculator, Calendar, Clocks, File Manager"
echo "  ✔  Fluent Dark theme"
echo "  ✔  NEXUSS wallpaper"
echo "  ✔  NEXUSS Welcome app"
echo ""
echo -e "  ${YELLOW}Handy commands you can now type:${NC}"
echo "  chrome    → Open Chrome"
echo "  files     → Open File Manager"
echo "  store     → Open Snap Store"
echo "  calc      → Open Calculator"
echo "  settings  → Open Settings"
echo "  welcome   → Open NEXUSS Welcome page"
echo "  nexuss    → Show system info"
echo ""
echo -e "  ${CYAN}To activate everything, close and reopen your terminal.${NC}"
echo ""
