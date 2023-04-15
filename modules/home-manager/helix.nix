{ pkgs, ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "edge_default";
    };
  };

  home.file.".config/helix/themes" = {
    source = pkgs.helix-themes;
    target = ".config/helix/themes";
  };
}
