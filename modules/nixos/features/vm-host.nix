{ pkgs, ... }:
{
  # Core virtualization settings
  virtualisation = {
    libvirtd = {
      enable = true;
      onBoot = "ignore";
      onShutdown = "shutdown";
      qemu = {
        package = pkgs.qemu_full;
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMFFull.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
        };
        swtpm.enable = true;
        runAsRoot = false;
      };
      # Logging and socket configuration
      extraConfig = ''
        log_level = 1
        log_filters="3:qemu 3:libvirt 3:conf 3:security"
        log_outputs="1:file:/var/log/libvirt/libvirtd.log"
        unix_sock_group = "libvirtd"
        unix_sock_rw_perms = "0770"
        max_queued = 1024
        max_parallel_queries = 32
        max_client_requests = 64
      '';
    };
    spiceUSBRedirection.enable = true; # Enable USB redirection for SPICE
  };

  # Required directories
  systemd.tmpfiles.rules = [
    "d /var/log/libvirt 0755 root root -"
    "d /var/lib/libvirt/qemu/nvram 0755 root root -"
    # VM storage structure
    "d /tank/vm 0755 root root -"
    "d /tank/vm/storage 0755 root root -"
    "d /tank/vm/iso 0755 root root -"
    "d /tank/vm/backup 0755 root root -"
    "d /tank/vm/templates 0755 root root -"
  ];

  # GUI management tools
  programs = {
    virt-manager.enable = true;
    dconf.enable = true; # Required for virt-manager settings
  };

  # Required packages
  environment.systemPackages = with pkgs; [
    virt-viewer
    spice-gtk
    win-virtio # Windows VirtIO drivers
    win-spice # Windows SPICE drivers
    swtpm # Software TPM emulator
  ];

  # Kernel configuration for virtualization
  boot = {
    kernelParams = [
      "amd_iommu=on"
      "iommu=pt"
      "kvm.ignore_msrs=1"
      "kvm.report_ignored_msrs=0"
    ];
    kernelModules = [
      "kvm-amd"
      "vfio"
      "vfio_iommu_type1"
      "vfio_pci"
      "vfio_virqfd"
    ];
    blacklistedKernelModules = [
      "nouveau"
      "nvidia"
      "nvidia_drm"
      "nvidia_uvm"
      "nvidia_modeset"
    ];
  };

  # Storage pools setup
  systemd.services.libvirtd-storage-pools = {
    description = "Creates storage pools for libvirt";
    requires = [ "libvirtd.service" ];
    after = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.libvirt ]; # Add libvirt to service path for virsh command
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      set -eu

      # Function to create pool if it doesn't exist
      create_pool() {
        local name=$1
        local path=$2
        if ! virsh pool-info "$name" >/dev/null 2>&1; then
          mkdir -p "$path"
          virsh pool-define-as --name "$name" --type dir --target "$path"
          virsh pool-start "$name"
          virsh pool-autostart "$name"
        fi
      }

      # Create various storage pools
      create_pool "default" "/var/lib/libvirt/images"
      create_pool "storage" "/tank/vm/storage"
      create_pool "iso" "/tank/vm/iso"
      create_pool "backup" "/tank/vm/backup"
      create_pool "templates" "/tank/vm/templates"
    '';
  };
}
