{ darwin, home-manager }:

darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    home-manager.darwinModules.home-manager
    ../modules/nix-darwin
  ];
}
