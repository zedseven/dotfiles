let
  private = import ../../private;
in
  {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      <home-manager/nixos>
      ./hardware-configuration.nix
      ../../modules/global.nix
      ../../modules/desktop
      ../../modules/desktop/nvidia.nix
      ../../modules/desktop/games.nix
      ../../modules/darlings.nix
      ../../modules/zfs.nix
      ../../zacc.nix
    ];

    environment = {
      etc."nixos".source = "/home/zacc/nix";
      etc."mullvad-vpn".source = "/persist/etc/mullvad-vpn";
    };

    networking.hostName = "duradeus"; # Define your hostname.
    networking.hostId = "c4f086eb";

    networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.
    networking.wireless.networks = private.networks;

    home-manager.users.zacc.programs.autorandr.profiles = {
      "home" = {
        # The easiest way to obtain these values is to run `autorandr --fingerprint`
        fingerprint = {
          "DP-0" = "00ffffffffffff001e6dfa761ae10400081c0104a55022789eca95a6554ea1260f5054256b807140818081c0a9c0b300d1c08100d1cfcd4600a0a0381f4030203a001e4e3100001a003a801871382d40582c4500132a2100001e000000fd00384b1e5a18000a202020202020000000fc004c4720554c545241574944450a0126020314712309060747100403011f1312830100008c0ad08a20e02d10103e96001e4e31000018295900a0a038274030203a001e4e3100001a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ae";
          "HDMI-0" = "00ffffffffffff004c2d5c0c4b484d302a190103803c22782a5295a556549d250e505423080081c0810081809500a9c0b30001010101023a801871382d40582c450056502100001e011d007251d01e206e28550056502100001e000000fd00323c1e5111000a202020202020000000fc00533237453539300a202020202001af02031af14690041f130312230907078301000066030c00100080011d00bc52d01e20b828554056502100001e8c0ad090204031200c4055005650210000188c0ad08a20e02d10103e9600565021000018000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061";
        };
        config = {
          "DP-0" = {
            enable = true;
            primary = true;
            position = "0x0";
            mode = "2560x1080";
            rate = "74.99";
            dpi = 96;
          };
          "HDMI-0" = {
            enable = true;
            position = "2560x0";
            mode = "1920x1080";
            rate = "60.00";
            dpi = 96;
          };
        };
      };
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It's perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "23.05"; # Did you read the comment?
  }