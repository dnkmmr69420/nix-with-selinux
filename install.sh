#!/bin/bash

# sets context for /nix
sudo semanage fcontext -a -t etc_t '/nix/store/[^/]+/etc(/.*)?'
sudo semanage fcontext -a -t lib_t '/nix/store/[^/]+/lib(/.*)?'
sudo semanage fcontext -a -t systemd_unit_file_t '/nix/store/[^/]+/lib/systemd/system(/.*)?'
sudo semanage fcontext -a -t man_t '/nix/store/[^/]+/man(/.*)?'
sudo semanage fcontext -a -t bin_t '/nix/store/[^/]+/s?bin(/.*)?'
sudo semanage fcontext -a -t usr_t '/nix/store/[^/]+/share(/.*)?'
sudo semanage fcontext -a -t var_run_t '/nix/var/nix/daemon-socket(/.*)?'
sudo semanage fcontext -a -t usr_t '/nix/var/nix/profiles(/per-user/[^/]+)?/[^/]+'

# makes nix directory at /var/lib/nix
sudo mkdir /var/lib/nix

# sets context for /var/lib/nix
sudo semanage fcontext -a -t etc_t '/var/lib/nix/store/[^/]+/etc(/.*)?'
sudo semanage fcontext -a -t lib_t '/var/lib/nix/store/[^/]+/lib(/.*)?'
sudo semanage fcontext -a -t systemd_unit_file_t '/var/lib/nix/store/[^/]+/lib/systemd/system(/.*)?'
sudo semanage fcontext -a -t man_t '/var/lib/nix/store/[^/]+/man(/.*)?'
sudo semanage fcontext -a -t bin_t '/var/lib/nix/store/[^/]+/s?bin(/.*)?'
sudo semanage fcontext -a -t usr_t '/var/lib/nix/store/[^/]+/share(/.*)?'
sudo semanage fcontext -a -t var_run_t '/var/lib/nix/var/nix/daemon-socket(/.*)?'
sudo semanage fcontext -a -t usr_t '/var/lib/nix/var/nix/profiles(/per-user/[^/]+)?/[^/]+'

# creates /etc/systemd/system/mkdir-rootfs@.service
sudo tee /etc/systemd/system/mkdir-rootfs@ <<EOF
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

#creates /etc/systemd/system/nix.mount
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

# Starting nix daemons
# Ensure systemd picks up the newly created units
sudo systemctl daemon-reload
# Enable the nix mount on boot.
sudo systemctl enable nix.mount
# Mount the nix mount now.
sudo systemctl start nix.mount
# R = recurse, F = full context (not just target)
sudo restorecon -RF /nix

# Temporarly sets selinux to permissive
sudo setenforce Permissive

# Install nix
sh <(curl -L https://nixos.org/nix/install) --daemon

# Remove the linked services
sudo rm -f /etc/systemd/system/nix-daemon.{service,socket}
# Manually copy the services
sudo cp /var/lib/nix/var/nix/profiles/default/lib/systemd/system/nix-daemon.{service,socket} /etc/systemd/system/
# R = recurse, F = full context (not just target)
sudo restorecon -RF /nix
# Ensure systemd picks up the newly created units
sudo systemctl daemon-reload
# Start (and enable) the nix-daemon socket
sudo systemctl enable --now nix-daemon.socket

# Sets selinux back to enforcing
sudo setenforce Enforcing

echo "reboot your system by typing "systemctl reboot""
