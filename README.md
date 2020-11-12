# IPOL Ansible Roles 

This repository is used for deploying various IPOL workloads using Ansible Automation.

## Registry 

The `registry` role will create a Docker V2 registry using ansible local connection. This approach is very useful for mirroring images before a disconnected Containerized installation.

The following automation works with a local ansible connection, taking into consideration all the needed steps for a docker registry to function as needed. After the playbook finishes and the validation phase has passed, you can start interacting with the registry as the playbook performs a login in your behalf.
To run the automation:

* Change the vars which are located in `group_vars/registry.yml` to your real registry FQDN. 
* Run the command ```bash ansible-playbook playbooks/registry.yml -i hosts --extra-vars "rh_username=spaz rh_password=" --tags registry``` and wait for it to finish

You could also mirror specific image list which is documented in `group_vars/registry.yml`, those images will be mirrored to your local registry so you could export it later on. 
To run the automation: 

* Change the `mirror_disconnected_images` to `true`, then edit the `disconnected_images` list
* Run with the command ```bash ansible-playbook playbooks/registry.yml -i hosts --extra-vars "rh_username= rh_password= --tags mirror"```

In addition, you could export/import an existing registry data directory. For example, if your'e about to have ao disconnected installation, you just export the registry's data dir into a tar.gz file, then load it when going on-site. 

To do so, you shold: 

* Change the `registry_data_action` to export/import, while changing the `tar_location` as well to tell Ansible where to pull/push the tar file. 
* Run the command ```bash ansible-playbook playbooks/registry.yml -i hosts --extra-vars "rh_username=spaz rh_password=" --tags export```
* Run the command ```bash ansible-playbook playbooks/registry.yml -i hosts --extra-vars "rh_username=spaz rh_password=" --tags import```

The import playbook takes an existing tar containing the registry's data and loads it to the existing registry. 
The export playbook doext exactly the opposite, while taking an exising registry and copy it's data dir into a compressable file. 

## Consul 

The `Consul` role will create a Consul cluster which will react as Load-balancer, service discovery, DNS resolver, etc. This Consul cluster will point to the RGW instances to load the traffic intelligently. 

This rule pulls a Consul container image from a given location, extracts the Consul binary and created the wanted cluster.
Important! don't forge to set the `consul_interface` so that Ansible will know which port it should bind the traffic to. 

To run the automation: 

* You should change the dictionary located in `group_vars/consul-servers.yml` to your RGW instances, Ansible will load them as consul config
* Run the command ```bash ansible-playbook playbooks/consul.yml -i hosts --extra-vars "registry_username= registry_password="``` 

This will create a three-node Consul cluster, and will serve the UI in port 80. 

  
