{...}: {
  # Use NetworkManager
  networking.networkmanager.enable = true;

  # Use Networkd
  # networking.useNetworkd = true;
  # networking.useDHCP = true;

  # Common network settings
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
    "8.8.8.8"
    "8.8.4.4"
  ];

  # NetworkManager settings
  systemd.services.NetworkManager-wait-online.enable = false;
  networking.networkmanager.wifi.powersave = false;

  # Network performance optimizations
  boot.kernel.sysctl = {
    # Increase network buffer sizes
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.core.rmem_default" = 1048576;
    "net.core.wmem_default" = 1048576;
    "net.core.netdev_max_backlog" = 16384;

    # TCP optimizations
    "net.ipv4.tcp_rmem" = "4096 1048576 16777216";
    "net.ipv4.tcp_wmem" = "4096 1048576 16777216";
    "net.ipv4.tcp_max_syn_backlog" = 8192;
    "net.ipv4.tcp_max_tw_buckets" = 2000000;
    "net.ipv4.tcp_tw_reuse" = 1;
    "net.ipv4.tcp_fin_timeout" = 10;
    "net.ipv4.tcp_slow_start_after_idle" = 0;
    "net.ipv4.tcp_mtu_probing" = 1;

    # TCP keepalive for better connection stability
    "net.ipv4.tcp_keepalive_time" = 60;
    "net.ipv4.tcp_keepalive_intvl" = 10;
    "net.ipv4.tcp_keepalive_probes" = 6;

    # TCP congestion control
    "net.ipv4.tcp_congestion_control" = "cubic";
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_window_scaling" = 1;
  };
}
