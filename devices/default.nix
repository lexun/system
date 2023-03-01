{ darwin, flake-utils, home-manager }:

{
  darwinConfigurations = {
    "Lukes-Personal-MBP" = import ./personal.nix { inherit darwin flake-utils home-manager; };
    "Lukes-Work-MBP" = import ./work.nix { inherit darwin flake-utils home-manager; };
  };
}
