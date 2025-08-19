{
  pkgs,
  lib,
  inputs,
  onePasswordEnabled,
  enableSshConfig ? true,
  nixvim,
  ...
}:

{
  imports =
    lib.optionals (onePasswordEnabled) [
      (import ./one-password.nix)
    ]
    ++ [
      (import ./coder-client.nix)
      nixvim.homeManagerModules.nixvim
    ];

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ 
      (import ../../packages/overlay.nix)
      inputs.vibetree.overlays.default
    ];
  };

  home = {
    packages = with pkgs; [
      aichat
      cachix
      claude-code
      devenv
      difftastic
      fzf
      gh
      git-coauthor
      gnupg
      k9s
      kube3d
      kubectl
      kubectx
      mermaid-cli
      mob
      nerd-fonts.fira-code
      nixfmt-rfc-style
      nodejs_24
      nufmt
      nodePackages.prettier
      ripgrep
      system-update
      tree
      uv
      vibetree
      watch
      zsm
    ];

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.nix-profile/bin"
    ];

    sessionVariables = {
      EDITOR = "nvim";
    };

    stateVersion = "23.05";
  };

  programs.alacritty = {
    enable = true;
    settings = {
      terminal.shell = {
        program = "${pkgs.nushell}/bin/nu";
        args = [
          "-e"
          "zsm"
        ];
      };
      window = {
        dynamic_padding = true;
        option_as_alt = "OnlyLeft";
        startup_mode = "Maximized";
      };
      font = {
        normal.family = "FiraCode Nerd Font";
        size = 14.0;
      };
    };
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
      ".aider*"
    ];
    includes = [
      { path = "~/.config/git-coauthor/config"; }
    ];
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      diff = {
        external = "difft";
      };
    };
  };

  programs.nixvim = {
    enable = true;
    globals.mapleader = " ";

    colorschemes.vscode = {
      enable = true;
      settings.style = "dark";
    };

    opts = {
      number = true;
      relativenumber = true;
      syntax = "on";
      termguicolors = true;
    };

    plugins = {
      lualine.enable = true;
      nvim-tree.enable = true;
      telescope.enable = true;
      web-devicons.enable = true;
      which-key.enable = true;

      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent.enable = true;
          ensure_installed = [
            "bash"
            "css"
            "elixir"
            "html"
            "javascript"
            "json"
            "markdown"
            "nix"
            "python"
            "rust"
            "typescript"
            "yaml"
          ];
        };
      };

      lsp = {
        enable = true;
        servers = {
          nil-ls.enable = true;
          elixirls.enable = true;
          bashls.enable = true;
        };
      };

      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            markdown = ["prettier"];
          };
          format_on_save = {
            timeout_ms = 500;
            lsp_fallback = true;
          };
        };
      };
    };

    keymaps = [
      {
        mode = "i";
        key = "jk";
        action = "<Esc>";
        options.desc = "Exit insert mode";
      }
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>NvimTreeToggle<cr>";
        options.desc = "Explorer toggle";
      }
      {
        mode = "n";
        key = "<leader>f";
        action = "<cmd>Telescope find_files<cr>";
        options.desc = "Find files";
      }
      {
        mode = "n";
        key = "<leader>g";
        action = "<cmd>Telescope live_grep<cr>";
        options.desc = "Grep text";
      }
      {
        mode = "n";
        key = "<leader>b";
        action = "<cmd>Telescope buffers<cr>";
        options.desc = "Browse buffers";
      }
    ];
  };

  programs.nushell = {
    enable = true;
    envFile.text = ''
      $env.config.show_banner = false
      $env.SHELL = "${pkgs.nushell}/bin/nu"
      $env.FORCE_COLOR = "1"
      $env.FZF_DEFAULT_OPTS = "--ansi"
      $env.PATH = (
        $env.PATH
        | split row (char esep)
        | append "/usr/local/bin"
        | append "/run/current-system/sw/bin"
        | append $"/etc/profiles/per-user/($env.USER)/bin"
        | append $"($env.HOME)/.nix-profile/bin"
      )
    '';
    shellAliases = {
      update = "system-update";
      ai = "aichat -e";
      gaa = "git add --all";
      gap = "git add --patch";
      gb = "git branch";
      gba = "git branch -a";
      gc = "git commit";
      gca = "git commit --amend";
      gcan = "git commit --amend --no-edit";
      gcana = "git commit --amend --no-edit --all";
      gcb = "git checkout -b";
      gcm = "git checkout (if (git rev-parse --verify main | complete).exit_code == 0 { 'main' } else { 'master' })";
      gcmsg = "git commit -m";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gd = "git diff";
      gdca = "git diff --cached";
      gf = "git fetch";
      gl = "git pull";
      glg = "git log";
      glp = "git log -p --ext-diff";
      glo = "git log --oneline";
      gm = "git merge";
      gma = "git merge --abort";
      gp = "git push";
      gpf = "git push --force";
      gpfl = "git push --force-with-lease";
      gpsup = "git push --set-upstream origin HEAD";
      grb = "git rebase";
      grba = "git rebase --abort";
      grbc = "git rebase --continue";
      grbi = "git rebase -i";
      grbm = "git rebase main";
      grh = "git reset HEAD";
      gs = "git show --ext-diff";
      gst = "git status";
      gsta = "git stash";
      gstp = "git stash pop";
      la = "ls -a";
      ll = "ls -l";
      lx = "ls -la";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;

    settings = {
      format = "$directory[|](red)$git_branch$git_status$character";

      character = {
        success_symbol = "[⇒](cyan)";
        error_symbol = "[⇒](red)";
      };

      directory = {
        style = "cyan";
        format = "[$path]($style)";
      };

      git_branch = {
        format = "[$branch](green) ";
      };

      git_status = {
        format = "[$staged](yellow)[$modified](blue)[$untracked](red)";
        style = "green";
        modified = "🧪 ";
        ahead = "";
        behind = "";
        conflicted = "";
        deleted = "";
        diverged = "";
        renamed = "";
        staged = "⚡️";
        stashed = "";
        untracked = "✗ ";
      };
    };
  };

  programs.ssh = {
    enable = enableSshConfig;
    controlPath = "none";
  };

  programs.zellij = {
    enable = true;
    settings = {
      default_shell = "${pkgs.nushell}/bin/nu";
      show_startup_tips = false;
    };
  };

  programs.zsh = {
    enable = true;
    localVariables = {
      RPROMPT = null;
    };
    shellAliases = {
      update = "system-update";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
  };
}
