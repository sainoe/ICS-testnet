#!/bin/bash
set -eux 

HOME_DIR=""
USERNAME="coordinator"

DELEGATIONS=$(interchain-security-pd q staking delegations \
	$(jq -r .address ${HOME_DIR}/provider/${USERNAME}_prov_keypair.json) \
	--home ${HOME_DIR}/provider -o json)

OPERATOR_ADDR=$(echo $DELEGATIONS | jq -r '.delegation_responses[0].delegation.validator_address')

interchain-security-pd tx staking delegate $OPERATOR_ADDR 1000000stake \
       	--from ${USERNAME} \
       	--keyring-backend test \
       	--home ${HOME_DIR}/provider \
       	--chain-id provider \
		-y -b block
    
