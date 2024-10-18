#!/bin/bash
# to be used with client-disconnect option of openvpn

# Clean up allocated IPv6 address for the client on disconnect
cleanup_ipv6_addr () {
    local common_name=$1
    local pool_ipv6_dir=$2
    local pool_ipv6_file=$pool_ipv6_dir/$common_name

    # Check if the allocated address file exists
    if [ -f $pool_ipv6_file ]; then
        # Remove the file containing the allocated address
        rm -f $pool_ipv6_file
        echo "Released IPv6 address for $common_name"
    else
        echo "No IPv6 address found for $common_name"
    fi
}

_config_file="$1"

# Extract the prefix from the configuration file (if needed)
# Here, we are assuming the prefix is provided, but it can also be hardcoded if necessary
prefix_ipv6=$(grep -E 'server-ipv6' "$_config_file" | awk '{print $2}' | cut -d':' -f1-7)

_pool_ipv6_dir="/var/lib/openvpn/pool_${prefix_ipv6}"

# Call cleanup function with the common name and pool directory
cleanup_ipv6_addr "$common_name" "$pool_ipv6_dir"
