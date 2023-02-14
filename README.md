# NixOS on Fedora

Please note that these instructions are not offically supported or condoned by Nix and are not guaranteed to always work, but from my testing everything seems to work perfectly fine.

These steps may not be required if https://github.com/NixOS/nix/issues/2374 is resolved.

## SELinux

These commands are required for both Fedora Workstation and Fedora Silverblue
```bash
sudo semanage fcontext -a -t etc_t '/nix/store/[^/]+/etc(/.*)?'
sudo semanage fcontext -a -t lib_t '/nix/store/[^/]+/lib(/.*)?'
sudo semanage fcontext -a -t systemd_unit_file_t '/nix/store/[^/]+/lib/systemd/system(/.*)?'
sudo semanage fcontext -a -t man_t '/nix/store/[^/]+/man(/.*)?'
sudo semanage fcontext -a -t bin_t '/nix/store/[^/]+/s?bin(/.*)?'
sudo semanage fcontext -a -t usr_t '/nix/store/[^/]+/share(/.*)?'
sudo semanage fcontext -a -t var_run_t '/nix/var/nix/daemon-socket(/.*)?'
sudo semanage fcontext -a -t usr_t '/nix/var/nix/profiles(/per-user/[^/]+)?/[^/]+'
```

If you are on Fedora Workstation, skip past the [Fedora Silverblue](#fedora-silverblue) section down to [Install Nix](#install-nix)

## Fedora Silverblue

If you are running Fedora Silverblue, you will need to follow these extra steps.

### Create the nix directory in a persistent location
```bash
sudo mkdir /var/lib/nix
```

### SELinux

You will want to the SELinux contexts for the mounted directory paths as well, it seems to help avoid some weird issues periodically.

```bash
sudo semanage fcontext -a -t etc_t '/var/lib/nix/store/[^/]+/etc(/.*)?'
sudo semanage fcontext -a -t lib_t '/var/lib/nix/store/[^/]+/lib(/.*)?'
sudo semanage fcontext -a -t systemd_unit_file_t '/var/lib/nix/store/[^/]+/lib/systemd/system(/.*)?'
sudo semanage fcontext -a -t man_t '/var/lib/nix/store/[^/]+/man(/.*)?'
sudo semanage fcontext -a -t bin_t '/var/lib/nix/store/[^/]+/s?bin(/.*)?'
sudo semanage fcontext -a -t usr_t '/var/lib/nix/store/[^/]+/share(/.*)?'
sudo semanage fcontext -a -t var_run_t '/var/lib/nix/var/nix/daemon-socket(/.*)?'
sudo semanage fcontext -a -t usr_t '/var/lib/nix/var/nix/profiles(/per-user/[^/]+)?/[^/]+'
```

### `/etc/systemd/system/mkdir-rootfs@.service`
```unit file (systemd)
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
```

### `/etc/systemd/system/nix.mount`
```unit file (systemd)
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
```

Enable and mount the nix mount and reset the SELinux context. 
```bash
# Ensure systemd picks up the newly created units
sudo systemctl daemon-reload
# Enable the nix mount on boot.
sudo systemctl enable nix.mount
# Mount the nix mount now.
sudo systemctl start nix.mount
# R = recurse, F = full context (not just target)
sudo restorecon -RF /nix
```

## Install Nix

After you have configured SELinux (and if you are on Silverblue, configured a `/nix` mount), it's time to install [Nix](https://github.com/NixOS/nix).

Temorarly set selinux to "permissive"

```bash
sudo setenforce Permissive
```

Install nix

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```
Enable selinux

```bash
sudo setenforce Enforcing
```

If you are running Fedora Workstation, you are now ready to rock!  If you are running Fedora Silverblue, you will need to do some additional configuration.

### Fedora Silverblue

If you are running Fedora Silverblue, you will need to run these additional steps.  Most likely the installation errored out while setting up systemd.  SELinux on Silverblue prevents systemd from loading the units linked by Nix, while the best solution would be to add a policy or package Nix as an RPM, we will just manually copy the units ourselves.

*TODO: Find a way to link the units, that way whenever Nix is updated you don't need to manually edit or copy the units.*

```bash
# Remove the linked services
sudo rm -f /etc/systemd/system/nix-daemon.{service,socket}
# Manually copy the services
sudo cp /var/lib/nix/var/nix/profiles/default/lib/systemd/system/nix-daemon.{service,socket} /etc/systemd/system/
# Ensure systemd picks up the newly created units
sudo systemctl daemon-reload
# Start (and enable) the nix-daemon socket
sudo systemctl enable --now nix-daemon.socket
```

Optionally, you may manually modify the `nix-daemon` units to add a bind to `nix.mount` to ensure the units activate and deactivate properly if the mount fails or if the mount is unmounted while the daemon is running.  Place the following at the bottom of the `[Unit]` section in both the `nix-daemon.socket` and `nix-daemon.service` units.

```
After=nix.mount
BindsTo=nix.mount
```

You have just installed Nix and should be ready to rock!

NOTE: the `nix-daemon.socket` unit will automatically start `nix-daemon.service` whenever it is needed, there is no need to enable or manually start the service.
