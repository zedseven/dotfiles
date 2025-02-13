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
    dmenu = {
      prompt = mkOption {
        description = "The prompt to display next to the input area.";
        type = types.nullOr types.str;
        default = null;
      };
      displayOnScreenTop = mkOption {
        description = "Whether to display `dmenu` on the top of the screen instead of the bottom.";
        type = types.bool;
        default = true;
      };
      listLinesCount = mkOption {
        description = "The number of lines of options to display. A value of `0` shows the options horizontally right of the input area.";
        type = types.ints.unsigned;
        default = 0;
      };
      wordDelimiters = mkOption {
        description = "Characters not considered part of a word when deleting words.";
        type = types.str;
        default = " ";
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
        normalForeground = mkOption {
          description = "Normal foreground.";
          type = types.str;
          default = "#bbbbbb";
        };
        normalBackground = mkOption {
          description = "Normal background.";
          type = types.str;
          default = "#222222";
        };
        selectedForeground = mkOption {
          description = "Selected foreground.";
          type = types.str;
          default = "#eeeeee";
        };
        selectedBackground = mkOption {
          description = "Selected background.";
          type = types.str;
          default = "#005577";
        };
        outForeground = mkOption {
          description = "Out foreground.";
          type = types.str;
          default = "#000000";
        };
        outBackground = mkOption {
          description = "Out background.";
          type = types.str;
          default = "#00ffff";
        };
        highlightForeground = mkOption {
          description = "Highlight foreground.";
          type = types.str;
          default = "#ffc978";
        };
        highPriorityForeground = mkOption {
          description = "High-priority foreground.";
          type = types.str;
          default = "#bbbbbb";
        };
        highPriorityBackground = mkOption {
          description = "High-priority background.";
          type = types.str;
          default = "#333333";
        };
      };
    };
    slock = {
      user = mkOption {
        description = "The user to drop privileges to.";
        type = types.str;
        default = "nobody";
      };
      group = mkOption {
        description = "The group to drop privileges to.";
        type = types.str;
        default = "nogroup"; # The default in `slock` is actually `nobody`, but NixOS uses `nogroup` instead
      };
      failOnClear = mkOption {
        description = "Whether to treat a cleared input like a wrong password (changing the screen colour).";
        type = types.bool;
        default = true;
      };
      controlKeyClear = mkOption {
        description = "Whether to allow control key to trigger fail on clear.";
        type = types.bool;
        default = false;
      };
      monitorOffSeconds = mkOption {
        description = "The time in seconds before the monitor shuts down.";
        type = types.ints.unsigned;
        default = 5;
      };
      quickCancelSeconds = mkOption {
        description = "The time in seconds to cancel lock with mouse movement.";
        type = types.ints.unsigned;
        default = 4;
      };
      quickCancelEnabledByDefault = mkOption {
        description = "Whether quick-cancel is enabled by default (the `-c` flag flips this).";
        type = types.bool;
        default = true;
      };
      commands = mkOption {
        description = "Password values for running commands while locked.";
        type = types.attrsOf types.str;
        default = {
          "shutdown" = "doas poweroff";
        };
      };
      colours = {
        initialisation = mkOption {
          description = "After initialisation.";
          type = types.str;
          default = "#000000";
        };
        input = mkOption {
          description = "During input.";
          type = types.str;
          default = "#005577";
        };
        failed = mkOption {
          description = "After a wrong password.";
          type = types.str;
          default = "#cc3333";
        };
        capsLock = mkOption {
          description = "Input while CapsLock is on.";
          type = types.str;
          default = "#007755";
        };
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
      dmenu = inputs.self.packages.${system}.dmenu.override {conf = cfg.dmenu;};

      dwm = inputs.self.packages.${system}.dwm.override {conf = cfg.dwm;};

      slock = inputs.self.packages.${system}.slock.override {conf = cfg.slock;};

      slstatus = pkgs.slstatus.override {conf = builtins.readFile ./config.slstatus.${hostname}.h;};

      st = inputs.self.packages.${system}.st.override {conf = cfg.st;};
    };
  };
}
