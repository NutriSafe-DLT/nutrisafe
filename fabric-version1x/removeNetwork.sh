#!/bin/bash
#
#####################################################################################################################
# DESCRIPTION                                                                                                       #
# This script starts a network which is configured in the other scripts.                                            #
#                                                                                                                   #
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




#####################################################################################################################
# Code                                                                                                              #
#####################################################################################################################
dockerimages=$(docker ps -aq)
if [[ -n "$dockerimages" ]]; 
then
    ### Stop all docker containers
    docker stop ns_prometheus
    docker rm ns_prometheus
    cd peerOperation/
    docker-compose -f docker_compose_peer_cli_couchdb_deoni.yaml down
    cd ../orderingService/
    docker-compose -f docker_compose_orderer_unibw.yaml down
    cd ../applications/
    docker-compose -f docker_compose_cli_unibw.yaml down
    
    docker stop $dockerimages
    ### Remove all docker containers
    docker rm $dockerimages
    ### Remove old chaincode images
    docker rmi $(docker images | grep dev | tr -s ' ' | cut -d ' ' -f 3)
    cd ..
else
    echo "No docker images to delete..." 
fi


### Remove all files from configTransactions but the README file
cd configTransactions/
shopt -s extglob
rm -f !(README.md)

echo "See you next time! 👋"
