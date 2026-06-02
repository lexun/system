{ inputs }:

let
  inherit (inputs) darwin home-manager;
in
darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    home-manager.darwinModules.home-manager
    ../modules/nix-darwin
    {
      homebrew.casks = [
        "blender"
        "godot"
        "krita"
        "obsidian"
        "telegram"
        "wacom-tablet"
      ];
    }
  ];
  specialArgs = {
    inherit inputs;
  };
}
