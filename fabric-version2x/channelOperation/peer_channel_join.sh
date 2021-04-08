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
# Author(s): Tim Hoiß, Andreas Hermann
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

### PATH to TLS CERT Orderer Node inside the above mentioned container  ###
TLS_CERT_ORDERER="/etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem"

# -------------------------------------------------------------------------------------------------------------------
# Section:      printHelp()
# Description:  Print the usage message
# -------------------------------------------------------------------------------------------------------------------
function printHelp() {
  echo "Usage: "
  echo "  peer_channel_join.sh [-t <Path to TLS Certficate for orderer>] [-n <Docker container name] [-o <Orderer FQDN>] [-c <channelID name>]"
  echo "  peer_channel_join.sh -h (print this message)"
}
# -------------------------------------------------------------------------------------------------------------------
# Section:      Parameters
# Description:  List of script parameters
# -------------------------------------------------------------------------------------------------------------------
while getopts "h?o:c:n:t:" opt; do
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
  t)
    TLS_CERT_ORDERER=$OPTARG
    ;;
  esac
done

#####################################################################################################################
# Code                                                                                                              #
#####################################################################################################################

docker exec $CONTAINER_NAME peer channel fetch oldest -c $CHANNEL_ID -o $ORDERER_ADDRESS --tls --cafile $TLS_CERT_ORDERER
sleep 10
echo "Peer joining Channel/n"
docker exec $CONTAINER_NAME peer channel join -b "./"$CHANNEL_ID"_oldest.block" 

CHANNEL_ID=cheese
