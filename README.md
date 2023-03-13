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

## Regular installer for muttable linux with selinux

```bash
wget https://raw.githubusercontent.com/dnkmmr69420/nix-with-selinux/main/regular-installer.sh && chmod a+x ./regular-installer.sh && ./regular-installer.sh ; rm ./regular-installer.sh
```

## Nix installer for silverblue

```bash
wget https://raw.githubusercontent.com/dnkmmr69420/nix-with-selinux/main/silverblue-installer.sh && chmod a+x ./silverblue-installer.sh && ./silverblue-installer.sh ; rm ./silverblue-installer.sh
```

# [Manual Install Guide](https://github.com/dnkmmr69420/nix-with-selinux/blob/main/manual-install-guide.md)

I gave it its own readme to make this guide less cluttered. Click on the link above to take you to that page.
