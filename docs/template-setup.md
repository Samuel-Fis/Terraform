# Step 1: Download a fresh cloud image (ubuntu 26.04 in this case)
cd /var/lib/vz/template/iso
wget -O resolute-server-cloudimg-amd64.img https://cloud-images.ubuntu.com/resolute/current/resolute-server-cloudimg-amd64.img

# Step 2: Create the VM shell
qm create 9000 \
  --name ubuntu-cloudinit-template \
  --memory 2048 \
  --cores 2 \
  --net0 virtio,bridge=vmbr0

# Step 3: Attach the disk and a cloud-init drive
qm importdisk 9000 resolute-server-cloudimg-amd64.img local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit
qm set 9000 --boot c --bootdisk scsi0
qm set 9000 --serial0 socket --vga serial0
qm set 9000 --agent enabled=1

# Step 4: Default user, DHCP, and vendor-data snippet
#qm set 9000 --ciuser <username> --cipassword '<password>' remove # if you want a local user with a password set.
qm set 9000 --ipconfig0 ip=dhcp

mkdir -p /var/lib/vz/snippets
cat > /var/lib/vz/snippets/install-agent.yaml << 'EOF'
#cloud-config
package_update: true
packages:
  - qemu-guest-agent
  - python3
  - locales
write_files:
  - path: /etc/sudoers.d/ansible
    permissions: '0440'
    content: |
      ansible ALL=(ALL) NOPASSWD:ALL
runcmd:
  - locale-gen en_GB.UTF-8 en_US.UTF-8
  - update-locale LANG=en_GB.UTF-8
  - systemctl enable --now qemu-guest-agent
EOF

qm set 9000 --cicustom "vendor=local:snippets/install-agent.yaml"

# Step 5: Convert to a template
qm template 9000

# Step 6: Verify (test clone, then clean up)
qm clone 9000 800 --name test-clone --full
qm start 800
sleep 90
qm agent 800 ping && echo "Guest agent OK"

qm stop 800 && qm destroy 800 --purge