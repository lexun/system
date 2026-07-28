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

  print $"==> Installing to ($APP_PATH)"
  if ($APP_PATH | path exists) { rm -rf $APP_PATH }
  mv $built $APP_PATH
  xattr -cr $APP_PATH

  print $"VoiceInk ($version) installed."

  if not $keep_permissions {
    reset-permissions
  }

  if $was_running {
    ^open $APP_PATH
  } else {
    print $"Launch it with: open ($APP_PATH)"
  }

  if not $keep_permissions {
    print-permission-instructions
  }
}

# Every local build is ad-hoc signed, which means a fresh signature each time.
# macOS ties TCC grants to the signature, so the old grants stop applying while
# System Settings still shows them enabled. Clearing them is what makes the
# breakage visible instead of silent.
#
# The durable fix is signing with a stable self-signed certificate, which would
# let the grants survive rebuilds. Not done yet; this is the stopgap.
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
  print "  This build has a new ad-hoc signature, so macOS discarded VoiceInk's"
  print "  Accessibility and Input Monitoring grants. Until you re-grant them the"
  print "  hotkey will do nothing."
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
