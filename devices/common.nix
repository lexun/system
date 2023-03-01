{ home-manager }:

[
  (import ../darwin)
  home-manager.darwinModules.home-manager
  {
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.users.luke = import ../darwin/home;
    users.users.luke.home = "/Users/luke";
  }
]
