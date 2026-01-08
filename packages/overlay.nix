final: prev: {
  beads = prev.callPackage ./beads { };
  git-coauthor = prev.callPackage ./git-coauthor { };
  graphiti-mcp = prev.callPackage ./graphiti-mcp { };
  system-update = prev.callPackage ./system-update { };
  zsm = prev.callPackage ./zsm { };

  # Skip flaky NarinfoQuery tests on Darwin (fixed upstream in cachix PR #715,
  # but not yet released in nixpkgs)
  cachix = prev.cachix.overrideAttrs (oldAttrs: prev.lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
    doCheck = false;
  });

  # Fix rocksdb build on macOS - the BUILTIN_ATOMIC check fails on ARM64
  # because it uses x86-only compiler flags, causing it to incorrectly
  # try to link against -latomic (which doesn't exist on macOS)
  rocksdb = prev.rocksdb.overrideAttrs (oldAttrs: {
    cmakeFlags = (oldAttrs.cmakeFlags or [ ]) ++ prev.lib.optionals prev.stdenv.hostPlatform.isDarwin [
      "-DCMAKE_CXX_STANDARD=20"
    ];
    # Patch the CMakeLists.txt to skip the broken atomic check on Darwin
    postPatch = (oldAttrs.postPatch or "") + prev.lib.optionalString prev.stdenv.hostPlatform.isDarwin ''
      substituteInPlace CMakeLists.txt \
        --replace-fail 'if (NOT BUILTIN_ATOMIC)' 'if (FALSE)'
    '';
  });
}
