#! /bin/bash 

podman login -u {{ rh_username }} -p {{ rh_password }} 

echo "opm index prune \
 -f registry.redhat.io/redhat/redhat-operator-index:v{{ ocp_minor_version.msg }} \
 -p {{ comma_seperated_operators.msg }} \
 -t {{ LOCAL_REGISTRY }}/redhat/redhat-operators-index:v{{ ocp_minor_version.msg }}" | sed "s/'//g" | xargs -I {} bash -c "{}"
