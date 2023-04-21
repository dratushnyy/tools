#!/bin/bash

# Install Charmcraft
echo "Installing charmcraft"
sudo snap install lxd --classic
sudo lxd init --auto
sudo snap install charmcraft --classic

# URLs for the Juju binary and its MD5 checksum
juju_major_version="3.1"
juju_minor_version="0"
juju_version="${juju_major_version}.${juju_minor_version}"

juju_file="juju-${juju_version}-linux-amd64.tar.xz"
juju_url="https://launchpad.net/juju/${juju_major_version}/${juju_version}/+download/${juju_file}"
juju_md5_url="https://launchpad.net/juju/${juju_major_version}/${juju_version}/+download/${juju_file}/+md5"


# Create the ~/downloads folder if it doesn't exist
downloads_folder="$HOME/downloads"
mkdir -p "$downloads_folder"
cd "$HOME/downloads"

# Download the Juju binary
echo "Downloading Juju..."
curl -LO "$juju_url"

# Download the Juju MD5 checksum
echo "Downloading Juju MD5 checksum..."
curl -L "$juju_md5_url" -o juju.md5

# Validate the checksum
echo "Validating checksum..."
if md5sum --check juju.md5; then
    # Checksum validation passed, unpack the archive
    echo "Checksum validation passed. Unpacking the archive..."
    tar -xf ${juju_file}
    echo "Installing Juju..."
    sudo install -o root -g root -m 0755 juju /usr/local/bin/juju
    echo "Checking Juju version..."
    juju version
else
    # Checksum validation failed
    echo "Checksum validation failed. Exiting..."
    exit 1
fi
