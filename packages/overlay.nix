self: super:

let
  erlang = super.erlang_26;
  beamPackages = super.beam.packagesWith erlang;
in

{
  elixir = beamPackages.elixir_1_15;
  livebook = super.callPackage ./livebook.nix { inherit beamPackages; };
}
