{ pkgs, ... }:

{
  imports = [ ../../modules/home-manager ];

  # Luke-specific packages for this device
  home.packages = with pkgs; [
    google-chrome
  ];
}
