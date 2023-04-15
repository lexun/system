{ stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "helix-themes";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "CptPotato";
    repo = "helix-themes";
    rev = "0ebf77d9e1dc3ee71fbb2a2956810cfc131d0008";
    sha256 = "Cr4NEEFq3XOmOvbsYpRUGkOY1Mq7wIFJzxVhf8e9T0c=";
  };

  configurePhase = "chmod +x ./build.sh";
  buildPhase = "./build.sh";
  installPhase = "cp -r build $out";
}

