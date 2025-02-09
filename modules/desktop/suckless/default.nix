{
  config,
  lib,
  inputs,
  hostname,
  system,
  ...
}: let
  cfg = config.custom.desktop.suckless;
in {
  options.custom.desktop.suckless = with lib; {
    dwm = {
      masterAreaSizePercentage = mkOption {
        description = "The percentage of the total size used by the master area.";
        type = types.float;
        default = 0.55;
      };
      respectResizeHints = mkOption {
        description = "Whether to respect size hints in tiled resizals.";
        type = types.bool;
        default = false;
      };
      font = {
        family = mkOption {
          description = "The font family to use.";
          type = types.str;
          default = "monospace";
        };
        pixelSize = mkOption {
          description = "The font pixel size.";
          type = types.ints.unsigned;
          default = 10;
        };
      };
      colours = {
        grey1 = mkOption {
          description = "Grey 1 (darkest).";
          type = types.str;
          default = "#222222";
        };
        grey2 = mkOption {
          description = "Grey 2.";
          type = types.str;
          default = "#444444";
        };
        grey3 = mkOption {
          description = "Grey 3.";
          type = types.str;
          default = "#bbbbbb";
        };
        grey4 = mkOption {
          description = "Grey 4 (lightest).";
          type = types.str;
          default = "#eeeeee";
        };
        active = mkOption {
          description = "The active/main colour.";
          type = types.str;
          default = "#005577";
        };
      };
      terminalProgram = mkOption {
        description = "The terminal program to execute.";
        type = types.str;
        default = "st";
      };
      highPriorityPrograms = mkOption {
        description = "The programs that should appear first in the list when using `dmenu`.";
        type = types.listOf types.str;
        default = [];
      };
    };
    st = {
      shell = mkOption {
        description = "The shell to execute on startup.";
        type = types.str;
        default = "/bin/sh";
      };
      font = {
        family = mkOption {
          description = "The font family to use.";
          type = types.str;
          default = "Liberation Mono";
        };
        pixelSize = mkOption {
          description = "The font pixel size.";
          type = types.ints.unsigned;
          default = 12;
        };
        characterTweaks = {
          widthScale = mkOption {
            description = "The font width scale.";
            type = types.float;
            default = 1.0;
          };
          heightScale = mkOption {
            description = "The font height scale.";
            type = types.float;
            default = 1.0;
          };
          xOffset = mkOption {
            description = "The font pixel X offset.";
            type = types.int;
            default = 0;
          };
          yOffset = mkOption {
            description = "The font pixel Y offset.";
            type = types.int;
            default = 0;
          };
        };
      };
      colourSchemeText = mkOption {
        description = "The colour scheme configuration text, matching the format in the original `config.def.h`.";
        type = types.str;
        default = ''
          /* Terminal colors (first 16 used in escape sequence) */
          static const char *colorname[] = {
            /* 8 normal colors */
            "black",
            "red3",
            "green3",
            "yellow3",
            "blue2",
            "magenta3",
            "cyan3",
            "gray90",

            /* 8 bright colors */
            "gray50",
            "red",
            "green",
            "yellow",
            "#5c5cff",
            "magenta",
            "cyan",
            "white",

            [255] = 0,

            /* more colors can be added after 255 to use with DefaultXX */
            "#cccccc",
            "#555555",
            "gray90", /* default foreground colour */
            "black", /* default background colour */
          };

          /*
           * Default colors (colorname index)
           * foreground, background, cursor, reverse cursor
           */
          unsigned int defaultfg = 258;
          unsigned int defaultbg = 259;
          unsigned int defaultcs = 256;
          static unsigned int defaultrcs = 257;
        '';
      };
    };
  };

  config = {
    nixpkgs.config.packageOverrides = pkgs: {
      dmenu = pkgs.dmenu.overrideAttrs (oldAttrs: {
        src = pkgs.fetchFromGitHub {
          owner = "zedseven";
          repo = "dmenu";
          rev = "b823f73f2b477796ff95f48edbe1f740d800986e";
          hash = "sha256-nxodcOXYhW5HPTWDyUot6lEIQDF2fnzWQFH+Xjq7ZSQ=";
        };
        # For `dmenu`, `conf` can't be used because the derivation doesn't support it
        postPatch =
          oldAttrs.postPatch
          + ''
            cp ${pkgs.writeText "config.dmenu.h" (builtins.readFile ./config.dmenu.h)} config.h
          '';
      });

      dwm = inputs.self.packages.${system}.dwm.override {conf = cfg.dwm;};

      slock =
        (pkgs.slock.overrideAttrs {
          src = pkgs.fetchFromGitHub {
            owner = "zedseven";
            repo = "slock";
            rev = "84c9d2702e94cf45bd0049cd430755613e6dfbd3";
            hash = "sha256-BnS/lKWgRpjxsGDWMflPfgrFQeuTiT5gXvg2cztxlYE=";
          };
        })
        .override
        {conf = builtins.readFile ./config.slock.h;};

      slstatus = pkgs.slstatus.override {conf = builtins.readFile ./config.slstatus.${hostname}.h;};

      st = inputs.self.packages.${system}.st.override {conf = cfg.st;};
    };
  };
}
