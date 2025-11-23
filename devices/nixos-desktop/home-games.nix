{ pkgs, ... }:

{
  # Minimal home-manager configuration for the dedicated gaming account
  home.stateVersion = "24.05";

  # Gaming-specific packages for the games user
  home.packages = with pkgs; [
    # Steam is the primary application for this account
    # System-level programs.steam.enable handles the FHS environment
  ];

  # Allow home-manager to manage this user's configuration
  programs.home-manager.enable = true;
}
