{ home-manager }:

[
  (import ../darwin)
  home-manager.darwinModules.home-manager
  {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    users.users.luke.home = "/Users/luke";
  }
]
