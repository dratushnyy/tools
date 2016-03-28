* Build container with 
```sh  
$ docker build -t test_tools:latest  .
```

* Run container with: 
```sh    
$ docker run -d -P --name test_tools test_tools:latest
```

## Running tempest
* Create external network for mercury installation with subnet.
* Edit default-overrides.conf add values to [identity] section
     - admin_tenant_name
     - admin_password
     - admin_username
     - uri_v3
     - uri

* In container run to create config

```sh  
python tools/config_tempest.py --create
```

* Run tests with 

```sh  
 $  ostestr --regex  '(?!.*\[.*\bslow\b.*\])(^tempest\.(api|scenario))' 
```

## Images
* [ubuntu](http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-i386-disk1.img)
* [cirros](http://download.cirros-cloud.net/0.3.1/cirros-0.3.1-x86_64-disk.img)