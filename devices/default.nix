{ inputs, ... }:

let
  inherit (inputs)
    darwin
    home-manager
    nixpkgs
    nixvim
    vibetree
    ;
in
{
  flake = {
    darwinConfigurations = {
      "LukesPersonalMBP" = import ./personal-macbook.nix { inherit darwin home-manager nixvim vibetree; };
      "LukesWorkMBP" = import ./work-macbook.nix { inherit darwin home-manager nixvim vibetree; };
    };
    nixosConfigurations = {
      "LukesNixosRB" = import ./nixos-laptop { inherit nixpkgs home-manager nixvim inputs; };
    };
    homeConfigurations = {
      "coder" = import ./coder.nix { inherit nixpkgs home-manager nixvim; };
    };
  };
}
