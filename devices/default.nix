{ inputs, ... }:

let inherit (inputs)
  darwin
  home-manager
  nixpkgs;
in
{
  flake = {
    darwinConfigurations = {
      "Lukes-Personal-MBP" = import ./personal-macbook.nix { inherit darwin home-manager; };
      "Lukes-Work-MBP" = import ./work-macbook.nix { inherit darwin home-manager; };
    };
    nixosConfigurations = {
      "Lukes-NixOS-RB" = import ./nixos-laptop { inherit nixpkgs home-manager; };
    };
  };
}
