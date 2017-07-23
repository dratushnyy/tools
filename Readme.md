## A set of  different tools
* VM and container provision
* DB deployment (Cassandra, Mongodb)
* Useful scripts for OpenStack
* Scripts for Cisco IMC
* Language deployment (R, Go)
* Misc

### Tools to up local virtual lab based on Vagrant, Ansible and Cobbler
Cobbler 

    Will provision nodes via management network.
Observer 
    
    Contains ELK stack with logs from nodes

### Installation
* Install VirtualBox
    Install VirtualBox Extension Pack
    
* Install vagrant 
* Install vagrant hosts plugin (vagrant plugin install vagrant-hostmanager)
* vagrant up
    
### Create Cobbler systems (CLI)
        vagrant ssh cobbler
        wget <path_to_image>
        sudo mkdir -p /mnt/<image_folder_name>
        mount -t iso9660 -o loop,ro /<path_to_image> /mnt/<image_folder_name>
        cobber import --name=<system_name_for_cobbler> --arch=<x86_64|x86_32> --path=/mnt/<image_folder_name>
    
#### Images
[CentOs 7 minimal iso] (http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1511.iso)



#### How to create box from VirtualBox image
vagrant package --base <name_of_vm_in_virtualbox> --output <box_name>.box
