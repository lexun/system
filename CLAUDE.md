# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## System Configuration Repository

This is a **Nix/NixOS system configuration repository** using **nix-darwin** and **home-manager** for managing macOS systems, with NixOS laptop support. The configuration uses flakes for reproducible builds across multiple devices.

## Common Commands

### System Updates

```bash
# Update all Nix dependencies
cd ~/.system && nix flake update

# Apply configuration changes
update  # Custom alias for system-update script

# Direct system rebuild
sudo darwin-rebuild switch --flake ~/.system  # macOS
sudo nixos-rebuild switch --flake ~/.system   # NixOS
```

### Development

```bash
# Initialize new project with devenv template
nix flake new -t ~/.system#devenv my-project

# Build and test changes locally before applying
nix build .#darwinConfigurations.$(hostname).system
```

## Architecture Overview

### Core Structure

- **flake.nix**: Main entry point using flake-parts for modular organization
- **devices/**: Device-specific configurations mapped by hostname
- **modules/**: Reusable configuration modules for different platforms
- **packages/**: Custom package definitions with overlays

### Key Modules

- **modules/home-manager/**: User environment (CLI tools, shell, editor)
- **modules/nix-darwin/**: macOS system configuration (Homebrew, system defaults)
- **modules/nixos/**: NixOS system configuration

### Device Mapping

Device hostnames are mapped in `devices/default.nix`:

- `LukesPersonalMBP` → personal-macbook.nix
- `LukesWorkMBP` → work-macbook.nix
- `LukesNixosRB` → nixos-laptop/
- `coder` → coder.nix

### Configuration Patterns

- **Modular design**: Separate concerns across platform-specific modules
- **Flake-based**: Modern Nix flakes for reproducible builds
- **Multi-platform**: Supports macOS (nix-darwin), NixOS, and GitHub Codespaces
- **Home-manager integration**: User-level configuration management
- **Custom packages**: Includes overlay system for additional software

## Important Files

- `flake.nix`: Main configuration entry point
- `devices/default.nix`: Device hostname to configuration mapping
- `modules/home-manager/default.nix`: User environment and CLI tools
- `modules/nix-darwin/default.nix`: macOS system settings
- `README.md`: Setup instructions and maintenance commands
