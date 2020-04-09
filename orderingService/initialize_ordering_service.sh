#!/bin/bash
#
#####################################################################################################################
# DESCRIPTION                                                                                                       #
# This script intialize an ordering service. It creates the necessary genesis block and starts the                  #
# ordering node with dockor compose.                                                                                #
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
### Name of the profile defined in the configtx.yaml ###
CONFIG_PROFILE=OneOrgOrdererGenesis
### Name of the genesis file which gets generated with configtxgen ###
OUTPUT_FILE=../configTransactions/genesis.block
### Name of the system channel ###
CHANNEL_ID=nutrisafesystemchannel
### Docker-compose file ###
DOCKER_COMPOSE_FILE=docker_compose_orderer_unibw.yaml
### Docker services to start ###
DOCKER_SERVICES="orderer.unibw.de orderer1.unibw.de orderer2.unibw.de"
### The fabric configuration path has to be set to the configtx.yaml ###
CFG_PATH=../config

#####################################################################################################################
# Code                                                                                                              #
#####################################################################################################################
 
# Necessary operation for configtxgen #
export FABRIC_CFG_PATH=$CFG_PATH


# Remove previous config transactions #

if [ -f  $OUTPUT_FILE ]; then
  rm $OUTPUT_FILE
fi
if [ "$?" -ne 0 ]; then
  echo "Failed to remove previous genesis block..."
  exit 1
fi


# generate genesis block for orderer
configtxgen -profile $CONFIG_PROFILE -outputBlock $OUTPUT_FILE -channelID $CHANNEL_ID
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

docker-compose -f $DOCKER_COMPOSE_FILE up -d $DOCKER_SERVICES
