{ writers }:

writers.writeNuBin "system-update" (builtins.readFile ./system-update.nu)