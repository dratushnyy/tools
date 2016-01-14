## Tools to up local virtual lab based on Vagrant, Ansible and Cobbler
Cobbler 

    Will provision nodes via management network.
Observer 
    
    Contains ELK stack with logs from nodes

## Installation
* Install VirtualBox
* Install vagrant 
* Install vagrant hosts plugin (vagrant plugin install vagrant-hostmanager)
* vagrant up
    
## Create Cobbler systems
        cd ~
        wget <path_to_image>
        sudmkdir -p /mnt/<image_folder_name>
        mount -t iso9660 -o loop,ro /<path_to_image> /mnt/<image_folder_name>
    
### Images
[CentOs 7 minimal iso] (http://isoredirect.centos.org/centos/7/isos/x86_64/CentOS-7-x86_64-Minimal-1511.iso)



### How to create box from VirtualBox image
vagrant package --base <name_of_vm_in_virtualbox> --output <box_name>.box