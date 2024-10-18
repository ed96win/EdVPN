#!/bin/bash
# to be used with client-connect option of openvpn

# Simple dad by checking all files in pool dir
dad_check () {
        local test_addr=$1
        for i in ls $_pool_ipv6_dir; do
                [ $i = $common_name ] && continue
                [ $(< $_pool_ipv6_dir/$i) = $test_addr ] && return 1
        done
        return 0
}

# Generate an IPv6 address based on the provided /112 prefix
gen_ipv6_addr () {
    local prefix=$1
    # Generate 4 hexadecimal digits (16 bits)
    local suffix=$(dd if=/dev/urandom bs=1 count=2 2> /dev/null | xxd -p)
    local addr=$prefix:$suffix
    dad_check $addr || addr=$(gen_ipv6_addr $prefix)
    echo $addr
}

_config_file="$1"

_timeout=3600

# Extract the /112 prefix (7 segments) from the provided IPv6 address
_prefix_ipv6=${ifconfig_ipv6_local%%::*}:0:0
_pool_ipv6_dir=/var/lib/openvpn/pool_$_prefix_ipv6

_pool_ipv6=$_pool_ipv6_dir/$common_name

# Create the pool directory if it doesn't exist
[ -d $_pool_ipv6_dir ] || mkdir $_pool_ipv6_dir

# Check if a valid IPv6 address is already allocated and still within the timeout
if [ -f $_pool_ipv6 ] && [ $(stat --printf %Y $_pool_ipv6) -ge $(date -d-${_timeout}sec +%s) ]; then
        _addr_ipv6=$(< $_pool_ipv6)
        dad_check $_addr_ipv6 || { _addr_ipv6=$(gen_ipv6_addr $_prefix_ipv6) && echo -n $_addr_ipv6 > $_pool_ipv6; }
else
        _addr_ipv6=$(gen_ipv6_addr $_prefix_ipv6)
        echo -n $_addr_ipv6 > $_pool_ipv6
fi

# Push the generated IPv6 address
echo "ifconfig-ipv6-push $_addr_ipv6" > $_config_file

