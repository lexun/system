{ inputs }:

let
  inherit (inputs) darwin home-manager;
in
darwin.lib.darwinSystem {
  system = "aarch64-darwin";
  modules = [
    home-manager.darwinModules.home-manager
    ../modules/nix-darwin
    ({ pkgs, ... }: {
      nixpkgs.config.packageOverrides = pkgs: {
        cloudsmith-cli = pkgs.cloudsmith-cli.overridePythonAttrs (old: {
          doCheck = false;
        });
      };
      homebrew.casks = [
        "amazon-workspaces"
        "dbvisualizer"
        "hex-fiend"
        "imhex"
"tandem"
        "tuple"
      ];
      home-manager.users.luke = {
        home.packages = with pkgs; [
          cloudsmith-cli
          fly
          mob
          # Keep client major aligned with the cluster; remove when it moves to 18.
          # https://goteleport.com/docs/upgrading/overview/#component-compatibility
          (stdenvNoCC.mkDerivation {
            pname = "teleport-client";
            version = "17.7.25";
            src = fetchurl {
              url = "https://cdn.teleport.dev/teleport-v17.7.25-darwin-arm64-bin.tar.gz";
              sha256 = "011f6f3d9a265d03152c614587b330f3e5efc77501887d6253ec44130ecf502a";
            };
            dontBuild = true;
            # Preserve the upstream app bundles and their code signatures.
            dontFixup = true;
            installPhase = ''
              mkdir -p "$out/bin" "$out/Applications"
              cp -R tsh.app tctl.app "$out/Applications/"
              ln -s "$out/Applications/tsh.app/Contents/MacOS/tsh" "$out/bin/tsh"
              ln -s "$out/Applications/tctl.app/Contents/MacOS/tctl" "$out/bin/tctl"
            '';
            meta.platforms = [ "aarch64-darwin" ];
          })
        ];
        programs.go.enable = true;
        programs.zsh = {
          profileExtra = ''eval "$(/opt/homebrew/bin/brew shellenv)"'';
        };
        programs.nushell.envFile.text = ''
          $env.PATH = (
            $env.PATH
            | split row (char esep)
            | append "/opt/homebrew/bin"
          )
        '';
      };
    })
  ];
  specialArgs = {
    inherit inputs;
  };
}
