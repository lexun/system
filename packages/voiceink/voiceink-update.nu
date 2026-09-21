# Build and install VoiceInk from source, then install it to /Applications.
#
# Usage:
#   voiceink-update              # pull latest, build, install
#   voiceink-update --clean      # also rebuild the cached whisper framework
#   voiceink-update --repo PATH  # use a checkout other than ~/workspace/VoiceInk

const REPO_URL = "https://github.com/Beingpax/VoiceInk.git"
const APP_PATH = "/Applications/VoiceInk.app"
const BUNDLE_ID = "com.prakashjoshipax.VoiceInk"

# A stable code-signing identity, created once by hand:
#   Keychain Access > Certificate Assistant > Create a Certificate
#   (Self Signed Root, type Code Signing), then trust it for code signing:
#     security find-certificate -c "VoiceInk Local" -p > cert.pem
#     security add-trusted-cert -r trustRoot -p codeSign \
#       -k ~/Library/Keychains/login.keychain-db cert.pem
#
# An ad-hoc signature's designated requirement is a content-derived cdhash,
# so changing the binary orphans TCC grants. This identity gives local builds
# a stable certificate-bound requirement instead.
#
# An imported identity can appear valid in `security find-identity -v` while
# codesign still needs authorization to use its private key. If a build fails
# with errSecInternalComponent, check for a pending Keychain/SecurityAgent
# prompt for codesign and the intended key. Approve only a request you expect;
# do not apply blanket Always Allow or keychain ACL changes. This is one possible
# cause, not a diagnosis of every errSecInternalComponent failure.
const SIGNING_IDENTITY = "VoiceInk Local"

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
  build-with-local-signing $repo_dir

  let built = ("~/Downloads/VoiceInk.app" | path expand)
  if not ($built | path exists) {
    error make { msg: $"Build reported success but ($built) is missing." }
  }

  # Inspect both artifacts before quitting or replacing the installed app.
  # Failed inspection must not look like two matching empty hashes, nor cause
  # a blind permission reset. No keychain lookup can establish this continuity.
  let permissions = (permission-plan (signature-of $APP_PATH) (signature-of $built))

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

  apply-permission-plan $permissions $keep_permissions

  if $was_running {
    ^open $APP_PATH
  } else {
    print $"Launch it with: open ($APP_PATH)"
  }
}

# Build via `make local`, with the local signing config patched in for the
# duration of the build only.
#
# Two upstream facts force this shape. LocalBuild.xcconfig hardcodes
# CODE_SIGN_IDENTITY = -, and an xcconfig beats an xcodebuild command-line build
# setting, so the LOCAL_CODESIGN_IDENTITY override upstream documents cannot
# take effect on its own (upstream's comment there claims otherwise; it is
# wrong). And ENABLE_HARDENED_RUNTIME = YES from the project file cannot coexist
# with a self-signed certificate: such a cert has no Team ID, the hardened
# runtime requires a process and its frameworks to share one, and the app dies
# at launch on "different Team IDs" loading whisper.framework.
#
# The file is restored afterwards because the update only pulls when the
# checkout is clean, so leaving it modified would silently stop future pulls.
def build-with-local-signing [repo_dir: string] {
  let identity = (signing-identity)
  if $identity == "" {
    run-quietly { ^make local } "build"
    return
  }

  let xcconfig = ([$repo_dir "LocalBuild.xcconfig"] | path join)
  let original = (open --raw $xcconfig)

  $"($original)
// Added by voiceink-update for the duration of this build; see the comment on
// build-with-local-signing. Never committed: a dirty checkout stops git pull.
ENABLE_HARDENED_RUNTIME = NO
CODE_SIGN_IDENTITY = ($identity)
" | save --force $xcconfig

  # try/catch so a failed build still restores the file: leaving it modified
  # would silently stop every future pull.
  try {
    run-quietly { ^make local $"LOCAL_CODESIGN_IDENTITY=($identity)" } "build"
  } catch { |err|
    $original | save --force $xcconfig
    error make { msg: $err.msg }
  }

  $original | save --force $xcconfig
}

# Empty when the named certificate is missing or untrusted. The upstream build
# then chooses its default identity; inspect the output rather than assuming
# which signature resulted.
def signing-identity [] {
  let found = (do { ^security find-identity -v -p codesigning } | complete)
  if ($found.stdout | str contains $SIGNING_IDENTITY) {
    return $SIGNING_IDENTITY
  }

  print $"    no valid \"($SIGNING_IDENTITY)\" certificate; using the upstream signing default"
  print "    permission handling will use the built app's actual signature"
  ""
}

