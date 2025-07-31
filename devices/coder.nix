{ nixpkgs, home-manager }:

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
  };
  modules = [
    ../modules/home-manager
    {
      home.username = "coder";
      home.homeDirectory = pkgs.lib.mkForce "/home/coder";
      home.packages = with pkgs; [
        _1password-cli
      ];
    }
  ];
}
