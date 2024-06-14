#!/bin/bash
# to be used with client-connect option of openvpn
#Debug mode

#exec 2> script_debug
#set -x

# Simple dad by checking all files in pool dir
dad_check () {
        local test_addr=$1
        for i in ls $_pool_ipv6_dir; do
                [ $i = $common_name ] && continue
                [ $(< $_pool_ipv6_dir/$i) = $test_addr ] && return 1
        done
        return 0
}

gen_ipv6_addr () {
        local prefix=$1
        local addr=$prefix$(dd if=/dev/random bs=1 count=8 2> /dev/null | xxd -p|sed -re 's/(.{4})/:\1/g')
        dad_check $addr || addr=$(gen_ipv6_addr $prefix)
        echo $addr
}

_config_file="$1"

_timeout=3600

#_prefix_ipv6="2001:bc8:2869:161"
_prefix_ipv6=${ifconfig_ipv6_local%%::*}
_pool_ipv6_dir=/var/lib/openvpn/pool_$_prefix_ipv6

_pool_ipv6=$_pool_ipv6_dir/$common_name

[ -d $_pool_ipv6_dir ] || mkdir $_pool_ipv6_dir

if [ -f $_pool_ipv6 ] && [ $(stat --printf %Y $_pool_ipv6) -ge $(date -d-${_timeout}sec +%s) ]; then
        _addr_ipv6=$(< $_pool_ipv6)
        dad_check $_addr_ipv6 || { _addr_ipv6=$(gen_ipv6_addr $_prefix_ipv6) && echo -n $_addr_ipv6 > $_pool_ipv6; }
else
        _addr_ipv6=$(gen_ipv6_addr $_prefix_ipv6)
        echo -n $_addr_ipv6 > $_pool_ipv6
fi

echo "ifconfig-ipv6-push $_addr_ipv6" > $_config_file

#exit 0
