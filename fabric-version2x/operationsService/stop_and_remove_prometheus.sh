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

prometheus_container_name="ns_prometheus"

echo "Stopping container $prometheus_container_name.."
docker stop $prometheus_container_name
echo "Removing container $prometheus_container_name.."
docker rm $prometheus_container_name
