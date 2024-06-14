#!/bin/bash
# To be used with client-disconnect option of openvpn

# Variables
_pool_ipv6_dir=/var/lib/openvpn/pool_${ifconfig_ipv6_local%%::*}
_pool_ipv6=$_pool_ipv6_dir/$common_name

# Check if the pool directory and the client file exist
if [ -d $_pool_ipv6_dir ] && [ -f $_pool_ipv6 ]; then
    # Remove the file corresponding to the disconnected client
    rm -f $_pool_ipv6
fi

# Exit script
exit 0
