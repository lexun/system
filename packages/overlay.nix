self: super:

{
  livebook = super.callPackage ./livebook.nix { };
  phx-new = super.callPackage ./phx-new.nix { };
}
