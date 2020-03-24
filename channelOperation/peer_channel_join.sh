#!/bin/bash
#
#####################################################################################################################
# DESCRIPTION                                                                                                       #
# This script starts a network which is configured in the other scripts.                                            #
#                                                                                                                   #
#
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

### Container of the organisation who wants to join ###
CONTAINER_NAME=cli.deoni.de

### ID of the Channel ###
CHANNEL_ID=cheese

### Address of the orderer ###
ORDERER_ADDRESS=orderer.unibw.de:7050


#####################################################################################################################
# Code                                                                                                              #
#####################################################################################################################

docker exec $CONTAINER_NAME peer channel fetch config -c $CHANNEL_ID -o $ORDERER_ADDRESS --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
sleep 10
docker exec $CONTAINER_NAME peer channel join -b "./"$CHANNEL_ID"_config.block" --tls --cafile /etc/hyperledger/msp/users/admin/tls/ca.crt

CHANNEL_ID=cheese
