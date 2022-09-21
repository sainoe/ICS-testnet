# Interchain-Security Testnet

## September 21st, 2022

Resuming after our weeklong hiatus. We'll be on a more relaxed schedule this week and next, due to the Cosmoverse conference. Work continues to figure out the strange packet relaying bug that we saw last week.

Our task for today is to vote on the stop-consumer-chain proposal. You can find the instructions (here)[https://github.com/sainoe/ICS-testnet/blob/main/stop-consumer-chain.md]. Voting on this is much simpler than the start-consumer-chain proposal was. There is nothing to verify besides checking that the chain-id belongs to a consumer chain that you want to stop.

## September 13th, 2022

Today, we have noticed several irregularities in the testnet. 

First of all, the IBC channel between the provider and the consumer is no longer working. It seems that a packet on the channel caused the Hermes relayer to have a parse error, resulting in the packet not being relayed, and no further packets being relayed because it is an ordered channel.

The Informal Hermes team is looking at this error, and the Stranglove team (thanks danb!) will attempt to set up an instance of go-relayer.

Second, it seems that on the provider chain, only Simon's coordinator node is proposing blocks. This is very odd, especially considering that we didn't touch tendermint at all, and the provider chain is less heavily modified than the consumer.

In good news, we have delegated out the stake on the provider chain to make it decentralized! Each validator has been delegated 10 tokens, bringing Simon's coordinator below 2/3s power. Unfortunately this will not be reflected on the consumer chain until we get this relaying issue figured out.

We also verified that even though the provider's unbonding period is over, Simon's coordinator has not gotten its tokens unbonded, since the consumer chain's unbonding period is not yet over (and even if it was, with the current relaying difficulties, the provider chain wouldn't know!)

## September 12th, 2022

