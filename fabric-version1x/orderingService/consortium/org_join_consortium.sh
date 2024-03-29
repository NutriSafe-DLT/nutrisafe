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
# Author(s): Tim Reimers, Andreas Hermann
# NutriSafe Research Project
# Institute for Protection and Dependability
# Department of Computer Science
# Bundeswehr University Munich
#####################################################################################################################


#####################################################################################################################
# Parameters                                                                                                        #
#####################################################################################################################

### The fabric configuration path has to be set to the configtx.yaml ###
CFG_PATH=../../config
### The name of the Organisation specified in the configtx.yaml ###
JOINING_ORGANISATION=Deoni
### Name of the docker container where we executed the commands, it should be a cli container of an organisation ###
### which has the rights to allow an organisation to join the channel.                                           ###
CONTAINER_NAME=cli.unibw.de
### Name of the  channel ###
CHANNEL_ID=nutrisafesystemchannel
### Address of an orderer node ###
ORDERER_ADDRESS=orderer.unibw.de:7050
### Name of the transaction file ###
TRANSACTION_FILE=./$JOINING_ORGANISATION"_update_in_envelope.pb"
### Name of the consortium to be joined ###
CONSORTIUM_NAME=SampleConsortium





#####################################################################################################################
# Code                                                                                                              #
#####################################################################################################################

# Crypto material has to be generated before #


# Set Fabric config Path #
export FABRIC_CFG_PATH=$CFG_PATH


# Generate the json representation of the organisation #
configtxgen -printOrg $JOINING_ORGANISATION > ../../configTransactions/org.json


# Echo all environment variables on the docker container #
#docker exec $CONTAINER_NAME echo $CORE_PEER_MSPCONFIGPATH
#docker exec $CONTAINER_NAME echo $CORE_PEER_LOCALMSPID
#docker exec $CONTAINER_NAME echo $CORE_PEER_TLS_ROOTCERT_FILE
#docker exec $CONTAINER_NAME echo $CORE_PEER_ADDRESS

# Fetch the newest config block on the cli container #
docker exec $CONTAINER_NAME sh -c "peer channel fetch config ./config_block.pb -o $ORDERER_ADDRESS -c $CHANNEL_ID --tls --cafile /etc/hyperledger/msp/orderer/tls/ca.crt "


# Translate the protobuf into json and removing irrelevant parts #
docker exec $CONTAINER_NAME sh -c "configtxlator proto_decode --input ./config_block.pb --type common.Block | jq .data.data[0].payload.data.config > ./config.json"



# Adding the json representation of the adding organisation #
##### Not sure if it's right #####
docker exec $CONTAINER_NAME sh -c "jq -s '.[0] * {\"channel_group\":{\"groups\":{\"Consortiums\":{\"groups\":{\"'$CONSORTIUM_NAME'\":{\"groups\":{\"'$JOINING_ORGANISATION'\":.[1]}}}}}}}' ./config.json ./org.json > ./modified_config.json"


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
docker exec $CONTAINER_NAME sh -c "rm ./org.json"
docker exec $CONTAINER_NAME sh -c "rm ./config_block.pb"
docker exec $CONTAINER_NAME sh -c "rm ./config.json"
docker exec $CONTAINER_NAME sh -c "rm ./modified_config.json"
docker exec $CONTAINER_NAME sh -c "rm ./config.pb"
docker exec $CONTAINER_NAME sh -c "rm ./modified_config.pb"
docker exec $CONTAINER_NAME sh -c "rm ./org_update.pb"
docker exec $CONTAINER_NAME sh -c "rm ./org_update.json"
docker exec $CONTAINER_NAME sh -c "rm ./org_update_in_envelope.json"
