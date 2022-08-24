## Interchain Security Testnet

This guide contains the instructions to setup a Interchain-Security Testnet. For the sake of simplicity, both provider and consumer chains run a single node chorum. After the completition of this tutorial you have the possibility to add other nodes to the networks by following these complementary intructions [guide](./join-testnet-tutorial.md).

---

### Prerequisites
- Go 1.18+ <sub><sup>([installation notes](https://go.dev/doc/install))<sub><sup>
- Interchain Security binaries <sub><sup>([installation notes](#install-the-interchain-security-binary))<sub><sup>
- Rust 1.60+ <sub><sup>([installation notes](https://www.rust-lang.org/tools/install))<sub><sup>
- Hermes v1.0.0 <sub><sup>([installation notes](https://hermes.informal.systems/getting_started.html))<sub><sup>
- jq  <sub><sup>([installation notes](https://stedolan.github.io/jq/download/))<sub><sup>

---

### Install the Interchain Security Binary
```
git clone https://github.com/cosmos/interchain-security.git
cd interchain-security
git checkout tags/v0.1.1
make install
```

---

### Install the IBC-Relayer
Follow the instruction to install the IBC-Relayer Rust implementation [here](https://hermes.informal.systems/getting_started.html).

---

### Provider chain setup
The following steps explain how to setup a provider chain running a single validator node. Along this guide we will describe the command arguments and save them using environment variables. 

__0. Remove any existing node directory__  
Start by choosing a directory name, like `~/provider` to store the provider chain node files.

```
PROV_NODE_DIR=~/provider-coordinator
rm -rf $PROV_NODE_DIR
pkill -f interchain-security-pd
```

<br/><br/>
    
    
__1. Create an initial genesis__  
The command below initializes the node's configuration files along with a initial genesis file (`${PROV_NODE_DIR}/config/genesis.json`). The `$PROV_NODE_DIR` argument is a public moniker that will identify your validator, i.e. `provider-coordinator`). Additionally, in this guide the provider and consumer chains id are self-titled but can be changed arbitrarly.

```
PROV_NODE_MONIKER=coordinator
PROV_NODE_DIR=provider-coordinator
PROV_CHAIN_ID=provider

interchain-security-pd init $PROV_NODE_MONIKER --chain-id $PROV_CHAIN_ID --home $PROV_NODE_DIR
```  

* *If you want to make any updates to the genesis, it is a good opportunity to make these updates now.*<br/><br/>

<br/><br/>
   
__2. Reduce proposal voting period__  
This command will shorten the voting period to 3 minutes in order to make pass a consumer chain proposal.

```
jq ".app_state.gov.voting_params.voting_period = \"180s\"" \
    ${PROV_NODE_DIR}/config/genesis.json > ${PROV_NODE_DIR}/edited_genesis.json

mv ${PROV_NODE_DIR}/edited_genesis.json ${PROV_NODE_DIR}/config/genesis.json
```  

<br/><br/>

__3. Create an account keypair__  
This following step creates a public/private keypair and stores it under the given keyname of your choice. The output is also exported into a json file for later use.  
```
PROV_KEY=provider-key
interchain-security-pd keys add $PROV_KEY --home $PROV_NODE_DIR \
    --keyring-backend test --output json > ${PROV_NODE_DIR}/${PROV_KEY}.json 2>&1
```
<br/><br/>

__4. Add funds to account__  
To set an initial account into the genesis states use the command bellow. It will allocates `1000000000` "stake" tokens to our local account.
```
# Get local account address
PROV_ACCOUNT_ADDR=$(jq -r .address ${PROV_NODE_DIR}/${PROV_KEY}.json)

$ Add tokens
interchain-security-pd add-genesis-account $PROV_ACCOUNT_ADDR 1000000000stake \
    --keyring-backend test --home $PROV_NODE_DIR
```
<br/><br/>

__5. Generate a validator transaction__  
To get our validator signing the genesis block (and to agree that this is the correct genesis starting point) and stake `100000000` stake tokens (1/100 of the token balance) executes the following command:  

```
interchain-security-pd gentx $PROV_KEY 100000000stake \
    --keyring-backend test \
    --moniker $PROV_NODE_MONIKER \
    --chain-id $PROV_CHAIN_ID \
    --home $PROV_NODE_DIR
```  

*This command generates a node keypair and use it to sign another "gentx" transaction file. Both files a stored in the `${PROV_NODE_DIR}/config/` folder*   
<br/><br/>

__6. Build the complete genesis__  
This command appends the gentx data into the genesis states.  

```
interchain-security-pd collect-gentxs --home $PROV_NODE_DIR \
    --gentx-dir ${PROV_NODE_DIR}/config/gentx/
```  
<br/><br/>

__7. Setup client RPC endpoint__  
This command changes the default RPC client endpoint port of our node. It is exposed by Tendermint and allows us to query the chains' states and to submit transactions.
    
```
MY_IP=$(host -4 myip.opendns.com resolver1.opendns.com | grep "address" | awk '{print $4}')
    
sed -i -r "/node =/ s/= .*/= \"tcp:\/\/${MY_IP}:26658\"/" \
    ${PROV_NODE_DIR}/config/client.toml
```
<br/><br/>  

__8. Start the Provider chain__  
Run the local node using the following command:
```
interchain-security-pd start --home $PROV_NODE_DIR \
        --rpc.laddr tcp://${MY_IP}:26658 \
        --grpc.address ${MY_IP}:9091 \
        --address tcp://${MY_IP}:26655 \
        --p2p.laddr tcp://${MY_IP}:26656 \
        --grpc-web.enable=false \
        &> ${PROV_NODE_DIR}/logs &
```
*Check the node deamon logs using `tail -f ${PROV_NODE_DIR}/logs`*    

Query the chain to verify your local node appears in the validators list.  

`interchain-security-pd q staking validators --home $PROV_NODE_DIR`

* *If you are running a coordinator node on a linux-like machine you might need to increase the file open limit using this command:
    `ulimit -n 4096` in order that Tendermint runs without limitations.*
---

### Consumer chain proposal  

These following steps show how to create a consumer chain using the governance and CCV modules enabled in the provider chain we setup before.

__1. Create a consumer chain proposal on the provider__  
Create a governance proposal for a new consumer chain by executing the command above.
```
tee ${PROV_NODE_DIR}/consumer-proposal.json<<EOF
{
    "title": "Create consumer chain",
    "description": "Gonna be a great chain",
    "chain_id": "consumer", 
    "initial_height": {
        "revision_height": 1
    },
    "genesis_hash": "Z2VuX2hhc2g=",
    "binary_hash": "YmluX2hhc2g=",
    "spawn_time": "2022-03-11T09:02:14.718477-08:00",
    "deposit": "10000001stake"
}
EOF
``` 

* *Note that each consumer chain project is expected to have its a different binary and genesis file. Therefore this proposal's `genesis_hash` and `binary_hash` fields are irrelevant in the context of this tutorial. Note that the "spawn_time" should be in the past in order to be able to start the consumer chain immediately.*

<br/><br/>

__2. Submit proposal for the consumer chain to the provider chain__  
This command below will create a governance proposal and allow us to vote for it.
```
#create proposal
interchain-security-pd tx gov submit-proposal \
       create-consumer-chain ${PROV_NODE_DIR}/consumer-proposal.json \
       --keyring-backend test \
       --chain-id $PROV_CHAIN_ID \
       --from $PROV_KEY \
       --home $PROV_NODE_DIR \
       -b block

#vote yes
interchain-security-pd tx gov vote 1 yes --from $PROV_KEY \
       --keyring-backend test --chain-id $PROV_CHAIN_ID --home $PROV_NODE_DIR -b block

#Verify that the proposal status is now `PROPOSAL_STATUS_PASSED`
interchain-security-pd q gov proposal 1 --home $PROV_NODE_DIR
```

---

### Consumer chain setup

This steps show how to setup and to run a consumer chain validator. Note that you must use a different folder to create the consumer chain local node, e.g. ~/consumer.  

__0. Remove network directory__  

```
CONS_NODE_DIR=~/consumer-coordinator
rm -rf $CONS_NODE_DIR
pkill -f interchain-security-cd

```
<br/><br/>  
  
__1. Create an initial genesis__  
Create the initial genesis file (`${CONS_NODE_DIR}/config/genesis.json`) with the following command:
  
```
CONS_NODE_MONIKER=coordinator
CONS_CHAIN_ID=consumer
interchain-security-cd init $CONS_NODE_MONIKER --chain-id $CONS_CHAIN_ID --home $CONS_NODE_DIR
```  
<br/><br/>

__2. Create an account keypair__  
As for the provider chain, this command below will create an account keypair and store into a json file.

```
CONS_KEY=consumer-key
interchain-security-cd keys add $CONS_KEY --home $CONS_NODE_DIR \
    --keyring-backend test --output json > ${CONS_NODE_DIR}/${CONS_KEY}.json 2>&1
```  
<br/><br/>

__3. Add account to genesis states__  
To set an initial account into the chain genesis states using the following command. It will allocates `1000000000` "stake" tokens to our local account.

```
#Get local account address
CONS_ACCOUNT_ADDR=$(jq -r .address ${CONS_NODE_DIR}/${CONS_KEY}.json)

#Add account address to genesis
interchain-security-cd add-genesis-account $CONS_ACCOUNT_ADDR 1000000000stake \
    --keyring-backend test --home $CONS_NODE_DIR
 ```  
<br/><br/>  

__4. Get the genesis consumer chain state from the provider chain__  
The CCV genesis states of the consumer chain are retrieved using the query below.  

```
interchain-security-pd query provider consumer-genesis $CONS_CHAIN_ID \
    --home $PROV_NODE_DIR -o json > ccvconsumer_genesis.json
```

Insert the CCV states into the initial local node genesis file using this command below.  

```
jq -s '.[0].app_state.ccvconsumer = .[1] | .[0]' ${CONS_NODE_DIR}/config/genesis.json ccvconsumer_genesis.json > \
      ${CONS_NODE_DIR}/edited_genesis.json 

mv ${CONS_NODE_DIR}/edited_genesis.json ${CONS_NODE_DIR}/config/genesis.json &&
    rm ccvconsumer_genesis.json
```
<br/><br/>

__5. Copy the validator keypair__  
During the consumer chain initialization, its validator set is populated with the unique provider chain validator. It entails that our consumer chain node is required to run using the same validator info in order to produce blocks. Hence, we have to copy the validator node keypair files into the local consumer chain node folder.

```
echo '{"height": "0","round": 0,"step": 0}' > ${CONS_NODE_DIR}/data/priv_validator_state.json  
cp ${PROV_NODE_DIR}/config/priv_validator_key.json ${CONS_NODE_DIR}/config/priv_validator_key.json  
cp ${PROV_NODE_DIR}/config/node_key.json ${CONS_NODE_DIR}/config/node_key.json
```
 <br/><br/>

__7. Setup client RPC endpoint__  
This command updates the consumer node RPC client config and allow to query the chain states as explained in the [section above](#provider-chain-setup/).  
  
`sed -i -r "/node =/ s/= .*/= \"tcp:\/\/${MY_IP}:26648\"/" ${CONS_NODE_DIR}/config/client.toml`
<br/><br/>

__8. Start the Consumer chain__  
Run the local node using the following command:  
```
# consumer local node use the following command
interchain-security-cd start --home $CONS_NODE_DIR \
        --rpc.laddr tcp://${MY_IP}:26648 \
        --grpc.address ${MY_IP}:9081 \
        --address tcp://${MY_IP}:26645 \
        --p2p.laddr tcp://${MY_IP}:26646 \
        --grpc-web.enable=false \
        &> ${CONS_NODE_DIR}/logs &
```

---
  
__Setup IBC-Relayer__  
These steps guide your through the IBC-Relayer setup in order to have the CCV IBC packet relayed betwen provider and consumer chains.
__1. Create the Hermes configuration file__  
Execute the following comman to create an Hermes relayer config file.  
    
```
tee ~/.hermes/config.toml<<EOF
[global]
 log_level = "info"

[[chains]]
account_prefix = "cosmos"
clock_drift = "5s"
gas_multiplier = 1.1
grpc_addr = "tcp://${MY_IP}:9081"
id = "$CONS_CHAIN_ID"
key_name = "relayer"
max_gas = 2000000
rpc_addr = "http://${MY_IP}:26648"
rpc_timeout = "10s"
store_prefix = "ibc"
trusting_period = "14days"
websocket_addr = "ws://${MY_IP}:26648/websocket"

[chains.gas_price]
       denom = "stake"
       price = 0.00

[chains.trust_threshold]
       denominator = "3"
       numerator = "1"

[[chains]]
account_prefix = "cosmos"
clock_drift = "5s"
gas_multiplier = 1.1
grpc_addr = "tcp://${MY_IP}:9091"
id = "$PROV_CHAIN_ID"
key_name = "relayer"
max_gas = 2000000
rpc_addr = "http://${MY_IP}:26658"
rpc_timeout = "10s"
store_prefix = "ibc"
trusting_period = "14days"
websocket_addr = "ws://${MY_IP}:26658/websocket"

[chains.gas_price]
       denom = "stake"
       price = 0.00

[chains.trust_threshold]
       denominator = "3"
       numerator = "1"
EOF
```
<br/><br/>
  
__2. Import keypair accounts to the IBC-Relayer__  
Import the acount keypairs to the relayer using the following command.  
```
#Delete all previous keys in relayer
hermes keys delete --chain consumer --all
hermes keys delete --chain provider --all

#Import accounts key
hermes keys add --key-file  ${CONS_NODE_DIR}/${CONS_KEY}.json --chain consumer
hermes keys add --key-file  ${PROV_NODE_DIR}/${PROV_KEY}.json --chain provider
```

<br/><br/>

__3. Create connection and chanel__  
These commands below establish the IBC connection and channel between the consumer chain and the provider chain.  
```
hermes create connection \
     --a-chain consumer \
    --a-client 07-tendermint-0 \
    --b-client 07-tendermint-0

hermes create channel \
    --a-chain consumer \
    --a-port consumer \
    --b-port provider \
    --order ordered \
    --channel-version 1 \
    --a-connection connection-0
```  
<br/><br/>

__4. Start Hermes__  
The command bellow run the Hermes daemon in listen-mode.  
    
```
pkill -f hermes    
hermes --json start &> ~/.hermes/logs &
```

<br/><br/>

---

### Test the CCV protocol
These optional steps show you how CCV updates the consumer chain validator-set voting power. To do so, delegate some tokens to the validator on the provider chain and verify that the consumer chain validator-set is updated.

__1. Delegate tokens__  
```
# Get validator delegations
DELEGATIONS=$(interchain-security-pd q staking delegations \
  $(jq -r .address ${PROV_NODE_DIR}/${PROV_KEY}.json) --home $PROV_NODE_DIR -o json)

# Get validator operator address
OPERATOR_ADDR=$(echo $DELEGATIONS | jq -r '.delegation_responses[0].delegation.validator_address')

# Delegate tokens
interchain-security-pd tx staking delegate $OPERATOR_ADDR 1000000stake \
                --from $PROV_KEY \
                --keyring-backend test \
                --home $PROV_NODE_DIR \
                --chain-id $PROV_CHAIN_ID \
                -y -b block
```
<br/><br/>

__2. Verify the chains validator-set__  
This commands below will print the updated validator consensus info.

```
# Query provider chain valset
interchain-security-pd q tendermint-validator-set --home $PROV_NODE_DIR
    
# Query consumer chain valset    
interchain-security-cd q tendermint-validator-set --home $CONS_NODE_DIR
```
