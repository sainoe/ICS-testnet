

```
DELEGATIONS=$(interchain-security-pd q staking delegations $(jq -r .address ${PROV_NODE_DIR}/${PROV_KEY}.json) --home $PROV_NODE_DIR -o json)
OPERATOR_ADDR=$(echo $DELEGATIONS | jq -r '.delegation_responses[0].delegation.validator_address')

interchain-security-pd tx staking unbond $OPERATOR_ADDR 2000000stake \
                --from ${PROV_KEY} \
                --keyring-backend test \
                --home $PROV_NODE_DIR \
                --chain-id $PROV_CHAIN_ID \
                -y -b block
```

Check that you are not in the validator set any more

```
# Get validator consensus address
VALCONS_ADDR=$(interchain-security-pd tendermint show-address --home $PROV_NODE_DIR)
        
# Query the chains validator set
interchain-security-pd q tendermint-validator-set --home $PROV_NODE_DIR | grep -A11 $VALCONS_ADDR
  
interchain-security-cd q tendermint-validator-set --home $CONS_NODE_DIR | grep -A11 $VALCONS_ADDR
```

After the unbonding period, check that you have your money back

```
interchain-security-pd q bank balances ${ACCOUNT_ADDR} --home $PROV_NODE_DIR
```
