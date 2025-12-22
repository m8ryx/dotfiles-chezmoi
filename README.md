# Dotfiles

My cross-platform dotfile configuration managed by [chezmoi](https://www.chezmoi.io/).

## Quick Start

### First Time Setup (New Machine)

```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# Initialize from this repo
chezmoi init https://github.com/YOURUSERNAME/dotfiles.git

# Review what will be changed
chezmoi diff

# Apply the dotfiles
chezmoi apply
```

### Daily Usage

```bash
# Edit a dotfile
chezmoi edit ~/.zshrc

# See what changed
chezmoi diff

# Apply changes
chezmoi apply

# Update from remote repo (on another machine)
chezmoi update
```

### Adding New Files

```bash
# Add a new dotfile to chezmoi
chezmoi add ~/.config/newfile

# Add as a template (for cross-platform configs)
chezmoi add --template ~/.gitconfig
```

## Platform Support

This configuration works on:
- Linux (Ubuntu/Debian)
- macOS (work machine)

Platform-specific settings are handled via chezmoi templates.

## Configuration

Machine-specific settings are in `~/.config/chezmoi/chezmoi.toml`.

Edit that file to set:
- Your name and email
- Machine type (work/personal)
- Other custom variables

## Files Managed

- `.zshrc` - Zsh configuration
- `.config/tmux/tmux.conf` - Tmux configuration with elflord theme
- `.gitconfig` - Git configuration
