{ pkgs, lib, codespaces ? false, ... }:

{
  imports = lib.optional (!codespaces) [
    (import ./one-password.nix)
  ];

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ (import ../../packages/overlay.nix) ];
  };

  home = {
    packages = with pkgs; [
      cachix
      fzf
      git-coauthor
      gnupg
      k9s
      kube3d
      kubectl
      kubectx
      mob
      navi
      nixpkgs-fmt
      nodePackages.prettier
      tree
      watch
    ];

    sessionPath = [
      "$HOME/.local/bin"
    ];

    sessionVariables = {
      EDITOR = "nvim";
    };

    stateVersion = "23.05";
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Luke Barbuto";
    userEmail = "luke.barbuto@gmail.com";
    lfs.enable = true;
    ignores = [
      ".vscode"
    ];
    includes = [
      { path = "~/.config/git-coauthor/config"; }
    ];
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.ssh = {
    enable = true;
    controlPath = "none";
  };

  programs.wezterm = {
    enable = true;
    extraConfig = ''
      return {
        keys = {
          -- Bind cmd-k to clear the entire scrollback and screen
          {
            key = 'k',
            mods = 'CMD',
            action = wezterm.action.ClearScrollback 'ScrollbackAndViewport',
          },
        },
      }
    '';
  };

  programs.zsh = {
    enable = true;
    localVariables = {
      RPROMPT = null;
    };
    shellAliases =
      let
        update-command =
          if pkgs.stdenv.isLinux
          then "sudo nixos-rebuild"
          else "darwin-rebuild";
      in
      {
        update = ''
          rm ~/.ssh/config.rebuild
          cd ~/.system \
            && nix-channel --update \
            && ${update-command} switch --flake . \
            && exec $SHELL
        '';
      };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "miloshadzic";
    };
  };
}
