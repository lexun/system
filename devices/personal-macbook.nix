{ darwin, home-manager }:

darwin.lib.darwinSystem {
  system = "x86_64-darwin";
  modules = [
    home-manager.darwinModules.home-manager
    ../modules/nix-darwin
  ];
}
