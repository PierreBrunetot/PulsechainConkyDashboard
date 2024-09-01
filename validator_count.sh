#!/bin/bash
sudo journalctl -u lighthouse-validator -n 1 | grep "All validators active" | awk -F'total_validators: ' '{print $2}' | awk '{print $1}' | tr -d ','
