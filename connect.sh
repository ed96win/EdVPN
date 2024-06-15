#!/bin/bash

# Function to check for duplicate addresses
dad_check () {
    local test_addr=$1
    for i in $(ls $_pool_ipv6_dir); do
        [ "$i" = "$common_name" ] && continue
        [ "$(cat $_pool_ipv6_dir/$i)" = "$test_addr" ] && return 1
    done
    return 0
}

# Function to generate a new IPv6 address
gen_ipv6_addr () {
    local prefix=$1
    local addr
    while true; do
        addr=$prefix$(dd if=/dev/random bs=1 count=8 2> /dev/null | xxd -p | sed -re 's/(.{4})/:\1/g')
        dad_check $addr && break
    done
    echo $addr
}

# Main script execution
_config_file="$1"
_timeout=3600

# Extract prefix from ifconfig_ipv6_local
_prefix_ipv6=${ifconfig_ipv6_local%%::*}
_pool_ipv6_dir=/var/lib/openvpn/pool_$_prefix_ipv6
_pool_ipv6=$_pool_ipv6_dir/$common_name

# Ensure pool directory exists
[ -d $_pool_ipv6_dir ] || mkdir -p $_pool_ipv6_dir

# Check if there's an existing valid address
if [ -f $_pool_ipv6 ] && [ "$(stat --printf %Y $_pool_ipv6)" -ge "$(date -d-${_timeout}sec +%s)" ]; then
    _addr_ipv6=$(< $_pool_ipv6)
    dad_check $_addr_ipv6 || _addr_ipv6=$(gen_ipv6_addr $_prefix_ipv6)
else
    _addr_ipv6=$(gen_ipv6_addr $_prefix_ipv6)
fi

# Save the address and update the config file
echo -n $_addr_ipv6 > $_pool_ipv6
echo "ifconfig-ipv6-push $_addr_ipv6" > $_config_file

# Exit successfully
exit 0
