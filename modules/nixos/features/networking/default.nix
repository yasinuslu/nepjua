{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.myNixOS.networking;
in
{
  imports = [
    ./qos.nix
    ./sysctl.nix
  ];

  options.myNixOS.networking = {
    qos = {
      enable = lib.mkEnableOption "Quality of Service";

      totalBandwidth = lib.mkOption {
        type = lib.types.int;
        default = 1000;
        description = "Total bandwidth in Mbps";
      };

      interactive = {
        minRate = lib.mkOption {
          type = lib.types.int;
          default = 80;
          description = "Minimum percentage of bandwidth for interactive traffic";
        };

        maxRate = lib.mkOption {
          type = lib.types.int;
          default = 100;
          description = "Maximum percentage of bandwidth for interactive traffic";
        };

        ports = lib.mkOption {
          type = lib.types.listOf lib.types.port;
          default = [
            22 # SSH
            443 # HTTPS (WebRTC)
            3478 # STUN
            3479 # STUN
            5349 # STUN/TURN
            5350 # STUN/TURN
            19302 # WebRTC
            19303 # WebRTC
          ];
          description = "Ports to be treated as interactive traffic";
        };
      };

      default = {
        minRate = lib.mkOption {
          type = lib.types.int;
          default = 60;
          description = "Minimum percentage of bandwidth for default traffic";
        };

        maxRate = lib.mkOption {
          type = lib.types.int;
          default = 80;
          description = "Maximum percentage of bandwidth for default traffic";
        };
      };

      downloads = {
        minRate = lib.mkOption {
          type = lib.types.int;
          default = 40;
          description = "Minimum percentage of bandwidth for download traffic";
        };

        maxRate = lib.mkOption {
          type = lib.types.int;
          default = 60;
          description = "Maximum percentage of bandwidth for download traffic";
        };

        hosts = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "cache.nixos.org"
            "cache.saumon.network"
            "github.com"
          ];
          description = "Hosts to be treated as download traffic";
        };
      };

      fq_codel = {
        quantum = lib.mkOption {
          type = lib.types.int;
          default = 300;
          description = "Quantum parameter for fq_codel";
        };

        flows = lib.mkOption {
          type = lib.types.int;
          default = 256;
          description = "Number of flows for fq_codel";
        };

        interval = lib.mkOption {
          type = lib.types.int;
          default = 20;
          description = "Interval in ms for fq_codel";
        };

        target = lib.mkOption {
          type = lib.types.int;
          default = 10;
          description = "Target latency in ms for fq_codel";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.network.enable = true;
    networking.networkmanager.enable = false;
    networking.useNetworkd = true;
    networking.useDHCP = true;

    # Common network settings
    networking.nameservers = [
      "1.1.1.1"
      "1.0.0.1"
      "8.8.8.8"
      "8.8.4.4"
    ];

    # Required packages
    environment.systemPackages = with pkgs; [
      iproute2
      iptables
      ipset
    ];
  };
}
