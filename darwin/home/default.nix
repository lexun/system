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
      phoenixframework.phoenix
      vscodevim.vim
      yzhang.markdown-all-in-one
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "copilot-labs";
        publisher = "github";
        version = "0.9.668";
        sha256 = "09pdyb844sfiz3akj3d0k6wbjb3w34j9wy7w76mkxj06a3a6f5dm";
      }
      {
        name = "elixir-test";
        publisher = "samuel-pordeus";
        version = "1.7.1";
        sha256 = "0w9z6bmmrql4wc37qd7zdyc5vyhs3xpdg1w5l8gshhfjn0kvp3k7";
      }
      {
        name = "remote-containers";
        publisher = "ms-vscode-remote";
        version = "0.276.0";
        sha256 = "1973x9r4k2b8919wzpash17c58csv2d6k953szfk3gcrvx8xdffq";
      }
      {
        name = "vscode-icons";
        publisher = "vscode-icons-team";
        version = "12.2.0";
        sha256 = "12s5br0s9n99vjn6chivzdsjb71p0lai6vnif7lv13x497dkw4rz";
      }
      {
        name = "vsliveshare";
        publisher = "ms-vsliveshare";
        version = "1.0.5828";
        sha256 = "1myk9njk2l3r989vf6m1x7ff0ygkrpkf2i5h2ba3zczp4sp8fh6d";
      }
    ];
    userSettings = {
      "[css]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
      "[javascript]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
      "[json]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
      "[markdown]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
      "editor.formatOnSave" = true;
      "editor.inlineSuggest.enabled" = true;
      "editor.lineNumbers" = "relative";
      "editor.tabSize" = 2;
      "files.associations" = { "*.livemd" = "markdown"; };
      "files.insertFinalNewline" = true;
      "prettier.proseWrap" = "always";
      "terminal.external.osxExec" = "iterm2.app";
      "terminal.integrated.scrollback" = 10000;
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
      update-code-extensions = "~/workspace/nixos/nixpkgs/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "miloshadzic";
    };
  };
}
