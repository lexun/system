{ pkgs, ... }:

{
  programs.nushell = {
    enable = true;
    configFile.text = ''
      let-env config = {
        show_banner: false
      }

      alias la = exa -la
    '';

    envFile.text = ''
      let-env SHELL = '${pkgs.nushell}/bin/nu'

      let-env PATH = ($env.PATH | split row (char esep))
      let-env PATH = [
        /Users/luke/.nix-profile/bin,
        /nix/var/nix/profiles/default/bin,
        /etc/profiles/per-user/luke/bin,
        /run/current-system/sw/bin,
        /usr/local/bin
      ] ++ $env.PATH
    '';
  };
}
