{ nixpkgs, home-manager, nixvim, inputs }:

let
  system = "x86_64-linux";
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };
in
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = {
    onePasswordEnabled = false;
    enableSshConfig = false;
    inherit nixvim inputs;
  };
  modules = [
    ../modules/home-manager
    {
      home.username = "coder";
      home.homeDirectory = pkgs.lib.mkForce "/home/coder";
      home.packages = with pkgs; [
        _1password-cli
        less
      ];
    }
  ];
}
