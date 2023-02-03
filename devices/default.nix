{ darwin, flake-utils, home-manager }:

{
  darwinConfigurations = {
    "Lukes-Personal-MBP" = darwin.lib.darwinSystem {
      system = flake-utils.lib.system.x86_64-darwin;
      modules = [
        ../darwin
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.luke = import ../darwin/home;
          users.users.luke.home = "/Users/luke";
        }
      ];
    };
  };
}
