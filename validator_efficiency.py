#!/usr/bin/env python3

import requests
from datetime import datetime, timedelta

# Configuration
PULSECHAIN_API_URL = 'https://api.scan.pulsechain.com/api'
VALIDATOR_ADDRESS = "0x0000000000000000000000000000000000000000"  # Placeholder address
GETH_RPC_URL = "http://localhost:8545"  # Adjust if necessary
LIGHTHOUSE_API_URL = "http://localhost:5052"  # Adjust if necessary

def get_pulsechain_data(params):
    """
    Fetch data from the PulseChain API.
    """
    try:
        response = requests.get(PULSECHAIN_API_URL, params=params)
        response.raise_for_status()
        return response.json()
    except requests.RequestException as e:
        print(f"Error fetching data from API: {e}")
        return None

def parse_timestamp(timestamp_str):
    """
    Parse a timestamp string into a datetime object.
    """
    try:
        return datetime.strptime(timestamp_str, "%Y-%m-%d %H:%M:%S.%fZ")
    except ValueError:
        print(f"Unable to parse timestamp: {timestamp_str}")
        return None

def get_latest_block_number():
    """
    Retrieve the latest block number from PulseChain.
    """
    params = {
        "module": "block",
        "action": "eth_block_number"
    }
    response = get_pulsechain_data(params)
    if response and response.get("result"):
        return int(response["result"], 16)
    print(f"Error getting latest block number: {response}")
    return None

def get_validator_stats():
    """
    Get statistics about the validator's performance.
    """
    current_time = datetime.now()
    start_time = current_time - timedelta(days=7)

    latest_block = get_latest_block_number()
    if not latest_block:
        return None

    mined_blocks_data = get_pulsechain_data({
        "module": "account",
        "action": "getminedblocks",
        "address": VALIDATOR_ADDRESS,
        "startblock": 0,
        "endblock": latest_block,
        "sort": "desc"
    })

    if not mined_blocks_data or "result" not in mined_blocks_data:
        print("Failed to fetch mined blocks data")
        return None

    total_blocks = len(mined_blocks_data["result"])
    recent_blocks = [block for block in mined_blocks_data["result"]
                     if parse_timestamp(block['timeStamp']) and parse_timestamp(block['timeStamp']) >= start_time]
    recent_blocks_count = len(recent_blocks)

    expected_blocks_7d = 7 * 24 * 60 * 60 / 12 / 1000
    efficiency_7d = (recent_blocks_count / expected_blocks_7d) * 100 if expected_blocks_7d > 0 else 0

    if len(recent_blocks) > 1:
        time_diffs = [(parse_timestamp(recent_blocks[i]['timeStamp']) - 
                       parse_timestamp(recent_blocks[i+1]['timeStamp'])).total_seconds()
                      for i in range(len(recent_blocks)-1)]
        avg_time_between_blocks = sum(time_diffs) / len(time_diffs) if time_diffs else 0
    else:
        avg_time_between_blocks = 0

    return {
        "total_blocks_mined": total_blocks,
        "blocks_mined_7d": recent_blocks_count,
        "latest_block": latest_block,
        "efficiency_7d": efficiency_7d,
        "avg_time_between_blocks": avg_time_between_blocks
    }

def get_geth_peer_count():
    """
    Get the number of connected Geth peers.
    """
    payload = {
        "jsonrpc": "2.0",
        "method": "net_peerCount",
        "params": [],
        "id": 1
    }
    try:
        response = requests.post(GETH_RPC_URL, json=payload)
        result = response.json()
        if "result" in result:
            return int(result["result"], 16)
        else:
            print(f"Error getting Geth peer count: {result.get('error', 'Unknown error')}")
            return None
    except Exception as e:
        print(f"Error connecting to Geth: {e}")
        return None

def get_lighthouse_peer_count():
    """
    Get the number of connected Lighthouse peers.
    """
    try:
        response = requests.get(f"{LIGHTHOUSE_API_URL}/eth/v1/node/peer_count")
        result = response.json()
        if "data" in result:
            return int(result["data"]["connected"])
        else:
            print(f"Error getting Lighthouse peer count: {result}")
            return None
    except Exception as e:
        print(f"Error connecting to Lighthouse: {e}")
        return None

if __name__ == "__main__":
    stats = get_validator_stats()
    if stats:
        print(f"Total Blocks: {stats['total_blocks_mined']}")
        print(f"7d Blocks: {stats['blocks_mined_7d']}")
        print(f"Latest Block: {stats['latest_block']}")
        print(f"7d Efficiency: {stats['efficiency_7d']:.2f}%")
        print(f"Avg Time Between Blocks: {stats['avg_time_between_blocks']:.2f} seconds")
    else:
        print("Failed to retrieve validator stats")

    geth_peers = get_geth_peer_count()
    if geth_peers is not None:
        print(f"Geth Connected Peers: {geth_peers}")
    else:
        print("Failed to retrieve Geth peer count")

    lighthouse_peers = get_lighthouse_peer_count()
    if lighthouse_peers is not None:
        print(f"Lighthouse Connected Peers: {lighthouse_peers}")
    else:
        print("Failed to retrieve Lighthouse peer count")
