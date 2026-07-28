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

  services.smartd = {
    enable = true;

    autodetect = false;

    devices = [
      {
        device = "/dev/sda";
        options = "-a -s S/../../1-5/09";
      }
    ];
  };
 
  services.samba = {
    enable = true;

    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "ThinkCentre music";
        "security" = "user";
        "map to guest" = "never";

        "socket options" = "TCP_NODELAY IPTOS_LOWDELAY";
        "read raw" = "yes";
        "write raw" = "yes";
        "max xmit" = "65535";
      };

      james_music = {
        path = "/data/james_music";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "no";
        "valid users" = "james";
      };

      patrick_music = {
        path = "/data/patrick_music";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "no";
        "valid users" = "james";
      };
    };
  };

  services.minidlna = {
    enable = true;

    settings = {
      friendly_name = "ThinkCentre music";

      media_dir = [
        "A,/data/james_music"
        "A,/data/patrick_music"
      ];

      inotify = "yes";
    };
  };

  networking.firewall.allowedTCPPorts = [
    139  # Samba NetBIOS file sharing
    445  # Samba SMB file sharing
    8200 # MiniDLNA HTTP server
  ];
  networking.firewall.allowedUDPPorts = [
    137  # Samba NetBIOS name service
    138  # Samba NetBIOS datagram service
    1900 # UPnP / SSDP discovery
  ];

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
      rrsync
    ];
  }; 

  users.users.patrick = {
    isNormalUser = true;
    description = "Patrick Jones";

    hashedPassword = "!";

    packages = with pkgs; [
      rrsync
    ];

    openssh.authorizedKeys.keys = [
      "command=\"rrsync /data/james_music/flac\",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCTAJY8bMT4y/VtewWCq3Qm81DnP6NMhUBfyTutBfRwY9YXIBLSWqdm9rexmily2WjOJE+vXfN59ItqR4FILAyjNUh1E9Cp+OqyETAlTCllmSxCHwVWBUMBIFxMA38B9Xvcc3P9ch4xWAn0/36FmrA10C1gmRmD5Z9aLd5P/4VK0p3aMoFzWopIwHNESkbvLnOo69eIuY3CrzORVHYtAR+UlErMMyMWcJ2xcMwXp3Cy3ZLaqdEiaJjmoNNFifFjxxExkrzyVvtDxBhYSo0/m5dgFh2YTvnPKhqU5k0p4iq72ONVs3sLQTUSbNjIWZgY5cxNpwa88IESO7A8W7L99NNQSkFzNWI1dMo6qqkIwTBcwn3AfwGCT8jdGDWJAM4FcXwmRmLm7AmeiAVhjlfyRv8cOX/zKLKyjbHRGiFlwhQxSwDi/zvEDyLhYh+/DaXX06vzuBpGyrKhKRamcm+jtQQDUm5oaerF5oP5o6R/7KGswtuXKkvKiCcYnlFNJAsJukE= pjones@pj-laptop"
    ];
  };

  system.stateVersion = "25.11";
}
