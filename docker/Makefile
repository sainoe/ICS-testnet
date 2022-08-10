#!/usr/bin/make -f

run-testnet:
	docker stop $$(docker ps -aq)
	docker rm $$(docker ps -aq)
	docker run -t -d is
	docker exec -it $$(docker ps -aq) /root/scripts/is-testnet-v2.sh

provider-logs:
	docker exec -it $$(docker ps -q) tail -f /provider/logs

provider-valset:
	docker exec -it $$(docker ps -q) interchain-security-pd q tendermint-validator-set --home /provider

consumer-valset:
	docker exec -it $$(docker ps -q) interchain-security-cd q tendermint-validator-set --home /consumer

consumer-logs:
	docker exec -it $$(docker ps -q) tail -f /consumer/logs

relayer-logs:
	docker exec -it $$(docker ps -q) tail -f /root/.hermes/logs

delegate:
	docker exec -it $$(docker ps -q) /root/scripts/delegate.sh

restart-consumer:
	docker exec -it $$(docker ps -q) /root/scripts/restart-consumer.sh

restart-provider:
	docker exec $$(docker ps -q) /root/scripts/restart-provider.sh

restart-relayer:
	docker exec $$(docker ps -q) /root/scripts/relay.sh

start-provider:
	docker exec $$(docker ps -q) /root/scripts/start-provider.sh