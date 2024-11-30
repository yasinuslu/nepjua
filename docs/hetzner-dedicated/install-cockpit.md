# Installing Cockpit

## Update System

Update your system and install the required packages.

```bash
sudo apt update -y
sudo apt upgrade -y
```

## Install Required Packages

Then install cockpit.

```bash
. /etc/os-release
sudo apt install -t ${VERSION_CODENAME}-backports cockpit
```

## Additional Configuration

### Fix Network Manager

You will probably get caught by the network problem. Here is how to fix it:

```bash
cat <<EOF | sudo tee /etc/NetworkManager/conf.d/10-globally-managed-devices.conf
[keyfile]
unmanaged-devices=none
EOF
```

Then create a "dummy" network:

```bash
nmcli con add type dummy con-name fake ifname fake0 ip4 1.2.3.4/24 gw4 1.2.3.1
```

Then restart cockpit:

```bash
sudo systemctl restart cockpit
```

### Install Virtual Machine Support

If you want to manage virtual machines, you need to install the following package:

```bash
sudo apt install -y cockpit-machines libvirt-daemon-system qemu-kvm
sudo systemctl restart cockpit
```
