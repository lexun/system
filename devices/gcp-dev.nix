{ inputs }:

let
  inherit (inputs) nixpkgs home-manager;
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [
      inputs.vibetree.overlays.default
    ];
  };
in
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = {
    onePasswordEnabled = false;
    enableSshConfig = false;
    inherit inputs;
    nixvim = inputs.nixvim;
  };
  modules = [
    ../modules/home-manager
    {
      home.username = "luke";
      home.homeDirectory = pkgs.lib.mkForce "/home/luke";
      # Non-NixOS Linux: `system-update` activates home-manager standalone and
      # needs to know which homeConfiguration this device is. Hostname is "dev",
      # which collides with nixosConfigurations."dev", so declare it explicitly.
      #
      # A file rather than a sessionVariable: home-manager writes sessionVariables
      # to hm-session-vars.sh, which nushell (the login shell here) never sources.
      home.file.".config/system/hm-config".text = "gcp-dev";
      home.packages = with pkgs; [
        _1password-cli
        less
        vibetree
      ];
    }
  ];
}
