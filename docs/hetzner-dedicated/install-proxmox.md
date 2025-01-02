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

BOOTLOADER grub

HOSTNAME pve

# System on first drive
PART /boot/efi   esp    512M
PART /boot       ext4     2G
PART swap       swap     4G
PART /          ext4    80G
PART /reserved  -       all

# Keep SSH keys from rescue system
SSHKEYS_FROM_RESCUE yes

# Root password
CRYPTPASSWORD your-root-password-here

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

auto ${PRIMARY_NIC}
iface ${PRIMARY_NIC} inet static
        address ${CURRENT_IP}/${CURRENT_MASK}
        gateway ${CURRENT_GW}

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
```

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

# Update grub
update-grub
```

Reboot the system:

```bash
reboot
```

## 4. ZFS Setup

### Create ZFS Pool

```bash
# Install ZFS tools
apt update
apt install -y linux-headers-amd64 zfs-dkms zfsutils-linux

# Load ZFS module
modprobe zfs

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

## 5. Configure Tailscale

### Install tailscale

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

### Advanced Tailscale Configuration

```bash
# Set your authentication key
TAILSCALE_AUTH_KEY="your-auth-key"

# Enable IP forwarding
cat <<EOF > /etc/sysctl.d/99-tailscale.conf
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF
sysctl -p /etc/sysctl.d/99-tailscale.conf

# Start Tailscale with subnet routing
tailscale up --auth-key=${TAILSCALE_AUTH_KEY} --advertise-routes=192.168.0.0/24

# Verify routes
tailscale status
```

## 6. Configure Proxmox Storage

1. Access Web UI at https://your-ip:8006
2. Go to Datacenter → Storage
3. Add ZFS storage:
   - ID: local-zfs
   - Pool: tank
   - Content:
     - Images (for VMs)
     - Containers
     - Backups

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
