def main [] {
  # Get list of sessions
  let sessions = (try {
    zellij list-sessions --no-formatting
  } catch {
    ""
  })

  # Check if we're in a coder environment
  let in_coder = ($env | get --optional CODER_WORKSPACE_NAME | is-not-empty)

  # Prepare options for fzf with new session at top
  let new_session_option = "✨ Create new session"

  let with_coder_option = if $in_coder {
    $new_session_option
  } else {
    $new_session_option + $"\n(ansi yellow)⚡️(ansi reset) Connect to coder workspace"
  }

  let options = if ($sessions | is-empty) {
    $with_coder_option
  } else {
    $with_coder_option + "\n─────────────────────────────────\n" + $sessions
  }

  # Use fzf to select
  let selected = ($options | fzf
    --prompt="Select or create Zellij session: "
    --border
    --preview-window=hidden
    --header="↑/↓ to navigate, Enter to select, Esc to cancel"
    --reverse
    --style=full)

  if ($selected | is-empty) {
    print "No selection made, exiting..."
    exit 0
  }

  if $selected == "✨ Create new session" {
    # Prompt for new session name
    print -n "Enter new session name (or press Enter for auto-generated): "
    let session_name = (input)
    if ($session_name | is-empty) {
      exec zellij
    } else {
      exec zellij --session $session_name
    }
  } else if ($selected | str contains "Connect to coder workspace") {
    # Get list of coder workspaces and connect
    let workspaces = (try {
      coder list --global-config "/Users/luke/Library/Application Support/coderv2"
      | lines
      | where not ($it | str contains "version mismatch")
      | where not ($it | str contains "download v")
      | str join "\n"
      | from ssv
      | get WORKSPACE
      | where $it != ""
      | each { |ws| $ws | split row "/" | last }
    } catch { [] })

    if ($workspaces | length) > 0 {
      let workspace = if ($workspaces | length) == 1 {
        $workspaces | get 0
      } else {
        $workspaces | str join "\n" | fzf --prompt="Select coder workspace: " --height=40% --border
      }

      if ($workspace | is-not-empty) {
        exec ssh $"($workspace).coder"
      }
    } else {
      print "No coder workspaces available"
      exit 1
    }
  } else if ($selected | str starts-with "─────") {
    # Ignore separator line, should not be selectable but just in case
    print "Invalid selection"
    exit 1
  } else {
    # Extract session name from the selected line
    let session_name = ($selected | split row " " | get 0)
    exec zellij attach $session_name
  }
}