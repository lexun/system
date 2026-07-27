def main [] {
  nix-channel --update
  rm -f ~/.ssh/config.rebuild

  if not ("~/.system" | path exists) {
    git clone git@github.com:lexun/system.git ~/.system
  }

  cd ~/.system

  if (git status --porcelain | is-empty) {
    git pull
  }

  if $nu.os-info.name == "linux" {
    if (which nixos-rebuild | is-empty) {
      # Non-NixOS Linux (GCP dev VM, coder workspaces): home-manager standalone.
      # Devices whose homeConfiguration name differs from $USER declare it in
      # ~/.config/system/hm-config (see devices/*.nix). A file, not an env var:
      # home-manager writes sessionVariables only to hm-session-vars.sh, which
      # nushell never sources. Falls back to $USER so coder needs no marker.
      let marker = ($env.HOME | path join ".config/system/hm-config")
      let cfg = if ($marker | path exists) {
        (open $marker | str trim)
      } else {
        $env.USER
      }
      exec nix run $".#homeConfigurations.($cfg).activationPackage"
    } else {
      exec sudo nixos-rebuild switch --flake .
    }
  } else {
    exec sudo darwin-rebuild switch --flake .
  }
}
