#!/bin/bash


# Install Charmcraft
echo "Installing charmcraft"
sudo snap install lxd --classic
sudo lxd init --auto
sudo snap install charmcraft --classic

# Install Juju
echo "Installing juju"
sudo snap install juju --classic

# Bootstrap MicroK8s
echo "Boostrap juju + m8ks"
juju bootstrap microk8s micro
juju add-model development

