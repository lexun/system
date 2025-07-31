# System

My full system configuration for various devices and environments. Mostly
undocumented, but I may add more notes over time.

## New Mac Setup

[https://github.com/DeterminateSystems/nix-installer](https://github.com/DeterminateSystems/nix-installer)

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

[https://brew.sh](https://brew.sh/)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

```bash
git clone https://github.com/lexun/system ~/.system
```

Change hostname to match device name in `~/.system/devices/default.nix`, then:

```bash
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.original
```

Apply the system configuration with [nix-darwin](https://github.com/LnL7/nix-darwin):

```bash
nix --extra-experimental-features 'nix-command flakes' run nix-darwin -- switch --flake ~/.system
```

Finally, enable the 1password ssh agent and CLI integration in the 1password developer settings.

## Coder Instances

For Nix-powered coder instances, setup is simple:

```bash
nix run github:lexun/system#homeConfigurations.coder.activationPackage
```

## Maintenance

To update Nix dependencies:

```
cd ~/.system && nix flake update
```

To apply changes to the configuration:

```
update
```

