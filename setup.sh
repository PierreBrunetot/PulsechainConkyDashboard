#!/bin/bash

# Installation script for Pulsechain Conky Dashboard

echo "Updating packages and installing dependencies..."

# Update packages
sudo apt-get update

# Install Conky
sudo apt-get install -y conky-all

# Install Python3 and pip (if not already installed)
sudo apt-get install -y python3 python3-pip

# Install the 'requests' package via pip
pip3 install requests

# Install sensors for temperature monitoring
sudo apt-get install -y lm-sensors

# Detect sensors (necessary to obtain temperature data)
sudo sensors-detect --auto

echo "Configuring Conky..."

# Copy Conky configuration file to the correct directory
mkdir -p ~/.config/conky
cp conky.conf ~/.config/conky/conky.conf

echo "Creating pulsechain_balance.py..."

# Create the pulsechain_balance.py script
cat << 'EOF' > pulsechain_balance.py
import requests
import json
import os
from datetime import datetime

# Replace these values with your own before using
address_hash = 'your_address_hash'
base_url = 'https://api.scan.pulsechain.com/api'
last_balance_file = '/path/to/your/file/last_balance.json'

def get_time_ago(timestamp):
    if timestamp == 'Never':
        return 'Never'
    now = datetime.now()
    diff = now - datetime.strptime(timestamp, '%Y-%m-%d %H:%M:%S')

    days = diff.days
    hours = diff.seconds // 3600
    minutes = (diff.seconds % 3600) // 60

    if days > 0:
        return f"{days}d {hours}h {minutes}m ago"
    elif hours > 0:
        return f"{hours}h {minutes}m ago"
    else:
        return f"{minutes}m ago"

def get_pls_info():
    try:
        response = requests.get(f'{base_url}?module=account&action=eth_get_balance&address={address_hash}')
        data = response.json()
        if 'result' in data:
            current_balance = int(data['result'], 16) / 1e18  # Convert from Wei to PLS
            last_data = load_last_data()
            last_balance = last_data.get('balance', 0)
            last_increase_time = last_data.get('last_increase_time', 'Never')
            now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            
            if current_balance > last_balance:
                increase = current_balance - last_balance
                save_last_data(current_balance, now, increase)
                return f"{current_balance:.2f}\n{increase:.2f} PLS {get_time_ago(now)}"
            else:
                time_ago = get_time_ago(last_increase_time)
                last_increase_value = last_data.get('last_increase_value', 0)
                return f"{current_balance:.2f}\n{last_increase_value:.2f} PLS {time_ago}"
    except Exception as e:
        return f"Error: {str(e)}\nNo data"

def load_last_data():
    if os.path.exists(last_balance_file):
        with open(last_balance_file, 'r') as f:
            return json.load(f)
    return {}

def save_last_data(balance, time, increase=0):
    with open(last_balance_file, 'w') as f:
        json.dump({'balance': balance, 'last_increase_time': time, 'last_increase_value': increase}, f)

if __name__ == "__main__":
    print(get_pls_info())
EOF

echo "Customizing pulsechain_balance.py..."

# Replace placeholder values with user input
echo "Please enter your ETH address for PLS balance tracking:"
read address_hash

sed -i "s/your_address_hash/$address_hash/g" pulsechain_balance.py

# Ask the user where to save the JSON file for tracking the balance
echo "Please specify the full path to save the balance data (e.g., /home/user/.pulsechain/last_balance.json):"
read last_balance_file

sed -i "s|/path/to/your/file/last_balance.json|$last_balance_file|g" pulsechain_balance.py

echo "Creating the validator count script..."

# Create the validator count script
cat << 'EOF' > ~/validator_count.sh
#!/bin/bash
# Replace this line with the actual command to get your validator count
lighthouse validators list | wc -l
EOF

# Create the check_sync.sh script
echo "Creating the check_sync.sh script..."

cat << 'EOF' > ~/check_sync.sh
#!/bin/bash

response=$(curl -s http://localhost:5052/eth/v1/node/syncing)
is_syncing=$(echo "$response" | grep -oP '"is_syncing":\K(true|false)')

if [ "$is_syncing" = "true" ]; then
    echo '${color yellow}⟳ Syncing${color}'
else
    echo '${color green}✓ Synced${color}'
fi
EOF

# Create the validator_efficiency.py script
echo "Creating the validator_efficiency.py script..."

cat << 'EOF' > ~/validator_efficiency.py
# This is a placeholder for the validator_efficiency.py script.
# Please update this file with the actual content.
EOF

# Make the scripts executable
chmod +x ~/validator_count.sh
chmod +x ~/check_sync.sh
chmod +x ~/validator_efficiency.py

echo "Installation completed. You can now launch Conky with the following configuration:"
echo "conky -c ~/.config/conky/conky.conf"

