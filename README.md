# 🚀 Hyprland Dotfiles

A comprehensive Hyprland configuration featuring Catppuccin Mocha theme, custom Waybar, Rofi menus, and optimized development workflows.

## 📸 Features

- **Window Manager**: Hyprland with smooth animations and custom workspace rules
- **Status Bar**: Waybar with custom modules (weather, updates, system stats, calendar integration)
- **Application Launcher**: Rofi with multiple custom menus (apps, emoji, wallpaper picker, power menu)
- **Notifications**: SwayNC with custom styling
- **Terminal**: Ghostty (primary) & Kitty with Catppuccin theme
- **Lock Screen**: Hyprlock with custom design
- **Idle Management**: Hypridle for automatic screen locking
- **Color Scheme**: Catppuccin Mocha throughout
- **Shell**: Zsh with Starship prompt, Zoxide, FZF, syntax highlighting, and Oh My Zsh
- **Editor Config**: IdeaVim configuration for IntelliJ-based IDEs
- **Utilities**: Qalculate (calculator), GNOME Calendar, clipboard manager (cliphist)

## 📋 Prerequisites

### Required Packages

#### Core System (Arch Linux)

```bash
# Base packages
sudo pacman -S hyprland waybar rofi mako kitty wlogout grim slurp \
               wl-clipboard pipewire pipewire-alsa pipewire-pulse \
               wireplumber pavucontrol networkmanager network-manager-applet \
               xdg-desktop-portal-hyprland blueman nautilus firefox chromium

# Shell and utilities
sudo pacman -S zsh oh-my-zsh-git zsh-syntax-highlighting starship fastfetch \
               fzf zoxide

# Development tools
sudo pacman -S rustup go nodejs npm aws-cli docker git

# Additional tools
sudo pacman -S hyprpaper hyprlock hypridle brightnessctl playerctl \
               cliphist imagemagick btop baobab qalculate-gtk gnome-calendar

# Security
sudo pacman -S ufw

# Fonts
sudo pacman -S ttf-jetbrains-mono-nerd ttf-fira-code noto-fonts
```

#### AUR Packages

```bash
yay -S zed swaync hyprshot wf-recorder satty ghostty-bin
```

**Note**: Ghostty is the default terminal in the Hyprland config. If unavailable, the config will fall back to Kitty.

#### Hyprland Plugins

```bash
# Install hyprpm if not already installed
hyprpm update

# Install hyprmodoro plugin (Pomodoro timer)
hyprpm add https://github.com/zakk4223/hyprmodoro
hyprpm enable hyprmodoro
```

### Optional Dependencies

