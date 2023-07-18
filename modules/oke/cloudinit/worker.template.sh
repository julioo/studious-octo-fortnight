#!/bin/bash

# DO NOT MODIFY
curl --fail -H "Authorization: Bearer Oracle" -L0 http://169.254.169.254/opc/v2/instance/metadata/oke_init_script | base64 --decode >/var/run/oke-init.sh

## run oke provisioning script
bash -x /var/run/oke-init.sh

### adjust block volume size
/usr/libexec/oci-growfs -y

timedatectl set-timezone ${worker_timezone}

# Prepare Oracle Linux 8 with Istio
cat  <<EOF | sudo tee /etc/modules-load.d/99-istio-modules.conf
# These modules need to be loaded on boot so that Istio (as required by
# Kubeflow) runs properly.
#
# See also: https://github.com/istio/istio/issues/23009

br_netfilter
nf_nat
xt_REDIRECT
xt_owner
iptable_nat
iptable_mangle
iptable_filter
EOF

modprobe br_netfilter ; modprobe nf_nat ; modprobe xt_REDIRECT ; modprobe xt_owner; modprobe iptable_nat; modprobe iptable_mangle; modprobe iptable_filter

touch /var/log/oke.done