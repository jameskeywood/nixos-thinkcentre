{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ]; 

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "thinkcentre";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/London";

  i18n.defaultLocale = "en_GB.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };

  console.keyMap = "uk"; 

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.openssh.enable = true;

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/6d737c19-e40c-4200-83b4-acae197ebed7";
    fsType = "ext4";
  };
 
  services.samba = {
    enable = true;

    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "ThinkCentre Music Server";
        "security" = "user";
        "map to guest" = "never";

        "socket options" = "TCP_NODELAY IPTOS_LOWDELAY";
        "read raw" = "yes";
        "write raw" = "yes";
        "max xmit" = "65535";
      };

      music = {
        path = "/data/music";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "no";
        "valid users" = "james";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 139 445 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    parted
    smartmontools
  ];

  users.users.james = {
    isNormalUser = true;
    description = "James Keywood";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      git
    ];
  }; 

  system.stateVersion = "25.11";
}
