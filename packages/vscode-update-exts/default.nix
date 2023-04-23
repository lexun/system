{ stdenv, fetchurl }:

let
  repo = "nixos/nixpkgs";
  rev = "7f2ace396aacc4bf07fab9b2bad8ce35c3e0d82c";
  file = "pkgs/applications/editors/vscode/extensions/update_installed_exts.sh";
in

stdenv.mkDerivation rec {
  pname = "vscode-update-exts";
  version = "0.0.1";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/${repo}/${rev}/${file}";
    sha256 = "sha256-+VczWApzt68jcjuDsHWsuBIacafEmRrWNEjCw88jo7Q=";
    executable = true;
  };

  unpackPhase = ''
    cp $src ./update_installed_exts.sh
  '';

  patches = [ ./patch.diff ];

  installPhase = ''
    mkdir -p $out/bin
    cp update_installed_exts.sh $out/bin/vscode-update-exts
  '';
}

