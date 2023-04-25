{ self, nixpkgs, flake-utils }:

let overlay = import ./overlay.nix;
in
{ overlays.default = overlay; } //
flake-utils.lib.eachDefaultSystem (system:
  let pkgs = import nixpkgs { inherit system; };
  in { packages = overlay self pkgs; }
)
