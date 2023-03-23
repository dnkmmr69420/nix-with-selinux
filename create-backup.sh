#!/bin/bash

# nb stands for nix backup

echo "Installing nix backup"

sudo mkdir /opt/nb
sudo cp -R /nix /opt/nb

sudo tee /opt/nb/reset-nix <<EOF
#!/bin/bash
sudo echo "Restoring nix..."
sudo rm -rf /nix/*
sudo mkdir -p /nix
sudo cp -R /opt/nb/nix/* /nix/
sudo restorecon -RF /nix
sudo echo "Nix has been restored. Reboot for changes to apply."
EOF

sudo chmod a+x /opt/nb/reset-nix

sudo echo "Finnished installing nix backup"
