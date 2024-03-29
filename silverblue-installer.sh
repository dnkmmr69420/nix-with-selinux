#!/bin/bash
sudo sleep 2
echo "Adding selinux content to /nix"
sudo semanage fcontext -a -t etc_t '/nix/store/[^/]+/etc(/.*)?' ; sudo semanage fcontext -a -t lib_t '/nix/store/[^/]+/lib(/.*)?' ; sudo semanage fcontext -a -t systemd_unit_file_t '/nix/store/[^/]+/lib/systemd/system(/.*)?' ; sudo semanage fcontext -a -t man_t '/nix/store/[^/]+/man(/.*)?' ; sudo semanage fcontext -a -t bin_t '/nix/store/[^/]+/s?bin(/.*)?' ; sudo semanage fcontext -a -t usr_t '/nix/store/[^/]+/share(/.*)?' ; sudo semanage fcontext -a -t var_run_t '/nix/var/nix/daemon-socket(/.*)?' ; sudo semanage fcontext -a -t usr_t '/nix/var/nix/profiles(/per-user/[^/]+)?/[^/]+'
sleep 1
sudo mkdir /var/lib/nix
sleep 1
echo "adding selinux content to /var/lib/nix"
sudo semanage fcontext -a -t etc_t '/var/lib/nix/store/[^/]+/etc(/.*)?' ; sudo semanage fcontext -a -t lib_t '/var/lib/nix/store/[^/]+/lib(/.*)?' ; sudo semanage fcontext -a -t systemd_unit_file_t '/var/lib/nix/store/[^/]+/lib/systemd/system(/.*)?' ; sudo semanage fcontext -a -t man_t '/var/lib/nix/store/[^/]+/man(/.*)?' ; sudo semanage fcontext -a -t bin_t '/var/lib/nix/store/[^/]+/s?bin(/.*)?' ; sudo semanage fcontext -a -t usr_t '/var/lib/nix/store/[^/]+/share(/.*)?' ; sudo semanage fcontext -a -t var_run_t '/var/lib/nix/var/nix/daemon-socket(/.*)?' ; sudo semanage fcontext -a -t usr_t '/var/lib/nix/var/nix/profiles(/per-user/[^/]+)?/[^/]+'
echo "Creating service files"
sleep 1
echo "creating SSL cert file"

sudo tee /etc/systemd/system/nix-daemon.service.d/override.conf <<EOF
[Service]
Environment="NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
EOF
sleep 1
echo "Creating rootfs mkdir service"

sudo tee /etc/systemd/system/mkdir-rootfs@.service <<EOF
[Unit]
Description=Enable mount points in / for ostree
ConditionPathExists=!%f
DefaultDependencies=no
Requires=local-fs-pre.target
After=local-fs-pre.target

[Service]
Type=oneshot
ExecStartPre=chattr -i /
ExecStart=mkdir -p '%f'
ExecStopPost=chattr +i /
EOF

sleep 1
echo "Creating nix.mount"

sudo tee /etc/systemd/system/nix.mount <<EOF
[Unit]
Description=Nix Package Manager
DefaultDependencies=no
After=mkdir-rootfs@nix.service
Wants=mkdir-rootfs@nix.service
Before=sockets.target
After=ostree-remount.service
BindsTo=var.mount

[Mount]
What=/var/lib/nix
Where=/nix
Options=bind
Type=none
EOF

sleep 1
echo "Enabling mounting of /var/lib/nix to /nix and resetting SELinux context"
sleep 1

sudo systemctl daemon-reload ; sudo systemctl enable nix.mount ; sudo systemctl start nix.mount ; sudo restorecon -RF /nix

sleep 1

echo "Temorarly setting SELinux to permissive"

sudo setenforce Permissive

sleep 1

echo "Prepareing the nix install script"

sleep 5

sh <(curl -L https://nixos.org/nix/install) --daemon

echo "Nix installer has finnished running"
sleep 1
echo "Now copying service files"

sleep 1

sudo rm -f /etc/systemd/system/nix-daemon.{service,socket} ; sudo cp /nix/var/nix/profiles/default/lib/systemd/system/nix-daemon.{service,socket} /etc/systemd/system/ ; sudo restorecon -RF /nix ; sudo systemctl daemon-reload ; sudo systemctl enable --now nix-daemon.socket

sleep 1

echo "Now setting SELinux back to Enforcing"

sudo setenforce Enforcing

sleep 1

echo "Making a nix backup"

bash <(curl -s https://raw.githubusercontent.com/dnkmmr69420/nix-with-selinux/main/create-backup.sh)

sleep 1

echo "Reboot your system by typing"
echo "systemctl reboot"
