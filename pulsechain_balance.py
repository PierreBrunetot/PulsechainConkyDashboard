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

