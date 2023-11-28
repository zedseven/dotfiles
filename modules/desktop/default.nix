{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./suckless.nix
  ];

  security.protectKernelImage = false; # To allow for hibernation

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    libinput.enable = true;
    windowManager.dwm.enable = true;
    displayManager = {
      defaultSession = "none+dwm";
      autoLogin = {
        enable = true;
        user = "zacc";
      };
    };
    desktopManager.wallpaper.mode = "fill";
    dpi = lib.mkDefault 96;
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryFlavor = "gtk2";
    enableSSHSupport = true;
  };

  # Enable sound.
  sound.enable = true;
  sound.enableOSSEmulation = true; # Allows for `/dev/mixer`
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;

  users.users.zacc = {
    extraGroups = [
      "audio"
      "video"
    ];
    # GUI packages
    packages = with pkgs; [
      betterdiscordctl
      (discord.overrideAttrs {
        withOpenASAR = true;
      })
      dmenu
      firefox-devedition
      jetbrains.clion
      jetbrains.rust-rover
      keepass
      obsidian
      slstatus
      st
    ];
  };
  home-manager.users.zacc = {
    xsession = {
      enable = true;
      profileExtra = ''
        slstatus &
        slock &
      '';
    };

    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.gnome.adwaita-icon-theme;
      size = lib.mkDefault 32;
      x11.enable = true;
    };

    xresources.properties = lib.mkDefault {
      "Xft.dpi" = 96;
    };

    services.sxhkd = {
      enable = true;
      keybindings = {
        "XF86AudioRaiseVolume" = "amixer set Master 5%+";
        "XF86AudioLowerVolume" = "amixer set Master 5%-";
        "XF86AudioMute" = "amixer set Master toggle";
        "XF86MonBrightnessUp" = "light -A 5";
        "XF86MonBrightnessDown" = "light -U 5";
      };
    };
  };

  programs.light.enable = true;

  programs.slock.enable = true;
  programs.xss-lock = {
    enable = true;
    lockerCommand = "${pkgs.slock}/bin/slock -c";
  };

  services.logind = {
    lidSwitch = "hybrid-sleep";
    extraConfig = ''
      HandlePowerKey=hybrid-sleep
      IdleAction=hybrid-sleep
      IdleActionSec=1m
    '';
  };

  systemd.sleep.extraConfig = ''
    AllowHibernation=yes
    HibernateMode=platform shutdown
    HibernateState=disk
    HybridSleepMode=suspend platform shutdown
    HybridSleepState=disk
  '';

  services.mullvad-vpn = {
    enable = true;
    package = pkgs.mullvad-vpn;
  };

  # To allow file sharing over HTTP via `miniserve`
  networking.firewall = {
    allowedTCPPorts = [8080];
  };
}
