{
  description = "Phoenix Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devenv.flakeModule ];
      systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Per-system attributes can be defined here. The self' and inputs'
      # module parameters provide easy access to attributes of the same
      # system.
      perSystem = { config, self', inputs', pkgs, system, ... }: {
        devenv.shells.default =
          {
            name = "phoenix";

            # https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
            imports = [
              # ./nix/example.nix
            ];

            # https://search.nixos.org/packages
            packages =
              with pkgs;
              let
                argc-pre-release = argc.overrideAttrs (_: _: {
                  src = fetchFromGitHub {
                    owner = "sigoden";
                    repo = "argc";
                    rev = "cf2cb386428641d182154a9b13740122dc2bcd4a";
                    hash = "sha256-DKZmpNWmbPLEivP5CRW+27oWxd0x6grP2bOE/FZ/7l4=";
                  };
                });
              in
              [
                argc-pre-release
                nodePackages.prettier
                shfmt
              ];

            # https://devenv.sh/reference/options/
            languages.elixir = {
              enable = true;
              package = with pkgs; (beam.packagesWith erlangR26).elixir_1_15;
            };
            services.postgres = {
              enable = true;
              initialDatabases = [{ name = "postgres"; }];
              initialScript = "CREATE USER postgres SUPERUSER;";
              listen_addresses = "127.0.0.1";
            };
          };

        formatter = pkgs.nixpkgs-fmt;
      };

      # The usual flake attributes can be defined here, including system-
      # agnostic ones like nixosModule and system-enumerating ones, although
      # those are more easily expressed in perSystem.
      flake = { };
    };
}
