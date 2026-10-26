{ pkgs, inputs, ... }:

{
  imports = [ ../../modules/home-manager ];

  nixpkgs.overlays = [
    (import ../../packages/overlay.nix)
  ];

  home.packages = with pkgs; [
    google-chrome
    setup-battlenet
    umu-launcher
    inputs.nix-citizen.packages.${pkgs.system}.rsi-launcher
    (pkgs.lib.lowPrio inputs.nix-citizen.packages.${pkgs.system}.lug-helper)
  ];

  xdg.desktopEntries.battlenet = {
    name = "Battle.net";
    exec = "setup-battlenet";
    icon = "applications-games";
    comment = "Launch Battle.net";
    categories = [ "Game" ];
    type = "Application";
  };
}
