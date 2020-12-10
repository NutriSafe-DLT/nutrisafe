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
CHANNEL_ID=trackandtrace

### Address of the orderer ###
ORDERER_ADDRESS=orderer.unibw.de:7050


# -------------------------------------------------------------------------------------------------------------------
# Section:      printHelp()
# Description:  Print the usage message
# -------------------------------------------------------------------------------------------------------------------
function printHelp() {
  echo "Usage: "
  echo "  peer_channel_join.sh <[-f <path for .yaml file>]>"
  echo "    TODO"
  echo "  peer_channel_join.sh -h (print this message)"
}
# -------------------------------------------------------------------------------------------------------------------
# Section:      Parameters
# Description:  List of script parameters
# -------------------------------------------------------------------------------------------------------------------
while getopts "h?o:c:n:x" opt; do
  case "$opt" in
  h | \?)
    printHelp
    exit 0
    ;;
  o)
    ORDERER_ADDRESS=$OPTARG
    ;;
  c)
    CHANNEL_ID=$OPTARG
    ;;
  n)
    CONTAINER_NAME=$OPTARG
    ;;
  esac
done

#####################################################################################################################
# Code                                                                                                              #
#####################################################################################################################

docker exec $CONTAINER_NAME peer channel fetch config -c $CHANNEL_ID -o $ORDERER_ADDRESS --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
sleep 10
echo "Peer joining Channel/n"
docker exec $CONTAINER_NAME peer channel join -b "./"$CHANNEL_ID"_config.block" 

CHANNEL_ID=cheese
