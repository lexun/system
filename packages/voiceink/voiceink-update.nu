# Build and install VoiceInk from source, then install it to /Applications.
#
# Usage:
#   voiceink-update              # pull latest, build, install
#   voiceink-update --clean      # also rebuild the cached whisper framework
#   voiceink-update --repo PATH  # use a checkout other than ~/workspace/VoiceInk

const REPO_URL = "https://github.com/Beingpax/VoiceInk.git"
const APP_PATH = "/Applications/VoiceInk.app"
const BUNDLE_ID = "com.prakashjoshipax.VoiceInk"

def main [
  --repo: string = "~/workspace/VoiceInk" # checkout location
  --clean # rebuild the whisper framework from scratch
  --keep-permissions # don't reset macOS permissions after installing
] {
  $env.PATH = ($env.PATH | prepend $NIX_BIN_PATHS)

  let repo_dir = ($repo | path expand)

  preflight-xcode

  # Source
  if not ($repo_dir | path exists) {
    print $"==> Cloning VoiceInk into ($repo_dir)"
    git clone $REPO_URL $repo_dir
  } else {
    print $"==> Updating ($repo_dir)"
    cd $repo_dir
    if (git status --porcelain | is-empty) {
      git pull
    } else {
      print "    local changes present, skipping pull"
    }
  }

  cd $repo_dir
  let version = (version-of)

  # Build. The output runs to thousands of lines, so it goes to a log and only
  # surfaces if something actually fails.
  if $clean {
    print "==> Removing cached whisper framework"
    run-quietly { ^make clean } "clean"
  }
  print $"==> Building VoiceInk ($version). A cold build takes several minutes."
  run-quietly { ^make local } "build"

  let built = ("~/Downloads/VoiceInk.app" | path expand)
  if not ($built | path exists) {
    error make { msg: $"Build reported success but ($built) is missing." }
  }

  # Install
  let was_running = (app-running)
  if $was_running {
    print "==> Quitting the running VoiceInk"
    try { osascript -e 'quit app "VoiceInk"' }
    sleep 2sec
  }

  # A rebuild with unchanged inputs is bit-identical, so compare signatures to
  # decide whether macOS will actually care. Must happen before the move.
  let binary_changed = ((cdhash-of $APP_PATH) != (cdhash-of $built))

  print $"==> Installing to ($APP_PATH)"
  if ($APP_PATH | path exists) { rm -rf $APP_PATH }
  mv $built $APP_PATH
  xattr -cr $APP_PATH

  print $"VoiceInk ($version) installed."

  if not $binary_changed {
    print "    binary is identical to the previous build; permissions left alone"
  } else if $keep_permissions {
    print "    binary changed, but permissions left alone as requested"
  } else {
    reset-permissions
  }

  if $was_running {
    ^open $APP_PATH
  } else {
    print $"Launch it with: open ($APP_PATH)"
  }

  if $binary_changed and (not $keep_permissions) {
    print-permission-instructions
  }
}

# Empty string when the app isn't present or has no signature.
def cdhash-of [app_path: string] {
  if not ($app_path | path exists) { return "" }

  let result = (do { ^codesign -dvvv $app_path } | complete)
  let lines = ($"($result.stdout)\n($result.stderr)"
    | lines
    | where ($it | str starts-with "CDHash="))

  if ($lines | is-empty) { "" } else { $lines | first | str replace "CDHash=" "" | str trim }
}

# Local builds are ad-hoc signed, so a build whose output actually differs gets
# a new signature, and macOS stops honouring the old TCC grants while System
# Settings still shows them switched on. Clearing them makes that visible rather
# than silent.
#
# Observed 2026-07-28: the rejection may not appear until the next reboot, so an
# update can seem fine for days and then break. That's why this warns loudly
# instead of waiting for symptoms.
#
# The durable fix is signing with a stable self-signed certificate so grants
# survive rebuilds entirely. Not done yet; this is the stopgap.
def reset-permissions [] {
  print "==> Clearing stale macOS permissions"
  for service in ["Accessibility" "ListenEvent"] {
    do { ^tccutil reset $service $BUNDLE_ID } | complete | ignore
  }
}

