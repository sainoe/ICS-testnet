#!/bin/bash
set -eux 

HOME_DIR=""

pkill -f interchain-security-pd &> /dev/null || true

interchain-security-pd start --home ${HOME_DIR}/provider \
        --rpc.laddr tcp://127.0.0.1:26658 \
        --grpc.address 127.0.0.1:9091 \
        --address tcp://127.0.0.1:26655 \
        --p2p.laddr tcp://127.0.0.1:26656 \
        --grpc-web.enable=false \
         &> ${HOME_DIR}/provider/logs &
