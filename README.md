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
