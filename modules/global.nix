{pkgs, ...}: {
  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-25.9.0"
    ];
  };
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = ["nix-command" "flakes"];
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.utf8";

  security.sudo.extraConfig = ''
    Defaults lecture="never"
    Defaults timestamp_timeout=15
  '';

  environment = {
    systemPackages = with pkgs; [
      killall
      lshw
      lsof
      pciutils
      unzip
      vim
      wget
    ];
    shells = with pkgs; [fish];
  };

  programs.fish.enable = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;
}
