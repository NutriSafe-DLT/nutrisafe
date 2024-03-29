#!/bin/bash
#
#####################################################################################################################
# DESCRIPTION                                                                                                       #
# This script creates a transaction to add an organisation to an existing channel.                                  #
# Crypto material has be created before.                                                                            #
# After creating the transaction is has to be signed and committed                                                  #
#                                                                                                                   #
# This work is licensed under a Creative Commons Attribution 4.0 International License
# (http://creativecommons.org/licenses/by/4.0/).
#
# Author(s): Tim Hoiß
# NutriSafe Research Project
# Institute for Protection and Dependability
# Department of Computer Science
# Bundeswehr University Munich
#####################################################################################################################


#####################################################################################################################
# Parameters                                                                                                        #
#####################################################################################################################


### Name of the docker container where we executed the commands, it should be a cli container of an organisation ###
### which has the rights to allow an organisation to join the channel.                                           ###
CONTAINER_NAME=cli.unibw.de
### Name of the  channel ###
CHANNEL_ID=nutrisafesystemchannel
### Address of an orderer node ###
ORDERER_ADDRESS=orderer.unibw.de:7050
### Name of the consortium to be created ###
CONSORTIUM_NAME=Logistics
### Name of the transaction file ###
TRANSACTION_FILE=./$CONSORTIUM_NAME"_creation.pb"
### PATH to TLS CERT Orderer Node inside the above mentioned container  ###
TLS_CERT_ORDERER="/etc/hyperledger/msp/orderer/tls/ca.crt"




#####################################################################################################################
# Code                                                                                                              #
#####################################################################################################################

# Crypto material has to be generated before #


# Fetch the newest config block on the cli container #
docker exec $CONTAINER_NAME sh -c "peer channel fetch config ./config_block.pb -o $ORDERER_ADDRESS -c $CHANNEL_ID --tls --cafile $TLS_CERT_ORDERER"


# Translate the protobuf into json and removing irrelevant parts #
docker exec $CONTAINER_NAME sh -c "configtxlator proto_decode --input ./config_block.pb --type common.Block | jq .data.data[0].payload.data.config > ./config.json"



# Adding the json representation of the adding organisation #
docker exec $CONTAINER_NAME sh -c "jq '.channel_group.groups.Consortiums.groups |= . + {\"'$CONSORTIUM_NAME'\":{\"groups\":{},\"mod_policy\":\"/Channel/Orderer/Admins\",\"policies\":{},\"values\":{\"ChannelCreationPolicy\":{\"mod_policy\":\"/Channel/Orderer/Admins\",\"value\":{\"type\":3,\"value\":{\"rule\":\"ANY\",\"sub_policy\":\"Admins\"}},\"version\":\"0\"}},\"version\":\"1\"}}' ./config.json  > ./modified_config.json"



# enconding both new files to protobufs and computing the update #
docker exec $CONTAINER_NAME sh -c "configtxlator proto_encode --input ./config.json --type common.Config --output ./config.pb"
docker exec $CONTAINER_NAME sh -c "configtxlator proto_encode --input ./modified_config.json --type common.Config --output ./modified_config.pb"
docker exec $CONTAINER_NAME sh -c "configtxlator compute_update --channel_id "$CHANNEL_ID" --original ./config.pb --updated ./modified_config.pb --output ./org_update.pb"


# decoding of the differences#
docker exec $CONTAINER_NAME sh -c "configtxlator proto_decode --input ./org_update.pb --type common.ConfigUpdate | jq . > ./org_update.json"


# Adding of the headerinformation #
docker exec $CONTAINER_NAME sh -c "echo '{\"payload\":{\"header\":{\"channel_header\":{\"channel_id\":\"'$CHANNEL_ID'\", \"type\":2}},\"data\":{\"config_update\":'\$(cat ./org_update.json)'}}}' | jq . > ./org_update_in_envelope.json"


# Encoding the file back to protobuf #
docker exec $CONTAINER_NAME sh -c "configtxlator proto_encode --input ./org_update_in_envelope.json --type common.Envelope --output "$TRANSACTION_FILE


# Deleting the files #
docker exec $CONTAINER_NAME sh -c "rm ./config_block.pb"
docker exec $CONTAINER_NAME sh -c "rm ./config.json"
docker exec $CONTAINER_NAME sh -c "rm ./modified_config.json"
docker exec $CONTAINER_NAME sh -c "rm ./config.pb"
docker exec $CONTAINER_NAME sh -c "rm ./modified_config.pb"
docker exec $CONTAINER_NAME sh -c "rm ./org_update.pb"
docker exec $CONTAINER_NAME sh -c "rm ./org_update.json"
docker exec $CONTAINER_NAME sh -c "rm ./org_update_in_envelope.json"
