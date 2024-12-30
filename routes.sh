#!/bin/bash

# Define the lines to append
ROUTES="""
route 0.0.0.0 255.0.0.0
route 10.0.0.0 255.0.0.0
route 100.64.0.0 255.192.0.0
route 169.254.0.0 255.255.0.0
route 172.16.0.0 255.240.0.0
route 192.0.0.0 255.255.255.0
route 192.0.2.0 255.255.255.0
route 192.88.99.0 255.255.255.0
route 192.168.0.0 255.255.0.0
route 198.18.0.0 255.254.0.0
route 198.51.100.0 255.255.255.0
route 203.0.113.0 255.255.255.0
route 224.0.0.0 240.0.0.0
route 240.0.0.0 240.0.0.0
"""

# Append the routes to /etc/openvpn/server.conf
echo "$ROUTES" >> /etc/openvpn/server.conf

# Append the routes to /etc/openvpn/tcp.conf
echo "$ROUTES" >> /etc/openvpn/tcp.conf

# Restart the OpenVPN services
service openvpn restart && service openvpn-tcp restart

# Output a message indicating success
if [ $? -eq 0 ]; then
    echo "Routes appended and OpenVPN services restarted successfully."
else
    echo "Failed to restart OpenVPN services. Check configuration files and try again."
fi
