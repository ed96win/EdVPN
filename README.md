If you're a VPN provider and you use OpenVPN + TunnelBroker to provide IPv6 connectivity to your VPN clients, you'd have a problem with Google and some other CDNs.
OpenVPN by default assigns IPv6 sequentially, so the last bit of the address goes up one by one (e.g: 1001, 1002). Google (and Instagram) don't like that. and they'd assume some kind of attack is coming from your network, so they ratelimit it.
it resutls in google webpages throwing 403 errors, your tunnelbroker forwarding you abuse complaints from google and some other kinds of problems.

well, here's a solution for that.

let's assume you've got 2001:470:1f13:97::/64 from your tunnelbroker.

we modify openvpn server.conf file

we put

server-ipv6 2001:470:1f13:97::/64\
push "tun-ipv6"\
push "route-ipv6 2000::/3"

and save, we also insert the connect.sh and disconnect.sh from this repo in the openvpn directory and we add this to the config:

script-security 3\
client-connect /etc/openvpn/connect.sh\
client-disconnect /etc/openvpn/disconnect.sh

make these two files executable by "chmod +x"

and then restart the openvpn restart.

now, instead of your ip addresses being like 2001:470:c85a:1001, its gonna be like 2001:470:c85a:8ca:f8fd:f5cc:3eda (completely random but valid).
