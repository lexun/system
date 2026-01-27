{ writers, symlinkJoin }:

let
  dev-up = writers.writeNuBin "dev-up" (builtins.readFile ./dev-up.nu);
  dev-down = writers.writeNuBin "dev-down" (builtins.readFile ./dev-down.nu);
in
symlinkJoin {
  name = "dev-droplet-scripts";
  paths = [ dev-up dev-down ];
}
