This command will let you vote for a proposal to create a second consumer chain using the CLI


1. See proposal on the blockchain
```
PROV_NODE_DIR=~/provider

interchain-security-pd q gov proposal 4 --home $PROV_NODE_DIR
```
You should a proposal called "Create consumer chain". Check what the `proposal_id` is, and input it as `PROP_ID` below.

2. Now vote for the proposal

```
PROP_ID=4
PROV_KEY=provider-key
PROV_CHAIN_ID=provider

interchain-security-pd tx gov vote $PROP_ID yes --from $PROV_KEY \
       --keyring-backend test --chain-id $PROV_CHAIN_ID --home $PROV_NODE_DIR -b block -y
```

