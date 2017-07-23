#!/usr/bin/env bash
# Use -gt 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use -gt 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to -gt 0 the /etc/hosts part is not recognized ( may be a bug )

while [[ $# -gt 1 ]]
do
key="$1"

case ${key} in
    --flavor)
    FLAVOR="$2"
    shift # past argument
    ;;
    --flavorparams)
    FLAVOR_PARAMS="$2"
    shift # past argument
    ;;
    --domains)
    DOMAINS="$2"
    shift
    ;;
    *)
    # unknown option
    ;;
esac
shift # past argument or value
done
FLAVOR="m1.medium"

PRIVATE_KEY="/root/openstack-configs/test_key_rsa"
PUBLIC_KEY="/root/openstack-configs/test_key_rsa.pub"


function set_quota() {
    local tenant_id=$(openstack project show $1 | awk '/ id / {print $4}' | cut -d "|" -f3 | cut -d " " -f2)
    openstack quota set ${tenant_id} --instances=-1 --cores=-1 --key-pairs=-1 --volumes=-1 --ram=-1 --fixed-ips=-1 --snapshots=-1
    neutron quota-update --tenant_id ${tenant_id} --port -1 --network -1 --subnet -1 --router -1 --floatingip -1 --security_group -1 --security_group_rule -1
}

function create_key_pair() {
    chmod 600 ${PRIVATE_KEY} && eval $(ssh-agent) && echo -e "y\n" | ssh-add ${PRIVATE_KEY}
    nova keypair-add --pub-key ${PUBLIC_KEY} mercury
    nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
    nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
}

function create_image() {
    curl -O http://172.29.173.233/fedora/fedora-dnsmasq-localadmin-ubuntu.qcow2

    glance image-create --architecture x86_64 --visibility public \
    --disk-format qcow2 --container-format bare \
    --name fedora --progress --file fedora-dnsmasq-localadmin-ubuntu.qcow2

}

function set_flavor_key() {
 if [[ ! -z ${FLAVOR_PARAMS} ]]; then
    nova flavor-key ${FLAVOR} set ${FLAVOR_PARAMS}
 fi
}

function create_networks_and_subnets() {
    for id in $(seq 1 $1); do
        neutron net-create net-${id}-$2
        neutron subnet-create net-${id}-$2 $2$2.${id}${id}.${id}${id}.0/24 --name subnet-${id}-$2
    done
}

function create_domain(){
    h_idx=1
    port_config=""

    for hypervisor in $(nova hypervisor-list | awk '/enabled/ {print $4}'); do
      for vm_idx in $(seq 1 $1); do
        for net_idx in $(seq 1 $2); do
            local net_id=$(neutron net-show net-${net_idx}-$3 | awk '/ id/ {print $4}')
            local subnet_id=$(neutron subnet-show subnet-${net_idx}-$3 | awk '/ id/ {print $4}')
            local mac_address="00:10:$3$3:${net_idx}${net_idx}:${net_idx}${net_idx}:$(($h_idx * 10 + $vm_idx - 1 ))"
            local ip_address="$3$3.${net_idx}${net_idx}.${net_idx}${net_idx}.$((h_idx * 10 + $vm_idx))"
            local port_name="port-$h_idx$vm_idx-net-${net_idx}-$3"
            local port_id=$(neutron port-create ${net_id} --fixed_ip subnet_id=${subnet_id},ip_address=${ip_address} \
                            --mac-address ${mac_address} --name ${port_name}  | awk '/ id/ {print $4}' )
            port_config="$port_config --nic port-id=$port_id"
        done
        nova boot vm${vm_idx}-on-${hypervisor}-d-$3 --flavor ${FLAVOR} --image fedora --availability-zone nova:${hypervisor} --key-name mercury ${port_config}
        port_config=""
      done
      ((h_idx+=1))
    done
}

source /root/openstack-configs/openrc
set_quota admin
create_key_pair
create_image
set_flavor_key

domain_idx=1
for domain_config in ${DOMAINS}; do
    vm2net=($(echo ${domain_config} | awk -F 'vm|net' '{print $1 " " $2}'))
    create_networks_and_subnets  ${vm2net[1]} ${domain_idx}
    create_domain ${vm2net[0]} ${vm2net[1]} ${domain_idx}
((domain_idx+=1))
done