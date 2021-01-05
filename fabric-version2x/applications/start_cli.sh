#!/bin/bash
#
#####################################################################################################################
# Description
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
### Path the docker-compose file ### 
DOCKER_COMPOSE_FILE=./docker_compose_cli_unibw.yaml
### Services to start ###
DOCKER_SERVICES=cli.unibw.de


#####################################################################################################################
# Code                                                                                                              #
#####################################################################################################################

# -------------------------------------------------------------------------------------------------------------------
# Section:      printHelp()
# Description:  Print the usage message
# -------------------------------------------------------------------------------------------------------------------
function printHelp() {
  echo "Usage: "
  echo "  create_cli.sh [-f <Path to docker compose cli .yaml File>] [-d <cli orderer domainname>]"
  echo "    -f <Path to docker compose cli .yaml File> - specify yaml path"
  echo "    -d <cli orderer domainname> - cli orderer domainname"
  echo "  create_cli.sh -h (print this message)"
}

# -------------------------------------------------------------------------------------------------------------------
# Section:      Parameters
# Description:  List of script parameters
# -------------------------------------------------------------------------------------------------------------------
while getopts "h?d:f:x" opt; do
  case "$opt" in
  h | \?)
    printHelp
    exit 0
    ;;
  f)
   CLI_YAML_FILE=$OPTARG
    ;;
  d)
    CLI_ORDERER=$OPTARG
    ;;
  esac
done

# -------------------------------------------------------------------------------------------------------------------
# Section:      docker-compose, docker
# Description:  Docker-Compose, docker
# Parameter:    $PATH_CONFIG_DIR
# Example:      start_cli.sh -f ./docker_compose_cli_unibw.yaml -d cliUnibwOrderer
# -------------------------------------------------------------------------------------------------------------------
docker-compose -f $DOCKER_COMPOSE_FILE up -d $DOCKER_SERVICES
docker ps -a


