{
  config,
  pkgs,
  lib,
  inputs,
  userInfo,
  system,
  ...
}: let
  cfg = config.custom.desktop.games.steam;
in {
  imports = [inputs.home-manager.nixosModules.home-manager];

  options.custom.desktop.games.steam = with lib; {
    enable = mkEnableOption "Steam";
    wrapSteam = mkEnableOption "a wrapped version of Steam with customisations";
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        programs.steam.enable = true;
        hardware.steam-hardware.enable = true;
      }
      (lib.mkIf cfg.wrapSteam (
        let
          # Wraps Steam with a patcher that removes the `What's New` section of the library
          steamWrapped = pkgs.writeShellScriptBin "steam" ''
            ${inputs.self.packages.${system}.steam-no-whats-new}/bin/patch.sh
            ${config.programs.steam.package}/bin/steam "$@"
          '';
        in {
          home-manager.users.${userInfo.username}.home.packages = [steamWrapped];
        }
      ))
    ]
  );
}
