{ config, pkgs, ... }:

{
  networking.hostName = "FamilyNixosROG";

  # Use latest kernel for best hardware support and performance
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # LUKS encryption for swap partition (separate from root LUKS device in hardware.nix)
  boot.initrd.luks.devices."luks-0eabf102-c02e-41f8-adb4-98fe827d8d41".device =
    "/dev/disk/by-uuid/0eabf102-c02e-41f8-adb4-98fe827d8d41";

  # Additional swap file for gaming (supplements the 17GB swap partition)
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 32 * 1024; # 32GB
    }
  ];

  # Kernel tuning for Star Citizen
  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
  };

  # nix-citizen binary cache
  nix.settings = {
    substituters = [ "https://nix-citizen.cachix.org" ];
    trusted-public-keys = [ "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo=" ];
  };

  # Gaming and multimedia optimizations
  # Enable steam and gaming support
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    # Add better Proton compatibility tools
    extraCompatPackages = with pkgs; [
      proton-ge-bin # GE-Proton for better game compatibility
    ];
  };

  # Nvidia GPU configuration (RTX 4070 Ti SUPER)
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Support for 32-bit games
  };

  hardware.nvidia = {
    # Use the latest Nvidia drivers for Ada Lovelace (RTX 40 series)
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # Required for most Wayland compositors
    modesetting.enable = true;

    # Enable power management (helps with performance and thermals)
    powerManagement.enable = true;

    # Use the open-source kernel modules (recommended for RTX 40 series)
    open = true;
  };

  # Family user accounts
  users.users.auri = {
    isNormalUser = true;
    description = "Auri Barbuto";
    extraGroups = [
      "networkmanager"
      "users"
    ];
    initialPassword = "";
  };

  users.users.zevi = {
    isNormalUser = true;
    description = "Zevi Barbuto";
    extraGroups = [
      "networkmanager"
      "users"
    ];
    initialPassword = "";
  };

  users.users.yasu = {
    isNormalUser = true;
    description = "Yasu Barbuto";
    extraGroups = [
      "networkmanager"
      "users"
    ];
    initialPassword = "";
  };

  # Dedicated Steam account
  users.users.games = {
    isNormalUser = true;
    description = "Shared Steam";
    extraGroups = [
      "networkmanager"
      "users"
    ];
    initialPassword = "";
  };

  # Remote access for development
  services.tailscale.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Open firewall for Tailscale
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
}
