{ writers }:

writers.writeNuBin "setup-battlenet" (builtins.readFile ./setup-battlenet.nu)
