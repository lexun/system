{ inputs, ... }:

let
  inherit (inputs)
    darwin
    home-manager
    nixpkgs
    ;
in
{
  flake = {
    darwinConfigurations = {
      "LukesPersonalMBP" = import ./personal-macbook.nix { inherit darwin home-manager; };
      "LukesWorkMBP" = import ./work-macbook.nix { inherit darwin home-manager; };
    };
    nixosConfigurations = {
      "LukesNixosRB" = import ./nixos-laptop { inherit nixpkgs home-manager; };
    };
    homeConfigurations = {
      "coder" = import ./coder.nix { inherit nixpkgs home-manager; };
    };
  };
}
