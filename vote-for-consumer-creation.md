This command will let you vote for a proposal to create a second consumer chain using the CLI


1. See proposal on the blockchain
```
PROV_NODE_DIR=~/provider

interchain-security-pd q gov proposal 8 --home $PROV_NODE_DIR
```
You should see a proposal called "Create consumer chain 2".

2. Check the votes

```
interchain-security-pd q gov tally 8 --home $PROV_NODE_DIR
```

3. Now vote for the proposal

```
PROP_ID=8
PROV_KEY=provider-key
PROV_CHAIN_ID=provider

interchain-security-pd tx gov vote $PROP_ID yes --from $PROV_KEY \
       --keyring-backend test --chain-id $PROV_CHAIN_ID --home $PROV_NODE_DIR -b block -y
```

4. Check that your vote was added

```
interchain-security-pd q gov tally 8 --home $PROV_NODE_DIR
```
