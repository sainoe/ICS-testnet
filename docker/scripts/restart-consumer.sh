#!/bin/bash
set -eux 

HOME_DIR=""
POWER=101

pkill -f interchain-security-cd &> /dev/null || true

interchain-security-pd q provider consumer-genesis consumer --home ${HOME_DIR}/provider -o json > ccvconsumer.json 2>&1

interchain-security-cd export --home ${HOME_DIR}/consumer --log_format=json > consumer-genesis-exp.json 2>&1

jq -s '.[0].app_state.ccvconsumer.initial_val_set = .[1].initial_val_set | .[0]'  consumer-genesis-exp.json ccvconsumer.json > new_genesis.json
jq ".app_state.ccvconsumer.initial_val_set[0].power = \"$POWER\"" new_genesis.json > final_genesis.json

mv final_genesis.json ${HOME_DIR}/consumer/config/genesis.json

rm consumer-genesis-exp.json ccvconsumer.json new_genesis.json final_genesis.json

cp -r ${HOME_DIR}/consumer/data ${HOME_DIR}/consumer/consumer-data.bak

interchain-security-cd unsafe-reset-all --home ${HOME_DIR}/consumer

interchain-security-cd start --home ${HOME_DIR}/consumer \
        --rpc.laddr tcp://127.0.0.1:26648 \
        --grpc.address 127.0.0.1:9081 \
        --address tcp://127.0.0.1:26645 \
        --p2p.laddr tcp://127.0.0.1:26646 \
        --grpc-web.enable=false \
        &> ${HOME_DIR}/consumer/logs &
