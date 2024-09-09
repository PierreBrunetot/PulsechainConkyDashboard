#!/bin/bash

response=$(curl -s http://localhost:5052/eth/v1/node/syncing)
is_syncing=$(echo "$response" | grep -oP '"is_syncing":\K(true|false)')

if [ "$is_syncing" = "true" ]; then
    echo '${color yellow}⟳ Syncing${color}'
else
    echo '${color green}✓ Synced${color}'
fi
