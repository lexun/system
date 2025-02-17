{ inputs, ... }:

{
  users.users.luke.home = "/Users/luke";

  home-manager.users.luke = ../home-manager;
  home-manager.useUserPackages = true;
  home-manager.backupFileExtension = "rebuild";
  home-manager.extraSpecialArgs.onePasswordEnabled = true;

  homebrew.enable = true;
  homebrew.casks = [
    "1password-cli"
    "1password"
    "beekeeper-studio"
    "brave-browser"
    "chatgpt"
    "cursor"
    "discord"
    "docker"
    "epic-games"
    "obsidian"
    "protonvpn"
    "raycast"
    "spotify"
    "wezterm"
    "zed"
  ];

  nix.settings = {
    experimental-features = [
      "flakes"
      "nix-command"
    ];

    trusted-users = [
      "root"
      "luke"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  security.pam.enableSudoTouchIdAuth = true;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  system.defaults.dock.autohide = true;
  system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = false;

  system.stateVersion = 6;
}
