# An HP Spectre x360 Laptop - 5FP19UA.
{
  config,
  inputs,
  userInfo,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    ../../modules
  ];

  custom = {
    user.type = "full";
    global.configurationPath = "/persist/etc/nixos";

    backups = {
      enable = true;
      repository = "b2:zedseven-restic";
      backupPaths = [
        "/home"
        "/persist"
      ];
      extraExcludeEntries = [
        "/home/${userInfo.username}/torrents/artifacts/"
        "/home/${userInfo.username}/git/nixpkgs"
      ];
      passwordFile = config.age.secrets."restic-repository-password".path;
      rclone = {
        enable = true;
        configPath = config.age.secrets."rclone.conf".path;
      };
      scheduled.onCalendar = "*-*-* 00:00:00";
      setEnvironmentVariables = true;
    };

    darlings.persist.paths = [
      "/etc/machine-id"
      "/etc/mullvad-vpn"
      "/etc/ssh"
      "/root/.cache/restic"
      "/var/log"
    ];

    desktop = {
      enable = true;

      displays = {
        fingerprints = {
          "eDP-1" = "00ffffffffffff0006afeb3000000000251b0104a5221378020925a5564f9b270c50540000000101010101010101010101010101010152d000a0f0703e803020350058c11000001852d000a0f07095843020350025a51000001800000000000000000000000000000000000000000002001430ff123caa8f0e29aa202020003e";
        };

        config = {
          "eDP-1" = {
            enable = true;
            primary = true;
            positionX = 0;
            positionY = 0;
            resolutionX = 3840;
            resolutionY = 2160;
            rate = 60;
            dpi = 192;
          };
        };
      };

      displayDriver = "nvidia";
      is4k = true;
      audio.persistentSettings = {
        enable = true;
        alsaDirPath = "/persist/var/lib/alsa";
      };
      discord = {
        enable = true;
        wrapDiscord = true;
      };
      games.ndsplus.enable = true;
    };

    symlinks = {
      "/etc/wpa_supplicant.conf".source = config.age.secrets."wpa_supplicant.conf".path;
      "/home/${userInfo.username}/.ssh/config".source = config.age.secrets."ssh_config".path;
    };

    grub = {
      enable = true;
      efi.enable = true;
    };

    wireguard.enable = true;
    zfs.enable = true;
  };

  networking = {
    hostId = "eff5369a";
    # Networks are defined in `/etc/wpa_supplicant.conf`
    wireless.enable = true;
  };

  hardware.nvidia.prime = {
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };

    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:59@0:0:0";
  };

  system.stateVersion = "23.05"; # Don't touch this, ever
}
