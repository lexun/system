{ darwin, home-manager, nixvim }:

darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    home-manager.darwinModules.home-manager
    ../modules/nix-darwin
  ];
  specialArgs = {
    inputs = {
      inherit nixvim;
    };
  };
}
