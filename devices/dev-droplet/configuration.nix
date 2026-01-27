{ pkgs, lib, ... }:

{
  virtualisation.digitalOceanImage.compressionMethod = "gzip";

  networking.hostName = "dev";

  # User configuration
  users.users.luke = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPvFuWgZeycJkUJI7pZxth/nhmtiH5Y6YD84EjNpFl63"
    ];
  };

  # Allow passwordless sudo
  security.sudo.wheelNeedsPassword = false;

  # SSH server
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
    # Handle brute-force attacks better
    extraConfig = ''
      MaxStartups 50:30:100
    '';
  };

  # Fail2ban to block brute-force attackers
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "1h";
  };

  # Root access for initial setup
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPvFuWgZeycJkUJI7pZxth/nhmtiH5Y6YD84EjNpFl63"
  ];

  # Swap for smaller droplets
  swapDevices = [{
    device = "/swapfile";
    size = 4096;
  }];

  # Docker
  virtualisation.docker.enable = true;

  # Mount the persistent volume at /home/luke
  # DigitalOcean volumes appear as /dev/disk/by-id/scsi-0DO_Volume_<name>
  fileSystems."/home/luke" = {
    device = "/dev/disk/by-id/scsi-0DO_Volume_dev-home";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  # Firewall - SSH only, other ports as needed
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # Nix settings
  nix.settings = {
    experimental-features = [ "flakes" "nix-command" ];
    trusted-users = [ "root" "luke" ];
  };

  # Basic packages available system-wide
  environment.systemPackages = with pkgs; [
    git
    vim
    htop
    curl
    wget
  ];

  system.stateVersion = "24.11";
}
