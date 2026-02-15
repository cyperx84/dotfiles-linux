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

## Hyprland Customizations

### Input Configuration (`hypr/.config/hypr/input.conf`)

**Trackpad (MacBook Pro)**
- Natural scrolling enabled (macOS-style)
- Two-finger right-click enabled (clickfinger behavior)

### Idle & Lock Screen (`hypr/.config/hypr/hypridle.conf`)

| Timeout | Action |
|---------|--------|
| 15 minutes | Screensaver starts |
| 15 minutes | Screen locks (password required) |
| 16 minutes | Display turns off |

## Extra Packages

Install scripts in `scripts/` for packages not in standard repos:
- `install-ghostty.sh` — Ghostty terminal
- `install-kanata.sh` — Kanata keyboard remapper
- `install-zen-browser.sh` — Zen Browser

## MacBook Pro T2 (15,3) — Suspend/Resume Fix

The T2 MacBook Pro needs special handling for suspend to work. Without it, `apple_bce` crashes on resume with `bce_vhci_drop_endpoint` page faults (kernel BUG), and the AMD Vega 20 GPU flickers after waking.

### Deploy

```bash
sudo bash ~/fix-suspend.sh
sudo reboot
```

### What it does

**1. Systemd services (unload modules before sleep)**

| Service | Before sleep | On resume |
|---------|-------------|-----------|
| `suspend-fix-t2.service` | `rmmod -f apple-bce` | `modprobe apple-bce` + `modprobe appletbdrm` |
| `suspend-fix-wifi.service` | `modprobe -r brcmfmac` | `modprobe brcmfmac` |

Both use `Before=sleep.target` / `WantedBy=sleep.target` with `StopWhenUnneeded=yes`. The hook approach (`/etc/systemd/system-sleep/`) does NOT work — systemd 259 only reads from `/usr/lib/systemd/system-sleep/`.

**2. Kernel parameters (amdgpu Vega 20)**

| Parameter | Purpose |
|-----------|---------|
| `amdgpu.dcdebugmask=0x10` | Disable Panel Self Refresh — fixes post-resume flicker |
| `amdgpu.dpm=0` | Disable Dynamic Power Management — t2linux wiki recommended for Vega 20 |
| `amdgpu.runpm=0` | Disable runtime PM — prevents deep GPU sleep recovery issues |

**3. Other fixes in the script**

- NVMe `d3cold_allowed=0` (prevents NVMe suspend failure)
- `resume` mkinitcpio hook positioned after `encrypt`, before `filesystems`
- Btrfs swapfile for hibernation with `resume=` and `resume_offset=` in cmdline
- `HandleLidSwitch=suspend-then-hibernate` with 30min delay

**4. Touch Bar (tiny-dfr + appletbdrm)**

- `appletbdrm` module loaded at boot via `/etc/modules-load.d/apple-bce.conf`
- `tiny-dfr.service` starts automatically (BindsTo the display device)
- On resume, `appletbdrm` is reloaded by `suspend-fix-t2.service` after `apple-bce`
- Configured to show media buttons by default (brightness, volume, etc.) — F-keys accessible via Fn key
  - Edit `/etc/tiny-dfr/config.toml` and set `MediaLayerDefault = true`

### Key files

| File | Purpose |
|------|---------|
| `~/fix-suspend.sh` | Master deploy script |
| `/etc/systemd/system/suspend-fix-t2.service` | apple_bce unload/reload |
| `/etc/systemd/system/suspend-fix-wifi.service` | brcmfmac unload/reload |
| `/etc/limine-entry-tool.d/resume.conf` | Kernel cmdline drop-in for hibernation |
| `/boot/limine.conf` | Bootloader config (cmdline patched by script) |

### References

- [t2linux wiki — Post Install](https://wiki.t2linux.org/guides/postinstall/)
- [T2Linux-Suspend-Fix](https://github.com/deqrocks/T2Linux-Suspend-Fix)
- Kernel requires `CONFIG_MODULE_FORCE_UNLOAD=y` (confirmed in `linux-t2`)

### T2 Hardware Status

| Component | Status | Package(s) |
|-----------|--------|------------|
| Keyboard / Trackpad | Working | `hid_apple` (fnmode=2 in `/etc/modprobe.d/hid_apple.conf`) |
| Touch Bar | Working | `tiny-dfr`, `appletbdrm` (kernel module) |
| Audio (speakers + headphones) | Working | `apple-t2-audio-config`, PipeWire |
| WiFi | Working | `brcmfmac`, `apple-bcm-firmware` |
| Bluetooth | Working | `bluez`, `apple-bcm-firmware` |
| Fan control | Working | `t2fanrd` (systemd service) |
| Webcam | Basic | Works at `/dev/video0` |
| Hybrid GPU | Working | Intel UHD 630 + AMD Vega 20 via `apple_gmux` |
| Power management | Working | `power-profiles-daemon` |

### T2 Packages

```bash
# T2-specific packages (install after base Omarchy setup)
sudo pacman -S tiny-dfr t2fanrd apple-bcm-firmware apple-t2-audio-config bluez bluez-utils
```

### Kernel cmdline reference

```
quiet splash cryptdevice=PARTUUID=...:root root=/dev/mapper/root zswap.enabled=0
rootflags=subvol=@ rw rootfstype=btrfs intel_iommu=on iommu=pt pcie_ports=compat
resume=/dev/mapper/root resume_offset=7873792
amdgpu.dcdebugmask=0x10 amdgpu.dpm=0 amdgpu.runpm=0
```
