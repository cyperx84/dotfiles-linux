# Dotfiles (Linux / Omarchy)

Personal dotfiles for Arch Linux with [Omarchy](https://omarchy.org). Managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Prerequisites

- Arch Linux with [Omarchy](https://omarchy.org) installed
- `git` and `yay` (AUR helper)

## Quick Start

```bash
git clone https://github.com/cyperx84/dotfiles-linux.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

## Stow Packages

| Package | What it manages |
|---------|----------------|
| `shell` | `.zshrc` (sources omarchy defaults, adds overrides) |
| `hypr` | Hyprland config (bindings, monitors, input, look & feel) |
| `waybar` | Status bar config and styling |
| `walker` | App launcher config |
| `terminals` | Ghostty, Alacritty, Kitty configs |
| `tmux` | Tmux with Catppuccin, sesh, vim-navigator, TPM plugins |
| `nvim` | Neovim (kickstart-based) with omarchy theme integration |
| `dev-tools` | Starship prompt, git, lazygit, btop, fastfetch |
| `kanata` | Keyboard remapper (home row mods, caps→esc/ctrl) |
| `omarchy-user` | Omarchy hooks and branding customization |

### Selective Install

```bash
stow shell tmux nvim   # Only install specific packages
```

## Architecture

Omarchy uses a three-layer config system:

```
~/.local/share/omarchy/     # Layer 1: System defaults (READ-ONLY)
         ↓ sourced by
~/.config/<app>/             # Layer 2: User configs (THIS REPO)
         ↓ imports
~/.config/omarchy/current/   # Layer 3: Auto-generated theme
```

This repo tracks **Layer 2 only**. Never edit Layer 1 or 3 directly.

## Theme Integration

Omarchy's theme system (`omarchy-theme-set <name>`) automatically updates all apps. The nvim config includes `omarchy-theme-hotreload.lua` which picks up theme changes at runtime.

Files managed by omarchy's theme system (NOT in this repo):
- `~/.config/nvim/lua/custom/plugins/theme.lua` → symlink (created by bootstrap)
- `~/.config/mako/config` → symlink

## Extra Packages

Install scripts in `scripts/` for packages not in standard repos:
- `install-ghostty.sh` — Ghostty terminal
- `install-kanata.sh` — Kanata keyboard remapper
- `install-zen-browser.sh` — Zen Browser
