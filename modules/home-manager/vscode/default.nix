{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;

    extensions =
      pkgs.vscode-utils.extensionsFromVscodeMarketplace
        (import ./extensions.nix);

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
      "keyboard.dispatch" = "keyCode";
    };
  };
}
