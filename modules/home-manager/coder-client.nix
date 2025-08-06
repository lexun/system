{ pkgs, lib, ... }:

{
  home.packages = [ pkgs.coder ];

  programs.ssh = {
    matchBlocks = lib.optionalAttrs pkgs.stdenv.isDarwin {
      "coder.*" = {
        forwardAgent = true;
        extraOptions = {
          ConnectTimeout = "0";
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
          LogLevel = "ERROR";
        };
        proxyCommand = "sh -c '${pkgs.coder}/bin/coder --global-config \"/Users/luke/Library/Application Support/coderv2\" ssh --stdio --ssh-host-prefix coder. %h 2>/dev/null'";
      };
      "*.coder" = {
        forwardAgent = true;
        extraOptions = {
          ConnectTimeout = "0";
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
          LogLevel = "ERROR";
          RemoteCommand = "bash -c 'source ~/.nix-profile/etc/profile.d/hm-session-vars.sh 2>/dev/null || true; exec zsm'";
          RequestTTY = "yes";
        };
        proxyCommand = "sh -c '${pkgs.coder}/bin/coder --global-config \"/Users/luke/Library/Application Support/coderv2\" ssh --stdio --hostname-suffix coder %h 2>/dev/null'";
      };
    };
  };
}