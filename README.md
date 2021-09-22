# Openshift Infrastructure Ansible Roles 

This repository is used for deploying various Openshift infrastructure workloads using Ansible Automation.

## Docker V2 Registry 

The `registry` role will create a Docker V2 registry using ansible local connection. This approach is very useful for mirroring images before a disconnected containerized installation.

#### Initial Deployment 

The following automation works with a local ansible connection, taking into consideration all the needed steps for a docker registry to function as needed. After the playbook finishes and the validation phase has passed, you can start interacting with the registry as the playbook performs a login in your behalf.
To run the automation:

* Change the vars which are located in `group_vars/registry.yml` to your real registry FQDN. 
* Run the command ```bash ansible-playbook playbooks/registry.yml -i hosts --tags registry``` and wait for it to finish

Things that are being handled by this `Initial Deployment` automation:
* Installation of all prereqs needed for the registry to function 
* Creation of htpasswd secrets in order to login properly 
* Configuration of Firewall ports for external access
* Deployment of a containerized registry using `podman` 
* Generation of a `systemd` serevice that will control the container's lifecycle

#### Mirroring Installation Materials 

The following automation can help you with mirroring the installation images of Openshift. In order to do so: 
* Change the vars that are located in `group_vars/registry.yml` to your needed Openshift version (var `ocp_mirror_version`) and your pull secret file location (var `pull_secret_location`) 
* Run the command ```bash ansible-playbook playbooks/registry.yml -i hosts --tags mirror``` and wait for it to finish

Things that are being handled by this `Mirroring Installation Materials` automation:
* Verification of your registry's readiness 
* Mirror of the needed images according to your provided Openshift version
* Mirrors are beign authenticated using your provided pull secret file 

#### Building & Mirroring a Custom Catalog

The following automation can help you building and mirroring a custom catalog, according to a given set of operators. In order to do so: 
* Choose and unhash the list of operators provided in `group_vars/registry.yml` to five the automation a script of operator to prune 
* Run the command ```bash ansible-playbook playbooks/registry.yml -i hosts --tags catalog``` and wait for it to finish

Things that are being handled by this `Building & Mirroring a Custom Catalog` automation:
* Validation of all prereqs needed for building such a catalog 
* Running the Red Hat global index to fetch packages names 
* Prunning the index image and building a new one according to the given set of operators 
* Mirroring all related images of the given operators into the offline registry 

*Attention! If you want to track the images that are being mirrored, the automation exports a file to /tmp/mirrored_images.txt that you can tail to*

#### Exporting & Importing Thw Whole Package

This automation can help you exporting the registry's data directory into a tarball file, so as importing it in the air-gapped environment. In order to do so: 
* Choose whether you'd like to export/import the data dir, by setting the `registry_data_action` var in the `group_vars/registry.yml` file
* Provide the location of the files that should be imported/exported by changing `tar_location` var in the `group_vars/registry.yml` file
* Run the command ```bash ansible-playbook playbooks/registry.yml -i hosts --tags export``` and wait for it to finish
* Run the command ```bash ansible-playbook playbooks/registry.yml -i hosts --tags import``` and wait for it to finish

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

