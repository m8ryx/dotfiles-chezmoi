# Secrets Management

This dotfiles repo does NOT contain secrets (API keys, tokens, passwords).

## Setup on Each Machine

After running `chezmoi init` and `chezmoi apply`, create your secrets file:

```bash
# Create the secrets file
cat > ~/.zshrc.secrets << 'EOF'
# Secret environment variables
# This file should NOT be committed to git

# Gemini API keys
export GEMINI_API_KEY=your_key_here
export GOOGLEAI_API_KEY=your_key_here

# Add other secrets as needed
EOF

# Secure the file
chmod 600 ~/.zshrc.secrets
```

## What Goes in Secrets File

- API keys (Gemini, OpenAI, AWS, etc.)
- Access tokens
- Passwords
- Private authentication credentials
- Work-specific environment variables

## Security Notes

- ✅ `.zshrc.secrets` is in `.gitignore` - won't be committed
- ✅ `.chezmoiignore` prevents chezmoi from managing it
- ✅ Each machine has its own secrets file
- ⚠️ Never commit `.zshrc.secrets` to any repo
- ⚠️ Use `chmod 600` to restrict file permissions

## Alternative: Encrypted Secrets

If you want to sync secrets securely, use chezmoi's encryption:

```bash
# Install age for encryption
brew install age  # or: apt install age

# Generate a key
age-keygen -o ~/.config/chezmoi/key.txt

# Add encrypted secret
chezmoi add --encrypt ~/.zshrc.secrets

# The encrypted file will be safe to commit to git
```
