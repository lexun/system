{ darwin, home-manager }:

darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    home-manager.darwinModules.home-manager
    ../modules/nix-darwin
    {
      homebrew.casks = [
        "amazon-workspaces"
        "hex-fiend"
        "tandem"
        "dbvisualizer"
      ];
      home-manager.users.luke = {
        programs.zsh = {
          profileExtra = ''eval "$(/opt/homebrew/bin/brew shellenv)"'';
        };
      };
    }
  ];
}
