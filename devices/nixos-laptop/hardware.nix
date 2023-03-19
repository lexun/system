{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/6817005f-0c8b-44d6-a5cb-da3f4308a124";
      fsType = "ext4";
    };

  boot.initrd.luks.devices."luks-652997e6-49b2-4405-a2c3-3183d63a8574".device = "/dev/disk/by-uuid/652997e6-49b2-4405-a2c3-3183d63a8574";

  fileSystems."/boot/efi" =
    {
      device = "/dev/disk/by-uuid/0E75-133D";
      fsType = "vfat";
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/59f5f88e-de47-4aff-927f-ebe0fa5c5b6e"; }];

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.video.hidpi.enable = lib.mkDefault true;
}
