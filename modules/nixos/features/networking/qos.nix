{
  config,
  lib,
  ...
}:
let
  cfg = config.myNixOS.networking.qos;

  # Helper function to calculate bandwidth in bits/s from percentage
  calcRate = percentage: toString (percentage * config.myNixOS.networking.qos.totalBandwidth * 10000);
in
{
  config = lib.mkIf (config.myNixOS.networking.enable && cfg.enable) {
    systemd.services.network-qos = {
      description = "Setup Network QoS";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = [ "/run/current-system/sw/bin" ];

      preStart = ''
        # Create ipsets for different traffic types
        ipset create nix_hosts hash:ip 2>/dev/null || true
        ipset create interactive_ports hash:port 2>/dev/null || true

        # Add Nix-related hosts
        ${lib.concatMapStrings (host: ''
          ipset add nix_hosts ${host} 2>/dev/null || true
        '') cfg.downloads.hosts}

        # Add interactive ports
        ${lib.concatMapStrings (port: ''
          ipset add interactive_ports ${toString port} 2>/dev/null || true
        '') cfg.interactive.ports}
      '';

      script = ''
        # Get the main interface name
        IFACE=$(ip route | grep default | awk '{print $5}')

        # Remove existing qdiscs
        tc qdisc del dev $IFACE root 2>/dev/null || true

        # Add HTB qdisc as root
        tc qdisc add dev $IFACE root handle 1: htb default 20

        # Add main rate limit class
        tc class add dev $IFACE parent 1: classid 1:1 htb rate ${
          toString (cfg.totalBandwidth * 1000000)
        }bit # Total bandwidth in bits/s

        # Add classes for different traffic types
        tc class add dev $IFACE parent 1:1 classid 1:10 htb rate ${calcRate cfg.interactive.minRate}bit ceil ${calcRate cfg.interactive.maxRate}bit prio 1
        tc class add dev $IFACE parent 1:1 classid 1:20 htb rate ${calcRate cfg.default.minRate}bit ceil ${calcRate cfg.default.maxRate}bit prio 2
        tc class add dev $IFACE parent 1:1 classid 1:30 htb rate ${calcRate cfg.downloads.minRate}bit ceil ${calcRate cfg.downloads.maxRate}bit prio 3

        # Add fair queuing for better latency management
        tc qdisc add dev $IFACE parent 1:10 handle 10: fq_codel \
          quantum ${toString cfg.fq_codel.quantum} \
          flows ${toString cfg.fq_codel.flows} \
          interval ${toString cfg.fq_codel.interval}ms \
          target ${toString cfg.fq_codel.target}ms

        tc qdisc add dev $IFACE parent 1:20 handle 20: fq_codel \
          quantum ${toString cfg.fq_codel.quantum} \
          flows ${toString cfg.fq_codel.flows} \
          interval ${toString cfg.fq_codel.interval}ms \
          target ${toString cfg.fq_codel.target}ms

        tc qdisc add dev $IFACE parent 1:30 handle 30: fq_codel \
          quantum ${toString cfg.fq_codel.quantum} \
          flows ${toString cfg.fq_codel.flows} \
          interval ${toString cfg.fq_codel.interval}ms \
          target ${toString cfg.fq_codel.target}ms

        # Mark packets using iptables
        iptables -t mangle -F

        # Mark interactive traffic (VoIP, video calls, gaming)
        iptables -t mangle -A OUTPUT -p udp -m set --match-set interactive_ports dst -j MARK --set-mark 10
        iptables -t mangle -A OUTPUT -p tcp -m set --match-set interactive_ports dst -j MARK --set-mark 10

        # Mark package manager and build traffic
        iptables -t mangle -A OUTPUT -m set --match-set nix_hosts dst -j MARK --set-mark 30
        iptables -t mangle -A OUTPUT -m owner --uid-owner nixbld -j MARK --set-mark 30

        # Add filters based on marks
        tc filter add dev $IFACE parent 1: protocol ip handle 10 fw flowid 1:10
        tc filter add dev $IFACE parent 1: protocol ip handle 20 fw flowid 1:20
        tc filter add dev $IFACE parent 1: protocol ip handle 30 fw flowid 1:30
      '';

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };
}
