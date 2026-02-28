{ writers, symlinkJoin, python3, writeShellScriptBin }:

let
  setup-battlenet = writers.writeNuBin "setup-battlenet" (builtins.readFile ./setup-battlenet.nu);
  add-steam-shortcut = writeShellScriptBin "add-steam-shortcut" ''
    exec ${python3.withPackages (ps: [])}/bin/python3 ${./add-steam-shortcut.py} "$@"
  '';
in
symlinkJoin {
  name = "setup-battlenet";
  paths = [ setup-battlenet add-steam-shortcut ];
}
