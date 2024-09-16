#!/bin/bash

# Function to check if Xray is already installed for server kharej
check_xray_installed_kharej() {
    if [ -d "/usr/local/etc/xray" ] && systemctl list-units --type=service | grep -q "xray.service"; then
        echo "Xray is already installed and configured."
        return 0
    else
        return 1
    fi
}

# Function to check if Xray is already installed for server iran
check_xray_installed_iran() {
    if [ -d "/usr/local/xray" ] && systemctl list-units --type=service | grep -q "xray.service"; then
        echo "Xray is already installed for server iran."
        return 0
    else
        return 1
    fi
}

# Function to detect architecture and download rathole
download_rathole() {
    local arch=$(uname -m)
    local rathole_dir="/etc/rathole"
    local rathole_zip

    mkdir -p "$rathole_dir"

    case "$arch" in
        x86_64)
            rathole_zip="https://github.com/edthepurple/EdVPN/raw/main/rathole-x86_64-unknown-linux-gnu.zip"
            ;;
        aarch64)
            rathole_zip="https://github.com/edthepurple/EdVPN/raw/main/rathole-aarch64-unknown-linux-musl.zip"
            ;;
        *)
            echo "Unsupported architecture: $arch"
            exit 1
            ;;
    esac

    echo "Downloading rathole for architecture $arch..."
    wget -O "$rathole_dir/rathole.zip" "$rathole_zip"

    # Unzip and clean up
    unzip "$rathole_dir/rathole.zip" -d "$rathole_dir"
    rm "$rathole_dir/rathole.zip"
    chmod +x "$rathole_dir/rathole"

    # Move rathole binary to /usr/bin
    mv "$rathole_dir/rathole" /usr/bin/rathole

    echo "Rathole installed in /usr/bin."
}

# Function to apply sysctl configuration
apply_sysctl_config() {
    echo "Applying sysctl configuration..."

    # Clear the /etc/sysctl.conf file
    > /etc/sysctl.conf

    # Append the new configuration to /etc/sysctl.conf
    {
        echo "# Enable IP Forwarding"
        echo "net.ipv4.ip_forward = 1"
        echo ""
        echo "# Enable TCP BBR congestion control"
        echo "net.core.default_qdisc = fq"
        echo "net.ipv4.tcp_congestion_control = bbr"
        echo ""
        echo "# Maximum number of packets allowed in the backlog"
        echo "net.core.netdev_max_backlog = 250000"
        echo ""
        echo "# Increase the maximum buffer size for send/receive"
        echo "net.core.rmem_max = 16777216"
        echo "net.core.wmem_max = 16777216"
        echo ""
        echo "# Increase the default buffer size for send/receive"
        echo "net.core.rmem_default = 8388608"
        echo "net.core.wmem_default = 8388608"
        echo ""
        echo "# Increase the TCP maximum buffer space for autotuning"
        echo "net.ipv4.tcp_rmem = 4096 87380 16777216"
        echo "net.ipv4.tcp_wmem = 4096 65536 16777216"
        echo ""
        echo "# Enable window scaling"
        echo "net.ipv4.tcp_window_scaling = 1"
        echo ""
        echo "# Increase TCP SYN backlog to handle more incoming connections"
        echo "net.ipv4.tcp_max_syn_backlog = 4096"
        echo ""
        echo "# Increase the number of file handles (useful if you are dealing with a high number of simultaneous connections)"
        echo "fs.file-max = 2097152"
        echo ""
        echo "# Enable TCP Fast Open"
        echo "net.ipv4.tcp_fastopen = 3"
        echo ""
        echo "# Reduce the time to keep connections in TIME_WAIT state"
        echo "net.ipv4.tcp_fin_timeout = 15"
        echo ""
        echo "# Enable timestamps as defined in RFC1323"
        echo "net.ipv4.tcp_timestamps = 1"
        echo ""
        echo "# Increase the maximum queue length of pending connections"
        echo "net.core.somaxconn = 1024"
        echo ""
        echo "# UDP buffer settings (increase receive buffer)"
        echo "net.core.rmem_max = 16777216"
        echo "net.core.wmem_max = 16777216"
        echo ""
        echo "# Increase UDP buffer sizes"
        echo "net.ipv4.udp_rmem_min = 16384"
        echo "net.ipv4.udp_wmem_min = 16384"
    } >> /etc/sysctl.conf

    # Apply the new sysctl settings
    sysctl -p

    echo "Sysctl configuration optimized."
}

echo "In server khareje ya iran?"
echo "1. Kharej"
echo "2. Iran"
read -p "Select an option (1 or 2): " choice

