## Unjail tutorial
This command shows you how to unjail your local provider chain validator.


__1. Submit unjail transaction__  
```
PROV_NODE_DIR=~/provider
PROV_CHAIN_ID=provider
PROV_KEY=provider-key


interchain-security-pd tx slashing unjail \
        --from ${PROV_KEY} \
        --keyring-backend test \
        --home $PROV_NODE_DIR \
        --chain-id $PROV_CHAIN_ID \
        -y -b block
```

 <br/><br/>  

__2. Check the updated validator-sets__  
Check that you are not in the validator set again.

```
# Get validator consensus address
VALCONS_ADDR=$(interchain-security-pd tendermint show-address --home $PROV_NODE_DIR)
        
# Query the chains validator set
interchain-security-pd q tendermint-validator-set --home $PROV_NODE_DIR | grep -A11 $VALCONS_ADDR
  
interchain-security-cd q tendermint-validator-set --home $CONS_NODE_DIR | grep -A11 $VALCONS_ADDR
```
