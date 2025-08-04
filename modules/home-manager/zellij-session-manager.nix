{ writers }:

writers.writeNuBin "zsm" ''
  def main [] {
    # Get list of sessions
    let sessions = (try { 
      zellij list-sessions --no-formatting 
    } catch { 
      "" 
    })
    
    # Prepare options for fzf
    let options = if ($sessions | is-empty) {
      "📝 Create new session"
    } else {
      $sessions + "\n📝 Create new session"
    }
    
    # Use fzf to select
    let selected = ($options | fzf 
      --prompt="Select or create Zellij session: "
      --height=40%
      --border
      --preview-window=hidden
      --header="↑/↓ to navigate, Enter to select, Esc to cancel")
    
    if ($selected | is-empty) {
      print "No selection made, exiting..."
      exit 0
    }
    
    if $selected == "📝 Create new session" {
      # Prompt for new session name
      print -n "Enter new session name (or press Enter for auto-generated): "
      let session_name = (input)
      if ($session_name | is-empty) {
        exec zellij
      } else {
        exec zellij --session $session_name
      }
    } else {
      # Extract session name from the selected line
      let session_name = ($selected | split row " " | get 0)
      exec zellij attach $session_name
    }
  }
''
