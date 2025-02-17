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

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableNushellIntegration = true;
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

  programs.nushell = {
    enable = true;
    envFile.text = ''
      $env.config.show_banner = false
    '';
    shellAliases = {
      gaa = "git add --all";
      gap = "git add --patch";
      gc = "git commit";
      gca = "git commit --amend";
      gcan = "git commit --amend --no-edit";
      gcana = "git commit --amend --no-edit --all";
      gcb = "git checkout -b";
      gcm = "git commit -m";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gd = "git diff";
      gdca = "git diff --cached";
      gf = "git fetch";
      gl = "git pull";
      glg = "git log";
      glo = "git log --oneline";
      gp = "git push";
      gpf = "git push --force";
      gpfl = "git push --force-with-lease";
      gpsup = "git push --set-upstream origin HEAD";
      grb = "git rebase";
      grbi = "git rebase -i";
      grbm = "git rebase main";
      grh = "git reset HEAD";
      gs = "git show";
      gst = "git status";
      gsta = "git stash";
      gstp = "git stash pop";
      la = "ls -a";
      ll = "ls -l";
      lx = "ls -la";
    };
  };

  programs.oh-my-posh = {
    enable = true;
    enableNushellIntegration = true;
    useTheme = "huvix";
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
    };
  };
}
