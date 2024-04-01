{
  description = "My Project";

  inputs = {
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    devenv.url = "github:cachix/devenv";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devenv.flakeModule ];
      systems = [ "aarch64-darwin" "aarch64-linux" "i686-linux" "x86_64-darwin" "x86_64-linux" ];

      # Per-system attributes can be defined here. The self' and inputs'
      # module parameters provide easy access to attributes of the same
      # system.
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        devenv.shells.default = {
          name = "my_project";

          # https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
          imports = [
            # ./nix/example.nix
          ];

          # https://search.nixos.org/packages
          packages = with pkgs; [
            argc
            lftp
            libiconv
            nodePackages.prettier
            shfmt
          ];

          # https://devenv.sh/reference/options/
          processes.app.exec = "echo 'Hello, World!' && read -r _";
        };

        formatter = pkgs.nixpkgs-fmt;
      };

      # The usual flake attributes can be defined here, including system-
      # agnostic ones like nixosModule and system-enumerating ones, although
      # those are more easily expressed in perSystem.
      flake = { };
    };
}
