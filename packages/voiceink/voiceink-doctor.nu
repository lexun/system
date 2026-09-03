# Diagnose why VoiceInk's hotkey isn't working.
#
# Checks the things that have actually broken, in the order they are worth
# checking. Upstream context:
#   https://github.com/Beingpax/VoiceInk/issues/735
#   https://github.com/Beingpax/VoiceInk/issues/883

const BUNDLE_ID = "com.prakashjoshipax.VoiceInk"
const APP_PATH = "/Applications/VoiceInk.app"

def main [] {
  print ""
  check-secure-input
  check-app
  check-duplicates
  check-shortcut
  check-diagnostics-hint
  print ""
}

# The one that actually broke things. A stale lock from a dead process blocks
# every event tap on the system, so no hotkey in any app receives keys.
def check-secure-input [] {
  print "== Secure Input =="

  let pids = (
    do { ^ioreg -l -w 0 } | complete
    | get stdout
    | parse --regex 'kCGSSessionSecureInputPID"=(?<pid>\d+)'
    | get pid
    | uniq
  )

  if ($pids | is-empty) {
    print "  ok: no secure input lock"
    return
  }

  for pid in $pids {
    let alive = (do { ^kill -0 $pid } | complete).exit_code == 0
    if $alive {
      let name = (do { ^ps -p $pid -o comm= } | complete | get stdout | str trim)
      print $"  BLOCKED by ($name) \(pid ($pid)), still running"
      print "    -> quit that app to release the lock"
    } else {
      print $"  BLOCKED by a dead process \(pid ($pid)): stale lock"
      print "    -> only a logout or reboot clears this"
    }
  }
}

def check-app [] {
  print "== App =="

  if not ($APP_PATH | path exists) {
    print $"  missing: ($APP_PATH). Run: voiceink-update"
    return
  }

  let running = (do { ^pgrep -f "VoiceInk.app/Contents/MacOS" } | complete).exit_code == 0
  print (if $running { "  running" } else { "  not running" })

  # Ad-hoc means TCC grants are pinned to a bare cdhash and die on rebuild.
  let sig = (do { ^codesign -dvvv $APP_PATH } | complete)
  let detail = $"($sig.stdout)($sig.stderr)"
  if ($detail | str contains "Signature=adhoc") {
    print "  signing: ad-hoc (grants are cdhash-pinned, so a rebuild drops them)"
  } else {
    let authority = (
      $detail | lines | where ($it | str starts-with "Authority=")
    )
    if ($authority | is-empty) {
      print "  signing: certificate"
    } else {
      print $"  signing: ($authority | first)"
    }
  }
}

# make local leaves a copy in the build tree, and TCC resolves a bundle id to a
# path. Several copies claiming one id have caused confusing behaviour before.
def check-duplicates [] {
  print "== Bundle copies =="

  let copies = (
    do { ^mdfind $"kMDItemCFBundleIdentifier == '($BUNDLE_ID)'" } | complete
    | get stdout
    | lines
    | where ($it | str trim | is-not-empty)
  )

  if ($copies | length) <= 1 {
    print $"  ok: ($copies | length) copy"
    return
  }

  print $"  ($copies | length) copies share this bundle id:"
  for c in $copies { print $"    ($c)" }
  print "    -> keep only /Applications, then: lsregister -u <stale path>"
}

def check-shortcut [] {
  print "== Shortcut =="

  # `defaults read` elides long blobs with "...", so splicing its hex together
  # yields garbage. `defaults export` emits the whole value as base64 in a plist.
  let exported = (do { ^defaults export $BUNDLE_ID - } | complete)
  if $exported.exit_code != 0 {
    print "  could not read VoiceInk preferences"
    return
  }

  let b64 = (
    $exported.stdout
    | parse --regex '(?s)<key>Shortcut_primaryRecording</key>\s*<data>(?<b64>.*?)</data>'
  )

  if ($b64 | is-empty) {
    print "  none configured: set one in VoiceInk settings"
    return
  }

  let decoded = (
    $b64 | get b64 | first
    | str replace --all --regex '\s' ''
    | decode base64
    | decode utf-8
  )

  let mod_rows = ($decoded | parse --regex '"modifierFlagsRawValue":(?<v>\d+)')
  let key_rows = ($decoded | parse --regex '"keyCode":(?<v>\d+)')
  let modifiers = (if ($mod_rows | is-empty) { "?" } else { $mod_rows | get v | first })
  let keycode = (if ($key_rows | is-empty) { "?" } else { $key_rows | get v | first })
  print $"  configured: modifiers ($modifiers), keyCode ($keycode)"

  # ids 60/61 are input source switching, the classic Option-Space thief.
  let hotkeys = (do { ^defaults read com.apple.symbolichotkeys AppleSymbolicHotKeys } | complete | get stdout)
  if ($keycode == "49") and ($hotkeys | str contains "enabled = 1") {
    print "    note: keyCode 49 is Space. If the shortcut uses Option, confirm"
    print "    'Select next/previous input source' is off in Keyboard settings."
  }
}

def check-diagnostics-hint [] {
  print "== Permissions =="
  print "  Only the app can report these truthfully."
  print "  VoiceInk > Settings > Diagnostics > Export Logs, then read the"
  print "  PERMISSIONS block in ~/Downloads/VoiceInk_Logs_*.log."
  print "  (VoiceInk needs Accessibility, not Input Monitoring: it never"
  print "  requests Input Monitoring, so it cannot appear in that pane.)"
}
