final: prev: {
  beads = prev.callPackage ./beads { };
  git-coauthor = prev.callPackage ./git-coauthor { };
  graphiti-mcp = prev.callPackage ./graphiti-mcp { };
  system-update = prev.callPackage ./system-update { };
  zsm = prev.callPackage ./zsm { };
}
