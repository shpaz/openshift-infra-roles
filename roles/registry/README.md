## Docker V2 Registry 

The `registry` role will create a Docker V2 registry using ansible local connection. This approach is very useful for mirroring images before a disconnected containerized installation.

### Prerequisites 
* A Bastion machine to work from (RHEL8.2+)
* Ansible Installed (2.9+)

Clone this repository to start using the automation: 
```git clone git clone https://github.com/shpaz/openshift-infra-roles.git```

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
BSD

Author Information
------------------
Shon Paz, Sr. Solution Architect, Red Hat 
Feel free to reach out - spaz@redhat.com 
