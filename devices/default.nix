{ inputs, ... }:

let
  inherit (inputs)
    darwin
    home-manager
    nixpkgs
    nixvim
    ;
in
{
  flake = {
    darwinConfigurations = {
      "LukesPersonalMBP" = import ./personal-macbook.nix { inherit darwin home-manager nixvim; };
      "LukesWorkMBP" = import ./work-macbook.nix { inherit darwin home-manager nixvim; };
    };
    nixosConfigurations = {
      "LukesNixosRB" = import ./nixos-laptop { inherit nixpkgs home-manager nixvim; };
    };
    homeConfigurations = {
      "coder" = import ./coder.nix { inherit nixpkgs home-manager nixvim; };
    };
  };
}
