# Pulsechain Conky Dashboard

A Conky-based monitoring dashboard for PulseChain validator nodes. This tool provides real-time information and logs to help manage and monitor your PulseChain validator efficiently.

## Features

- Real-time Monitoring: Monitor CPU, RAM, disk usage, and temperatures (CPU, SSD, ACPI, Wi-Fi) for real-time resource consumption insights.
- Download/Upload: Track the current download and upload speeds for network usage.
- Network Latency: Measure the latency of your connection to check network performance.
- Logs Display: View logs for Lighthouse Beacon, Lighthouse Validator, and Geth for easier troubleshooting.
- Geth Sync Status: Monitor the synchronization status of Geth to ensure your node is up to date.
- Sync Status: Easily check if your node is syncing or fully synced:
   ⟳ Syncing (yellow) — The node is currently syncing.
  ✓ Synced (green) — The node is fully synced.
   ✗ Sync Error (red) — There is an issue with the sync process.
- Active Validators: Track the number of active validators for your node.
- Latest Block: Display the latest block to stay informed about your node’s progress.
- Connected Peers: Track the number of Geth and Lighthouse peers.
- PLS Balance: Track your PLS balance directly within the system.
- Validator Reward: Display the latest validator reward to stay updated on earnings.

## Prerequisites

- Ubuntu or Debian-based system
- Python 3.x
- Conky
- Lighthouse
- Geth

## Installation

### Automated Installation

To automatically install and configure the necessary dependencies, you can use the provided `setup.sh` script.

#### Installation Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/PierreBrunetot/PulsechainConkyDashboard.git
   cd PulsechainConkyDashboard

2. Make the script executable and run it:
   chmod +x setup.sh
   ./setup.sh

3. Follow the on-screen instructions to enter your ETH address and configure the balance file path.

4. Launch Conky:
   conky -c ~/.config/conky/conky.conf
   
## Updating the PATH

To include `/opt/lighthouse` in your `PATH`, follow these steps:

1. Open your shell configuration file (e.g., `.bashrc`, `.zshrc`, etc.) in a text editor.

2. Add the following line to the file:
   ```bash
   export PATH=$PATH:/opt/lighthouse

3. Save the changes to the file.

4. Apply the changes by running the appropriate command for your shell:
   source ~/.bashrc  # For Bash users
   
## Setting Up the Desktop Wallpaper

This repository includes a custom desktop wallpaper named `minimal.png`, sourced from PulseChain's official branding assets.

### Steps to Set the Wallpaper

1. Locate the `minimal.png` file in the repository directory.
2. Open the **Settings** application on your Ubuntu system.
3. Navigate to the **Background** section.
4. Click on **Add Picture** and select `minimal.png`.

For more details and to access additional branding assets, visit the official PulseChain branding page: [PulseChain Branding](https://pulsechain.com/Branding.zip).
