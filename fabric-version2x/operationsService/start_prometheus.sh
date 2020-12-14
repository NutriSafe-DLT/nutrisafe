#!/bin/bash
#
#####################################################################################################################
# DESCRIPTION                                                                                                       #
# This script starts a prometheus and attaches to the nutrisafe network.                                            #
#                                                                                                                   #
#                                                                                                                   #
# This work is licensed under a Creative Commons Attribution 4.0 International License
# (http://creativecommons.org/licenses/by/4.0/).
#
# Author(s): Tim Hoiß, Andreas Hermann, Prabhakar Mishra
# NutriSafe Research Project
# Institute for Protection and Dependability
# Department of Computer Science
# Bundeswehr University Munich
#####################################################################################################################

PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
PROMETHEUS_CONTAINER_NAME="ns_prometheus"

echo -e "\n Starting prometheus.."
docker run -d -p 9090:9090 -v $PARENT_PATH/prometheus.yaml:/prometheus.yaml --name $PROMETHEUS_CONTAINER_NAME  prom/prometheus --config.file=/prometheus.yaml
echo -e "\n Attaching prometheus container to nutrisafe blockchain container.."
docker -v network connect orderingservice_basic $PROMETHEUS_CONTAINER_NAME
