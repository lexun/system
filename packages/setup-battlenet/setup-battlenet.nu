const INSTALLER_URL = "https://www.battle.net/download/getInstallerForGame?os=win&gameProgram=BATTLENET_APP"

def battlenet-env [] {
  {
    WINEPREFIX: ($"($env.HOME)/Games/battlenet/prefix")
    GAMEID: "umu-battlenet"
    PROTONPATH: "GE-Proton"
  }
}

def launcher-path [] {
  [$env.HOME "Games" "battlenet" "prefix" "drive_c" "Program Files (x86)" "Battle.net" "Battle.net Launcher.exe"] | path join
}

# Download and install Battle.net with Proton
def "main install" [] {
  let dir = $"($env.HOME)/Games/battlenet"
  let installer = $"($dir)/Battle.net-Setup.exe"

  mkdir $dir

  if not ($installer | path exists) {
    print "Downloading Battle.net installer..."
    ^curl -L -o $installer $INSTALLER_URL
  }

  print "Installing Battle.net with Proton..."
  print "Complete the installer, then close Battle.net when done."

  with-env (battlenet-env) {
    ^umu-run $installer
  }

  print "Done. Launch with: setup-battlenet"
}

# Launch Battle.net
def main [] {
  let launcher = (launcher-path)

  if not ($launcher | path exists) {
    print "Battle.net is not installed yet."
    print ""
    print "To install, run: setup-battlenet install"
    return
  }

  with-env (battlenet-env) {
    ^umu-run $launcher
  }
}
