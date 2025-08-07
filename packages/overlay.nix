final: prev: {
  git-coauthor = prev.callPackage ./git-coauthor { };
  system-update = prev.callPackage ./system-update { };
  zsm = prev.callPackage ./zsm { };

  carapace = prev.carapace.overrideAttrs (oldAttrs: {
    version = "1.4.1";
    src = prev.fetchFromGitHub {
      owner = "carapace-sh";
      repo = "carapace-bin";
      tag = "v1.4.1";
      hash = "sha256-aI69LQuyXUGqxjcUIH3J8AG7cgn/onBg0mZc+zz+YrA=";
    };
    vendorHash = "sha256-AwR+Oh1Rlg1z/pYdc9VDvp/FLH1ZiPsP/q4lks3VqqE=";
  });
}
