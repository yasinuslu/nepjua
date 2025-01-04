# Proxmox VE Installation Guide

## 1. Base Installation

### Initial Configuration

```plaintext
## ===================================================
##  Hetzner Online GmbH - installimage  -  Proxmox-VE
## ===================================================

DRIVE1 /dev/nvme0n1
DRIVE2 /dev/nvme1n1

SWRAID 0
HOSTNAME pve
USE_KERNEL_MODE_SETTING yes

# System on first drive
PART /boot/efi   esp    512M
PART /boot       ext4     2G
PART swap       swap     4G
PART /          ext4    80G
PART /reserved  -       all

IMAGE /root/.oldroot/nfs/images/Debian-1207-bookworm-amd64-base.tar.gz
```

### Installation Steps

1. Boot into rescue system
2. Run `installimage`
3. Paste the configuration above
4. Adjust password
5. Let installation complete
6. Reboot into new system

## 2. Initial System Configuration

### Network Detection

```bash
# VM Subnet
VM_SUBNET="192.168.0.0/24"

# Get primary network interface name
PRIMARY_NIC=$(ip -o link show | awk -F': ' '$2 ~ /^(en|eth)/ && $2 !~ /br/ {print $2; exit}')

# Get current IP configuration
CURRENT_IP=$(ip -4 addr show $PRIMARY_NIC | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
CURRENT_MASK=$(ip -4 addr show $PRIMARY_NIC | grep -oP '(?<=inet\s)(\d+(\.\d+){3})/\K\d+')
CURRENT_GW=$(ip route | awk '/default/ {print $3}')
CURRENT_IPV6=$(ip -6 addr show $PRIMARY_NIC | grep -oP '(?<=inet6\s)([0-9a-f:]+)/64' | head -n1)
```

### Hostname Configuration

```bash
# Set hostname
hostnamectl set-hostname pve

# Configure /etc/hosts with current IP
cat > /etc/hosts << EOF
# IPv4
127.0.0.1       localhost
${CURRENT_IP}   pve

# IPv6
::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
${CURRENT_IPV6} pve
EOF
```

### Network Configuration

```bash
# Create network configuration for VMs
cat > /etc/network/interfaces << EOF
auto lo
iface lo inet loopback

# Primary Network Interface
auto ${PRIMARY_NIC}
iface ${PRIMARY_NIC} inet static
        address ${CURRENT_IP}/${CURRENT_MASK}
        gateway ${CURRENT_GW}
        # Hetzner requires these for proper networking
        up route add -net 172.31.1.1/32 gw ${CURRENT_GW}
        up route add -net 169.254.0.0/16 gw ${CURRENT_GW}

iface ${PRIMARY_NIC} inet6 static
        address ${CURRENT_IPV6}
        gateway fe80::1

# Bridge for VMs with NAT
auto vmbr0
iface vmbr0 inet static
        address 192.168.0.1/24
        bridge-ports none
        bridge-stp off
        bridge-fd 0
        post-up   echo 1 > /proc/sys/net/ipv4/ip_forward
        post-up   iptables -t nat -A POSTROUTING -s '192.168.0.0/24' -o ${PRIMARY_NIC} -j MASQUERADE
        post-down iptables -t nat -D POSTROUTING -s '192.168.0.0/24' -o ${PRIMARY_NIC} -j MASQUERADE
EOF

# Install tcpdump for network debugging (optional)
apt install -y tcpdump

# Restart networking
systemctl restart networking

# Verify configuration
ip addr show vmbr0
ip route | grep 192.168.0
iptables -t nat -L POSTROUTING -v -n
```

### Verify Network Setup

```bash
# Check bridge interface configuration
ip addr show vmbr0
# Expected output should show:
#  - IP address: 192.168.0.1/24
#  - Interface state: UP
#  - Scope: global

# Verify routing
ip route | grep 192.168.0
# Expected output:
# 192.168.0.0/24 dev vmbr0 proto kernel scope link src 192.168.0.1

# Check NAT rules
iptables -t nat -L POSTROUTING -v -n
# Should show two rules:
#  1. ts-postrouting (Tailscale)
#  2. MASQUERADE for 192.168.0.0/24 via primary interface

# Test connectivity from host
ping -c 3 8.8.8.8
# Should show successful pings with low latency
```

The network is correctly configured when:

- Bridge has correct IP (192.168.0.1/24)
- Routing table shows proper VM subnet routing
- NAT masquerade rule is present
- Host can reach internet

## 3. Proxmox Installation

```bash
# Add Proxmox repository key
curl -o /etc/apt/trusted.gpg.d/proxmox-release-bookworm.gpg http://download.proxmox.com/debian/proxmox-release-bookworm.gpg

# Add Proxmox repository
echo "deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list

# Update and install
apt update && apt full-upgrade -y
apt install -y proxmox-ve postfix open-iscsi

# Disable enterprise repository
rm -rf /etc/apt/sources.list.d/pve-enterprise.list
```