- **Font**: JetBrains Mono Nerd Font, Fira Code (for terminal and UI)
- **Weather API**: Get a free API key from [WeatherAPI.com](https://www.weatherapi.com/)

## 🔧 Installation

### 0. Backup Existing Configurations (Important!)

```bash
# Backup existing configs if they exist
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.backup
[ -f ~/.ideavimrc ] && mv ~/.ideavimrc ~/.ideavimrc.backup
[ -d ~/.config/hypr ] && mv ~/.config/hypr ~/.config/hypr.backup
[ -d ~/.config/waybar ] && mv ~/.config/waybar ~/.config/waybar.backup
# Add more backups as needed
```

### 1. Clone the Repository

```bash
# Clone to the specified location
git clone https://github.com/yourusername/dotfiles ~/.config/Dot_files
```

### 2. Create Symbolic Links

You need to create symbolic links from `~/.config/Dot_files` to `~/.config` for each configuration folder:

```bash
cd ~/.config

# Create symbolic links for all configurations
ln -sf ~/Dot_files/hypr ./hypr
ln -sf ~/Dot_files/kitty ./kitty
ln -sf ~/Dot_files/waybar ./waybar
ln -sf ~/Dot_files/rofi ./rofi
ln -sf ~/Dot_files/swaync ./swaync
ln -sf ~/Dot_files/wlogout ./wlogout

# Home directory configs
ln -sf ~/Dot_files/.ideavimrc ~/.ideavimrc
ln -sf ~/Dot_files/.zshrc ~/.zshrc
ln -sf ~/Dot_files/starship.toml ~/.config/starship.toml
```

### 3. Set Up Weather API (Optional)

Create a `.env` file in the waybar directory:

```bash
cd ~/.config/waybar
echo 'WEATHER_API_KEY=your_api_key_here' > .env
```

Get your free API key from [WeatherAPI.com](https://www.weatherapi.com/)

### 4. Install Rust, Go, and Node.js

The `.zshrc` automatically configures PATH for these tools:

```bash
# Rust
rustup install stable

# Node.js global packages directory (configured in .zshrc)
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'

# Go is ready to use (~/go/bin is in PATH)
```

**Optional Tools** (used by .zshrc if available):

- **ASDF** version manager - for managing multiple runtime versions
- **Zoxide** - better cd command (already in pacman list above)
- **FZF** - fuzzy finder (already in pacman list above)

### 5. Configure Shell

The `.zshrc` from the dotfiles includes:

- **Oh My Zsh** with plugins (git, rust, golang, docker)
- **Starship** prompt (custom config)
- **PATH** exports for Rust, Go, and Node.js
- **Tool integrations**: Zoxide, FZF, AWS CLI completer
- **Fastfetch** on startup with Arch logo
- **Zsh syntax highlighting**

After creating the symbolic link, reload your shell:

```bash
source ~/.zshrc
```

**Important Note:** The `.zshrc` references the Starship config at `~/.config/Dot_Files/starship.toml`. Make sure this path matches your setup, or update line in `.zshrc`:

```bash
export STARSHIP_CONFIG="$HOME/.config/Dot_files/starship.toml"
```

The `.zshrc` also sets up:

- **Zed editor** alias: `zed` → `zeditor`
- **Default editor**: `$EDITOR` = `zeditor`

If you have an existing `.zshrc`, back it up first:

```bash
mv ~/.zshrc ~/.zshrc.backup
```

### 6. Create Required Directories

```bash
# Create wallpapers directory
mkdir -p ~/Pictures/wallpapers

# Create screenshots directory (configured in .zshrc as HYPRSHOT_DIR)
mkdir -p ~/Pictures/Screenshots

# Create screencasts directory for video recordings
mkdir -p ~/Videos/Screencasts

# Place your wallpapers in ~/Pictures/wallpapers
# The wallpaper picker (Super + W) will use this directory
# Screenshots will be saved to ~/Pictures/Screenshots automatically
# Screen recordings will be saved to ~/Videos/Screencasts
```

## ⌨️ Key Bindings

### General

| Keybinding | Action |
|------------|--------|
| `Super + T` | Open terminal (Ghostty) |
| `Super + Shift + T` | Open Kitty terminal |
| `Super + Q` | Close active window |
| `Super + M` | Exit Hyprland |
| `Super + Backspace` | Application launcher |
| `Super + /` | Keybind cheatsheet |
| `Super + G` | Toggle floating |
| `Super + B` | Open browser |

### Window Navigation

| Keybinding | Action |
|------------|--------|
| `Super + H/J/K/L` | Move focus (Vim-style) |
| `Super + 1-9` | Switch to workspace |
| `Super + Shift + 1-9` | Move window to workspace |
| `Alt + J/K` | Move lines up/down |

### Rofi Menus

| Keybinding | Action |
|------------|--------|
| `Super + Backspace` | App launcher |
| `Super + W` | Wallpaper picker |
| `Super + .` | Emoji & Nerd Fonts picker |
| `Super + V` | Clipboard history |
| `Super + C` | Calculator (Qalculate) |
| `Ctrl + Delete` | Power menu |

### Screenshots & Recording

| Keybinding | Action |
|------------|--------|
| `Ctrl + Shift + 3` | Screenshot window |
| `Ctrl + Shift + 4` | Screenshot region |
| `Ctrl + Shift + 5` | Toggle screen recording |

### Pomodoro Timer

| Keybinding | Action |
|------------|--------|
| `Super + A` | Start timer |
| `Super + Shift + A` | Stop timer |

### Notifications

| Keybinding | Action |
|------------|--------|
| `Super + N` | Toggle notification center |

### Utilities

| Keybinding | Action |
|------------|--------|
| Click date in Waybar | Open GNOME Calendar |

## 📁 Structure

```
Dot_files/
├── hypr/              # Hyprland configuration
│   ├── hyprland.conf  # Main config
│   └── config/        # Split configs
├── waybar/            # Status bar
│   ├── .env           # Weather API key (create this)
│   └── scripts/       # Custom scripts
├── rofi/              # Application launcher & menus
├── kitty/             # Kitty terminal
├── swaync/            # Notification daemon
├── wlogout/           # Power menu
├── .ideavimrc         # IdeaVim (IntelliJ) config
├── .zshrc             # Zsh configuration
└── starship.toml      # Shell prompt
```

## 🎨 Customization

### Changing Theme Colors

The Catppuccin Mocha theme is defined in:

- `rofi/colors/ghostvox.rasi`
- `waybar/style.css`
- `kitty/current-theme.conf`
- `swaync/style.css`
- `hypr/mocha.conf`

### Modifying Waybar Modules

Edit `waybar/config.jsonc` to add/remove modules. Custom scripts are in `waybar/scripts/`

### Adding Custom Rofi Menus

Create new menu configs in `rofi/` following the existing pattern in `launchers/` or `powermenu/`

## 🔍 Monitor Configuration

Edit `hypr/config/monitors.conf` to match your setup:

```conf
monitor = DP-6,preferred,0x0,1
monitor = HDMI-A-2,3840x2160@120,2560x0,1.5
```

## 🐛 Troubleshooting

### Starship prompt not showing correctly

- Check the path in `.zshrc` - should point to `~/.config/Dot_files/starship.toml`
- Verify starship is installed: `which starship`
- Reload shell: `source ~/.zshrc`

### Waybar not showing weather

- Ensure you have a valid API key in `~/.config/waybar/.env`
- Check internet connection
- Run `~/.config/waybar/scripts/wttr.py` manually to debug

### Hyprland not starting

- Check logs: `cat /tmp/hypr/$(ls -t /tmp/hypr/ | head -n 1)/hyprland.log`
- Ensure all required packages are installed

### Rofi menus not working

- Make scripts executable: `chmod +x ~/.config/rofi/**/*.sh`
- Check if rofi is installed: `which rofi`

## 📝 Credits

- **Hyprland**: [hyprland.org](https://hyprland.org)
- **Catppuccin Theme**: [catppuccin.com](https://catppuccin.com)
- **Rofi Themes**: Based on adi1090x's collection
- **Waybar**: Custom configuration
- **Icons**: Nerd Fonts

## 📄 License

This configuration is free to use and modify. Attribution appreciated but not required.

## 🤝 Contributing

Feel free to submit issues or pull requests for improvements!

---

**Note**: This configuration is optimized for Arch Linux. Adjustments may be needed for other distributions.
