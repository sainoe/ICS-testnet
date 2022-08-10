#!/bin/bash
set -eux 

pkill -f hermes 2> /dev/null || true
hermes -j start &> ~/.hermes/logs &
