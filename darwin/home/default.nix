{ config, pkgs, ... }:

{
  imports = [
    (import ./one-password.nix)
  ];

  home = {
    packages = with pkgs; [
      gnupg
      navi
      nixpkgs-fmt
      nodePackages.prettier
    ];

    sessionVariables = {
      EDITOR = "nvim";
    };

    stateVersion = "23.05";
  };

  programs.direnv = {
    enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Luke Barbuto";
    userEmail = "luke.barbuto@gmail.com";
    extraConfig = {
      init = {
        defaultBranch = "master";
      };
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      bungcip.better-toml
      eamodio.gitlens
      esbenp.prettier-vscode
      github.copilot
      jakebecker.elixir-ls
      jnoortheen.nix-ide
      mkhl.direnv
      vscodevim.vim
      yzhang.markdown-all-in-one
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "copilot-labs";
        publisher = "github";
        version = "0.4.488";
        sha256 = "Vy7T8PfU/4vAgHtFb++mJCfQYVijIL183XgfOJRB0ck=";
      }
      {
        name = "vscode-icons";
        publisher = "vscode-icons-team";
        version = "12.0.1";
        sha256 = "zxKD+8PfuaBaNoxTP1IHwG+25v0hDkYBj4RPn7mSzzU=";
      }
    ];
    userSettings = {
      "[markdown]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
      "editor.formatOnSave" = true;
      "editor.inlineSuggest.enabled" = true;
      "editor.lineNumbers" = "relative";
      "files.associations" = { "*.livemd" = "markdown"; };
      "files.insertFinalNewline" = true;
      "prettier.proseWrap" = "always";
      "terminal.external.osxExec" = "iterm2.app";
      "vim.useSystemClipboard" = true;
      "workbench.iconTheme" = "vscode-icons";
    };
  };

  programs.zsh = {
    enable = true;
    localVariables = {
      RPROMPT = null;
    };
    shellAliases = {
      update = "cd ~/.system && darwin-rebuild switch --flake . && exec $SHELL";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "miloshadzic";
    };
  };
}
