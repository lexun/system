{ inputs }:

let
  inherit (inputs) nixpkgs home-manager;
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = [
      inputs.vibetree.overlays.default
      inputs.memex.overlays.default
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
      home.username = "coder";
      home.homeDirectory = pkgs.lib.mkForce "/home/coder";
      home.packages = with pkgs; [
        _1password-cli
        cloudsmith-cli
        less
        memex
        vibetree
      ];
    }
  ];
}
