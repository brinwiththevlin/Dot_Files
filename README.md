# 🚀 Hyprland Dotfiles
A comprehensive Hyprland configuration featuring Catppuccin Mocha theme, Noctalia, Rofi menus, and optimized development workflows.

## 📸 Features
- **Window Manager**: Hyprland with smooth animations and custom workspace rules
- **Desktop Shell**: Noctalia for the panel, launcher, wallpaper, and control center
- **Application Launcher**: Rofi with multiple custom menus (apps, emoji, wallpaper picker, power menu)
- **Notifications**: SwayNC with custom styling
- **Terminal**: Ghostty (primary) & Kitty with Catppuccin theme
- **Lock Screen**: Hyprlock with custom design
- **Idle Management**: Hypridle for automatic screen locking
- **Color Scheme**: Catppuccin Mocha throughout
- **Shell**: Zsh with Starship prompt, Zoxide, FZF, syntax highlighting, and Oh My Zsh
- **Editor Config**: IdeaVim configuration for IntelliJ-based IDEs
- **Utilities**: Qalculate (calculator), GNOME Calendar, clipboard manager (cliphist)

## Demo

[![Watch the demo](https://img.youtube.com/vi/I52polarkx0/0.jpg)](https://www.youtube.com/watch?v=I52polarkx0)

## 📋 Prerequisites

### Required Packages

#### Core System (Arch Linux)
```bash
# Base packages
sudo pacman -S hyprland rofi kitty grim slurp \
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

#### Application Flags
discords application file should be in ~/.local/share/applications/discord.desktop. This makes
discord render nice and crisp
```bash
[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=/usr/bin/discord --enable-font-antialiasing--enable-font-subpixel-positioning --ozone-platform-hint=auto --enable-features=WaylandWindowDecorations
Icon=discord
Type=Application
Categories=Network;InstantMessaging;
Path=/usr/bin

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
ln -sf ~/Dot_files/rofi ./rofi
ln -sf ~/Dot_files/swaync ./swaync
ln -sf ~/Dot_files/wlogout ./wlogout

# Home directory configs
ln -sf ~/Dot_files/.ideavimrc ~/.ideavimrc
ln -sf ~/Dot_files/.zshrc ~/.zshrc
ln -sf ~/Dot_files/starship.toml ~/.config/starship.toml
```

### 3. Install Rust, Go, and Node.js
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

### 6. Configure Shell
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

### 7. Create Required Directories
```bash
# Create wallpapers directory
mkdir -p ~/Pictures/wallpapers

# Create screenshots directory (configured in .zshrc as HYPRSHOT_DIR)
mkdir -p ~/Pictures/Screenshots

# Create screencasts directory for video recordings
mkdir -p ~/Videos/Screencasts

# Create the cache directory used by desktop utilities
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}"

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
| Open Noctalia control center | Open desktop controls |
| Open Noctalia launcher | Launch applications and commands |

## 📁 Structure
```
Dot_files/
├── hypr/              # Hyprland configuration
│   ├── hyprland.conf  # Main config
│   └── config/        # Split configs
├── noctalia/          # Desktop shell configuration
│   └── config.toml    # Wallpaper, clock, location, and weather settings
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
- `noctalia/config.toml`
- `kitty/current-theme.conf`
- `swaync/style.css`
- `hypr/mocha.conf`

### Customizing Noctalia
Edit `noctalia/config.toml` to change wallpaper behavior, clock formatting, location, and weather settings. Validate changes with `noctalia config validate ~/.config/noctalia/config.toml`.

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
- **Noctalia**: Desktop shell configuration
- **Icons**: Nerd Fonts

## 📄 License
This configuration is free to use and modify. Attribution appreciated but not required.

## 🤝 Contributing
Feel free to submit issues or pull requests for improvements!

---
**Note**: This configuration is optimized for Arch Linux. Adjustments may be needed for other distributions.
