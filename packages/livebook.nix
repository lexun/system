{ beamPackages
, fetchFromGitHub
, lib
, makeWrapper
}:

let
  pname = "livebook";

  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "livebook-dev";
    repo = "livebook";
    rev = "v${version}";
    sha256 = "sha256-z2nNNp+gyB3hfI0RoaXkKm/+/gjzcCY3fzV0CMr6UJw=";
  };

  mixFodDeps = beamPackages.fetchMixDeps {
    pname = "mix-deps-${pname}";
    inherit src version;
    sha256 = "sha256-w0ytJuzsCvRMNpy+bSYMwT/5yCg+tJ+Vf4ESE6BlZKY=";
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
