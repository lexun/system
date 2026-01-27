{ inputs }:

let
  inherit (inputs) home-manager nixpkgs;
in
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    "${nixpkgs}/nixos/modules/virtualisation/digital-ocean-image.nix"
    ./configuration.nix
    home-manager.nixosModules.home-manager
    {
      home-manager.users.luke = ../../modules/home-manager;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {
        inherit inputs;
        onePasswordEnabled = false;
        enableSshConfig = false;
        nixvim = inputs.nixvim;
      };
    }
  ];
}
