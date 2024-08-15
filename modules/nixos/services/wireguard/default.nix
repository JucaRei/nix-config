{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.excalibur; let
  cfg = config.excalibur.services.wireguard;
in {
  options.excalibur.services.wireguard = with types; {
    enable = mkBoolOpt false "Enable OpenVPN Server;";
    server = mkBoolOpt true "Is a Wireguard Server";
    publicKey = mkOpt str "123456789" "The server's public key";
    endpoint = mkOpt str "vpn.aiexcalibur.com" "VPN Domain Name / IP address.";
    port = mkOpt int 1149 "Port to use for the VPN";
    ips =
      mkOpt (listOf str) ["10.100.0.2/24" "fc10:100:0::1/64"]
      "List of IPs of the server end of the tunner interface.";
    allowedIPs =
      mkOpt (listOf str) ["10.100.0.5/32" "fc10:100:0::5/128"]
      "List of IPs of the client IPs supported.";
    postRoutCIDR = mkOpt str "10.100.0.0/24" "CIDR to route traffic to..";
    peers = mkOption {
      type = types.listOf (types.submodule {
        options = {
          publicKey = mkOption {
            type = types.str;
            description = "Public key of the peer.";
          };
          allowedIPs = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "IPs allowed for this peer.";
          };
          presharedKeyFile = mkOption {
            type = types.str;
            description = "PreShared key of the peer.";
          };
        };
      });
      default = [];
      description = "Configuration for WireGuard peers.";
      example = [
        {
          publicKey = "public1";
          presharedKeyFile = "/var/lib/wireguard/preshared-keyfile";
          allowedIPs = ["10.100.0.2/32"];
        }
        {
          publicKey = "public2";
          presharedKeyFile = "/var/lib/wireguard/preshared-keyfile";
          allowedIPs = ["10.100.0.3/32"];
        }
      ];
    };
    role-id =
      mkOpt str config.excalibur.services.vault-agent.settings.vault.role-id
      "Absolute path to the Vault role-id";
    secret-id =
      mkOpt str config.excalibur.services.vault-agent.settings.vault.secret-id
      "Absolute path to the Vault secret-id";
    vault-path =
      mkOpt str "secret/excalibur/wireguard"
      "The Vault path to the Server Cert in Vault";
    kvVersion = mkOption {
      type = enum ["v1" "v2"];
      default = "v2";
      description = "KV store version used for tls key";
    };
    vault-address = mkOption {
      type = str;
      default = config.excalibur.services.vault-agent.settings.vault.address;
      description = "The address of your Vault";
    };
  };

  config = mkIf cfg.enable {
    networking.nat = {
      enable = true;
      enableIPv6 = true;
      externalInterface = "eth0";
      internalInterfaces = ["wg0"];
    };
    services.dnsmasq = {
      enable = true;
      settings = {interface = "wg0";};
    };

    boot.kernel.sysctl = {"net.ipv4.ip_forward" = 1;};
    networking.firewall.allowedUDPPorts = [cfg.port 53];
    # networking.firewall.allowedTCPPorts = [ 53 ];

    networking.wireguard.enable = true;
    # TODO: Support multiple vpns
    networking.wireguard.interfaces."wg0" = {
      privateKeyFile = "/var/lib/wireguard/wg0-private-key";
      # The port that WireGuard listens to. Must be accessible by the client.
      listenPort = cfg.port;
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = cfg.ips;

      # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
      # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s ${cfg.postRoutCIDR} -o eno1 -j MASQUERADE;
      '';

      # This undoes the above command
      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s ${cfg.postRoutCIDR} -o eno1 -j MASQUERADE
      '';
      peers = cfg.peers;
    };

    # systemd.services.getWireguardKeys = {
    #   description = "Fetch Private Key from Vault";
    #   serviceConfig = {
    #     Type = "oneshot";
    #     User = "root";  # Use the root user to create the folder and set permissions
    #     ExecStart = "/bin/sh /tmp/detsys-vault/getWireguardKeys.sh";
    #   };
    #   wantedBy = [ "multi-user.target" ];
    # };

    excalibur.services.vault-agent.services.getWireguardKeys = {
      settings = {
        vault.address = cfg.vault-address;
        auto_auth = {
          method = [
            {
              type = "approle";
              config = {
                role_id_file_path = cfg.role-id;
                secret_id_file_path = cfg.secret-id;
                remove_secret_id_file_after_reading = false;
              };
            }
          ];
        };
      };
      secrets = {
        file = {
          files = {
            "getWireguardKeys.sh" = {
              text = ''
                #!/bin/sh
                set -e  # exit immediately on error

                # Create directory for VPN certificates
                mkdir -p /var/lib/wireguard

                cat <<EOL > /var/lib/wireguard/wg0-private-key
                {{ with secret "${cfg.vault-path}" }}{{ if eq "${cfg.kvVersion}" "v1" }}{{ .Data.privateKey }}{{ else }}{{ .Data.data.privateKey }}{{ end }}{{ end }}
                EOL

                cat <<EOL > /var/lib/wireguard/wg0-preshared-key
                {{ with secret "${cfg.vault-path}" }}{{ if eq "${cfg.kvVersion}" "v1" }}{{ .Data.presharedKey }}{{ else }}{{ .Data.data.presharedKey }}{{ end }}{{ end }}
                EOL

                # Fix permissions
                chmod -R 0600 /var/lib/wireguard
              '';
              permissions = "0400";
              change-action = "restart";
            };
          };
        };
      };
    };
  };
}
