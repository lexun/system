{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "beads";
  version = "0.21.9";

  src = fetchFromGitHub {
    owner = "steveyegge";
    repo = "beads";
    rev = "v${version}";
    hash = "sha256-Z3hRlZpoq/Y/vtD3b5OuOUXOPmEGp4Z4EA3N6Srj8Fw=";
  };

  vendorHash = "sha256-m/2e3OxM4Ci4KoyH+leEt09C/CpD9SRrwPd39/cZQ9E=";

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  # Tests require network access and git setup
  doCheck = false;

  meta = {
    mainProgram = "bd";
  };
}
