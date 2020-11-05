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

### Stop all docker containers
docker stop $(docker ps -aq)

### Remove all docker containers
docker rm $(docker ps -aq)

### Remove old chaincode images
docker rmi $(docker images | grep dev | tr -s ' ' | cut -d ' ' -f 3)

### Remove all files from configTransactions
cd configTransactions/
shopt -s extglob
su rm !(README.md)

echo "See you next time! 👋"
