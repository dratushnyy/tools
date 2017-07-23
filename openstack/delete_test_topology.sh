#!/usr/bin/env bash

function virsh_clean {
    virsh list | awk '{print $2}' | grep -v ^Name | xargs -n 1 virsh destroy
    virsh list --all | awk '{print $2}' | grep -v ^Name | xargs -n 1 virsh undefine
    virsh net-list | awk '{print $1}' | grep -vE "^Name|^default" | xargs -n1 virsh net-destroy
    virsh net-list --all | awk '{print $1}' | grep -vE "^Name|^default" | xargs -n1 virsh net-undefine
    virsh pool-list | awk '{print $1}' | grep -vE "^Name|^-----" | xargs -n1 virsh pool-destroy
    virsh pool-list --all | awk '{print $1}' | grep -vE "^Name|^-----" | xargs -n1 virsh pool-undefine
}

function clear_iptables {
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT

}
function dump_n9k_configs {
    ssh $1@$2 "show startup-config" > $2_startup_config.bak
    ssh $1@$2 "show running-config" > $2_run_config.bak

}

### Docker stuff
function delete_container_with_status {
    sudo docker ps -a | grep $1 | cut -d ' ' -f 1 | xargs sudo docker rm

}

### OpenStack stuff
function delete_neutron_port()
{
    for port in `neutron port-list -c id | egrep -v '\-\-|id' | awk '{print $2}'`
    do
        neutron port-delete ${port}
    done
}

function delete_neutron_router()
{
    for router in `neutron router-list -c id | egrep -v '\-\-|id' | awk '{print $2}'`
    do
        for subnet in `neutron router-port-list ${router} -c fixed_ips -f csv | egrep -o '[0-9a-z\-]{36}'`
        do
            neutron router-interface-delete ${router} ${subnet}
        done
        neutron router-gateway-clear ${router}
        neutron router-delete ${router}
    done
}

function delete_neutron_subnet()
{
    for subnet in `neutron subnet-list -c id | egrep -v '\-\-|id' | awk '{print $2}'`
    do
        neutron subnet-delete ${subnet}
    done
}

function delete_neutron_net()
{
    for net in `neutron net-list -c id | egrep -v '\-\-|id' | awk '{print $2}'`
    do
        neutron net-delete ${net}
    done
}


function delete_neutron_floatingip()
{
    for ip in `neutron floatingip-list -c id | egrep -v '\-\-|id' | awk '{print $2}'`
    do
        neutron floatingip-delete ${ip}
    done
}


function delete_nova_keys()
{
  for key in `nova keypair-list | egrep -v '\-\-|Name'  | awk '{print $2}'`
  do
     echo "Deleting ${key}"
     nova keypair-delete ${key}
  done
}


function delete_instances()
{
  for inst in `nova list --minimal | egrep -v '\-\-|ID'  | awk '{print $2}'`
  do
     echo "Deleting ${inst}"
     nova delete ${inst}
  done
}