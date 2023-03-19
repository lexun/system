{ flake-utils, home-manager, nixpkgs }:

nixpkgs.lib.nixosSystem {
  system = flake-utils.lib.system.x86_64-linux;
  modules = [
    ../../modules/nixos
    ./configuration.nix
    ./hardware.nix
    home-manager.nixosModules.home-manager
    {
      home-manager.users.luke = import ../../modules/home-manager;
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
    }
  ];
}
