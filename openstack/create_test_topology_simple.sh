#!/usr/bin/env bash

function create_ext_net() {
    # Add cidr, gw and allocation pool values
    if [ -z "$1" ]

    then
        echo "Please provide VLAN id for external network"
    else
        neutron net-create ext-net --router:external \
                           --provider:physical_network=physnet1 \
                           --provider:network_type=vlan --provider:segmentation_id=$1

        neutron subnet-create ext-net {cidr} --name ext-sub \
                           --gateway {gw} \
                           --allocation-pool start={start},end={end}
    fi
}

function create_internal_nets() {
    # dns should be updated to correct one. now it is google dns
    for net_idx in $(seq 1 $1);
    do
        neutron net-create int-net-${net_idx}
        neutron subnet-create int-net-${net_idx} ${net_idx}.1.1.0/24 \
                --name int-subnet-${net_idx} \
                --gateway ${net_idx}.1.1.1 \
                --dns-nameserver 8.8.8.8 \
                --allocation-pool start=${net_idx}.1.1.10,end=${net_idx}.1.1.200
        sleep 2
    done

}

function create_ext_router() {
    neutron router-create ext-router
    for subnet in $(neutron  subnet-list | awk  "/int-subnet-*/ {print $1}" | awk -F "|" '{print $3}');
    do
       neutron router-interface-add ext-router ${subnet}
    done
    neutron router-gateway-set ext-router ext-net
}

function create_test_key_pair() {
    nova keypair-add test-keypair > ~/.ssh/test_keypair.rsa
    chmod 644 ~/.ssh/test_keypair.rsa
}

function create_provider_networks() {
    net=50
    for vlan in $@;
    do
        neutron net-create prov-net-${net} \
                    --provider:physical_network=phys_prov \
                    --provider:network_type=vlan \
                    --provider:segmentation_id=${vlan}
        neutron subnet-create prov-net-$net $net.1.1.0/24 \
                  --name prov-sub-$net \
                  --gateway ${net}.1.1.1 \
                  --dns-nameserver 171.70.168.183 \
                  --allocation-pool start=${net}.1.1.10,end=${net}.1.1.200
    net=$((net+1))
    done
}

function create_base_network_topology() {
    create_ext_net #vlanid
    create_internal_nets #num_of_newtorks
    create_ext_router
    create_provider_networks # vlan ids seq
    neutron net-list

}

function create_floating_ips() {
    while true; do
        floating_ip=`neutron floatingip-create ext-net | grep floating_ip_address | awk -F"|" '{ print $3}' | tr -d '[[:space:]]'`
        if [ "$floating_ip" = "" ]; then
            break;
        else
            echo "Created floating ip " ${floating_ip};
        fi
    done

}

function create_sriov_ports() {
 i=1
 for net_re in "int-net-*" "prov-net-*";
 do
    echo ${net_re};
    for net in $(neutron net-list | awk "/$net_re/{print $1}" | awk -F "|" '{print $3}');
    do
        export sriov_pid_${i}=`neutron port-create --name sriov-port-${net} ${net} --binding:vnic-type direct -c id | grep id |  awk -F"|" '{ print $3}' | tr -d '[[:space:]]'`
        i=$((i+1))
    done
 done

}

create_base_network_topology
create_floating_ips
create_sriov_ports