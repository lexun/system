{ pkgs, inputs, ... }:

{
  home.stateVersion = "24.05";

  nixpkgs.overlays = [
    (import ../../packages/overlay.nix)
  ];

  home.packages = with pkgs; [
    setup-battlenet
    umu-launcher
    inputs.nix-citizen.packages.${pkgs.system}.rsi-launcher
    (pkgs.lib.lowPrio inputs.nix-citizen.packages.${pkgs.system}.lug-helper)
  ];

  xdg.desktopEntries.battlenet = {
    name = "Battle.net";
    exec = "steam";
    icon = "applications-games";
    comment = "Launch Battle.net via Steam";
    categories = [ "Game" ];
    type = "Application";
  };

  programs.home-manager.enable = true;
}
