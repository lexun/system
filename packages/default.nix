{ inputs, ... }:

let overlay = import ./overlay.nix;
in
{
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];
  perSystem = { config, pkgs, self, ... }: {
    overlayAttrs = config.packages;
    packages = (overlay self pkgs);
  };
}
