{ self, nixpkgs, flake-utils }:

let overlay = import ./overlay.nix;
in
{ inherit overlay; } //
flake-utils.lib.eachDefaultSystem (system:
  let pkgs = import nixpkgs { inherit system overlay; };
  in { packages = overlay self pkgs; }
)
