{ inputs, ... }:

{
  users.users.luke.home = "/Users/luke";

  home-manager.users.luke = ../home-manager;
  home-manager.useUserPackages = true;

  homebrew.enable = true;
  homebrew.casks = [
    "1password-cli"
    "1password"
    "beekeeper-studio"
    "brave-browser"
    "discord"
    "docker"
    "iterm2"
    "obsidian"
    "protonvpn"
    "raycast"
    "slack"
    "spotify"
    "zoom"
  ];

  nix.settings = {
    experimental-features = [
      "flakes"
      "nix-command"
      "repl-flake"
    ];

    trusted-users = [
      "root"
      "luke"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  security.pam.enableSudoTouchIdAuth = true;

  services.nix-daemon.enable = true;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  system.defaults.dock.autohide = true;
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;

  system.stateVersion = 4;
}
