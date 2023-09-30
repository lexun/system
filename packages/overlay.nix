self: super:

let
  erlang = super.erlangR26;
  beamPkgs = super.beam.packagesWith erlang;
in

{
  elixir = beamPkgs.elixir_1_15;
  livebook = super.callPackage ./livebook.nix { };
}
