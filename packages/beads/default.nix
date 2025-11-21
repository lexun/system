{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "beads";
  version = "0.24.0";

  src = fetchFromGitHub {
    owner = "steveyegge";
    repo = "beads";
    rev = "v${version}";
    hash = "sha256-FFotq1HfsT2WKaW/1usxRNxL1MGfvAC7DZIxbvFkQy8=";
  };

  vendorHash = "sha256-oXPlcLVLoB3odBZzvS5FN8uL2Z9h8UMIbBKs/vZq03I=";

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
