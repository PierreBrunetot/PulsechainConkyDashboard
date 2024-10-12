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
${if_match "${execi 5 ${HOME}/scripts/check_internet.sh}" == "online"}
${color1}${font DejaVu Sans:bold:size=14}Server Status${font}
${color5}${hr 4}
${font DejaVu Sans:size=12}${color2}Uptime ${goto 330}${uptime}
${font DejaVu Sans:size=12}${color2}CPU Usage ${goto 330}${cpu}% ${goto 370}${color1}${cpubar 5,350}
${font DejaVu Sans:size=12}${color2}RAM Usage ${goto 330}${execi 5 ${HOME}/.config/conky/format_ram.sh} ${goto 421}${color1}${membar 5,299}
${font DejaVu Sans:size=12}${color2}Disk Usage ${goto 330}${fs_used /} / ${fs_size /} (${fs_used_perc /}%) ${goto 525}${color1}${fs_bar 5,195 /}
${font DejaVu Sans:size=12}${color2}Swap Usage ${goto 330}${execi 5 ${HOME}/scripts/check_swap.sh}${goto 437}${color1}${swapbar 5,283}
${font DejaVu Sans:size=12}${color2}Download/Upload:${goto 330}${execi 5 ${HOME}/vnstat_and_ifstat_stats.sh | sed 's/ / \/ /2'}
${font DejaVu Sans:size=12}${color2}Network Latency ${goto 330}${execi 5 timeout 2 ping -c 1 8.8.8.8 | awk -F'/' 'END{print $5}' || echo "N/A"} ms${color}
${font DejaVu Sans:size=12}${color2}CPU Temperature ${goto 330}${execi 5 sensors | awk '/Core [0-9]+/ {sum += $3; count++} END {printf "%.1f°C", int(sum/count)}'}
${font DejaVu Sans:size=12}${color2}SSD Temperature ${goto 330}${execi 5 sudo /usr/sbin/nvme smart-log /dev/nvme0 | grep temperature | awk '{printf "%.1f°C", $3+0.0}'}
${font DejaVu Sans:size=12}${color2}ACPI Temperature ${goto 330}${execi 5 sensors -u | awk '/acpitz-acpi-0/,/^$/' | grep 'temp1_input' | awk '{printf "%.1f°C", $2+0.0}'}
${font DejaVu Sans:size=12}${color2}Wi-Fi Temperature ${goto 330}${execi 5 sensors -u | awk '/iwlwifi_1-virtual-0/,/^$/' | grep 'temp1_input' | awk '{printf "%.1f°C", $2}'}

