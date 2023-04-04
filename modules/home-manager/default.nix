{ pkgs, ... }:

{
  imports = [
    (import ./one-password.nix)
    (import ./vscode)
  ];

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ (import ../../packages/overlay.nix) ];
  };

  home = {
    packages = with pkgs; [
      elixir
      gnupg
      navi
      nixpkgs-fmt
      nodePackages.prettier
      tree
      vscode-update-exts
      watch
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
          cd ~/.system \
            && ${update-command} switch --flake . \
            && exec $SHELL
        '';
        update-code-extensions = ''
          vscode-update-exts \
            > ~/.system/modules/home-manager/vscode/extensions.nix
        '';
      };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "miloshadzic";
    };
  };
}
