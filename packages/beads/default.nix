{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "beads";
  version = "0.22.0";

  src = fetchFromGitHub {
    owner = "steveyegge";
    repo = "beads";
    rev = "v${version}";
    hash = "sha256-n/nv7FoCvJQiGN3ibQgxNWYOLMLwzzGxdwm5cJW+uwI=";
  };

  vendorHash = "sha256-eUwVXAe9d/e3OWEav61W8lI0bf/IIQYUol8QUiQiBbo=";

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
