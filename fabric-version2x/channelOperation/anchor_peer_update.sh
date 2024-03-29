#!/bin/bash
#
#####################################################################################################################
# DESCRIPTION                                                                                                       #
# This script is creating an transaction with adds an organisation to an existing channel.                          #
# Crypto material has be created before.                                                                            #
# After creating the transaction is has to be signed and committed.                                                 #       
#                                                                                                                   #
# SPDX-License-Identifier: Apache-2.0                                                                               #
#####################################################################################################################


#####################################################################################################################
# Parameters                                                                                                        #
#####################################################################################################################

### The fabric configuration path has to be set to the configtx.yaml ###
CFG_PATH=../config
### The name of the Organisation specified in the configtx.yaml ###
JOINING_ORGANISATION=Salers
### Name of the docker container where we executed the commands, it should be a cli container of an organisation ###
### which has the rights to allow an organisation to join the channel.                                           ###
CONTAINER_NAME=cli.deoni.de
### Name of the  channel ###
CHANNEL_ID=trackandtrace
### Address of an orderer node ###
ORDERER_ADDRESS=orderer.unibw.de:7050
### PATH to TLS CERT Orderer Node inside the above mentioned container  ###
TLS_CERT_ORDERER="/etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem"





#####################################################################################################################
# printHelp()
#####################################################################################################################
function printHelp() {
  echo "Usage: "
  echo "  anchor_peer_update.sh [-o <joining org as defined in configtx.yaml>] [-c <cli container name>] [-i <channelID name>] [-t <tlscert odererer>] [-p <path to configtx.yaml>] [-a <orderer address>]"
  echo "    -h or ? prints this message"
  echo "    -o domain name of joining organization"
  echo "    -c <Docker Container Name>"
  echo "    -i <ChannelID Name> - ChannelID Name"
  echo "    -t <Path to certificate file for orderer> "
  echo "    -p <Path to configtx.yaml> "
  echo "    -a orderer address "
}

#####################################################################################################################
# Code                                                                                                              #
#####################################################################################################################


# Parameters for organization and container
while getopts "h?o:c:i:t:p:a:" opt; do
  case "$opt" in
  h | \?)
    printHelp
    exit 0
    ;;
  o)
    JOINING_ORGANISATION=$OPTARG
    ;;
  c)
    CONTAINER_NAME=$OPTARG
    ;;
  i)
    CHANNEL_ID=$OPTARG
    ;;
  t)
    TLS_CERT_ORDERER=$OPTARG
    ;;
  p)
    CFG_PATH=$OPTARG
    ;;
  a)
    ORDERER_ADDRESS=$OPTARG
    ;;
  esac
done

JOINING_ORGANISATION_LOWER=$(echo ${JOINING_ORGANISATION} | tr '[:upper:]' '[:lower:]')


### Name of the transaction file ###
TRANSACTION_FILE="./"$JOINING_ORGANISATION"_update_in_envelope.pb"

# Set Fabric config Path #
export FABRIC_CFG_PATH=$CFG_PATH


# Fetch the newest config block on the cli container #
docker exec $CONTAINER_NAME sh -c "peer channel fetch config ./config_block.pb -o $ORDERER_ADDRESS -c $CHANNEL_ID --tls --cafile $TLS_CERT_ORDERER"


# Translate the protobuf into json and removing irrelevant parts #
docker exec $CONTAINER_NAME sh -c "configtxlator proto_decode --input ./config_block.pb --type common.Block | jq .data.data[0].payload.data.config > ./config.json"



# Adding the json representation of the adding organisation #
docker exec $CONTAINER_NAME sh -c "jq '.channel_group.groups.Application.groups.'$JOINING_ORGANISATION'.values += {\"AnchorPeers\":{\"mod_policy\": \"Admins\",\"value\":{\"anchor_peers\": [{\"host\": \"peer0.'$JOINING_ORGANISATION_LOWER'.de\",\"port\": 7051}]},\"version\": \"0\"}}' ./config.json > ./modified_config.json"


# enconding both new files to protobufs and computing the update #
docker exec $CONTAINER_NAME sh -c "configtxlator proto_encode --input ./config.json --type common.Config --output ./config.pb"
docker exec $CONTAINER_NAME sh -c "configtxlator proto_encode --input ./modified_config.json --type common.Config --output ./modified_config.pb"
docker exec $CONTAINER_NAME sh -c "configtxlator compute_update --channel_id $CHANNEL_ID --original ./config.pb --updated ./modified_config.pb --output ./org_update.pb"


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
