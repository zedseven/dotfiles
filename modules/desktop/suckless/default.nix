{
  config,
  pkgs,
  lib,
  ...
}: {
  nixpkgs.config.packageOverrides = pkgs: {
    dmenu = pkgs.dmenu.overrideAttrs (oldAttrs: {
      src = pkgs.fetchFromGitHub {
        owner = "zedseven";
        repo = "dmenu";
        rev = "b823f73f2b477796ff95f48edbe1f740d800986e";
        sha256 = "sha256-nxodcOXYhW5HPTWDyUot6lEIQDF2fnzWQFH+Xjq7ZSQ=";
      };
      postPatch =
        oldAttrs.postPatch
        + ''
          cp ${pkgs.writeText "config.dmenu.h" (builtins.readFile ./config.dmenu.h)} config.h
        '';
    });
    dwm =
      (pkgs.dwm.overrideAttrs (oldAttrs: {
        buildInputs = oldAttrs.buildInputs ++ [pkgs.xorg.libXcursor];
        src = pkgs.fetchFromGitHub {
          owner = "zedseven";
          repo = "dwm";
          rev = "8119b63b814295ff80083647e8b6ac3888aa045e";
          sha256 = "sha256-GnXanSRQlh66X0EBnevrU/oR3Qc1lD2VesN1EdTwSf0=";
        };
      }))
      .override {
        conf = builtins.readFile ./config.dwm.h;
      };
    slock =
      (pkgs.slock.overrideAttrs {
        src = pkgs.fetchFromGitHub {
          owner = "zedseven";
          repo = "slock";
          rev = "84c9d2702e94cf45bd0049cd430755613e6dfbd3";
          sha256 = "sha256-BnS/lKWgRpjxsGDWMflPfgrFQeuTiT5gXvg2cztxlYE=";
        };
      })
      .override {
        conf = builtins.readFile ./config.slock.h;
      };
    slstatus = pkgs.slstatus.override {
      conf = builtins.readFile ./config.slstatus.h;
    };
    st =
      (pkgs.st.overrideAttrs
        (oldAttrs: {
          buildInputs = oldAttrs.buildInputs ++ [pkgs.xorg.libXcursor pkgs.harfbuzz];
          src = pkgs.fetchFromGitHub {
            owner = "zedseven";
            repo = "st";
            rev = "54d82a8156a1bee8ebfec5836c3325490259fca3";
            sha256 = "sha256-n91/Evy9RuUXF+G5gbwm/7eKvMwVMKg/pBgl6rX9UZg=";
          };
        }))
      .override {
        conf = builtins.readFile ./config.st.h;
      };
  };
}