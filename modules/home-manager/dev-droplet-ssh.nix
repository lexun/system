{ lib, pkgs, config, ... }:

{
  config = lib.mkIf pkgs.stdenv.isDarwin {
    # Ensure SSH sockets directory exists
    home.file.".ssh/sockets/.keep".text = "";

    programs.ssh.matchBlocks."dev" = {
      hostname = "146.190.13.220";
      user = "luke";
      forwardAgent = true;

      # Port forwarding for common dev ports
      localForwards = [
        { bind.port = 3000; host.address = "localhost"; host.port = 3000; }
        { bind.port = 3001; host.address = "localhost"; host.port = 3001; }
        { bind.port = 4000; host.address = "localhost"; host.port = 4000; }
        { bind.port = 5173; host.address = "localhost"; host.port = 5173; }
        { bind.port = 8000; host.address = "localhost"; host.port = 8000; }
        { bind.port = 8080; host.address = "localhost"; host.port = 8080; }
      ];

      extraOptions = {
        ControlMaster = "auto";
        ControlPath = "~/.ssh/sockets/%r@%h-%p";
        ControlPersist = "600";
        RequestTTY = "yes";
      };
    };
  };
}
