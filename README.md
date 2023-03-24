# Nix package manager on Fedora with selinux enabled 

(also works for RHEL and its clones too)

Please note that these instructions are not offically supported or condoned by Nix and are not guaranteed to always work, but from my testing everything seems to work perfectly fine.

This is my modified version of the documentation [here](https://gist.github.com/matthewpi/08c3d652e7879e4c4c30bead7021ff73)

These steps may not be required if https://github.com/NixOS/nix/issues/2374 is resolved.

When this happens sucessfully for your, report it to [Issues](https://github.com/dnkmmr69420/nix-with-selinux/issues) as a [successfull test](https://github.com/dnkmmr69420/nix-with-selinux/issues/new?assignees=&labels=successful+test&template=successful-test.md&title=)

When this fails for you, report it as a [bug](https://github.com/dnkmmr69420/nix-with-selinux/issues/new?assignees=&labels=bug&template=bug_report.md&title=).

Want to improve this documentation, submit a [request](https://github.com/dnkmmr69420/nix-with-selinux/issues/new?assignees=&labels=&template=improvements-requests.md&title=)

# Install Scripts

Copy and paste the correct installer for your linux distro into the terminal to install

## Regular installer for mutable linux with selinux

```bash
wget https://raw.githubusercontent.com/dnkmmr69420/nix-with-selinux/main/regular-installer.sh && chmod a+x ./regular-installer.sh && ./regular-installer.sh ; rm ./regular-installer.sh
```

## Nix installer for silverblue

```bash
wget https://raw.githubusercontent.com/dnkmmr69420/nix-with-selinux/main/silverblue-installer.sh && chmod a+x ./silverblue-installer.sh && ./silverblue-installer.sh ; rm ./silverblue-installer.sh
```

## [Ublue nix installer](https://github.com/ublue-os/bluefin/blob/main/usr/bin/ublue-nix-install) Currently doesn't work

This installer is a modified version of mine and it is meant for ublue's bluefin but should run fine on regular silverblue and other ublue spins. 

DON'T USE THIS AT THE MOMENT SINCE IT CURRENTLY DOES NOT WORK. You are welcome to test it but do it in a vm.

```bash
wget https://raw.githubusercontent.com/ublue-os/bluefin/main/usr/bin/ublue-nix-install && chmod a+x ./ublue-nix-install && ./ublue-nix-install ; rm ./ublue-nix-install
```

thanks [castrojo](https://github.com/castrojo)

# [Manual Install Guide](https://github.com/dnkmmr69420/nix-with-selinux/blob/main/manual-install-guide.md)

I gave it its own readme to make this guide less cluttered. Click on the link above to take you to that page.

Want to uninstall nix? I made uninstallers for it [here](https://github.com/dnkmmr69420/nix-uninstallers).

# Other stuff

## Nix graphical icons

### nix graphical icons

It has its own [guide](https://github.com/dnkmmr69420/nix-graphical-app-icon-guide)

#### Single User

add this to the end of `~/.bashrc`

```bash
XDG_DATA_DIRS="$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share:$XDG_DATA_DIRS"
```

#### Multiuser

type this command

```bash
sudo tee /etc/profile.d/nix-app-icons.sh <<EOF
XDG_DATA_DIRS="$HOME/.nix-profile/share:/nix/var/nix/profiles/default/share:$XDG_DATA_DIRS"
EOF
```


