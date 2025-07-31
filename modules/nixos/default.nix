{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    neovim
    pciutils
  ];

  users.users.luke.home = "/home/luke";
  users.users.luke = {
    isNormalUser = true;
    description = "Luke Barbuto";
    extraGroups = [ "docker" "networkmanager" "wheel" ];
    packages = with pkgs; [
      brave
      obsidian
      protonvpn-gui
    ];
  };

  time.timeZone = "America/New_York";

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  users.users.luke.useDefaultShell = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.xserver.xkbOptions = "caps:escape";

  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  networking.networkmanager.enable = true;
  services.printing.enable = true;

  hardware.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  security.rtkit.enable = true;
  security.polkit.enable = true;

  programs._1password.enable = true;
  programs._1password-gui.enable = true;
  programs._1password-gui.polkitPolicyOwners = [ "luke" ];
  programs.ssh.startAgent = true;

  virtualisation.docker.enable = true;

  boot.initrd.secrets = { "/crypto_keyfile.bin" = null; };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.systemd-boot.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  system.stateVersion = "22.11";
}
