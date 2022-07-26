## Join a consumer chain
This guide shows the steps to start a consumer chain assuming that a provider chain validator node is already set on your local machine.

<br />

### Setup consumer chain

__0. Remove any existing directory__  
```
CONS2_NODE_DIR=~/consumer2
rm -rf $CONS2_NODE_DIR
```

<br />

__1. Setup the node directory__   
This following step create the node configuration files.
```
CONS2_CHAIN_ID=consumer2
CONS2_NODE_MONIKER=change-me

interchain-security-cd init $CONS2_NODE_MONIKER --chain-id $CONS2_CHAIN_ID --home $CONS2_NODE_DIR
```

<br />

__2. Get consumer chain genesis__   
Download the consumer chain genesis using the following command:
```
wget -O ${CONS2_NODE_DIR}/config/genesis.json https://paste.c-net.org/TacomaTortoise
```

<br />

__3. Copy provider chain validator keys__   
In order to run the consumer chain node you need a provider validator node private key. 
Here we are assuming that these keys are stored in the same local machine. 

```
PROV_NODE_DIR=~/provider

echo '{"height": "0","round": 0,"step": 0}' > ${CONS2_NODE_DIR}/data/priv_validator_state.json
cp ${PROV_NODE_DIR}/config/node_key.json ${CONS2_NODE_DIR}/config/node_key.json
cp ${PROV_NODE_DIR}/config/priv_validator_key.json ${CONS2_NODE_DIR}/config/priv_validator_key.json
```

<br />

__4. Setup cleint RPC endpoint__  
This command updates the consumer node RPC client config and allow to query the chain states as explained in the above.
```
MY_IP=$(host -4 myip.opendns.com resolver1.opendns.com | grep "address" | awk '{print $4}')
sed -i -r "/node =/ s/= .*/= \"tcp:\/\/${MY_IP}:26638\"/" ${CONS2_NODE_DIR}/config/client.toml
```

<br />


__5. Run the validator__   

```

COORDINATOR_P2P_ADDRESS=$(jq -r '.app_state.genutil.gen_txs[0].body.memo' ${PROV_NODE_DIR}/config/genesis.json)
CONS2_P2P_ADDRESS=$(echo $COORDINATOR_P2P_ADDRESS | sed 's/:.*/:26636/')

interchain-security-cd start --home $CONS2_NODE_DIR \
        --rpc.laddr tcp://${MY_IP}:26638 \
        --grpc.address ${MY_IP}:9071 \
        --address tcp://${MY_IP}:26635 \
        --p2p.laddr tcp://${MY_IP}:26636 \
        --grpc-web.enable=false \
        --p2p.persistent_peers $CONS2_P2P_ADDRESS \
        &> ${CONS2_NODE_DIR}/logs &
```

__6. Check that you are in the validator set of the second consumer chain__

```
# Get validator consensus address
VALCONS_ADDR=$(interchain-security-pd tendermint show-address --home $PROV_NODE_DIR)
        
# Query the chains validator set  
interchain-security-cd q tendermint-validator-set --home $CONS2_NODE_DIR | grep -A11 $VALCONS_ADDR
```
