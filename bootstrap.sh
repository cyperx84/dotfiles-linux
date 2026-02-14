#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
PACKAGES=(shell hypr waybar walker terminals tmux nvim dev-tools kanata omarchy-user)

echo "==================================="
echo "  Dotfiles Bootstrap"
echo "==================================="
echo

# 1. Check omarchy is installed
if [[ ! -d ~/.local/share/omarchy ]]; then
  echo "ERROR: Omarchy not found at ~/.local/share/omarchy"
  echo "Install omarchy first: https://omarchy.org"
  exit 1
fi
echo "✓ Omarchy detected ($(cat ~/.local/share/omarchy/version 2>/dev/null || echo 'unknown version'))"

# 2. Install stow if missing
if ! command -v stow &>/dev/null; then
  echo "Installing stow..."
  source "$DOTFILES_DIR/scripts/install-stow.sh"
fi
echo "✓ GNU Stow available"

# 3. Back up conflicting files
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$HOME/dotfiles-backup-$TIMESTAMP"
CONFLICTS=false

for pkg in "${PACKAGES[@]}"; do
  cd "$DOTFILES_DIR"
  # Dry-run stow to find conflicts
  if ! stow -n "$pkg" 2>/dev/null; then
    CONFLICTS=true
  fi
done

if [[ "$CONFLICTS" == true ]]; then
  echo "Backing up conflicting files to $BACKUP_DIR..."
  mkdir -p "$BACKUP_DIR"

  # Use stow --adopt to pull existing files into repo, then restore repo versions
  cd "$DOTFILES_DIR"
  for pkg in "${PACKAGES[@]}"; do
    stow --adopt "$pkg" 2>/dev/null || true
  done

  # Save adopted files as backup, then restore repo versions
  cp -r "$DOTFILES_DIR" "$BACKUP_DIR/dotfiles-adopted"
  git -C "$DOTFILES_DIR" checkout -- . 2>/dev/null || true
  echo "✓ Backup created at $BACKUP_DIR"
else
  # No conflicts, stow directly
  cd "$DOTFILES_DIR"
  for pkg in "${PACKAGES[@]}"; do
    stow "$pkg"
  done
fi

# 4. Stow all packages
cd "$DOTFILES_DIR"
for pkg in "${PACKAGES[@]}"; do
  stow -R "$pkg" 2>/dev/null || stow "$pkg"
  echo "✓ Stowed $pkg"
done

# 5. Re-create omarchy theme symlink for nvim
THEME_SYMLINK="$HOME/.config/nvim/lua/custom/plugins/theme.lua"
THEME_TARGET="$HOME/.config/omarchy/current/theme/neovim.lua"
if [[ -f "$THEME_TARGET" ]]; then
  ln -sf "$THEME_TARGET" "$THEME_SYMLINK"
  echo "✓ Nvim theme symlink created"
else
  echo "⚠ Omarchy theme file not found, skipping nvim theme symlink"
fi

# 6. Clone TPM for tmux if missing
if [[ ! -d ~/.config/tmux/plugins/tpm ]]; then
  echo "Installing Tmux Plugin Manager..."
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
  echo "✓ TPM installed (press prefix+I in tmux to install plugins)"
else
  echo "✓ TPM already installed"
fi

# 7. Run extra install scripts (optional)
echo
read -p "Install extra packages (ghostty, kanata, zen-browser)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  for script in install-ghostty.sh install-kanata.sh install-zen-browser.sh; do
    if [[ -f "$DOTFILES_DIR/scripts/$script" ]]; then
      echo "Running $script..."
      source "$DOTFILES_DIR/scripts/$script"
    fi
  done
fi

# 8. Validate
echo
echo "Running validation..."
bash "$DOTFILES_DIR/validate.sh"
