{ darwin, flake-utils, home-manager }:

darwin.lib.darwinSystem {
  system = flake-utils.lib.system.aarch64-darwin;
  modules = [{
    imports = import ./common.nix { inherit home-manager; };
    homebrew.casks = [
      "amazon-workspaces"
      "tandem"
    ];
    home-manager.users.luke = { pkgs, ... }: {
      imports = [ (import ../darwin/home) ];
      programs.vscode = {
        extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "vscode-extension-for-zowe";
            publisher = "zowe";
            version = "2.6.1";
            sha256 = "sha256-oILRL07atIoEHdJiGZWvvXMgvDUZ2n+TwpTvGObra9g=";
          }
          {
            name = "zopeneditor";
            publisher = "ibm";
            version = "3.0.1";
            sha256 = "sha256-c0kpv0hbPriWK5oJyacXB81d0es6xRdKuu6U1ybB39I=";
          }
        ];
      };
    };
  }];
}
