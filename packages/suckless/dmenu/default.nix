{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  fontconfig,
  libX11,
  libXinerama,
  libXft,
  libXcursor,
  zlib,
  conf ? {},
  extraConfigText ? "",
  extraLibs ? [],
}:
stdenv.mkDerivation {
  pname = "dmenu";
  version = "5.2";

  src = fetchFromGitHub {
    owner = "zedseven";
    repo = "dmenu";
    rev = "b823f73f2b477796ff95f48edbe1f740d800986e";
    hash = "sha256-nxodcOXYhW5HPTWDyUot6lEIQDF2fnzWQFH+Xjq7ZSQ=";
  };

  strictDeps = true;

  makeFlags = ["PKG_CONFIG=${stdenv.cc.targetPrefix}pkg-config"];

  nativeBuildInputs = [pkg-config];

  buildInputs =
    [
      fontconfig
      libX11
      libXinerama
      libXft
      zlib
    ]
    ++ extraLibs;

  patches = [./configurable.patch];

  postPatch = let
    promptString =
      if conf.prompt != null
      then "\"${conf.prompt}\""
      else "NULL";
    displayOnScreenTopString =
      if conf.displayOnScreenTop
      then "1"
      else "0";
  in ''
    sed -ri -e 's!\<(dmenu|dmenu_path|stest)\>!'"$out/bin"'/&!g' dmenu_run
    sed -ri -e 's!\<stest\>!'"$out/bin"'/&!g' dmenu_path

    cp config.def.h config.h

    substituteInPlace config.h \
      --replace-fail "@PROMPT@" '${promptString}' \
      --replace-fail "@DISPLAY_ON_SCREEN_TOP@" "${displayOnScreenTopString}" \
      --replace-fail "@LIST_LINES_COUNT@" "${(builtins.toString conf.listLinesCount)}" \
      --replace-fail "@WORD_DELIMITERS@" "${conf.wordDelimiters}" \
      --replace-fail "@FONT_FAMILY@" "${conf.font.family}" \
      --replace-fail "@FONT_PIXEL_SIZE@" "${(builtins.toString conf.font.pixelSize)}" \
      --replace-fail "@COLOUR_NORMAL_FOREGROUND@" "${conf.colours.normalForeground}" \
      --replace-fail "@COLOUR_NORMAL_BACKGROUND@" "${conf.colours.normalBackground}" \
      --replace-fail "@COLOUR_SELECTED_FOREGROUND@" "${conf.colours.selectedForeground}" \
      --replace-fail "@COLOUR_SELECTED_BACKGROUND@" "${conf.colours.selectedBackground}" \
      --replace-fail "@COLOUR_OUT_FOREGROUND@" "${conf.colours.outForeground}" \
      --replace-fail "@COLOUR_OUT_BACKGROUND@" "${conf.colours.outBackground}" \
      --replace-fail "@COLOUR_HIGHLIGHT_FOREGROUND@" "${conf.colours.highlightForeground}" \
      --replace-fail "@COLOUR_HIGH_PRIORITY_FOREGROUND@" "${conf.colours.highPriorityForeground}" \
      --replace-fail "@COLOUR_HIGH_PRIORITY_BACKGROUND@" "${conf.colours.highPriorityBackground}"

    echo "" >> config.h
    echo '''${extraConfigText}''' >> config.h
  '';

  preConfigure = ''
    makeFlagsArray+=(
      PREFIX="$out"
      CC="$CC"
      # default config.mk hardcodes dependent libraries and include paths
      INCS="`$PKG_CONFIG --cflags fontconfig x11 xft xinerama`"
      LIBS="`$PKG_CONFIG --libs   fontconfig x11 xft xinerama`"
    )
  '';

  meta = {
    homepage = "https://github.com/zedseven/dmenu";
    description = "zedseven's custom fork of dmenu";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [zedseven];
    mainProgram = "dmenu";
    platforms = lib.platforms.unix;
  };
}
