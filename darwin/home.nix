{ config, pkgs, ... }:

{
  home = {
    file.".1password/agent.sock" = {
      source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
    };

    packages = with pkgs; [
      elixir_1_14
      gnupg
      navi
      nixpkgs-fmt
      nodePackages.prettier
    ];

    sessionVariables = {
      EDITOR = "nvim";
      SSH_AUTH_SOCK = "~/.1password/agent.sock";
    };

    stateVersion = "23.05";
  };

  programs.git = {
    enable = true;
    userName = "Luke Barbuto";
    userEmail = "luke.barbuto@gmail.com";
    signing = {
      key = "38F5A5A55CFBA98B";
      signByDefault = true;
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.ssh = {
    enable = true;
    matchBlocks."*" = {
      extraOptions = {
        identityAgent = "~/.1password/agent.sock";
      };
    };
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      eamodio.gitlens
      esbenp.prettier-vscode
      jnoortheen.nix-ide
      vscodevim.vim
      yzhang.markdown-all-in-one
    ];
    userSettings = {
      "[markdown]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
      "editor.formatOnSave" = true;
      "editor.lineNumbers" = "relative";
      "prettier.proseWrap" = "always";
      "terminal.external.osxExec" = "iterm2.app";
      "vim.useSystemClipboard" = true;
    };
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      update = "cd ~/.system && darwin-rebuild switch --flake . && rm result && exec $SHELL";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "miloshadzic";
    };
  };
}