def print-permission-instructions [] {
  print ""
  print "ACTION REQUIRED — re-grant permissions"
  print ""
  print "  This build's contents changed, so it has a new ad-hoc signature and"
  print "  macOS discarded VoiceInk's Accessibility and Input Monitoring grants."
  print "  Until you re-grant them the hotkey will do nothing. Note the breakage"
  print "  can also surface later, after your next reboot."
  print ""
  print "    1. Approve the Accessibility prompt VoiceInk shows on launch."
  print "    2. No prompt? Open System Settings > Privacy & Security >"
  print "       Accessibility and switch VoiceInk on."
  print "    3. Recording broken instead of the hotkey? Check the same"
  print "       Privacy & Security pane under Microphone."
  print ""
  print "  Keep the existing grants instead with: voiceink-update --keep-permissions"
  print ""
}

# Xcode checks. Nix cannot own any of this state, but a clear failure here is
# far better than the misleading cmake error it otherwise produces.
def preflight-xcode [] {
  if not ("/Applications/Xcode.app" | path exists) {
    error make { msg: "VoiceInk needs the full Xcode, not just the Command Line Tools. Install Xcode, then run: sudo xcode-select -s /Applications/Xcode.app" }
  }

  let selected = (xcode-select -p | str trim)
  if not ($selected | str starts-with "/Applications/Xcode.app") {
    error make { msg: $"xcode-select points at ($selected). Run: sudo xcode-select -s /Applications/Xcode.app" }
  }

  # Apple's imperative /Library/Developer content goes stale after an Xcode
  # upgrade. When it does, plugin loading fails and every cmake
  # Xcode-generator build dies with a misleading "No CMAKE_CXX_COMPILER could
  # be found". This is idempotent and takes a few seconds, so just always run
  # it rather than trying to detect the broken state.
  print "==> Ensuring Xcode components are current"
  let first_launch = (do { ^xcodebuild -runFirstLaunch } | complete)
  if $first_launch.exit_code != 0 {
    print "    runFirstLaunch failed; continuing anyway"
  }

  trust-package-plugins
  ensure-metal-toolchain
}

# mlx-swift ships a CudaBuild build-tool plugin and mlx-swift-lm ships the
# MLXHuggingFaceMacros macro. Xcode refuses to run either until it has been
# trusted, which in the GUI is a "Trust & Enable" prompt. xcodebuild cannot show
# that prompt, so a headless build just fails with "must be enabled before it
# can be used" (observed 2026-08-27, after mlx entered the dependency tree).
#
# The equivalent non-interactive consent is these two defaults. They are set
# here rather than by patching upstream's Makefile: the update pulls only when
# the checkout is clean, so a local Makefile edit would silently stop pulls.
#
# Note the misspelled "Validatation" key — that typo is Xcode's, and the
# correctly spelled variant has no effect.
def trust-package-plugins [] {
  print "==> Trusting VoiceInk's package plugins and macros"
  for key in ["IDESkipPackagePluginFingerprintValidatation" "IDESkipMacroFingerprintValidation"] {
    do { ^defaults write com.apple.dt.Xcode $key -bool YES } | complete | ignore
  }
}

# whisper.cpp's Metal kernels need the Metal toolchain, which Xcode 26 splits
# out into a separately downloaded component. Without it the build dies on
# "cannot execute tool 'metal'". The download is ~700MB, so only fetch it when
# the compiler is actually missing.
def ensure-metal-toolchain [] {
  if (do { ^xcrun --find metal } | complete).exit_code == 0 {
    return
  }

  print "==> Downloading the Metal toolchain (~700MB, one time)"
  let result = (do { ^xcodebuild -downloadComponent MetalToolchain } | complete)
  if $result.exit_code != 0 {
    error make { msg: "Could not download the Metal toolchain. Run: xcodebuild -downloadComponent MetalToolchain" }
  }
}

# Run a command with its output captured to a log, showing the tail only on
# failure so a successful update stays readable.
def run-quietly [action: closure, label: string] {
  let log_path = $"/tmp/voiceink-($label)-(date now | format date '%Y%m%dT%H%M%S').log"
  let result = (do $action | complete)
  $"($result.stdout)\n($result.stderr)" | save -f $log_path

  if $result.exit_code != 0 {
    print $"    last 30 lines of ($log_path):"
    print ($result.stdout | lines | last 30 | str join "\n")
    error make { msg: $"VoiceInk ($label) failed with exit code ($result.exit_code). Full log: ($log_path)" }
  }
  print $"    ok. log: ($log_path)"
}

def version-of [] {
  # Shallow clones have no tags, so fall back to a short sha.
  try {
    git describe --tags --always | str trim
  } catch {
    try { git rev-parse --short HEAD | str trim } catch { "unknown" }
  }
}

def app-running [] {
  (ps | where name =~ "VoiceInk" | length) > 0
}
