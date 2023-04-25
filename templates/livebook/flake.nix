{
  description = "Livebook environment";

  inputs.devshell.url = "github:numtide/devshell";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.livebook.url = "github:lexun/system";

  outputs = { self, nixpkgs, devshell, flake-utils, livebook }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            livebook.overlays.default
            devshell.overlays.default
          ];
        };
      in
      {
        devShell = pkgs.devshell.mkShell {
          imports = [ (pkgs.devshell.importTOML ./devshell.toml) ];
        };
      }
    );
}
