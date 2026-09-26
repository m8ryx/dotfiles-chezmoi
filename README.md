# Dotfiles

My cross-platform dotfile configuration managed by [chezmoi](https://www.chezmoi.io/).

## Quick Start

### First Time Setup (New Machine)

```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# Initialize from this repo
chezmoi init https://github.com/m8ryx/dotfiles-chezmoi.git

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

## Secret scanning (do this on every machine)

This repo is **public**, and dotfiles are exactly the files people paste API keys
into. A `pre-commit` hook in `.githooks/` scans staged changes and refuses the
commit if it finds credential-shaped content.

It runs **two passes**, because they fail in opposite directions:

1. **A regex net**, built into the hook. Naive prefix matching — fires on any
   `AKIA`/`ghp_`/`sk-ant-`-shaped string, including low-entropy fakes. High
   recall on format, correspondingly prone to false positives.
2. **[betterleaks](https://github.com/betterleaks/betterleaks)**, if installed
   (`gitleaks` works too — the hook picks up whichever is on `PATH`). ~200
   maintained rules using keyword context and entropy: near-zero false
   positives, and it catches real-world shapes the regex net never will.

Neither is sufficient alone. Verified concretely: a bare invented AWS-format key
is caught only by pass 1 — betterleaks correctly declines it, because its AWS rule
validates more than the prefix. A JWT is caught only by pass 2, because no prefix
rule in pass 1 matches one.

Install betterleaks from a **release binary** and verify the checksum
(v1.8.1 ships a signed `checksums.txt`):

```bash
sha256sum -c <(grep linux_x64 checksums.txt)
install -m 755 betterleaks ~/.local/bin/
```

### Enabling the hook

Git does not enable tracked hooks automatically, and `core.hooksPath` is local
config that does not travel with a clone. After `chezmoi init` on a new machine:

```bash
git -C "$(chezmoi source-path)" config core.hooksPath .githooks
```

Confirm it is live — the commit must be refused:

```bash
cd "$(chezmoi source-path)"
# build the fake key at runtime — never commit a credential-shaped literal,
# even a documented one: public-push scanners cannot tell it is fake
echo "aws=AKIA$(printf 'X%.0s' {1..16})" > .hooktest && git add .hooktest
git commit -m 'should be blocked'   # expect: pre-commit refuses
git restore --staged .hooktest && rm .hooktest
```

Real secrets belong in `~/.zshrc.secrets`, which `.zshrc` sources if present.
That file is untracked, chezmoi-ignored, and mode 600. Never put a key in a
managed file.

### The allowlist marker

Security docs have to quote credential formats to be useful, so the hook skips
any line containing `pragma: allowlist secret`. Use it for documentation and test
fixtures only, never to silence a real finding. Every exemption is auditable:

```bash
git -C "$(chezmoi source-path)" grep 'pragma: allowlist secret'
```

### A note on scanner behaviour

Context-aware scanners deliberately do **not** fire on bare invented keys. When
testing one, use realistic inputs with keyword context and quoting
(`aws_key = "..."`), or you will conclude a working scanner is broken. Also note
`--redact` takes an *optional* value: write `--redact=100`, because `--redact -v`
swallows the next flag and the scan silently reports nothing. Both mistakes were
made while building this hook.
