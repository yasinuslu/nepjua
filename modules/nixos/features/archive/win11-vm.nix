{ config, pkgs, ... }:
{
  # Define the Windows 11 VM
  virtualisation.libvirtd.qemu.verbatimConfig = ''
    nvram = [ "/var/lib/libvirt/qemu/nvram/win11_VARS.fd:/run/libvirt/nix-ovmf/OVMF_VARS.ms.fd" ]
  '';

  # Create the Windows 11 VM definition
  systemd.services.libvirtd-win11-vm = {
    description = "Create Windows 11 VM";
    requires = [
      "libvirtd.service"
      "libvirtd-storage-pools.service"
    ];
    after = [
      "libvirtd.service"
      "libvirtd-storage-pools.service"
    ];
    wantedBy = [ "multi-user.target" ];
    path = [ pkgs.libvirt ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
            set -eu

            # Only create if VM doesn't exist
            if ! virsh dominfo win11 >/dev/null 2>&1; then
              # Create VM XML
              cat > /tmp/win11.xml << 'EOF'
      <domain type='kvm'>
        <name>win11</name>
        <memory unit='KiB'>16384000</memory>
        <currentMemory unit='KiB'>16384000</currentMemory>
        <vcpu placement='static'>8</vcpu>
        <os firmware='efi'>
          <type arch='x86_64' machine='pc-q35-9.2'>hvm</type>
          <firmware>
            <feature enabled='no' name='enrolled-keys'/>
            <feature enabled='yes' name='secure-boot'/>
          </firmware>
          <loader readonly='yes' secure='yes' type='pflash'>/run/libvirt/nix-ovmf/OVMF_CODE.ms.fd</loader>
          <nvram template='/run/libvirt/nix-ovmf/OVMF_VARS.ms.fd'>/var/lib/libvirt/qemu/nvram/win11_VARS.fd</nvram>
          <boot dev='hd'/>
        </os>
        <features>
          <acpi/>
          <apic/>
          <hyperv mode='custom'>
            <relaxed state='on'/>
            <vapic state='on'/>
            <spinlocks state='on' retries='8191'/>
            <vpindex state='on'/>
            <runtime state='on'/>
            <synic state='on'/>
            <stimer state='on'/>
            <frequencies state='on'/>
            <tlbflush state='on'/>
            <ipi state='on'/>
            <avic state='on'/>
          </hyperv>
          <vmport state='off'/>
          <smm state='on'/>
        </features>
        <cpu mode='host-passthrough' check='none' migratable='on'/>
        <clock offset='localtime'>
          <timer name='rtc' tickpolicy='catchup'/>
          <timer name='pit' tickpolicy='delay'/>
          <timer name='hpet' present='no'/>
          <timer name='hypervclock' present='yes'/>
        </clock>
        <devices>
          <emulator>/run/libvirt/nix-emulators/qemu-system-x86_64</emulator>
          <disk type='file' device='disk'>
            <driver name='qemu' type='qcow2' discard='unmap'/>
            <source file='/var/lib/libvirt/images/win11.qcow2'/>
            <target dev='sda' bus='sata'/>
          </disk>
          <interface type='network'>
            <source network='default'/>
            <model type='e1000e'/>
          </interface>
          <graphics type='spice' autoport='yes'>
            <listen type='address' address='127.0.0.1'/>
            <image compression='off'/>
          </graphics>
          <video>
            <model type='qxl' ram='65536' vram='65536' vgamem='16384' heads='1' primary='yes'/>
          </video>
          <channel type='spicevmc'>
            <target type='virtio' name='com.redhat.spice.0'/>
          </channel>
          <controller type='usb' model='qemu-xhci'/>
          <controller type='sata' index='0'/>
          <input type='tablet' bus='usb'/>
          <input type='keyboard' bus='usb'/>
          <memballoon model='virtio'/>
        </devices>
      </domain>
      EOF

              # Create disk if it doesn't exist
              if [ ! -f /var/lib/libvirt/images/win11.qcow2 ]; then
                qemu-img create -f qcow2 /var/lib/libvirt/images/win11.qcow2 64G
              fi

              # Define the VM
              virsh define /tmp/win11.xml
            fi
    '';
  };
}
