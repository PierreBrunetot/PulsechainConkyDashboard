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

# Detect screen resolution
resolution=$(xrandr | grep '*' | awk '{print $1}')
width=$(echo $resolution | cut -d'x' -f1)
height=$(echo $resolution | cut -d'x' -f2)

# Calculate configuration parameters based on resolution
gap_x=$((width / 50))
gap_y=$((height / 20))
minimum_width=$((width / 2))

echo "Screen resolution detected: $resolution"
echo "Configuring Conky with gap_x=$gap_x, gap_y=$gap_y, minimum_width=$minimum_width"

echo "Configuring Conky..."

# Copy Conky configuration file to the correct directory
mkdir -p ~/.config/conky

# Generate the Conky configuration file with dynamic parameters
cat << EOF > ~/.config/conky/conky.conf
conky.config = {
    alignment = 'top_right',
    background = false,
    border_width = 1,
    cpu_avg_samples = 2,
    net_avg_samples = 2,
    no_buffers = true,
    override_utf8_locale = true,
    use_spacer = 'right',
    uppercase = false,
    gap_x = $gap_x,
    gap_y = $gap_y,
    minimum_width = $minimum_width,
    border_inner_margin = 20,
    border_outer_margin = 0,
    color1 = '#E0E0E0',  -- Color for titles
    color2 = '#E0E0E0',  -- Color for logs
    color3 = '#88B04B',  -- Color for balance
    color4 = '#FFD700',  -- Color for rewards
    color5 = '#A64DFF',  -- Color for separators
    double_buffer = true,
    draw_borders = false,
    draw_graph_borders = true,
    draw_outline = false,
    draw_shades = false,
    use_xft = true,
    font = 'DejaVu Sans:size=12',
    xftalpha = 0.8,
    own_window = true,
    own_window_type = 'desktop',
    own_window_transparent = true,
    own_window_argb_visual = true,
};

conky.text = [[
${color1}${font DejaVu Sans:bold:size=14}Server Status${font}
${color5}${hr 4}
${font DejaVu Sans:size=12}${color2}Uptime ${goto 280}${uptime}
${font DejaVu Sans:size=12}${color2}CPU Usage ${goto 280}${cpu}% ${goto 320}${color1}${cpubar 5,350}
${font DejaVu Sans:size=12}${color2}RAM Usage ${goto 280}${exec ${HOME}/.config/conky/format_ram.sh} ${goto 365}${color1}${membar 5,305}
${font DejaVu Sans:size=12}${color2}Disk Usage ${goto 280}${fs_used /} / ${fs_size /} (${fs_used_perc /}%) ${goto 475}${color1}${fs_bar 5,195 /}
${font DejaVu Sans:size=12}${color2}Swap Usage ${goto 280}${color2}${execi 60 ${HOME}/scripts/check_swap.sh}${goto 385}${color1}${swapbar 5,285}
${font DejaVu Sans:size=12}${color2}Download/Upload:${goto 280}${execi 5 ${HOME}/vnstat_and_ifstat_stats.sh | sed 's/ / \/ /2'}
${font DejaVu Sans:size=12}${color2}Network Latency ${goto 280}${color2}${execi 300 ping -c 3 8.8.8.8 | tail -1 | awk '{print $4}' | cut -d '/' -f 2} ms${color}
${font DejaVu Sans:size=12}${color2}CPU Temperature ${goto 280}${execi 10 sensors | awk '/Core [0-9]+/ {sum += $3; count++} END {printf "%.1f°C", int(sum/count)}'}
${font DejaVu Sans:size=12}${color2}SSD Temperature ${goto 280}${execi 10 sudo /usr/sbin/nvme smart-log /dev/nvme0 | grep temperature | awk '{printf "%.1f°C", $3+0.0}'}
${font DejaVu Sans:size=12}${color2}ACPI Temperature ${goto 280}${execi 10 sensors -u | awk '/acpitz-acpi-0/,/^$/' | grep 'temp1_input' | awk '{printf "%.1f°C", $2+0.0}'}
${font DejaVu Sans:size=12}${color2}Wi-Fi Temperature ${goto 280}${execi 10 sensors -u | awk '/iwlwifi_1-virtual-0/,/^$/' | grep 'temp1_input' | awk '{printf "%.1f°C", $2}'}

${font DejaVu Sans:size=12}${color2}Geth Service ${goto 280}${if_match "${execi 60 systemctl is-active geth.service}"=="active"}${color #00cc44}✓ Active${else}${color red}✗ Inactive${endif}${color}
${font DejaVu Sans:size=12}${color2}Lighthouse Beacon ${goto 280}${if_match "${execi 60 systemctl is-active lighthouse-beacon.service}"=="active"}${color #00cc44}✓ Active${else}${color red}✗ Inactive${endif}${color}
${font DejaVu Sans:size=12}${color2}Lighthouse Validator ${goto 280}${if_match "${execi 60 systemctl is-active lighthouse-validator.service}"=="active"}${color #00cc44}✓ Active${else}${color red}✗ Inactive${endif}${color}
${font DejaVu Sans:size=12}${color2}Sync Status ${goto 280}${execi 60 ${HOME}/scripts/check_sync.sh | grep 'is_synced' | awk '{print $2}' | tr -d '\n' | tr -d ' '}${if_match "${execi 60 ${HOME}/scripts/check_sync.sh | grep 'is_synced' | awk '{print $2}' | tr -d '\n' | tr -d ' '}"}${color #00cc44}✓ Synced${else}${color yellow}⟳ Syncing${end>
${font DejaVu Sans:size=12}${color2}Geth Sync Status ${goto 280}${if_match "${execi 60 curl -s http://localhost:8545 -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' | jq -r '.result'}"=="false"}${color #00cc44}✓ Synced${else}${color yellow}⟳ Syncing${endif}${color}
${font DejaVu Sans:size=12}${color2}Validator Status ${goto 280}${if_match "${execi 60 curl -s http://localhost:8545 -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' | jq -r '.result'}"=="false"}${color #00cc44}✓ Active${else}${color yellow}⟳ Syncing${endif}${color}
${font DejaVu Sans:size=12}${color2}Active Validators ${goto 280}${execi 60 ${HOME}/validator_count.sh}
${font DejaVu Sans:size=12}${color2}Latest Block ${goto 280}${execi 300 python3 ${HOME}/validator_efficiency.py | grep "Latest Block" | cut -d ":" -f2 | tr -d " "}
${font DejaVu Sans:size=12}${color2}Geth Connected Peers ${goto 280}${execi 60 python3 ${HOME}/validator_efficiency.py | grep "Geth Connected Peers" | cut -d ":" -f2 | tr -d " "}
${font DejaVu Sans:size=12}${color2}Lighthouse Connected Peers ${goto 280}${execi 60 python3 ${HOME}/validator_efficiency.py | grep "Lighthouse Connected Peers" | cut -d ":" -f2 | tr -d " "}
${font DejaVu Sans:size=12}${color2}Block Time ${goto 280}${execi 60 python3 ${HOME}/validator_efficiency.py | grep "Block Time" | cut -d ":" -f2 | tr -d " "}
${font DejaVu Sans:size=12}${color2}Latest Log ${goto 280}${execi 60 tail -n 20 ~/.ethereum/geth.log | tail -n 1}
]];
EOF

# Create the pulsechain_balance.py script
echo "Creating pulsechain_balance.py..."

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
