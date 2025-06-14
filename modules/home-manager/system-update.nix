{ writers }:

writers.writeNuBin "system-update" ''
  def main [] {
      rm -f ~/.ssh/config.rebuild
      cd ~/.system
      nix-channel --update
      if $nu.os-info.name == "linux" {
          exec sudo nixos-rebuild switch --flake .
      } else {
          exec sudo darwin-rebuild switch --flake .
      }
  }
''
