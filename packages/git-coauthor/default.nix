{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "git-coauthor";
  version = "1.2.1-alpha";

  src = fetchFromGitHub {
    owner = "simoleone";
    repo = "git-coauthor";
    rev = "b4d31a81e66ee8ab4c0d18b1cddf1af8cb205cd2";
    sha256 = "sha256-q8ITTBxSMii/lzch3juKirZy4FlZtiubJR0PNe3TXI0=";
  };

  patches = [
    ./config-file.patch
  ];

  installPhase = ''
    install -Dm755 git-coauthor $out/bin/git-coauthor
  '';
}

