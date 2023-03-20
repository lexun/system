{
  description = "Luke's Nix packages and system configurations.";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";

    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixified-ai.url = "github:nixified-ai/flake";
    nixified-ai.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, darwin, home-manager, flake-utils, nixified-ai }:
    let
      devices = import ./devices { inherit darwin home-manager flake-utils nixpkgs nixified-ai; };
      packages = import ./packages { inherit self nixpkgs flake-utils; };
    in
    devices // packages // { templates = import ./templates; };
}
