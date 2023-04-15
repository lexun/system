self: super:

{
  alacritty-theme = super.callPackage ./alacritty-theme.nix { };
  helix-themes = super.callPackage ./helix-themes.nix { };
  livebook = super.callPackage ./livebook.nix { };
  vscode-update-exts = super.callPackage ./vscode-update-exts { };
}
