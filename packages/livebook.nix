{ beamPackages
, fetchFromGitHub
, lib
, makeWrapper
}:

let
  pname = "livebook";

  version = "0.12.1";

  src = fetchFromGitHub {
    owner = "livebook-dev";
    repo = "livebook";
    rev = "v${version}";
    hash = "sha256-Q4c0AelZZDPxE/rtoHIRQi3INMLHeiZ72TWgy183f4Q=";
  };

  mixFodDeps = beamPackages.fetchMixDeps {
    pname = "mix-deps-${pname}";
    inherit src version;
    hash = "sha256-x/VvXB2rJ03c3tWZRXnD3gbTT494P8GVD0sYEHcTp3o=";
  };

  elixir = beamPackages.elixir_1_16;
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
