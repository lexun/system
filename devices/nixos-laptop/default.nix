{ inputs }:

let
  inherit (inputs) home-manager nixpkgs;
in
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ../../modules/nixos
    ./configuration.nix
    ./hardware.nix
    home-manager.nixosModules.home-manager
    {
      home-manager.users.luke = ../../modules/home-manager;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {
        inherit inputs;
        onePasswordEnabled = false;
        enableSshConfig = true;
        nixvim = inputs.nixvim;
      };
    }
  ];
}
