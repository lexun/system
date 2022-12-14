{ beamPackages
, fetchFromGitHub
, lib
, makeWrapper
}:

let
  pname = "livebook";

  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "livebook-dev";
    repo = "livebook";
    rev = "v${version}";
    sha256 = "0HsJGve4sLQ9cXpwwmMyo4R/wHaCwr22N32OX7O//oo=";
  };

  mixFodDeps = beamPackages.fetchMixDeps {
    pname = "mix-deps-${pname}";
    inherit src version;
    sha256 = "tWJ4Rdv4TAY/6XI8cI7/GUfRXW34vrx2ZXlJYxDSGsU=";
  };

  elixir = beamPackages.elixir_1_14;
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
