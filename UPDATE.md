# Update Summary

## New Features and Changes

- **Sync Status**: Added a new script to monitor the synchronization status of your node.
- **Geth Sync Status**: Added monitoring for Geth sync status.
- **Latest Block**: Added a feature to display the latest block information.
- **Geth Connected Peers**: Added monitoring for the number of Geth connected peers.
- **Lighthouse Connected Peers**: Added monitoring for the number of Lighthouse connected peers.
- **check_sync.sh**: Added a new script to check sync status with the following functionality:
  ```bash
  response=$(curl -s http://localhost:5052/eth/v1/node/syncing)
  is_syncing=$(echo "$response" | grep -oP '"is_syncing":\K(true|false)')

  if [ "$is_syncing" = "true" ]; then
      echo '${color yellow}⟳ Syncing${color}'
  else
      echo '${color green}✓ Synced${color}'
  fi
