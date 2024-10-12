import requests
import json
import os
from datetime import datetime
from requests.exceptions import RequestException

# New Ethereum address
address_hash = '0xYourNewEthAddress'
# API URL remains unchanged
base_url = 'https://api.scan.pulsechain.com/api'
# New path for GitHub environment
last_balance_file = './data/last_balance.json'

def get_time_ago(timestamp):
    """Returns the time elapsed since the given timestamp."""
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
    """Fetches the balance information and rewards."""
    try:
        response = requests.get(f'{base_url}?module=account&action=eth_get_balance&address={address_hash}', timeout=10)
        response.raise_for_status()  # Raises an exception for HTTP error codes
        data = response.json()
        if 'result' in data:
            current_balance = int(data['result'], 16) / 1e18  # Convert from Wei to PLS
            last_data = load_last_data()
            last_balance = last_data.get('balance', 0)
            last_increase_time = last_data.get('last_increase_time', 'Never')
            now = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

            # Check if it's the first run
            if last_balance == 0:
                # Initialize data with current balance
                save_last_data(current_balance, now, 0)
                return f"{current_balance:.2f}\nN/A (First Run)"
            
            # Check balance change
            if current_balance > last_balance:
                increase = current_balance - last_balance
                save_last_data(current_balance, now, increase)
                return f"{current_balance:.2f}\n{increase:.2f} PLS {get_time_ago(now)}"
            else:
                # If the balance decreased (e.g., after a sale), update the balance
                if current_balance < last_balance:
                    save_last_data(current_balance, now, 0)
                
                # Even if the balance hasn't increased, update the recorded balance
                time_ago = get_time_ago(last_increase_time)
                last_increase_value = last_data.get('last_increase_value', 0)
                return f"{current_balance:.2f}\n{last_increase_value:.2f} PLS {time_ago}"
        else:
            return "N/A\nN/A (Invalid API Response)"
    except RequestException as e:
        return f"N/A\nN/A (Connection Error: {str(e)})"
    except json.JSONDecodeError:
        return "N/A\nN/A (Invalid API Response)"
    except Exception as e:
        return f"N/A\nN/A (Error: {str(e)})"

def load_last_data():
    """Loads the last saved data."""
    if os.path.exists(last_balance_file):
        try:
            with open(last_balance_file, 'r') as f:
                return json.load(f)
        except json.JSONDecodeError:
            return {}
    return {}

def save_last_data(balance, time, increase=0):
    """Saves the balance data and time of increase."""
    try:
        with open(last_balance_file, 'w') as f:
            json.dump({'balance': balance, 'last_increase_time': time, 'last_increase_value': increase}, f)
    except Exception as e:
        print(f"Error saving data: {str(e)}")

if __name__ == "__main__":
    try:
        print(get_pls_info())
    except Exception as e:
        print(f"N/A\nN/A (Unexpected Error: {str(e)})")

