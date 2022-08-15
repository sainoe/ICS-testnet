## Join the Interchain-Security Testnet
This guide contains the instructions for joining a Interchain-Security Testnet. You can find the instructions to setup a IS-testnet from scratch [here](./start-testnet-tutorial.md). 

---

### Prerequesites
- Go 1.18+ <sub><sup>([installation notes](https://go.dev/doc/install))<sub><sup>
- Interchain Security binaries <sub><sup>([installation notes](./start-testnet-tutorial.md#install-the-interchain-security-binary))<sub><sup>
- Rust 1.60+ <sub><sup>([installation notes](https://www.rust-lang.org/tools/install))<sub><sup>
- Hermes v1.0.0-rc.0 <sub><sup>([installation notes](https://hermes.informal.systems/getting_started.html))<sub><sup>
- jq  <sub><sup>([installation notes](https://stedolan.github.io/jq/download/))<sub><sup>


---

### Run a validator on the Provider chain
This section will explain you how to setup and run an node in order to participate to the Provider chain as a validator.
Choose a directory name (e.g. `~/provider-recruit`) to store the provider chain node files.

* *If you have completed the [IS-testnet tutorial](./start-testnet-tutorial.md) on the same machine,
  be sure to use <b>a different node folder</b>!*

__1. Remove any existing directory__  

```
PROV_NODE_DIR=~/provider
rm -rf $PROV_NODE_DIR
```  
 <br/><br/>  

__2. Create the node directory__  
The command below initializes the node's configuration files. The `$PROV_NODE_MONIKER` argument is a public moniker that will identify your validator, i.e. `coop-validator`).Additionally, in this guide its assumed that the provider and consumer chains id are self-titled.
```
PROV_NODE_MONIKER=change-me
PROV_CHAIN_ID=provider

interchain-security-pd init $PROV_NODE_MONIKER --chain-id $PROV_CHAIN_ID --home $PROV_NODE_DIR
```
<br/><br/>

__3. Generate the node keypair__  
This following step creates a public/private keypair and stores it under the given keyname of your choice. The output is also exported into a json file for later use.

```
PROV_KEY=provider-key

interchain-security-pd keys add $PROV_KEY --home $PROV_NODE_DIR --keyring-backend test --output json > ${PROV_NODE_DIR}/${PROV_KEY}.json 2>&1
```  

* *The `--keyring-backend` option can be removed if you would prefer securing the account with a password*
<br/><br/>

__4. Get the Provider chain genesis file__
Download the provider chain genesis file to the correct location.

```
wget -O ${PROV_NODE_DIR}/config/genesis.json https://pastebin.com/raw/F1TCk0Gf
```

<br/><br/>


__5. Run the node__  
This command will run the node using the coordinator persistent peer address retrieved from the genesis state.
```
# Retrieve public ip address
MY_IP=$(host -4 myip.opendns.com resolver1.opendns.com | grep "address" | awk '{print $4}')

# Get persistent peer
COORDINATOR_P2P_ADDRESS=$(jq -r '.app_state.genutil.gen_txs[0].body.memo' ${PROV_NODE_DIR}/config/genesis.json)

# Run node
interchain-security-pd start --home $PROV_NODE_DIR \
        --rpc.laddr tcp://${MY_IP}:26658 \
        --grpc.address ${MY_IP}:9091 \
        --address tcp://${MY_IP}:26655 \
        --p2p.laddr tcp://${MY_IP}:26656 \
        --grpc-web.enable=false \
        --p2p.persistent_peers $COORDINATOR_P2P_ADDRESS \
        &> ${PROV_NODE_DIR}/logs &
```
   
   
* *If you get the error "can't bind address xxx.xxx.x.x", try using `127.0.0.1` instead.* 


<br/><br/>

__6. Setup client RPC endpoint__  
This command changes the default RPC client endpoint port of our node. It is exposed by Tendermint and allows us to query the chains' states and to submit transactions.This command below change the client RPC endpoint using the following command.

```
sed -i -r "/node =/ s/= .*/= \"tcp:\/\/${MY_IP}:26658\"/" ${PROV_NODE_DIR}/config/client.toml
```

<br/><br/>


__7. Fund your account__   
Make sure your node account has at least `1000000stake` coins in order to stake.
Verify your account balance using the command below.

```
# Check your account balance
interchain-security-pd q bank balances $(jq -r .address ${PROV_NODE_DIR}/${PROV_KEY}.json) --home $PROV_NODE_DIR
```

* *Ask to get your local account fauceted or use the command below if you have access to another account at least extra `1000000stake` tokens.*

 ```
# Get local account addresses
ACCOUNT_ADDR=$(interchain-security-pd keys show $PROV_KEY \
       --keyring-backend test --home $PROV_NODE_DIR --output json | jq -r '.address')

# Run this command 
interchain-security-pd tx bank send <source-address> <destination-address> \
        1000000stake --from <source-keyname> --keyring-backend test --home $PROV_NODE_DIR --chain-id provider -b block 
```

<br/><br/>

### Run a validator on the Consumer chain
The following steps will explain you how to configure and run a validator node for joining the Consumer chain.  

__1. Remove any existing directory__  

```
CONS_NODE_DIR=~/consumer
rm -rf $CONS_NODE_DIR
```
<br/><br/>

__2. Create the node directory__  

This command generates the required node directory stucture along with the intial genesis file.  

```
CONS_NODE_MONIKER=change-me
CONS_CHAIN_ID=consumer

interchain-security-cd init $CONS_NODE_MONIKER --chain-id $CONS_CHAIN_ID --home $CONS_NODE_DIR
```

<br/><br/>

__3. Generate a node keypair__   

This command create a keypair for the consumer node.
```
$CONS_KEY=consumer-key

interchain-security-cd keys add $CONS_KEY \
    --home $CONS_NODE_DIR --output json > ${CONS_NODE_DIR}/${CONS_KEY}.json 2>&1
```
<br/><br/>

__4. Get the Consumer chain genesis file__  
Download the consumer chain genesis file to the correct location.

```
wget -O ${CONS_NODE_DIR}/config/genesis.json https://pastebin.com/raw/NEVEgcgz
``` 

<br/><br/>

__5. Import validator keypair node__  
 
The following will copy the required validator keypair files in order to run the same node on the consumer chain.  

```
cp ${PROV_NODE_DIR}/config/node_key.json ${CONS_NODE_DIR}/config/node_key.json

cp ${PROV_NODE_DIR}/config/priv_validator_key.json ${CONS_NODE_DIR}/config/priv_validator_key.json
```
<br/><br/>

__6. Setup client RPC endpoint__  
This command updates the consumer node RPC client config and allow to query the chain states as explained in the above.  
  
```
sed -i -r "/node =/ s/= .*/= \"tcp:\/\/localhost:26648\"/" ${CONS_NODE_DIR}/config/client.toml
```
<br/><br/>

__7. Run the validator node__  

This command will run the validator on the consumer chain.  

```
# Get persistent peer address
COORDINATOR_P2P_ADDRESS=$(jq -r '.app_state.genutil.gen_txs[0].body.memo' ${PROV_NODE_DIR}/config/genesis.json)

# Get consumer chain coordinator node p2p address
CONSUMER_P2P_ADDRESS=$(echo $COORDINATOR_P2P_ADDRESS | sed 's/:.*/:26646/')

interchain-security-cd start --home $CONS_NODE_DIR \
        --rpc.laddr tcp://${MY_IP}:26648 \
        --grpc.address ${MY_IP}:9081 \
        --address tcp://${MY_IP}:26645 \
        --p2p.laddr tcp://${MY_IP}:26646 \
        --grpc-web.enable=false \
        --p2p.persistent_peers $CONSUMER_P2P_ADDRESS \
        &> ${CONS_NODE_DIR}/logs &
```

<br/><br/>


__8. Bond the validator__  
Now that both consumer and provider nodes are running, we can bond it to be a validator on boths chain, by submitting the following transaction to the provider chain.

```
# Get the validator node pubkey 
VAL_PUBKEY=$(interchain-security-pd tendermint show-validator --home $PROV_NODE_DIR)

# Create the validator
interchain-security-pd tx staking create-validator \
            --amount 1000000stake \
            --pubkey $VAL_PUBKEY \
            --from $PROV_KEY \
            --keyring-backend test \
            --home $PROV_NODE_DIR \
            --chain-id provider \
            --commission-max-change-rate 0.01 \
            --commission-max-rate 0.2 \
            --commission-rate 0.1 \
            --moniker $PROV_MONIKER \
            --min-self-delegation 1 \
            -b block -y
```
<br>
Verify that your validator node is now part of the validator-set.

```
interchain-security-pd q tendermint-validator-set --home $PROV_NODE_DIR

interchain-security-cd q tendermint-validator-set --home $CONS_NODE_DIR
```  

---


### Test the CCV protocol
These optional steps show you how CCV updates the Consumer chain validator-set voting power. In order to do so, we will delegate some tokens to the validator on the Provider chain and verify that the Consumer chain validator-set gets updated.

__1. Delegate tokens__  
```
# Get validator delegations
DELEGATIONS=$(interchain-security-pd q staking delegations \
    $(jq -r .address ${PROV_KEY}.json) --home $PROV_NODE_DIR -o json)

# Get validator operator address
OPERATOR_ADDR=$(echo $DELEGATIONS | jq -r '.delegation_responses[0].delegation.validator_address')


# Delegate tokens
interchain-security-pd tx staking delegate $OPERATOR_ADDR 1000000stake \
                --from ${PROV_KEY} \
                --keyring-backend test \
                --home $PROV_NODE_DIR \
                --chain-id $PROV_CHAIN_ID \
                -y -b block
```

<br/><br/>

__2.Check the validator set__  
This commands below will print the updated validator set.

```
# Get validator consensus address
VAL_ADDR=$(interchain-security-pd tendermint show-address --home $PROV_NODE_DIR)
        
# Query validator consenus info        
interchain-security-cd q tendermint-validator-set --home $CONS_NODE_DIR | grep -A11 $VAL_ADDR
```

<br/><br/>

### Run the validatos using systemd services (optional)
The following steps show how to optionally setup the nodes' deamon to be run as systemd services.

__1. Create service file for the nodes__  

```
$BINARY_HOME=change-me

tee vim /etc/systemd/system/interchain-security-pd.service<<EOF
[Unit]
Description=Interchain Security service
After=network-online.target
[Service]
User=root
ExecStart=${BINARY_HOME}/interchain-security-pd start --home $PROV_NODE_DIR --rpc.laddr tcp://${NODE_IP}:26658 --grpc.address ${NODE_IP}:9091 --address tcp://${NODE_IP}:26655 --p2p.laddr tcp://${NODE_IP}:26656 --grpc-web.enable=false
Restart=always
RestartSec=3
LimitNOFILE=4096
Environment='DAEMON_NAME=interchain-security-pd'
Environment='DAEMON_HOME=${BINARY_HOME}'
Environment='DAEMON_ALLOW_DOWNLOAD_BINARIES=true'
Environment='DAEMON_RESTART_AFTER_UPGRADE=true'
Environment='DAEMON_LOG_BUFFER_SIZE=512'
[Install]
WantedBy=multi-user.target
EOF
```

```
tee vim /etc/systemd/system/interchain-security-cd.service<<EOF
[Unit]
Description=Interchain Security service
After=network-online.target
[Service]
User=root
ExecStart=${BINARY_HOME}/interchain-security-cd start --home $CONS_NODE_DIR --rpc.laddr tcp://${NODE_IP}:26648 --grpc.address ${NODE_IP}:9081 --address tcp://${NODE_IP}:26645 --p2p.laddr tcp://${NODE_IP}:26646 --grpc-web.enable=false
Restart=always
RestartSec=3
LimitNOFILE=4096
Environment='DAEMON_NAME=interchain-security-cd'
Environment='DAEMON_HOME=${BINARY_HOME}'
Environment='DAEMON_ALLOW_DOWNLOAD_BINARIES=true'
Environment='DAEMON_RESTART_AFTER_UPGRADE=true'
Environment='DAEMON_LOG_BUFFER_SIZE=512'
[Install]
WantedBy=multi-user.target
EOF
```
<br/><br/>

__2. Reload the services__  
Run the following command to reload the services

```
systemctl daemon-reload
systemctl restart systemd-journald

# check the validators status and logs
systemctl status interchain-security-pd
journalctl -n 100 --no-pager`
```
