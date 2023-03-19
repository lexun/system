{ darwin, flake-utils, home-manager }:

darwin.lib.darwinSystem {
  system = flake-utils.lib.system.x86_64-darwin;
  modules = [{
    imports = [
      ../modules/nix-darwin
      home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        users.users.luke.home = "/Users/luke";
      }
    ];
    home-manager.users.luke = import ../modules/home-manager;
  }];
}
