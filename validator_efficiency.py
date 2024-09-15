import requests
from datetime import datetime, timedelta

# Configuration
PULSECHAIN_API_URL = 'https://api.scan.pulsechain.com/api'  # PulseChain API URL
VALIDATOR_ADDRESS = "0x0000000000000000000000000000000000000000"  # Placeholder Ethereum validator address
GETH_RPC_URL = "http://localhost:8545"  # Geth node URL
LIGHTHOUSE_API_URL = "http://localhost:5052"  # Lighthouse API URL

def get_pulsechain_data(params):
    try:
        response = requests.get(PULSECHAIN_API_URL, params=params, timeout=5)
        response.raise_for_status()
        return response.json()
    except requests.RequestException:
        return None

def parse_timestamp(timestamp_str):
    try:
        return datetime.strptime(timestamp_str, "%Y-%m-%d %H:%M:%S.%fZ")
    except ValueError:
        return None

def get_latest_block_number():
    params = {
        "module": "block",
        "action": "eth_block_number"
    }
    response = get_pulsechain_data(params)
    if response and response.get("result"):
        return int(response["result"], 16)
    return None

def get_validator_stats():
    try:
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
            return None

        total_blocks = len(mined_blocks_data["result"])
        recent_blocks = [block for block in mined_blocks_data["result"]
                         if parse_timestamp(block['timeStamp']) and parse_timestamp(block['timeStamp']) >= start_time]
        recent_blocks_count = len(recent_blocks)

        expected_blocks_7d = 7 * 24 * 60 * 60 / 12 / 1000  # Block time in seconds (~12s per block)
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
    except Exception:
        return None

def get_geth_peer_count():
    try:
        payload = {
            "jsonrpc": "2.0",
            "method": "net_peerCount",
            "params": [],
            "id": 1
        }
        response = requests.post(GETH_RPC_URL, json=payload, timeout=5)
        result = response.json()
        if "result" in result:
            return int(result["result"], 16)
    except Exception:
        pass
    return None

def get_lighthouse_peer_count():
    try:
        response = requests.get(f"{LIGHTHOUSE_API_URL}/eth/v1/node/peer_count", timeout=5)
        result = response.json()
        if "data" in result:
            return int(result["data"]["connected"])
    except Exception:
        pass
    return None

def get_geth_sync_status():
    try:
        payload = {
            "jsonrpc": "2.0",
            "method": "eth_syncing",
            "params": [],
            "id": 1
        }
        response = requests.post(GETH_RPC_URL, json=payload, timeout=5)
        result = response.json()
        if "result" in result:
            sync_status = result["result"]
            if sync_status is False or sync_status == "false":
                return "Synced"
            else:
                return "Syncing"
    except Exception:
        pass
    return "Unknown"

if __name__ == "__main__":
    try:
        stats = get_validator_stats()
        if stats:
            print(f"Total Blocks: {stats['total_blocks_mined']}")
            print(f"7d Blocks: {stats['blocks_mined_7d']}")
            print(f"Latest Block: {stats['latest_block']}")
            print(f"7d Efficiency: {stats['efficiency_7d']:.2f}%")
            print(f"Avg Time Between Blocks: {stats['avg_time_between_blocks']:.2f} seconds")
        else:
            print("Total Blocks: N/A")
            print("7d Blocks: N/A")
            print("Latest Block: N/A")
            print("7d Efficiency: N/A")
            print("Avg Time Between Blocks: N/A")

        geth_peers = get_geth_peer_count()
        print(f"Geth Connected Peers: {geth_peers if geth_peers is not None else 'N/A'}")

        lighthouse_peers = get_lighthouse_peer_count()
        print(f"Lighthouse Connected Peers: {lighthouse_peers if lighthouse_peers is not None else 'N/A'}")

        geth_sync_status = get_geth_sync_status()
        with open('/tmp/geth_sync_status.txt', 'w') as file:
            file.write(geth_sync_status)
    except Exception:
        print("Total Blocks: N/A")
        print("7d Blocks: N/A")
        print("Latest Block: N/A")
        print("7d Efficiency: N/A")
        print("Avg Time Between Blocks: N/A")
        print("Geth Connected Peers: N/A")
        print("Lighthouse Connected Peers: N/A")
        with open('/tmp/geth_sync_status.txt', 'w') as file:
            file.write("Unknown")

