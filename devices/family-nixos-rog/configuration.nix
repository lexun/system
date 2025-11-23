{ config, lib, pkgs, ... }:

{
  networking.hostName = "FamilyNixosROG";

  # Use latest kernel for best hardware support and performance
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Override default EFI mount point (this device uses /boot not /boot/efi)
  boot.loader.efi.efiSysMountPoint = lib.mkForce "/boot";

  # LUKS encryption configuration from installer
  boot.initrd.luks.devices."luks-0eabf102-c02e-41f8-adb4-98fe827d8d41".device = "/dev/disk/by-uuid/0eabf102-c02e-41f8-adb4-98fe827d8d41";

  # This device doesn't use a keyfile for LUKS (unlike the laptop)
  boot.initrd.secrets = lib.mkForce { };

  # Gaming and multimedia optimizations
  # Enable steam and gaming support
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;

    # Add better Proton compatibility tools
    extraCompatPackages = with pkgs; [
      proton-ge-bin  # GE-Proton for better game compatibility
    ];
  };

  # Create shared Steam library folder for all family members
  # Using /games at root level for better FHS container compatibility
  systemd.tmpfiles.rules = [
    "d /games 0775 root users -"  # Group-writable by all users
  ];

  # Nvidia GPU configuration (RTX 4070 Ti SUPER)
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;  # Support for 32-bit games
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
}
