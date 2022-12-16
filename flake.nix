{
  description = "Luke's Nix packages and system configurations.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, darwin, home-manager, flake-utils }:
    let
      config = import ./devices { inherit darwin home-manager flake-utils; };
      packages = import ./packages { inherit self nixpkgs flake-utils; };
    in
    config // packages;
}
