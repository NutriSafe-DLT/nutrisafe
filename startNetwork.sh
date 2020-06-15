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
# Author(s): Tim Hoiß, Andreas Hermann
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

### All the scripts have to be executed in their directory ###

### Starting the ordering service with one ordering node ###
### Use of CONFIG_PROFILE, OUTPUT_FILE, CHANNEL_ID, DOCKER_COMPOSE_FILE, DOCKER_SERVICES, CFG_PATH ###
echo "Starting intitialize ordering service"
cd orderingService/
./initialize_ordering_service.sh
echo "Sleeping for 5 seconds"
sleep 5s

### Starting an cli container for the ordering organization to interact with the network ###
### Use of DOCKER_COMPOSE_FILE, DOCKER_SERVICES ###
echo -e "\n \n Starting cli container"
cd ../applications/
./create_cli.sh

### Organisation joining an existing consortium ###
### Use of CFG_PATH, JOINING_ORGANISATION, CONTAINER_NAME, CHANNEL_ID, ORDERER_ADDRESS, TRANSACTION_FILE, CONSORTIUM_NAME ###
echo -e "\n \n Organisation joining consortium"
cd ../orderingService/consortium/
./org_join_consortium.sh
docker exec cli.unibw.de peer channel update -f Deoni_update_in_envelope.pb -c nutrisafesystemchannel -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/orderer/tls/ca.crt

### Starting peer, couchdb, cli containers for the organisations ###
### Use of DOCKER_COMPOSE_FILE, DOCKER_SERVICES ###
echo -e "\n \n Starting peer container"
cd ../../peerOperation/
./create_peer.sh 

### Create Channel from the consortium ###
### Use of CFG_PATH, CHANNEL_ID, TRANSACTION_FILE, CONFIG_PROFILE ###
echo -e "\n \n Creating channel"
cd ../channelOperation/
./create_channel_cheese.sh
docker exec cli.unibw.de peer channel update -f ./cheese_creation.tx -o orderer.unibw.de:7050 -c cheese --tls --cafile /etc/hyperledger/msp/orderer/tls/ca.crt

echo "Sleeping for 8 seconds"
sleep 8s

### Peer join a channel ###
### Use of CONTAINER_NAME, CHANNEL_ID, ORDERER_ADDRESS ###
echo -e "\n \n Peer joining channel"
./peer_channel_join.sh 
./anchorPeerUpdate.sh -o Deoni -c cli.deoni.de
docker exec cli.deoni.de peer channel update -f Deoni_update_in_envelope.pb -c cheese -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
sleep 2s

### Org join a channel ###
### Use of CFG_PATH, JOINING_ORGANISATION, CONTAINER_NAME, CHANNEL_ID, ORDERER_ADDRESS,TRANSACTION_FILE ###

echo -e "\n \n Organisation Salers joining channel"
./org_join_channel.sh -o Salers -c cli.deoni.de
docker exec cli.unibw.de peer channel signconfigtx -f Salers_update_in_envelope.pb 
docker exec cli.deoni.de peer channel update -f Salers_update_in_envelope.pb -c cheese -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
### Peer join a channel ###

sleep 2s
echo -e "\n \n Peer Salers joining channel"
docker exec cli.salers.de peer channel fetch oldest -c cheese -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
docker exec cli.salers.de peer channel join -b ./cheese_oldest.block 


echo -e "\n \n Organisation Tuxer joining channel"
./org_join_channel.sh -o Tuxer -c cli.salers.de


docker exec cli.deoni.de peer channel signconfigtx -f Tuxer_update_in_envelope.pb 
docker exec cli.salers.de peer channel update -f Tuxer_update_in_envelope.pb -c cheese -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
### Peer join a channel ###
sleep 2s
echo -e "\n \n Peer Tuxer joining channel"
docker exec cli.tuxer.de peer channel fetch oldest -c cheese -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
docker exec cli.tuxer.de peer channel join -b ./cheese_oldest.block 


echo -e "\n \n Organisation Brangus joining channel"
./org_join_channel.sh -o Brangus -c cli.tuxer.de
docker exec cli.deoni.de peer channel signconfigtx -f Brangus_update_in_envelope.pb
docker exec cli.salers.de peer channel signconfigtx -f Brangus_update_in_envelope.pb
docker exec cli.tuxer.de peer channel update -f Brangus_update_in_envelope.pb -c cheese -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
### Peer join a channel ###
sleep 2s
echo -e "\n \n Peer Brangus joining channel"
docker exec cli.brangus.de peer channel fetch oldest -c cheese -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
docker exec cli.brangus.de peer channel join -b ./cheese_oldest.block 


echo -e "\n \n Organisation Pinzgauer joining channel"
./org_join_channel.sh -o Pinzgauer -c cli.brangus.de
docker exec cli.salers.de peer channel signconfigtx -f Pinzgauer_update_in_envelope.pb
docker exec cli.tuxer.de peer channel signconfigtx -f Pinzgauer_update_in_envelope.pb
docker exec cli.brangus.de peer channel update -f Pinzgauer_update_in_envelope.pb -c cheese -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
### Peer join a channel ###
sleep 2s
echo -e "\n Peer Pinzgauer joining channel"
docker exec cli.pinzgauer.de peer channel fetch oldest -c cheese -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
docker exec cli.pinzgauer.de peer channel join -b ./cheese_oldest.block

sleep 2s
cd ../operationsService/
./start_prometheus.sh

echo -e "🚀 Successfully started 🚀"
