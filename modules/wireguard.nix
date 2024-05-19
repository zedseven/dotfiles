{
  config,
  pkgs,
  lib,
  inputs,
  hostname,
  ...
}: let
  cfg = config.custom.wireguard;
in {
  # The actual configuration is located in the `private` flake, since it's a mesh of all hosts, and it's sensitive
  options.custom.wireguard = with lib; {
    enable = mkEnableOption "Wireguard networking";
    interface = mkOption {
      description = "The interface to set up for Wireguard.";
      type = types.str;
      default = "wg0";
    };
  };

  config = let
    presharedKeyFile = config.age.secrets."wireguard-pre-shared-key".path;

    prepareInterfaceConfig = interfaceConfig: {inherit (interfaceConfig) address;};
    preparePeerConfig = peerConfig: {
      inherit
        (peerConfig)
        publicKey
        endpoint
        allowedIPs
        persistentKeepalive
        presharedKeyFile
        ;
    };

    wireguardConfig = inputs.private.unencryptedValues.wireguard;
    interfaceConfig =
      {
        isRouter = false;
      }
      // wireguardConfig.peers.${hostname};
    unfilteredPeerList =
      lib.mapAttrsToList (
        name: peerConfig:
          {
            inherit name presharedKeyFile;

            isRouter = false;
            endpoint = null;
            allowedIPs = peerConfig.address; # Map `address` for a peer into `allowedIPs` as a default
            persistentKeepalive = null;
          }
          // peerConfig
      )
      wireguardConfig.peers;
    peers = map preparePeerConfig (
      if interfaceConfig.isRouter
      then builtins.filter (peer: peer.name != hostname) unfilteredPeerList
      else builtins.filter (peer: peer.isRouter && peer.name != hostname) unfilteredPeerList
    );
  in
    lib.mkIf cfg.enable (
      lib.mkMerge [
        {
          networking = {
            firewall.allowedUDPPorts = [wireguardConfig.listenPort];

            wg-quick.interfaces.${cfg.interface} =
              {
                inherit (wireguardConfig) listenPort;
                inherit peers;

                privateKeyFile = config.age.secrets."wireguard-private-key-${hostname}".path;
              }
              // (prepareInterfaceConfig interfaceConfig);
          };
        }
        # "Routers" need to be set up with IP Forwarding
        (lib.mkIf interfaceConfig.isRouter {
          boot.kernel.sysctl = {
            "net.ipv4.ip_forward" = 1;
            "net.ipv6.conf.all.forwarding" = 1;
          };
        })
        # If Mullvad is running on the system, some extra table rules are required to allow traffic through this interface
        # https://mullvad.net/en/help/split-tunneling-with-linux-advanced#excluding
        # https://serverfault.com/questions/1147215/prevent-routing-loop-with-fwmark-in-wireguard/1147291#1147291
        # https://wiki.nftables.org/wiki-nftables/index.php/Quick_reference-nftables_in_10_minutes
        (lib.mkIf config.services.mullvad-vpn.enable {
          networking.wg-quick.interfaces.${cfg.interface} = let
            excludeTableName = "wg-quick-${cfg.interface}";
            excludeTable = pkgs.writeText "${excludeTableName}.nft" ''
              # For idempotence
              table inet ${excludeTableName}
              delete table inet ${excludeTableName}

              # Mark any traffic for our interface as excluded from Mullvad's killswitch
              table inet ${excludeTableName} {
                chain excludeOutgoing {
                  type route hook output priority -10; policy accept;
                  iifname ${cfg.interface} ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
                  oifname ${cfg.interface} ct mark set 0x00000f41 meta mark set 0x6d6f6c65;
                }
              }
            '';
          in {
            preUp = ["${pkgs.nftables}/bin/nft -f ${excludeTable}"];
            preDown = ["${pkgs.nftables}/bin/nft delete table ${excludeTableName} 2>/dev/null || true"];
          };
        })
      ]
    );
}
