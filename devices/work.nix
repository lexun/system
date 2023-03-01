{ darwin, flake-utils, home-manager }:

darwin.lib.darwinSystem {
  system = flake-utils.lib.system.aarch64-darwin;
  modules = [{
    imports = import ./common.nix { inherit home-manager; };
    homebrew.casks = [
      "amazon-workspaces"
      "tandem"
    ];
  }];
}