${font DejaVu Sans:size=12}${color2}Geth Service ${goto 330}${if_match "${execi 5 systemctl is-active geth.service}" == "active"}${color #00cc44}✓ Active${else}${color red}✗ Inactive${endif}${color}
${font DejaVu Sans:size=12}${color2}Lighthouse Beacon ${goto 330}${if_match "${execi 5 systemctl is-active lighthouse-beacon.service}" == "active"}${color #00cc44}✓ Active${else}${color red}✗ Inactive${endif}${color}
${font DejaVu Sans:size=12}${color2}Lighthouse Validator ${goto 330}${if_match "${execi 5 systemctl is-active lighthouse-validator.service}" == "active"}${color #00cc44}✓ Active${else}${color red}✗ Inactive${endif}${color}
${font DejaVu Sans:size=12}${color2}Geth Sync Status ${goto 330}${if_match "${execi 10 timeout 2 curl -s http://localhost:8545 -X POST -H 'Content-Type: application/json' --data '{\"jsonrpc\":\"2.0\",\"method\":\"eth_syncing\",\"params\":[],\"id\":1}' | jq -r '.result'}" == "false"}${color #00cc44}✓ Synced${else}${color red}✗ Syncing${endif}${color}
${font DejaVu Sans:size=12}${color2}Sync Status ${goto 330}${if_match "${execi 10 timeout 2 ${HOME}/scripts/check_sync.sh | grep 'is_synced' | awk '{print $2}' | tr -d '\n' | tr -d ' '}" == "true"}${color #00cc44}✓ Synced${else}${color red}✗ Syncing${endif}${color}
${font DejaVu Sans:size=12}${color2}Active Validators ${goto 330}${execi 10 ${HOME}/validator_count.sh || echo "N/A"}
${font DejaVu Sans:size=12}${color2}Latest Block ${goto 330}${execi 10 timeout 5 python3 ${HOME}/validator_efficiency.py | grep "Latest Block" | cut -d ":" -f2 | tr -d " " || echo "N/A"}
${font DejaVu Sans:size=12}${color2}Geth Connected Peers ${goto 330}${execi 10 timeout 5 python3 ${HOME}/validator_efficiency.py | grep "Geth Connected Peers" | cut -d ":" -f2 | tr -d " " || echo "N/A"}
${font DejaVu Sans:size=12}${color2}Lighthouse Connected Peers ${goto 330}${execi 10 timeout 5 python3 ${HOME}/validator_efficiency.py | grep "Lighthouse Connected Peers" | cut -d ":" -f2 | tr -d " " || echo "N/A"}

${color1}${font DejaVu Sans:bold:size=14}Lighthouse Beacon Logs${font}
${color5}${hr 4}
${color2}${execpi 10 journalctl -u lighthouse-beacon.service --no-pager -n 3 | fold -w 70 | head -n 6}

${color1}${font DejaVu Sans:bold:size=14}Lighthouse Validator Logs${font}
${color5}${hr 4}
${color2}${execpi 10 journalctl -u lighthouse-validator.service --no-pager -n 3 | fold -w 70 | head -n 6}

${color1}${font DejaVu Sans:bold:size=14}Geth Logs${font}
${color5}${hr 4}
${color2}${execpi 10 journalctl -u geth.service --no-pager -n 3 | fold -w 70 | head -n 6}

${color1}${font DejaVu Sans:bold:size=14}PLS Balance${font}
${color5}${hr 4}
${font DejaVu Sans:size=12}${color #E0E0E0}PLS Balance ${goto 330}${execi 300 python3 ${HOME}/pulsechain_balance.py | sed -n 1p || echo "N/A"} PLS
${font DejaVu Sans:size=12}${color lightgrey}Last Increase ${goto 330}${color 00cc44}${execi 300 python3 ${HOME}/pulsechain_balance.py | sed -n 2p || echo "N/A"}${color}

${else}

${color1}${font DejaVu Sans:bold:size=14}Server Status${font}
${color5}${hr 4}
${font DejaVu Sans:size=12}${color2}Uptime ${goto 330}${uptime}
${font DejaVu Sans:size=12}${color2}CPU Usage ${goto 330}${cpu}% ${goto 370}${color1}${cpubar 5,350}
${font DejaVu Sans:size=12}${color2}RAM Usage ${goto 330}${execi 5 ${HOME}/.config/conky/format_ram.sh} ${goto 421}${color1}${membar 5,299}
${font DejaVu Sans:size=12}${color2}Disk Usage ${goto 330}${fs_used /} / ${fs_size /} (${fs_used_perc /}%) ${goto 525}${color1}${fs_bar 5,195 /}
${font DejaVu Sans:size=12}${color2}Swap Usage ${goto 330}${execi 5 ${HOME}/scripts/check_swap.sh}${goto 437}${color1}${swapbar 5,283}
${font DejaVu Sans:size=12}${color2}CPU Temperature ${goto 330}${execi 5 sensors | awk '/Core [0-9]+/ {sum += $3; count++} END {printf "%.1f°C", int(sum/count)}'}
${font DejaVu Sans:size=12}${color2}SSD Temperature ${goto 330}${execi 5 sudo /usr/sbin/nvme smart-log /dev/nvme0 | grep temperature | awk '{printf "%.1f°C", $3+0.0}'}
${font DejaVu Sans:size=12}${color2}ACPI Temperature ${goto 330}${execi 5 sensors -u | awk '/acpitz-acpi-0/,/^$/' | grep 'temp1_input' | awk '{printf "%.1f°C", $2+0.0}'}
${font DejaVu Sans:size=12}${color2}Wi-Fi Temperature ${goto 330}${execi 5 sensors -u | awk '/iwlwifi_1-virtual-0/,/^$/' | grep 'temp1_input' | awk '{printf "%.1f°C", $2}'}

${font DejaVu Sans:size=12}${color2}Geth Service ${goto 330}${color red}Active (No Internet)${color}
${font DejaVu Sans:size=12}${color2}Lighthouse Beacon ${goto 330}${color red}Active (No Internet)${color}
${font DejaVu Sans:size=12}${color2}Lighthouse Validator ${goto 330}${color red}Active (No Internet)${color}
${font DejaVu Sans:size=12}${color2}Geth Sync Status ${goto 330}${color red}Not Synced (No Internet)${color}
${font DejaVu Sans:size=12}${color2}Sync Status ${goto 330}${color red}Not Synced (No Internet)${color}
${font DejaVu Sans:size=12}${color2}Active Validators ${goto 330}${color red}N/A (No Internet)${color}
${font DejaVu Sans:size=12}${color2}Latest Block ${goto 330}${color red}N/A (No Internet)${color}
${font DejaVu Sans:size=12}${color2}Geth Connected Peers ${goto 330}${color red}N/A (No Internet)${color}
${font DejaVu Sans:size=12}${color2}Lighthouse Connected Peers ${goto 330}${color red}N/A (No Internet)${color}

${color1}${font DejaVu Sans:bold:size=14}PLS Balance${font}
${color5}${hr 4}
${font DejaVu Sans:size=12}${color #E0E0E0}PLS Balance ${goto 330}${color red}N/A (No Internet)${color}
${font DejaVu Sans:size=12}${color lightgrey}Last Increase ${goto 330}${color red}N/A (No Internet)${color}

${endif}
]]
EOF

# Create the check_internet.sh script
mkdir -p ~/scripts

cat << 'EOF' > ~/scripts/check_internet.sh
#!/bin/bash

# Vérifie si la connexion Internet est disponible avec un timeout de 5 secondes
if timeout 5 curl -s --head http://www.google.com/ | head -n 1 | grep -q "HTTP/"; then
    echo "online"
else
    echo "offline"
fi
EOF

# Make the script executable
chmod +x ~/scripts/check_internet.sh

echo "Configuration completed. Starting Conky..."

# Start Conky
conky -c ~/.config/conky/conky.conf &

