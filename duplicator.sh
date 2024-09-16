#!/bin/bash

# Function to create a systemd service file
create_service_file() {
    local ip=$1
    local toml_file="/etc/rathole/server-${ip}.toml"
    local service_file="/etc/systemd/system/rathole-client-${ip}.service"

    # Download and modify the service file
    wget -qO- https://raw.githubusercontent.com/edthepurple/EdVPN/main/rathole-client.service | sed "s/server.toml/server-${ip}.toml/" > "$service_file"

    # Reload systemd, enable the service at startup, and start the service
    systemctl daemon-reload
    systemctl enable "rathole-client-${ip}.service"
    systemctl start "rathole-client-${ip}.service"

    echo "Service for $ip created, enabled at startup, and started successfully."
}

# Function to replace IP in the TOML file
replace_ip_in_toml() {
    local old_ip=$1
    local new_ip=$2
    local toml_file=$3

    # Replace the IP address in the remote_addr field
    sed -i "s/$old_ip/$new_ip/g" "$toml_file"
}

# Check if /etc/rathole and server.toml both exist
if [ ! -d "/etc/rathole" ] || [ ! -f "/etc/rathole/server.toml" ]; then
    echo "Either rathole is not installed or server.toml is missing. Please run MushMushak first."
    exit 1
fi

# Ask for the number of Iran servers
read -p "How many Iran servers do you have? " num_servers

# Declare an array to store the IPs for status commands later
declare -a iran_ips

# Iterate over the number of servers to get the IPs and create the files
for (( i=1; i<=num_servers; i++ )); do
    read -p "Enter the IP address of Iran server #$i: " iran_ip

    # Store the IP in the array
    iran_ips+=("$iran_ip")

    # Copy the base server.toml file
    cp /etc/rathole/server.toml "/etc/rathole/server-${iran_ip}.toml"

    # Find the current IP in remote_addr and replace it with the provided IP
    current_ip=$(grep -Po '(?<=remote_addr = ")[^:]*' /etc/rathole/server.toml)
    if [ -n "$current_ip" ]; then
        replace_ip_in_toml "$current_ip" "$iran_ip" "/etc/rathole/server-${iran_ip}.toml"
    else
        echo "Warning: Could not find an IP address in server.toml. Skipping replacement for $iran_ip."
    fi

    # Create, enable at startup, and start the systemd service for the current IP
    create_service_file "$iran_ip"
done

# Check the status of the services
echo "All services were created, enabled at startup, and started successfully!"
echo "To view the status of each service, run the following commands:"
for ip in "${iran_ips[@]}"; do
    echo "  sudo systemctl status rathole-client-${ip}.service"
done
