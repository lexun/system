{ darwin, home-manager, nixvim, vibetree }:

darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    home-manager.darwinModules.home-manager
    ../modules/nix-darwin
  ];
  specialArgs = {
    inputs = {
      inherit nixvim vibetree;
    };
  };
}
