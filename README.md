# Pulsechain Conky Dashboard

A Conky-based monitoring dashboard for PulseChain validator nodes. This tool provides real-time information and logs to help manage and monitor your PulseChain validator efficiently.

## Features

- Real-time monitoring of CPU, RAM, and disk usage
- Display of Lighthouse Beacon, Lighthouse Validator, and Geth logs
- PLS balance tracking
- Customizable desktop wallpaper for Ubuntu

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
 
## Setting Up the Desktop Wallpaper

This repository includes a custom desktop wallpaper named `minimal.png`, sourced from PulseChain's official branding assets.

### Steps to Set the Wallpaper

1. Locate the `minimal.png` file in the repository directory.
2. Open the **Settings** application on your Ubuntu system.
3. Navigate to the **Background** section.
4. Click on **Add Picture** and select `minimal.png`.

For more details and to access additional branding assets, visit the official PulseChain branding page: [PulseChain Branding](https://pulsechain.com/Branding.zip).
