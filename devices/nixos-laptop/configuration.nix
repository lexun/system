{ config, pkgs, ... }:

{
  boot.initrd.luks.devices."luks-62d65fd2-4119-4f54-8908-c4956df9596d".device = "/dev/disk/by-uuid/62d65fd2-4119-4f54-8908-c4956df9596d";
  boot.initrd.luks.devices."luks-62d65fd2-4119-4f54-8908-c4956df9596d".keyFile = "/crypto_keyfile.bin";

  networking.hostName = "LukesNixosRB";

  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "nvidia-offload" ''
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-GO
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec "$@"
    '')
  ];

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = false;

  hardware.nvidia.prime = {
    offload.enable = true;
    intelBusId = "PCI:00:02:0";
    nvidiaBusId = "PCI:01:00:0";
  };
}
