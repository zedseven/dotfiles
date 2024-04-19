# Everything here comes from https://github.com/FabricMC/fabric-installer/issues/50#issuecomment-1013444858
# with additional modifications by me.
{
  lib,
  callPackage,
  writeText,
  stdenvNoCC,
  runtimeShell,
  jre_headless,
  minecraft-server,
}: let
  lock = import ./lock.nix;
  loader = callPackage ./generate-loader.nix {};

  log4jConfiguration = let
    fileName = "log4j.xml";
    storePath = lib.fileset.toSource {
      root = ./.;
      fileset = ./. + "/${fileName}";
    };
  in "${storePath}/${fileName}";

  # This is so that all JARs use the same JRE, since the `minecraft-server` package uses a different version by default
  vanillaServer = minecraft-server.override {inherit jre_headless;};

  # https://github.com/FabricMC/fabric-loader/blob/63840270caa7f7e0a660354577afe19d133bff77/src/main/java/net/fabricmc/loader/impl/launch/server/FabricServerLauncher.java#L52
  launcherProperties = writeText "fabric-server-launcher.properties" ''
    serverJar=${vanillaServer}/lib/minecraft/server.jar
    launch.mainClass=${lock.mainClass}
  '';

  mainProgram = "minecraft-server";
in
  stdenvNoCC.mkDerivation {
    pname = "minecraft-server-fabric";
    version = "${lock.minecraftVersion}-${lock.loaderVersion}";

    installPhase = ''
      mkdir -p $out/bin


      cat > $out/bin/${mainProgram} << EOF
      #!${runtimeShell}

      # Create a link to the Fabric loader properties file in the working directory
      ln -sf ${launcherProperties} fabric-server-launcher.properties

      # Execute
      exec ${jre_headless}/bin/java -Dlog4j.configurationFile=${log4jConfiguration} \$@ -jar ${loader} nogui
      EOF


      chmod +x $out/bin/${mainProgram}
    '';

    dontUnpack = true;

    meta = {
      inherit mainProgram;
      homepage = "https://fabricmc.net/";
      description = "The server version of a modular, lightweight mod loader for Minecraft";
      license = lib.licenses.unfreeRedistributable;
      maintainers = with lib.maintainers; [zedseven];
      platforms = lib.platforms.all;
      sourceProvenance = with lib.sourceTypes; [binaryBytecode];
    };
  }
