#!/bin/bash

#iptables -A OUTPUT -m ndpi --bittorrent -j DROP

iptables -A OUTPUT -p tcp -s 0/0 -d 0.0.0.0/8 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 10.0.0.0/8 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 100.64.0.0/10 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 169.254.0.0/16 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 172.16.0.0/12 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 192.0.0.0/24 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 192.0.2.0/24 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 192.88.99.0/24 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 192.168.0.0/16 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 198.18.0.0/15 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 198.51.100.0/24 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 203.0.113.0/24 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 224.0.0.0/4 -j DROP
iptables -A OUTPUT -p tcp -s 0/0 -d 240.0.0.0/4 -j DROP

iptables -A OUTPUT -p udp -s 0/0 -d 0.0.0.0/8 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 10.0.0.0/8 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 100.64.0.0/10 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 169.254.0.0/16 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 172.16.0.0/12 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 192.0.0.0/24 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 192.0.2.0/24 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 192.88.99.0/24 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 192.168.0.0/16 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 198.18.0.0/15 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 198.51.100.0/24 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 203.0.113.0/24 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 224.0.0.0/4 -j DROP
iptables -A OUTPUT -p udp -s 0/0 -d 240.0.0.0/4 -j DROP

iptables -P FORWARD ACCEPT
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

ip6tables -P FORWARD ACCEPT
ip6tables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ip6tables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ip6tables -A INPUT -s 2001:470:18fa::/48 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
ip6tables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT
ip6tables -t nat -A POSTROUTING -s 2001:470:18fa::/48 -o eth0 -j MASQUERADE

iptables -A INPUT -s 10.9.0.0/24 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
iptables -A INPUT -s 10.8.0.0/24 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

ip6tables -A FORWARD -m state --state NEW -i tun+ -o eth0 -s 2001:470:18fa::/48 -j ACCEPT
ip6tables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

iptables -A FORWARD -i eth0 -o wg0 -j ACCEPT
iptables -A FORWARD -i wg0 -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
ip6tables -A FORWARD -i wg0 -j ACCEPT
ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A INPUT -p udp --sport 53 -j ACCEPT
ip6tables -A INPUT -p udp --sport 53 -j ACCEPT

iptables -I INPUT -i tun0 -j ACCEPT
iptables -I INPUT -i wg0 -j ACCEPT

ip6tables -A FORWARD -i tun0 -o eth0 -s 2001:470:18fa::/48 -m state --state NEW -j ACCEPT

iptables -A INPUT -i eth0 -p tcp --dport 1723 -j ACCEPT
iptables -A INPUT -i eth0 -p gre -j ACCEPT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
