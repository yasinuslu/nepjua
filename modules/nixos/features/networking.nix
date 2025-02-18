{ ... }:
{
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

  # Network performance optimizations
  boot.kernel.sysctl = {
    # More conservative buffer sizes for stability
    "net.core.rmem_max" = 8388608; # 8MB instead of 16MB
    "net.core.wmem_max" = 8388608;
    "net.core.rmem_default" = 524288; # 512KB instead of 1MB
    "net.core.wmem_default" = 524288;
    "net.core.netdev_max_backlog" = 8192; # More conservative backlog

    # TCP optimizations focused on stability
    "net.ipv4.tcp_rmem" = "4096 524288 8388608"; # More conservative TCP buffers
    "net.ipv4.tcp_wmem" = "4096 524288 8388608";
    "net.ipv4.tcp_max_syn_backlog" = 4096;
    "net.ipv4.tcp_max_tw_buckets" = 1440000;
    "net.ipv4.tcp_tw_reuse" = 1;
    "net.ipv4.tcp_fin_timeout" = 15; # Slightly longer FIN timeout
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv4.tcp_mtu_probing" = 1;

    # More aggressive TCP keepalive for faster detection of connection issues
    "net.ipv4.tcp_keepalive_time" = 30; # Check every 30 seconds (was 60)
    "net.ipv4.tcp_keepalive_intvl" = 5; # 5 second interval (was 10)
    "net.ipv4.tcp_keepalive_probes" = 9; # More probes (was 6)

    # Additional stability settings
    "net.ipv4.tcp_syncookies" = 1; # Protection against SYN floods
    "net.ipv4.tcp_rfc1337" = 1; # Protect against time-wait assassination
    "net.ipv4.tcp_timestamps" = 1; # Better RTT calculation
    "net.ipv4.tcp_sack" = 1; # Selective ACK for better recovery
    "net.ipv4.tcp_fack" = 1; # Forward ACK for better recovery
    "net.ipv4.tcp_ecn" = 1; # Explicit Congestion Notification
    "net.ipv4.tcp_reordering" = 3; # Conservative reordering threshold
    "net.ipv4.tcp_retries2" = 8; # More retries before giving up
    "net.ipv4.tcp_abort_on_overflow" = 0; # Don't abort on queue overflow

    # TCP congestion control
    "net.ipv4.tcp_congestion_control" = "cubic";
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_window_scaling" = 1;
    "net.ipv4.tcp_moderate_rcvbuf" = 1; # Auto-tune receive buffers
  };
}
