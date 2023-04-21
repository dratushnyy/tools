#!/bin/sh

# Install/Setup MicroK8s
echo "Installing M8ks"
sudo snap install --classic microk8s
sudo usermod -aG microk8s $(whoami)
sudo microk8s status --wait-ready
sudo microk8s enable storage dns ingress
sudo snap alias microk8s.kubectl kubectl