if [ "$choice" == "1" ]; then
    echo "Server kharej entekhab shod"
    
    # Check if Xray is already installed (kharej)
    if check_xray_installed_kharej; then
        exit 0
    fi

    # Prompt the user for a port with a default value of 8081
    read -p "Enter the port for Xray (default: 8081): " port
    port=${port:-8081}  # Default to 8081 if no input is provided

    echo "Using port $port for Xray."

    # Install Xray with the beta version and run as root
    bash -c "$(wget -O - https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta -u root

    # Download the server config and place it in the correct directory
    wget -O /usr/local/etc/xray/config.json https://raw.githubusercontent.com/edthepurple/EdVPN/main/server-config.json

    # Update the config file to use the specified port
    sed -i "s/8081/$port/g" /usr/local/etc/xray/config.json

    # Apply sysctl configuration
    apply_sysctl_config

    # Download and install rathole
    download_rathole

    # Download rathole client service
    wget -O /etc/systemd/system/rathole.service https://raw.githubusercontent.com/edthepurple/EdVPN/main/rathole-client.service

    # Reload systemd to register the new service
    systemctl daemon-reload

    # Enable the service to run at startup
    systemctl enable rathole

    # Download and configure server.toml
    wget -O /etc/rathole/server.toml https://github.com/edthepurple/EdVPN/raw/main/kharej.toml

    # Ask for the IP address to replace in the configuration file
    read -p "Enter the IP address of iran server (default: 94.182.145.210): " ip_address
    ip_address=${ip_address:-94.182.145.210}

    # Replace the default IP address with the user-provided IP address
    sed -i "s/94.182.145.210/$ip_address/g" /etc/rathole/server.toml

    # Start the rathole service
    systemctl start rathole

    # Now start the xray service (after rathole)
    systemctl restart xray

    systemctl enable xray

elif [ "$choice" == "2" ]; then
    echo "Server iran entekhab shod"
    
    # Check if Xray is already installed (iran)
    if check_xray_installed_iran; then
        exit 0
    fi

    # Prompt the user for the ports with default values
    read -p "Enter the main UDP port on the server (default: 42100): " main_udp_port
    main_udp_port=${main_udp_port:-42100}

    read -p "Enter the UDP port to listen on client (default: 42300): " client_udp_port
    client_udp_port=${client_udp_port:-42300}

    read -p "Enter the tunnel port (default: 443): " tunnel_port
    tunnel_port=${tunnel_port:-443}

    echo "Using ports:"
    echo "Main UDP port: $main_udp_port"
    echo "Client UDP port: $client_udp_port"
    echo "Tunnel port: $tunnel_port"

    # Create the directory for Xray if not exists
    mkdir -p /usr/local/xray

    # Download Xray-linux-64.zip
    wget -O /usr/local/xray/Xray-linux-64.zip https://github.com/edthepurple/EdVPN/raw/main/Xray-linux-64.zip

    # Unzip the downloaded file and clean up
    unzip /usr/local/xray/Xray-linux-64.zip -d /usr/local/xray
    rm /usr/local/xray/Xray-linux-64.zip

    # Move Xray to /usr/bin and make it executable
    mv /usr/local/xray/xray /usr/bin/xray
    chmod +x /usr/bin/xray

    # Download the client-config.json as config.json
    wget -O /usr/local/xray/config.json https://raw.githubusercontent.com/edthepurple/EdVPN/main/client-config.json

    # Update the config file with user-provided ports
    sed -i "s/42100/$main_udp_port/g" /usr/local/xray/config.json
    sed -i "s/42300/$client_udp_port/g" /usr/local/xray/config.json
    sed -i "s/8081/$tunnel_port/g" /usr/local/xray/config.json

    # Download the xray.service file
    wget -O /etc/systemd/system/xray.service https://raw.githubusercontent.com/edthepurple/EdVPN/main/xray.service

    # Reload systemd to register the new service
    systemctl daemon-reload

    # Enable the service to run at startup
    systemctl enable xray

    # Apply sysctl configuration
    apply_sysctl_config

    # Download and install rathole
    download_rathole

    # Download and configure server.toml
    wget -O /etc/rathole/server.toml https://github.com/edthepurple/EdVPN/raw/main/iran.toml

    # Download rathole server service
    wget -O /etc/systemd/system/rathole.service https://raw.githubusercontent.com/edthepurple/EdVPN/main/rathole-server.service

    # Reload systemd to register the new service
    systemctl daemon-reload

    # Enable the service to run at startup
    systemctl enable rathole

    # Start the rathole service
    systemctl start rathole

    # Now start the xray service (after rathole)
    systemctl start xray

else
    echo "Lotfan ye adad dorost vared konid."
fi
