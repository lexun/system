{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "alacritty-theme";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "alacritty";
    repo = "alacritty-theme";
    rev = "981f48c9e4de2c0b657ed23a8ca425d8bf6ae0c7";
    sha256 = "ABZFJx+TbGtAr84WVTgB2Oa6MAHhQFoORInVjbw3UGk=";
  };

  installPhase = ''
    cp -r $src/themes $out
  '';
}

