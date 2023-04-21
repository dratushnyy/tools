#!/bin/bash

sudo snap remove juju --purge
microk8s disable storage dns ingress 

sudo snap remove microk8s --purge
