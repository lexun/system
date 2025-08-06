{ inputs, ... }:
{
  flake = {
    darwinConfigurations = {
      "LukesPersonalMBP" = import ./personal-macbook.nix { inherit inputs; };
      "LukesWorkMBP" = import ./work-macbook.nix { inherit inputs; };
    };
    nixosConfigurations = {
      "LukesNixosRB" = import ./nixos-laptop { inherit inputs; };
    };
    homeConfigurations = {
      "coder" = import ./coder.nix { inherit inputs; };
    };
  };
}
