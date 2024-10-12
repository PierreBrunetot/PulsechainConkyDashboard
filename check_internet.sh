#!/bin/bash

# Vérifie si la connexion Internet est disponible avec un timeout de 5 secondes
if timeout 5 curl -s --head http://www.google.com/ | head -n 1 | grep -q "HTTP/"; then
    echo "online"
else
    echo "offline"
fi
