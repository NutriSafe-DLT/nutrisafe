#!/bin/bash
# Script to instantiate chaincode
cp $FABRIC_CFG_PATH/core.yaml /vars/core.yaml
cd /vars
export FABRIC_CFG_PATH=/vars
CHANNEL_NAME="cheese"



# 1. Fetch the channel configuration
peer channel fetch config config_block.pb -o $ORDERER_ADDRESS \
  --cafile $ORDERER_TLS_CA --tls -c $CHANNEL_NAME

# 2. Translate the configuration into json format
configtxlator proto_decode --input config_block.pb --type common.Block \
  | jq .data.data[0].payload.data.config > $CHANNEL_NAME_current_config.json

# MANUELL

# 3. Translate the current config in json format to protobuf format
configtxlator proto_encode --input $CHANNEL_NAME"_current_config.json" \
  --type common.Config --output config.pb

# 4. Translate the desired config in json format to protobuf format
configtxlator proto_encode --input $CHANNEL_NAME"_config.json" \
  --type common.Config --output modified_config.pb

# 5. Calculate the delta of the current config and desired config
configtxlator compute_update --channel_id $CHANNEL_NAME \
  --original config.pb --updated modified_config.pb \
  --output $CHANNEL_NAME"_update.pb"

# 6. Decode the delta of the config to json format
configtxlator proto_decode --input $CHANNEL_NAME_update.pb \
  --type common.ConfigUpdate | jq . > $CHANNEL_NAME_update.json

# 7. Now wrap of the delta config to fabric envelop block
echo '{"payload":{"header":{"channel_header":{"channel_id":"$CHANNEL_NAME", "type":2}},"data":{"config_update":'$(cat $CHANNEL_NAME_update.json)'}}}' | jq . > $CHANNEL_NAME_update_envelope.json

# 8. Encode the json format into protobuf format
configtxlator proto_encode --input $CHANNEL_NAME_update_envelope.json \
  --type common.Envelope --output $CHANNEL_NAME"_update_envelope.pb"

# 9. Need to sign channel update envelop by each org admin
for org in peerorgs ;
 set signpeer = allpeers|selectattr('org', 'equalto', org)|list|random %}
export CORE_PEER_LOCALMSPID={{ signpeer.mspid }}
export CORE_PEER_TLS_ROOTCERT_FILE=/vars/keyfiles/peerOrganizations/{{ signpeer.org }}/peers/{{ signpeer.fullname }}/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/vars/keyfiles/peerOrganizations/{{ signpeer.org }}/users/Admin@{{ signpeer.org }}/msp
export CORE_PEER_ADDRESS={{ signpeer.url }}:{{ signpeer.port }}

peer channel signconfigtx -f $CHANNEL_NAME"_update_envelope.pb"

{% endfor %}