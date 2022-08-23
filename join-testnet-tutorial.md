## Join the Interchain-Security Testnet
This guide contains the instructions for joining a Interchain-Security Testnet. You can find the instructions to setup a ICS-testnet from scratch [here](./start-testnet-tutorial.md). 

---

### Prerequesites
- Go 1.18+ <sub><sup>([installation notes](https://go.dev/doc/install))<sub><sup>
- Interchain Security binaries <sub><sup>([installation notes](#install-the-interchain-security-binary))<sub><sup>
- Rust 1.60+ <sub><sup>([installation notes](https://www.rust-lang.org/tools/install))<sub><sup>
- Hermes v1.0.0-rc.0 <sub><sup>([installation notes](https://hermes.informal.systems/getting_started.html))<sub><sup>
- jq  <sub><sup>([installation notes](https://stedolan.github.io/jq/download/))<sub><sup>


---
  
  
### Install the Interchain Security Binary
```
git clone https://github.com/cosmos/interchain-security.git
cd interchain-security
git checkout tags/v0.1
make install
```

### Run a validator on the Provider chain
This section will explain you how to setup and run an node in order to participate to the Provider chain as a validator.
Choose a directory name (e.g. `~/provider-recruit`) to store the provider chain node files.

* *If you have completed the [ICS-testnet tutorial](./start-testnet-tutorial.md) on the same machine,
  be sure to use <b>a different node folder</b>!*

__1. Remove any existing directory__  

```
PROV_NODE_DIR=~/provider
rm -rf $PROV_NODE_DIR
pkill -f interchain-security-pd
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
wget -O ${PROV_NODE_DIR}/config/genesis.json https://paste.c-net.org/GlitterTracker
```

<br/><br/>


__5. Run the node__  
This command will run the node using the coordinator persistent peer address retrieved from the genesis state.
```
MY_IP=$(host -4 myip.opendns.com resolver1.opendns.com | grep "address" | awk '{print $4}')
COORDINATOR_P2P_ADDRESS=$(jq -r '.app_state.genutil.gen_txs[0].body.memo' ${PROV_NODE_DIR}/config/genesis.json)

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

### Run a validator on the Consumer chain
The following steps will explain you how to configure and run a validator node for joining the Consumer chain.  

__1. Remove any existing directory__  

```
CONS_NODE_DIR=~/consumer
rm -rf $CONS_NODE_DIR
pkill -f interchain-security-cd
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
CONS_KEY=consumer-key

interchain-security-cd keys add $CONS_KEY \
    --home $CONS_NODE_DIR --keyring-backend test --output json > ${CONS_NODE_DIR}/${CONS_KEY}.json 2>&1
```
<br/><br/>

__4. Get the Consumer chain genesis file__  
Download the consumer chain genesis file to the correct location.

```
wget -O ${CONS_NODE_DIR}/config/genesis.json https://paste.c-net.org/CrewsOrton
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
sed -i -r "/node =/ s/= .*/= \"tcp:\/\/${MY_IP}:26648\"/" ${CONS_NODE_DIR}/config/client.toml
```
<br/><br/>

__7. Run the validator node__  

This command will run the validator on the consumer chain.  

```
COORDINATOR_P2P_ADDRESS=$(jq -r '.app_state.genutil.gen_txs[0].body.memo' ${PROV_NODE_DIR}/config/genesis.json)
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

__8. Get fauceted__   
Execute the following command to get fauceted `5000000stake` in order to have the minimum deposit and to bond your validator.

```
# Get local account addresses
ACCOUNT_ADDR=$(interchain-security-pd keys show $PROV_KEY \
       --keyring-backend test --home $PROV_NODE_DIR --output json | jq -r '.address')

# Request tokens 
curl "http://167.172.190.207:8000/request?address=${ACCOUNT_ADDR}&chain=provider"

# Check your account's balance
interchain-security-pd q bank balances ${ACCOUNT_ADDR} --home $PROV_NODE_DIR
```


<br/><br/>

__9. Bond the validator__  
Now that both consumer and provider nodes are running, we can bond it to be a validator on boths chain, by submitting the following transaction to the provider chain.

```
VAL_PUBKEY=$(interchain-security-pd tendermint show-validator --home $PROV_NODE_DIR)

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
            --moniker $PROV_NODE_MONIKER \
            --min-self-delegation 1 \
            -b block -y
```
  
 <br/><br/>
 
__10. Check the validator set__  
Verify that you node was added to the validators using the following command.

```
# Get validator consensus address
VALCONS_ADDR=$(interchain-security-pd tendermint show-address --home $PROV_NODE_DIR)
        
# Query the chains validator set
interchain-security-pd q tendermint-validator-set --home $PROV_NODE_DIR | grep -A11 $VALCONS_ADDR
  
interchain-security-cd q tendermint-validator-set --home $CONS_NODE_DIR | grep -A11 $VALCONS_ADDR
```

---


### Test the CCV protocol
These optional steps show you how CCV updates the Consumer chain validator-set voting power. In order to do so, we will delegate some tokens to the validator on the Provider chain and verify that the Consumer chain validator-set gets updated.

__1. Delegate tokens__  
```
DELEGATIONS=$(interchain-security-pd q staking delegations $(jq -r .address ${PROV_NODE_DIR}/${PROV_KEY}.json) --home $PROV_NODE_DIR -o json)
OPERATOR_ADDR=$(echo $DELEGATIONS | jq -r '.delegation_responses[0].delegation.validator_address')

interchain-security-pd tx staking delegate $OPERATOR_ADDR 1000000stake \
                --from ${PROV_KEY} \
                --keyring-backend test \
                --home $PROV_NODE_DIR \
                --chain-id $PROV_CHAIN_ID \
                -y -b block
```
  
<br/><br/>
    
__2. Check the validator set__  
Check that your validator's voting power is updated by querying the validator set

```
interchain-security-pd q tendermint-validator-set --home $PROV_NODE_DIR | grep -A11 $VALCONS_ADDR
  
interchain-security-cd q tendermint-validator-set --home $CONS_NODE_DIR | grep -A11 $VALCONS_ADDR
```

<br/><br/>


### Use systemd services (optional)
The following steps show how to optionally setup the nodes' deamon to run in systemd services.

__1. Create service file for the nodes__  

```
BINARY_HOME=$(which interchain-security-pd)

tee vim /etc/systemd/system/interchain-security-pd.service<<EOF
[Unit]
Description=Interchain Security service
After=network-online.target
[Service]
User=root
ExecStart=${BINARY_HOME}/interchain-security-pd start --home $PROV_NODE_DIR --rpc.laddr tcp://${MY_IP}:26658 --grpc.address ${MY_IP}:9091 --address tcp://${MY_IP}:26655 --p2p.laddr tcp://${MY_IP}:26656 --grpc-web.enable=false
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
BINARY_HOME=$(which interchain-security-cd)
  
tee vim /etc/systemd/system/interchain-security-cd.service<<EOF
[Unit]
Description=Interchain Security service
After=network-online.target
[Service]
User=root
ExecStart=${BINARY_HOME}/interchain-security-cd start --home $CONS_NODE_DIR --rpc.laddr tcp://${MY_IP}:26648 --grpc.address ${MY_IP}:9081 --address tcp://${MY_IP}:26645 --p2p.laddr tcp://${MY_IP}:26646 --grpc-web.enable=false
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