Today, we had to restart the entire testnet because of a complicated bug. We have updated the **[Join the testnet](https://github.com/sainoe/ICS-testnet/blob/main/join-testnet-tutorial.md)** instructions with the new binary release and genesis files. Follow along with these to start a new provider and first consumer chain. It's exactly the same procedure as last time, just with different binary and genesis.

We put up a proposal for a second consumer chain. The voting period is 2 days, so this will hopefully go live on Wednesday the 14th. Please vote for this consumer chain, but please verify it first. There are instructions on how to verify a proposal in the `description` field below. The purpose of these verification steps is to make sure that the consumer chain and binary are good quality and not malicious. In production, this inspection and verification will most likely be done by community members. [Here](https://github.com/sainoe/ICS-testnet/blob/main/vote-for-consumer-creation.md) are the instructions on how to vote for the proposal once you have verified it.

```
- content:
    '@type': /interchain_security.ccv.provider.v1.CreateConsumerChainProposal
    binary_hash: 1a590bd6c2b0e855e11ff3bc307a82dbe6a6487dd7e4a84ed90698c0b072ff96
    chain_id: consumer2
    description: 'This is the proposal to create consumer chain 2. First, verify the
      genesis, download and hash the genesis.json file with the following command:
      ''curl -s https://paste.c-net.org/DriftedSounding > genesis.json; sha256sum
      genesis.json''. The outputted hash should match this proposal''s ''genesis_hash''
      field. Now, you can inspect the genesis file to make sure that everything is
      in order. The ''ccvconsumer'' field is empty. It will be filled in after this
      proposal passes. Next, verify the binary. Follow the steps here https://github.com/sainoe/ICS-testnet/blob/main/join-testnet-tutorial.md#install-the-interchain-security-binary
      to download and build the binary (it is the same one as used for the first consumer
      chain, so if you already have it locally, you can skip downloading and building
      it again). Run this command to get the hash ''sha256sum /root/go/bin/interchain-security-cd'',
      and see that it matches this proposal''s ''binary_hash'' field. Now, you can
      inspect the binary''s source code to make sure that everything is in order,
      and vote yes or no on this proposal.'
    genesis_hash: 6ae334300acc66f31c7c32f7a8f0c996991a6ea35021a3dafcf7d21c8202cad4
    initial_height:
      revision_height: "1"
      revision_number: "0"
    lock_unbonding_on_timeout: false
    spawn_time: "2022-03-11T17:02:14.718477Z"
    title: Create consumer chain 2
  deposit_end_time: "2022-09-14T13:57:05.787056198Z"
  final_tally_result:
    abstain: "0"
    "no": "0"
    no_with_veto: "0"
    "yes": "0"
  proposal_id: "8"
  status: PROPOSAL_STATUS_VOTING_PERIOD
  submit_time: "2022-09-12T13:57:05.787056198Z"
  total_deposit:
  - amount: "10000001"
    denom: stake
  voting_end_time: "2022-09-14T13:57:05.787056198Z"
  voting_start_time: "2022-09-12T13:57:05.787056198Z"
```

We delegated and undelegated from a validator to demonstrate how consumer chains can keep tokens from unbonding. The consumer chain's unbonding period is 2 days, while the provider chain's unbonding period is only 1 day. Tomorrow, we will check back in to see that even though the provider chain's unbonding period is over, the tokens have still not fully unbonded because they are waiting for the consumer chain. The day after tomorrow when the consumer chain unbonding period is over, we will check that the tokens are fully returned.

We will decentralize the stake of this new testnet. We will check who is up tomorrow, and delegate tokens to everyone who is running and unjailed. 

Also, Simply Staking and P2P.org will be helping us demonstrate various aspects of the protocol. P2P.org will have their validator intentionally double sign. We will see that it is removed from the provider validator set as well as the consumer validator set. Simply Staking will unselfbond, demonstrating that their validator is removed from both validator sets as well, and that the tokens do not come back until the consumer unbonding period is over.

## September 9th, 2022

Today, we created a proposal for the second consumer chain! You can follow these instructions: https://github.com/sainoe/ICS-testnet/blob/main/vote-for-consumer-creation.md to vote for it. 

In this proposal, we did not fill out the `binary_hash` and `genesis_hash` fields, and didn't link a genesis file in the description. This doesn't matter for actual operation but it would have been interesting to have testnet participants try hashing and verifying these fields themselves. However, these fields are only for signaling purposes, so the consumer chain will have no problem starting on Monday. The only pieces of the proposal that are actually used by the provider chain to start the consumer are the `chain_id`, `initial_height` and `spawn_time` fields.

On Monday, we will start the consumer chain, hopefully on our call. Nobody will get slashed for downtime until the chain actually starts producing blocks, so there will be a little bit of leeway if you don't make the call.

Maybe later on in this testnet, once we've gotten past some of the other tasks, we can try a more realistic consumer chain proposal. This will include verification of the binary and genesis, plus a spawn time in the future to allow validators to coordinate around the start of the consumer chain.

## September 8th, 2022

Today we tested the effect that ICS can have on the provider chain's unbonding period, if a consumer chain does not finish unbonding before the provider.

- Simon delegated 60 tokens to Hypha, which brought their power to 32.8%
- The power changed on the consumer chain as well.
- Simon then undelegated 40 tokens, bringing the power back down, but above what it had been before.
- Looking at the unbonding delegation entry, we see that the completion_time is on Sunday. This is when the provider chain's unbonding period ends, and without interchain security, when Simon would get his tokens back. But, with interchain security, the unbonding_on_hold flag is set to true until the consumer chain tells the provider over IBC that its unbonding period is also over. This will happen on Monday, at which point Simon will get his tokens back.
- We'll update on the progress of this unbonding on Sunday and Monday.

## September 7th, 2022

Welcome to the testnet everyone! There are two sets of instructions for you today. You should be able to follow these to add yourself to the testnet.

**[Join the testnet](https://github.com/sainoe/ICS-testnet/blob/main/join-testnet-tutorial.md)**

These instructions will get you set up on the provider chain, and a consumer chain which we already have running. If you have any problems, message jehan-classic#4116 or Simon | Informal#7212 on the Discord channel.

**[Unjail](https://github.com/sainoe/ICS-testnet/blob/main/unjail.md)**

In case you get jailed because your provider or consumer nodes go down, you can follow these instructions to get back into the validator set.

We will have a call at 8am-10am PST tomorrow, September 8th, 2022. In this call we can help you get set up if you need help. 
