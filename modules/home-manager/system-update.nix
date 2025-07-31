{ writers }:

writers.writeNuBin "system-update" ''
  def main [] {
      nix-channel --update
      rm -f ~/.ssh/config.rebuild

      if not ("~/.system" | path exists) {
          git clone https://github.com/lexun/system ~/.system
      }
      cd ~/.system

      if $nu.os-info.name == "linux" {
          if $env.USER == "coder" {
              exec nix run .#homeConfigurations.coder.activationPackage
          } else {
              exec sudo nixos-rebuild switch --flake .
          }
      } else {
          exec sudo darwin-rebuild switch --flake .
      }
  }
''
