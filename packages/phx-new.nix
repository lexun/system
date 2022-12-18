{ beamPackages
, fetchFromGitHub
, writeShellApplication
}:

let
  pname = "phx_new";

  version = "1.7.0-rc.0";

  src = fetchFromGitHub {
    owner = "phoenixframework";
    repo = "phoenix";
    rev = "v${version}";
    sha256 = "kCAC3dj9wbPKQss7JA6JE30VYYnKpGUPX3aSp0ZOjho=";
  };

  elixir = beamPackages.elixir_1_14;

  phx-new = beamPackages.mixRelease {
    inherit pname version src elixir;

    buildInputs = [ beamPackages.erlang ];

    buildPhase = ''
      cd installer
      mix compile.elixir --docs
      mix archive.build --no-compile
    '';

    installPhase = ''
      MIX_ENV=prod MIX_ARCHIVES=. mix archive.install --force
      mkdir -p $out/lib
      mv $name/$name/ebin $out/lib
    '';
  };
in

writeShellApplication {
  name = "phx_new";
  runtimeInputs = [ elixir ];
  text = ''
    ERL_LIBS=${phx-new}/lib MIX_ARCHIVES=${phx-new}/lib mix phx.new "$@"
  '';
}
