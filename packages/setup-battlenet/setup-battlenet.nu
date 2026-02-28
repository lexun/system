const INSTALLER_URL = "https://www.battle.net/download/getInstallerForGame?os=win&gameProgram=BATTLENET_APP"

def launcher-path [] {
  let steam = $"($env.HOME)/.local/share/Steam"
  [$steam "steamapps" "compatdata" "3735928559" "pfx" "drive_c" "Program Files (x86)" "Battle.net" "Battle.net Launcher.exe"] | path join
}

# Download Battle.net installer and add it to Steam
def "main install" [] {
  let dir = $"($env.HOME)/Games/battlenet"
  let installer = $"($dir)/Battle.net-Setup.exe"

  mkdir $dir

  if not ($installer | path exists) {
    print "Downloading Battle.net installer..."
    ^curl -L -o $installer $INSTALLER_URL
  }

  print "Adding Battle.net to Steam..."
  ^add-steam-shortcut install

  print ""
  print "Next steps:"
  print "  1. Restart Steam"
  print "  2. Find 'Battle.net' in your Steam library"
  print "  3. Right-click → Properties → Compatibility → Force GE-Proton"
  print "  4. Click Play to run the installer"
  print "  5. Complete the installer, then close Battle.net"
  print "  6. Run: setup-battlenet finish"
}

# Update Steam shortcut from installer to launcher
def "main finish" [] {
  ^add-steam-shortcut finish
}

# Open Steam to play Battle.net
def main [] {
  if not (launcher-path | path exists) {
    print "Battle.net is not installed yet."
    print ""
    print "To install, run: setup-battlenet install"
    return
  }

  ^steam
}
