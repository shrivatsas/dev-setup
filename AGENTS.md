# AGENTS.md

Guidance for AI coding assistants working with this repository.

## Repository Purpose

This is a personal development environment setup repository. It contains shell scripts and configuration files for bootstrapping development machines on macOS and Ubuntu.

## Key Files

- `mac.m1.sh` - macOS Apple Silicon setup (primary, actively maintained)
- `ubuntu.sh` - Ubuntu/Linux setup (less frequently updated)
- `vscode-extensions.txt` - VS Code extension IDs (one per line)
- `conda-packages.txt` - Python packages (one per line)
- `fishshell` - Fish shell setup notes

## Conventions

### Script Style
- Use Homebrew (`brew install`) for macOS packages
- Use apt/snap for Ubuntu packages
- Comment out optional/situational tools with `#`
- Group related tools under markdown-style headers (`#### Section Name`)
- Keep one package per line for readability when practical

### Adding New Tools
1. Add to the appropriate section based on category
2. Use `brew install --cask` for GUI applications on macOS
3. Comment out niche/optional tools by default
4. Prefer `mise` for language runtime management over individual version managers

### Version Management
- Use `mise` (formerly rtx) for managing language versions
- Avoid hardcoded version numbers when possible
- Use `@latest` for mise installations unless a specific version is required

## Common Tasks

### Adding a new macOS tool
Add to `mac.m1.sh` under the appropriate section header.

### Adding a VS Code extension
Append the extension ID to `vscode-extensions.txt`.

### Adding a Python package
Append to `conda-packages.txt`.

## Notes

- Scripts are designed for fresh machine setup, not incremental updates
- Many tools are commented out - only uncomment what's needed
- The ubuntu.sh script mixes fish and bash syntax in places (legacy)
- AI tools section in mac.m1.sh is actively updated
