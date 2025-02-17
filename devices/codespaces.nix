{ nixpkgs, home-manager }:

let
  system = "x86_64-linux";
  pkgs = nixpkgs.legacyPackages.${system};
in
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  extraSpecialArgs = {
    codespaces = true;
  };
  modules = [
    ../modules/home-manager
    {
      home.username = "vscode";
      home.homeDirectory = pkgs.lib.mkForce "/home/vscode";
    }
  ];
}
