{ beamPackages
, fetchFromGitHub
, lib
, makeWrapper
}:

let
  pname = "livebook";

  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "livebook-dev";
    repo = "livebook";
    rev = "v${version}";
    sha256 = "sha256-khC3gtRvywgAY6qHslZgAV3kmziJgKhdCB8CDg/HkIU=";
  };

  mixFodDeps = beamPackages.fetchMixDeps {
    pname = "mix-deps-${pname}";
    inherit src version;
    sha256 = "sha256-rwWGs4fGeuyV6BBFgCyyDwKf/YLgs1wY0xnHYy8iioE=";
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
