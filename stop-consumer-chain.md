

This command will let you vote for a proposal to stop a consumer chain using the CLI

0. Check the state of the IBC channel used by the CCV protocol. You can see that it is still running because the consumer chain is still running.

```
PROV_NODE_DIR=~/provider
PROV_CHAIN_ID=provider
CHANNEL_ID=channel-0

interchain-security-pd q ibc channel end $PROV_CHAIN_ID $CHANNEL_ID --home $PROV_NODE_DIR 
```

1. See proposals on the blockchain
```
interchain-security-pd q gov proposals --home $PROV_NODE_DIR
```
You should see a proposal called "Stop the first consumer", with `chain_id: consumer` Check what the `proposal_id` is, and input it as `PROP_ID` below.

2. Now vote for the proposal

```
PROP_ID=9
PROV_KEY=provider-key

interchain-security-pd tx gov vote $PROP_ID yes --from $PROV_KEY \
       --keyring-backend test --chain-id $PROV_CHAIN_ID --home $PROV_NODE_DIR -b block -y
```

Check that your vote was added to the proposals total yes votes:

```
interchain-security-pd q gov tally 9 --home $PROV_NODE_DIR
```

*Once the voting period is over*

3. Verify that the proposal passed and check the IBC channel's state again

```
interchain-security-pd q gov proposal PROP_ID=3 --home ${PROV_NODE_DIR}
interchain-security-pd q ibc channel end $PROV_CHAIN_ID $CHANNEL_ID --home $PROV_NODE_DIR 
```

It should have been updated to "STATE_CLOSED"


4. Check that the consumer chain has stopped
```
CONS_NODE_DIR=~/consumer
cat ${CONS_NODE_DIR}/logs | grep -m 1 "shutdown consumer chain since it is not secured anymore"
```

You will see where the consumer chain stopped itself once the channel was closed. For example: `4:46PM ERR CCV channel "channel-0" was closed - shutdown consumer chain since it is not secured anymore`