# Missing is distinct from unreadable or invalid: a first install has no old
# grants to reset, whereas failed inspection must stop before installation.
def signature-of [app_path: string] {
  if not ($app_path | path exists) { return null }

  let verified = (do { ^codesign --verify --strict $app_path } | complete)
  if $verified.exit_code != 0 {
    error make { msg: $"Cannot verify signature of ($app_path); not installing or resetting permissions. ($verified.stderr)" }
  }

  let result = (do { ^codesign -dvvv -r- $app_path } | complete)
  if $result.exit_code != 0 {
    error make { msg: $"Cannot inspect signature of ($app_path); not installing or resetting permissions. ($result.stderr)" }
  }
  let output = ($"($result.stdout)\n($result.stderr)" | lines)
  let hashes = ($output | parse --regex '^CDHash=(?<hash>[0-9a-fA-F]{40})$')
  # codesign prefixes synthesized ad-hoc requirements with '# '.
  let requirements = ($output | parse --regex '^(?:# )?designated => (?<requirement>.+)$')
  let identifiers = ($output | parse --regex '^Identifier=(?<identifier>.+)$')
  if ($hashes | length) != 1 or ($requirements | length) != 1 or ($identifiers | length) != 1 {
    error make { msg: $"Incomplete signature information for ($app_path); not installing or resetting permissions." }
  }
  if $identifiers.0.identifier != $BUNDLE_ID {
    error make { msg: $"Unexpected bundle identifier for ($app_path); not installing or resetting permissions." }
  }

  let requirement = $requirements.0.requirement
  # Only recognize the exact leaf-pinned requirement generated by our local
  # certificate signing. Do not mistake a broad/custom requirement containing
  # the word 'certificate' for stable identity. Other changed signatures take
  # the conservative reset path, even if codesign considers them valid.
  let leaf_pinned = ($requirement =~ '^identifier "com\.prakashjoshipax\.VoiceInk" and certificate leaf = H"[0-9a-fA-F]{40}"$')
  let has_authority = ($output | any { |line| $line | str starts-with 'Authority=' })
  let adhoc = ('Signature=adhoc' in $output)
  {
    cdhash: ($hashes.0.hash | str downcase)
    requirement: $requirement
    certificate_bound: ($leaf_pinned and $has_authority and (not $adhoc))
  }
}

# This is a continuity check, not proof that the user has granted permissions.
# A new certificate, a changed ad-hoc binary, or a signing-mode transition must
# not inherit the old grant merely because a certificate exists in the keychain.
def permission-plan [previous: any, current: any] {
  if $current == null {
    error make { msg: "Built app is missing; not installing or resetting permissions." }
  }
  if $previous == null {
    return {reset: false, instructions: true, reason: "first install; grant permissions on launch"}
  }
  if $previous.cdhash == $current.cdhash and $previous.requirement == $current.requirement {
    return {reset: false, instructions: false, reason: "signature is unchanged; permissions left alone"}
  }
  if $previous.certificate_bound and $current.certificate_bound and $previous.requirement == $current.requirement {
    return {reset: false, instructions: false, reason: "certificate-bound identity is unchanged; permissions left alone"}
  }
  {reset: true, instructions: true, reason: "signing identity changed or continuity could not be established"}
}

def apply-permission-plan [plan: record, keep_permissions: bool] {
  if $keep_permissions {
    print "    permissions left alone as requested (--keep-permissions)"
    return
  }
  print $"    ($plan.reason)"
  if $plan.reset { reset-permissions }
  if $plan.instructions { print-permission-instructions }
}

# Reset only after a verified signing transition, never just a CDHash change
# under the same leaf-pinned certificate. Accessibility gates the active event
# tap; ScreenCapture gates context enrichment, not the hotkey.
def reset-permissions [] {
  print "==> Clearing stale macOS permissions"
  for service in ["Accessibility" "ScreenCapture"] {
    do { ^tccutil reset $service $BUNDLE_ID } | complete | ignore
  }
}

def print-permission-instructions [] {
  print ""
  print "ACTION REQUIRED — re-grant permissions"
  print ""
  print "  This is a first install or the previous signing identity wasn't retained."
  print "  Check VoiceInk's Accessibility and Screen Recording permissions."
  print "  Accessibility is needed for the hotkey; Screen Recording is for context."
  print ""
  print "    1. Approve the Accessibility prompt VoiceInk shows on launch."
  print "    2. No prompt? Open System Settings > Privacy & Security >"
  print "       Accessibility and switch VoiceInk on."
  print "    3. Recording broken instead of the hotkey? Check the same"
  print "       Privacy & Security pane under Microphone."
  print ""
  print "  VoiceInk needs Accessibility, not Input Monitoring. It never requests"
  print "  Input Monitoring, so it cannot appear in that pane."
  print ""
  print "  Hotkey dead while permissions look fine? Run: voiceink-doctor"
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
# "cannot execute tool 'metal'". A located binary can be a shim whose backing
# toolchain is absent, so execute it instead of trusting `xcrun --find metal`.
# The component is large and its size varies by Xcode release.
def ensure-metal-toolchain [] {
  if (do { ^xcrun metal --version } | complete).exit_code == 0 {
    return
  }

  print "==> Downloading the Metal toolchain (size varies by Xcode version)"
  let result = (do { ^xcodebuild -downloadComponent MetalToolchain } | complete)
  if $result.exit_code != 0 {
    error make { msg: "Could not download the Metal toolchain. Run: xcodebuild -downloadComponent MetalToolchain" }
  }
  let probe = (do { ^xcrun metal --version } | complete)
  if $probe.exit_code != 0 {
    error make { msg: $"Metal still cannot run after the download. Check `xcrun metal --version` before rebuilding. ($probe.stderr)" }
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
