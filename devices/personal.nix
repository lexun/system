{ darwin, flake-utils, home-manager }:

darwin.lib.darwinSystem {
  system = flake-utils.lib.system.x86_64-darwin;
  modules = [{
    imports = import ./common.nix { inherit home-manager; };
    home-manager.users.luke = import ../darwin/home;
  }];
}
