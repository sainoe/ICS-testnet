# Interchain-Security Testnet

## September 7th, 2022

Welcome to the testnet everyone! There are two sets of instructions for you today. You should be able to follow these to add yourself to the testnet.

**[Join the testnet](https://github.com/sainoe/ICS-testnet/blob/main/join-testnet-tutorial.md)**

These instructions will get you set up on the provider chain, and a consumer chain which we already have running. If you have any problems, message jehan-classic#4116 or Simon | Informal#7212 on the Discord channel.

**[Unjail](https://github.com/sainoe/ICS-testnet/blob/main/unjail.md)**

In case you get jailed because your provider or consumer nodes go down, you can follow these instructions to get back into the validator set.

We will have a call at 8am-10am PST tomorrow, September 8th, 2022. In this call we can help you get set up if you need help. 

## September 8th, 2022

Today we tested the effect that ICS can have on the provider chain's unbonding period, if a consumer chain does not finish unbonding before the provider.

- Simon delegated 60 tokens to Hypha, which brought their power to 32.8%
- The power changed on the consumer chain as well.
- Simon then undelegated 40 tokens, bringing the power back down, but above what it had been before.
- Looking at the unbonding delegation entry, we see that the completion_time is on Sunday. This is when the provider chain's unbonding period ends, and without interchain security, when Simon would get his tokens back. But, with interchain security, the unbonding_on_hold flag is set to true until the consumer chain tells the provider over IBC that its unbonding period is also over. This will happen on Monday, at which point Simon will get his tokens back.
- We'll update on the progress of this unbonding on Sunday and Monday.


## September 9th, 2022
Today, we created a proposal for the second consumer chain! You can follow these instructions: https://github.com/sainoe/ICS-testnet/blob/main/vote-for-consumer-creation.md to vote for it. 

In this proposal, we did not fill out the `binary_hash` and `genesis_hash` fields, and didn't link a genesis file in the description. This doesn't matter for actual operation but it would have been interesting to have testnet participants try hashing and verifying these fields themselves. However, these fields are only for signaling purposes, so the consumer chain will have no problem starting on Monday. The only pieces of the proposal that are actually used by the provider chain to start the consumer are the `chain_id`, `initial_height` and `spawn_time` fields.

On Monday, we will start the consumer chain, hopefully on our call. Nobody will get slashed for downtime until the chain actually starts producing blocks, so there will be a little bit of leeway if you don't make the call.

Maybe later on in this testnet, once we've gotten past some of the other tasks, we can try a more realistic consumer chain proposal. This will include verification of the binary and genesis, plus a spawn time in the future to allow validators to coordinate around the start of the consumer chain.
