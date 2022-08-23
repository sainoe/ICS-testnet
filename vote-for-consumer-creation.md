This command will let you vote for a proposal to create a second consumer chain using the CLI


1. See proposals on the blockchain
```
PROV_NODE_DIR=~/provider

interchain-security-pd q gov proposals --home $PROV_NODE_DIR
```
You should a proposal called "Create the second consumer chain!". Check what the `proposal_id` is, and input it as `PROP_ID` below.

2. Now vote for the proposal

```
PROP_ID=2
PROV_KEY=provider-key
PROV_CHAIN_ID=provider

interchain-security-pd tx gov vote $PROP_NUMBER yes --from $PROV_KEY \
       --keyring-backend test --chain-id $PROV_CHAIN_ID --home $PROV_NODE_DIR -b block -y
```

