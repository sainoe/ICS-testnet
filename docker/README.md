# Interchain Security Testnet

This directory contains a dockerfile and some scripts to deploy a Interchain Security Testnet in a Docker container.
It enables to spawn a provider chain, a consumer chains and a IBC relayer (Hermes V0.15).
For the sake of simplicity, both provider and consumer chains run a single node chorum.
The cross chain validation protocol specification is available [here](https://github.com/cosmos/ibc/tree/main/spec/app/ics-028-cross-chain-validation).

<br/>

## Instructions

### Build Docker image
`docker build --tag is-testnet .`

### Start Docker container
`make run-tesnet`

<br/>

## Test the CCV module
Operations changing the provider chain's voting power, for instance a token delegation, trigger the relaying of IBC packets to be relayed from the provider chain to the consumer chain .
Below are a some prepared commands to interact with the testnet container and get you started with some tests.

```
#Run/Reboot IS-Tesnet from scratch
make run-tesnet

#Display the chains and relayer logs
make provider-logs
make consumer-logs
make relayer-logs

#Delegate tokens
make delegate

#Get the chains valset 
make provider-valset
make consumer-valset

#Restart the chains from genesis
make restart-consumer
make restart-provider

#Restart the relayer
make restart-relayer
```

### TODO
- Add script to add new participants
