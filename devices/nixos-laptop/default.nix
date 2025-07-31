{ home-manager, nixpkgs }:

nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ../../modules/nixos
    ./configuration.nix
    ./hardware.nix
    home-manager.nixosModules.home-manager
    {
      home-manager.users.luke = import ../../modules/home-manager;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs.onePasswordEnabled = false;
    }
  ];
}
