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

  programs.git = {
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPvFuWgZeycJkUJI7pZxth/nhmtiH5Y6YD84EjNpFl63";
      signByDefault = true;
    };

    extraConfig = {
      gpg = { format = "ssh"; };
      "gpg \"ssh\"" = { program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"; };
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
