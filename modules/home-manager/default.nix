{ config, pkgs, ... }:

{
  imports = [
    ./helix.nix
    ./nushell.nix
    ./one-password.nix
    ./vscode
  ];

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ (import ../../packages/overlay.nix) ];
  };

  home = {
    packages = with pkgs; [
      elixir
      exa
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

    shellAliases =
      let
        update-command =
          if pkgs.stdenv.isLinux
          then "sudo nixos-rebuild"
          else "darwin-rebuild";
      in
      {
        update-system = ''
          cd ~/.system \
            && ${update-command} switch --flake . \
            && exec $SHELL
        '';
        update-code-extensions = ''
          vscode-update-exts \
            > ~/.system/modules/home-manager/vscode/extensions.nix
        '';
      };

    stateVersion = "23.05";
  };

  programs.alacritty = {
    enable = true;
    settings = {
      shell = "${pkgs.nushell}/bin/nu";
      import = [ "${pkgs.alacritty-theme}/citylights.yaml" ];
      window = {
        option_as_alt = "Both";
      };
    };
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

  programs.zellij = {
    enable = true;
  };

  programs.zsh = {
    enable = true;
    localVariables.RPROMPT = null;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "miloshadzic";
    };
  };
}
