let overlay = import ./overlay.nix;
in

{
  perSystem = { config, self, pkgs, ... }: {
    packages = overlay self pkgs;
  };
}