Reboot the system:

```bash
# Update grub just in case
update-grub

# Reboot
reboot
```

Verify that you are now using pve kernel:

```bash
uname -r
```

Verify you can access the web interface at https://pve:8006

## 4. ZFS Setup

### Create ZFS Pool

```bash
# Install ZFS tools
apt update -y
apt install -y linux-headers-amd64 zfs-dkms zfsutils-linux

# Load ZFS module
modprobe zfs

# Wipe the partition
umount /dev/nvme0n1p5
wipefs -a /dev/nvme0n1p5

# Create pool with mirror (force different sizes)
zpool create -f -o ashift=12 tank mirror /dev/nvme0n1p5 /dev/nvme1n1

# Set basic properties
zfs set compression=lz4 tank
zfs set atime=off tank

# Create datasets structure for Proxmox
zfs create tank/backup
zfs create tank/iso
zfs create tank/ct
zfs create tank/snippets

# Verify setup
zpool status tank
zfs list -r tank
```

### Remove /reserved Mount Point

After creating the ZFS pool using the reserved partition, you need to remove its entry from `/etc/fstab` to prevent boot issues:

```bash
# Remove the /reserved mount point from fstab
sed -i '/\/reserved/d' /etc/fstab

# Verify fstab contents
cat /etc/fstab
```

### Enable IOMMU Support

For better VM performance and PCI passthrough capabilities, enable IOMMU support:

```bash
# Add IOMMU parameters to GRUB
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*"/GRUB_CMDLINE_LINUX_DEFAULT="consoleblank=0 amd_iommu=on iommu=pt iommu.strict=1 kvm.ignore_msrs=1"/' /etc/default/grub

# Update GRUB configuration
update-grub

# Reboot to apply changes
reboot
```

### VM Configuration

For NixOS development workstations with GNOME Shell, start with these basic settings:

```bash
# Create VM with basic configuration
qm set <vmid> \
  -memory 50000 \
  -cores 10 \
  -sockets 1 \
  -vga "virtio,memory=512"
```

Basic configuration includes:

1. 50GB RAM (`memory: 50000`)
2. 10 cores on single socket for better performance
3. Virtio GPU with 512MB video memory for GNOME Shell

### VM Performance Optimization

After basic setup, apply these performance optimizations:

```bash
# Stop the VM before applying changes
qm stop <vmid>

# Apply optimizations
qm set <vmid> \
  -cpu "host,flags=+pdpe1gb;+aes,hidden=1" \
  -numa 0 \
  -balloon 40000 \
  -net0 "virtio=XX:XX:XX:XX:XX:XX,bridge=vmbr0,firewall=1,queues=8" \
  -scsi0 "local-zfs:vm-<vmid>-disk-0,iothread=1,aio=native,discard=on"

# Start the VM
qm start <vmid>
```

These optimizations include:

1. CPU passthrough with host model and essential flags
2. Memory ballooning for dynamic memory management (40GB target)
   - Allows dynamic memory allocation between 40-50GB
   - VM starts with 50GB (`memory: 50000`)
   - Can shrink down to 40GB when memory pressure is high
   - Helps with memory overcommitment and efficient host memory utilization
3. Network optimization with multi-queue support
4. I/O optimization with native AIO and discard
5. NUMA configuration for optimal memory access

### Network Performance Tuning

For better network performance, especially for real-time applications and remote desktop connections, apply these network optimizations to the Proxmox host:

```bash
# Create network tuning configuration
cat > /etc/sysctl.d/98-network-tune.conf << EOF
# Buffer Sizes
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.core.rmem_default = 1048576
net.core.wmem_default = 1048576
net.core.netdev_max_backlog = 16384
net.core.somaxconn = 8192

# TCP Memory
net.ipv4.tcp_rmem = 4096 1048576 16777216
net.ipv4.tcp_wmem = 4096 1048576 16777216

# Connection Handling
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 10

# Performance Optimization
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.tcp_mtu_probing = 1
EOF

# Apply settings
sysctl -p /etc/sysctl.d/98-network-tune.conf
```

These settings optimize:

1. Network buffer sizes for better streaming performance
2. Connection handling for more concurrent connections
3. TCP behavior for better throughput and latency
4. MTU probing for optimal packet sizes

The configuration is particularly beneficial for:

- Remote desktop connections (like RustDesk)
- Container image downloads
- Development tools with network requirements
- Real-time applications

After reboot, verify IOMMU is enabled:

```bash
dmesg | grep -i 'iommu'
```

## 5. Configure Proxmox Storage

### Via Web UI

1. Access Web UI at https://your-ip:8006
2. Go to Datacenter → Storage
3. Add ZFS storage:
   - ID: local-zfs
   - Pool: tank
   - Content:
     - Images (for VMs)
     - Containers
     - Backups

