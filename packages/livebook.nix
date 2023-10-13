{ beamPackages
, fetchFromGitHub
, lib
, makeWrapper
}:

let
  pname = "livebook";

  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "livebook-dev";
    repo = "livebook";
    rev = "v${version}";
    hash = "sha256-8td6BUaJiEPjABrfsJTvaA+PXZ+8PnRl2hj7Ft/kb+Q=";
  };

  mixFodDeps = beamPackages.fetchMixDeps {
    pname = "mix-deps-${pname}";
    inherit src version;
    hash = "sha256-xc5AyIYbsvjNPKMPavSnxDgf7lNGWWlEgL/6/9ICR0Y=";
  };

  elixir = beamPackages.elixir_1_15;
in

beamPackages.mixRelease {
  inherit pname version src elixir mixFodDeps;

  buildInputs = [ beamPackages.erlang ];
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mix escript.build
    mkdir -p $out/bin
    mv ./livebook $out/bin

    wrapProgram $out/bin/livebook \
      --prefix PATH : ${lib.makeBinPath [ elixir ]} \
      --prefix ERL_LIBS : "${beamPackages.hex}/lib/erlang/lib" \
      --set MIX_REBAR3 ${beamPackages.rebar3}/bin/rebar3
  '';
}
