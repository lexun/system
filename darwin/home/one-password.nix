{ config, ... }:

{
  home = {
    file.".1password/agent.sock" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    };

    sessionVariables = {
      SSH_AUTH_SOCK = "~/.1password/agent.sock";
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks."*" = {
      extraOptions = {
        identityAgent = "~/.1password/agent.sock";
      };
    };
  };
}
