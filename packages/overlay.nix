self: super:

{
  livebook = super.callPackage ./livebook.nix { };
  vscode-update-exts = super.callPackage ./vscode-update-exts { };
}
