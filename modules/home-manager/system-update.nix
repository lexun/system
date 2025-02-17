{ writers }:

writers.writeNuBin "system-update" ''
  def main [] {
      rm -f ~/.ssh/config.rebuild
      cd ~/.system
      nix-channel --update
      let update_command: string = if $nu.os-info.name == "linux" {
          "sudo nixos-rebuild"
      } else {
          "darwin-rebuild"
      }
      exec $update_command switch --flake .
  }
''
