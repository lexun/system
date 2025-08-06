{ inputs }:

let
  inherit (inputs) darwin home-manager;
in
darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    home-manager.darwinModules.home-manager
    ../modules/nix-darwin
  ];
  specialArgs = {
    inherit inputs;
  };
}
