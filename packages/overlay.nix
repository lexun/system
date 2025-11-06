final: prev: {
  beads = prev.callPackage ./beads { };
  git-coauthor = prev.callPackage ./git-coauthor { };
  system-update = prev.callPackage ./system-update { };
  zsm = prev.callPackage ./zsm { };
}
