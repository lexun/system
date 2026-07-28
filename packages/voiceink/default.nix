{
  writers,
  git,
  cmake,
  gnumake,
}:

# VoiceInk is a GPL-3 macOS dictation app (Superwhisper replacement). Its
# prebuilt binary is a paid license, but building from source is free and
# supported upstream via `make local`.
#
# This is a script rather than a real derivation on purpose: the build drives a
# SwiftUI .xcodeproj through xcodebuild plus a cmake Xcode-generator build of a
# whisper.cpp xcframework, all of which need the full Xcode.app that the Nix
# build sandbox cannot reach. An impure derivation would give up Nix's
# guarantees while keeping its complexity, so the imperative parts stay
# explicit and the recoverable failure modes are checked up front instead.

writers.writeNuBin "voiceink-update" ''
  const NIX_BIN_PATHS = [ "${git}/bin" "${cmake}/bin" "${gnumake}/bin" ]

  ${builtins.readFile ./voiceink-update.nu}
''
