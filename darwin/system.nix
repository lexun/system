{
  homebrew.enable = true;
  homebrew.casks = [
    "1password-cli"
    "1password"
    "brave-browser"
    "discord"
    "iterm2"
    "nordvpn"
    "obsidian"
    "raycast"
    "spotify"
    "zoom"
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;

  security.pam.enableSudoTouchIdAuth = true;

  services.nix-daemon.enable = true;

  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = true;

  system.defaults.dock.autohide = true;

  system.stateVersion = 4;
}