### Via CLI

```bash
# Add ZFS storage for VM images
pvesm add zfspool local-zfs -pool tank
pvesm set local-zfs -content images,rootdir

# Add storage for ISO images
pvesm add dir local-iso -path /tank/iso
pvesm set local-iso -content iso

# Add storage for container templates
pvesm add dir local-ct -path /tank/ct
pvesm set local-ct -content vztmpl

# Add storage for backups
pvesm add dir local-backup -path /tank/backup
pvesm set local-backup -content backup

# Add storage for snippets (cloud-init)
pvesm add dir local-snippets -path /tank/snippets
pvesm set local-snippets -content snippets

# Modify local storage to only allow disk image imports
pvesm set local --content images
pvesm set local --disable 1

# Verify storage configuration
pvesm status
```

## 6. Configure Tailscale

### Install tailscale

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

### Advanced Tailscale Configuration

```bash
# Set your authentication key
TAILSCALE_AUTH_KEY="auth-key"

# Enable IP forwarding
cat <<EOF > /etc/sysctl.d/99-tailscale.conf
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF
sysctl -p /etc/sysctl.d/99-tailscale.conf

# Start Tailscale with subnet routing
tailscale up --auth-key=${TAILSCALE_AUTH_KEY} --advertise-routes=${VM_SUBNET}

# Verify routes
tailscale status
```

## 7. DHCP Server Setup

### Install and Configure DHCP Server

```bash
# Install ISC DHCP server
apt install -y isc-dhcp-server

# Stop the service for configuration
systemctl stop isc-dhcp-server

# Configure DHCP server interface
cat > /etc/default/isc-dhcp-server << EOF
INTERFACESv4="vmbr0"
INTERFACESv6=""
EOF

# Configure DHCP server
cat > /etc/dhcp/dhcpd.conf << EOF
# Global configuration
default-lease-time 600;
max-lease-time 7200;
authoritative;
ddns-update-style none;

# Ensure unique IP assignments
one-lease-per-client true;
deny duplicates;

# VM Network
subnet 192.168.0.0 netmask 255.255.255.0 {
    range 192.168.0.100 192.168.0.200;
    option routers 192.168.0.1;
    option domain-name-servers 1.1.1.1, 8.8.8.8;
    
    # Use hardware addresses for unique identification
    use-host-decl-names on;
}
EOF

# Test configuration syntax
dhcpd -t -cf /etc/dhcp/dhcpd.conf

# Start and enable DHCP server
systemctl start isc-dhcp-server
systemctl enable isc-dhcp-server

# Verify DHCP server status
systemctl status isc-dhcp-server
```

### Verify DHCP Configuration

```bash
# Check if DHCP server is listening
ss -tunlp | grep dhcpd

# Check DHCP server logs
journalctl -u isc-dhcp-server -n 50

# View current DHCP leases
cat /var/lib/dhcp/dhcpd.leases
```

The DHCP server is configured to:

- Assign IPs in range 192.168.0.100 - 192.168.0.200
- Set VM gateway to 192.168.0.1 (our bridge)
- Use Cloudflare and Google DNS servers

## Recovery Procedures

### System Drive Failure (nvme0n1)

1. Boot rescue system
2. Use same installation config
3. After installation:

```bash
# Import existing ZFS pool
zpool import tank

# Resilver if needed
zpool replace tank /dev/nvme0n1p5
```

### Data Drive Failure (nvme1n1)

1. Replace drive
2. Add to pool:

```bash
# Replace failed drive
zpool replace tank /dev/nvme1n1

# Monitor resilver
zpool status tank
```

## Maintenance

### Regular Checks

```bash
# Check pool status
zpool status tank

# Check dataset usage
zfs list -r tank

# Scrub pool monthly
zpool scrub tank
```

### Performance Tuning

```bash
# Adjust ARC size if needed
echo "options zfs zfs_arc_max=8589934592" > /etc/modprobe.d/zfs.conf  # 8GB max

# Monitor ARC stats
arc_summary
```

## Notes

- System partition is on first drive only
- ZFS uses remaining space from both drives
- VM network uses 192.168.0.0/24 range
- VMs access internet through NAT
- Regular scrubs recommended
- Keep system backups
- Monitor ZFS pool health
- Access web interface at: https://pve:8006
- Default login: root (with system password)

### Labeling VM Partitions

For better partition management in VMs, you can label partitions using:

```bash
# For ext4 partitions
sudo e2label /dev/sda1 nixos

# For swap partitions - need to disable swap first
sudo swapoff /dev/sda2
sudo swaplabel -L swap /dev/sda2
sudo swapon /dev/sda2

# Verify labels
sudo lsblk -o NAME,LABEL,FSTYPE,SIZE,MOUNTPOINT
```
