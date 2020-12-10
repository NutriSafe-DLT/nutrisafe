#!/bin/bash
#
#####################################################################################################################
# Description                                                                                                       #
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

### Path to the docker-compose file ###
DOCKER_COMPOSE_FILE=docker_compose_peer_cli_couchdb_deoni.yaml

### Docker Services to start ###
DOCKER_SERVICES="peer0.deoni.de cli.deoni.de couchdb.deoni.de peer0.salers.de cli.salers.de couchdb.salers.de peer0.brangus.de cli.brangus.de couchdb.brangus.de peer0.pinzgauer.de cli.pinzgauer.de couchdb.pinzgauer.de peer0.tuxer.de cli.tuxer.de couchdb.tuxer.de peer0.authority.de cli.authority.de couchdb.authority.de peer0.schwarzfuss.de cli.schwarzfuss.de couchdb.schwarzfuss.de peer0.duroc.de cli.duroc.de couchdb.duroc.de"


#####################################################################################################################
# Code                                                                                                              #
#####################################################################################################################

# -------------------------------------------------------------------------------------------------------------------
# Section:      printHelp()
# Description:  Print the usage message
# -------------------------------------------------------------------------------------------------------------------
function printHelp() {
  echo "Usage: "
  echo "  create_peer.sh [-f <path for .yaml file>] [-d <peer domain name] [-c <channelID name>]>"
  echo "    -f <Path to .yaml File> - specify yaml path"
  echo "    -d <Peer Domainname> - peer domain address"
  echo "    -c <ChannelID Name> - ChannelID Name"
  echo "  create_peer.sh -h (print this message)"
}

# -------------------------------------------------------------------------------------------------------------------
# Section:      Parameters
# Description:  List of script parameters
# -------------------------------------------------------------------------------------------------------------------
while getopts "h?d:f:c:p:x" opt; do
  case "$opt" in
  h | \?)
    printHelp
    exit 0
    ;;
  f)
   DOCKER_COMPOSE_FILE=$OPTARG
    ;;
  d)
   DOCKER_SERVICES=$OPTARG
    ;;
  esac
done

# -------------------------------------------------------------------------------------------------------------------
# Section:      docker-compose
# Description:  Create new peer
# Parameter:    $PATH_TO_YAML_FILE
#               $PEER_DOMAIN_NAME
#               $CHANNEL_ID_NAME
# Example:      create_peer.sh -f /pathTo/file.yaml -d peer0.unibw.de -c peerCl
# -------------------------------------------------------------------------------------------------------------------
docker-compose -f $DOCKER_COMPOSE_FILE up -d $DOCKER_SERVICES
docker ps -a
