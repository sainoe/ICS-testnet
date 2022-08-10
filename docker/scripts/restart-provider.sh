#!/bin/bash
set -eux 

HOME_DIR=""

pkill -f interchain-security-pd &> /dev/null || true

interchain-security-pd export --home ${HOME_DIR}/provider --log_format=json > provider-genesis-exp.json 2>&1

cp provider-genesis-exp.json ${HOME_DIR}/provider/config/genesis.json

rm provider-genesis-exp.json

cp -r ${HOME_DIR}/provider/data ${HOME_DIR}/provider/provider-data.bak

interchain-security-pd unsafe-reset-all --home ${HOME_DIR}/provider

interchain-security-pd start --home ${HOME_DIR}/provider \
        --rpc.laddr tcp://127.0.0.1:26658 \
        --grpc.address 127.0.0.1:9091 \
        --address tcp://127.0.0.1:26655 \
        --p2p.laddr tcp://127.0.0.1:26656 \
        --grpc-web.enable=false \
        &> ${HOME_DIR}/provider/logs &
