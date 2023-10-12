{ darwin, home-manager }:

darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    home-manager.darwinModules.home-manager
    ../modules/nix-darwin
    {
      homebrew.casks = [
        "amazon-workspaces"
        "cursor"
        "dbvisualizer"
        "hex-fiend"
        "imhex"
        "kap"
        "tandem"
        "tuple"
      ];
      home-manager.users.luke = {
        programs.go.enable = true;
        programs.zsh = {
          profileExtra = ''eval "$(/opt/homebrew/bin/brew shellenv)"'';
        };
      };
    }
  ];
}
