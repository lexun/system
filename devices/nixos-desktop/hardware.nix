{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/f2cd30a5-ea96-48ef-b63a-ac085cbde705";
      fsType = "ext4";
    };

  # LUKS encryption for root partition (auto-detected by installer)
  boot.initrd.luks.devices."luks-1b10d001-98ae-42fc-ae69-015b345b2f53".device = "/dev/disk/by-uuid/1b10d001-98ae-42fc-ae69-015b345b2f53";

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/C277-A345";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/06c15be4-a4b5-4607-9bac-a32f36cdd413"; }];

  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp6s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp7s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
