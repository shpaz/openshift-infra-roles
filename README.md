# IPOL Ansible Roles 

This repository is used for deploying various IPOL workloads using Ansible Automation.

## Registry 

The `registry` role will create a Docker V2 registry using ansible local connection. This approach is very useful for mirroring images before a disconnected Containerized installation.

The following automation works with a local ansible connection, taking into consideration all the needed steps for a docker registry to function as needed. After the playbook finishes and the validation phase has passed, you can start interacting with the registry as the playbook performs a login in your behalf.
To run the automation:

* Change the vars which are located in `playbooks/registry.yml` to your real registry FQDN.
* Run the command `ansible-playbook playbooks/registry.yml -i hosts` and wait for it to finish
