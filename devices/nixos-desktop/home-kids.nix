{ pkgs, ... }:

{
  # Minimal home-manager configuration for kid's accounts
  home.stateVersion = "24.05";

  # Hide Steam to remind everyone to use the games account
  xdg.desktopEntries.steam = {
    name = "Steam (use games account!)";
    noDisplay = true;
  };

  programs.home-manager.enable = true;
}
