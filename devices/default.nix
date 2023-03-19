{ darwin, flake-utils, home-manager, nixpkgs }:

{
  darwinConfigurations = {
    "Lukes-Personal-MBP" = import ./personal-macbook.nix { inherit darwin flake-utils home-manager; };
    "Lukes-Work-MBP" = import ./work-macbook.nix { inherit darwin flake-utils home-manager; };
  };
  nixosConfigurations = {
    "Lukes-NixOS-RB" = import ./nixos-laptop { inherit nixpkgs flake-utils home-manager; };
  };
}
