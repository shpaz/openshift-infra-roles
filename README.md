# Openshift Infrastructure Ansible Roles 

This repository is used for deploying various Openshift infrastructure workloads using Ansible Automation.

## Docker V2 Registry 

### Initial Deployment 

The `registry` role will create a Docker V2 registry using ansible local connection. This approach is very useful for mirroring images before a disconnected containerized installation.

#### Run the automation 
The following automation works with a local ansible connection, taking into consideration all the needed steps for a docker registry to function as needed. After the playbook finishes and the validation phase has passed, you can start interacting with the registry as the playbook performs a login in your behalf.
To run the automation:

* Change the vars which are located in `group_vars/registry.yml` to your real registry FQDN. 
* Run the command ```bash ansible-playbook playbooks/registry.yml -i hosts --tags registry``` and wait for it to finish

Things that are being handled by this `Initial Deployment` automation:
* Installation of all prereqs needed for the registry to function 
* Creation of htpasswd secrets in order to login properly 
* Configuration Firewall ports for external access
* Deployment a containerized registry using `podman` 
* Generation of a `systemd` serevice that will control the container's lifecycle

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

This will create a three-node Consul cluster, and will serve the UI in port 80. To access your S3 service, use the following url - http://s3.service.dc1.domain1 for example.  

## S3bench 

The `S3bench` role will create an entire infrastructure for you to start benchmarking your S3 service in a multiclient manner. This role creates a pod that interacts with your S3 service, created a workload and documents all results in an ELK stack deployed by this role as well. In addition, There is an automation for throwing in some pre-defined dashboards that will help you analyze the results you get when performing the workload. 

This role divides into three parts: 

* The first part, deploys the ELK stack, and can be initiated by runinng `ansible-playbook playbooks/s3bench.yml -i hosts --tags start_infra`. This will deploy an ELK stack, that will be available by host networking and can be accessed via port 5601 (Kibana port). 
* The second part, deploys the s3bench service, which is being defined by a workload located in `group_vars/s3bench.yml`. Once you edit this vars file with your configuration (such as endpoint_url, access_key, secret_key, bucket_name, etc) you could pick the hosts you want to run these on by editing the inventory file. After running `ansible-playbook playbooks/s3bench.yml -i hosts --tags start_s3bench`, the playbook will add the needed containers to the pod and start testing your S3 service. 
* The third part, created the dashboards, running `ansible-playbook playbooks/s3bench.yml -i hosts --tags create_dashboards` will send an API request to Kibana wit hthe needed ndjson file. 

