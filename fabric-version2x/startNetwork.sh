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
./start_cli.sh

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
./start_peer.sh

### Create Channel from the consortium ###
### Use of CFG_PATH, CHANNEL_ID, TRANSACTION_FILE, CONFIG_PROFILE ###
echo -e "\n \n Creating channel"
cd ../channelOperation/
./create_channel.sh
docker exec cli.deoni.de peer channel update -f ./trackandtrace_creation.tx -o orderer.unibw.de:7050 -c trackandtrace --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem

echo "Sleeping for 8 seconds"
sleep 8s

### Peer join a channel ###
### Use of CONTAINER_NAME, CHANNEL_ID, ORDERER_ADDRESS ###
echo -e "\n \n Peer joining channel"
./peer_channel_join.sh 
./anchor_peer_update.sh -o Deoni -c cli.deoni.de
docker exec cli.deoni.de peer channel update -f Deoni_update_in_envelope.pb -c trackandtrace -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
sleep 2s

### Org join a channel ###
### Use of CFG_PATH, JOINING_ORGANISATION, CONTAINER_NAME, CHANNEL_ID, ORDERER_ADDRESS,TRANSACTION_FILE ###

echo -e "\n \n Organisation Salers joining channel"
./org_join_channel.sh -o Salers -n cli.deoni.de
docker exec cli.deoni.de peer channel update -f Salers_update_in_envelope.pb -c trackandtrace -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
### Peer join a channel ###

sleep 2s
echo -e "\n \n Peer Salers joining channel"
./peer_channel_join.sh -n cli.salers.de


echo -e "\n \n Organisation Tuxer joining channel"
./org_join_channel.sh -o Tuxer -n cli.salers.de
docker exec cli.deoni.de peer channel signconfigtx -f Tuxer_update_in_envelope.pb 
docker exec cli.salers.de peer channel update -f Tuxer_update_in_envelope.pb -c trackandtrace -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
### Peer join a channel ###
sleep 2s
echo -e "\n \n Peer Tuxer joining channel"
./peer_channel_join.sh -n cli.tuxer.de


echo -e "\n \n Organisation Brangus joining channel"
./org_join_channel.sh -o Brangus -n cli.tuxer.de
docker exec cli.deoni.de peer channel signconfigtx -f Brangus_update_in_envelope.pb
docker exec cli.salers.de peer channel signconfigtx -f Brangus_update_in_envelope.pb
docker exec cli.tuxer.de peer channel update -f Brangus_update_in_envelope.pb -c trackandtrace -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
### Peer join a channel ###
sleep 2s
echo -e "\n \n Peer Brangus joining channel"
./peer_channel_join.sh -n cli.brangus.de


echo -e "\n \n Organisation Pinzgauer joining channel"
./org_join_channel.sh -o Pinzgauer -n cli.brangus.de
docker exec cli.salers.de peer channel signconfigtx -f Pinzgauer_update_in_envelope.pb
docker exec cli.tuxer.de peer channel signconfigtx -f Pinzgauer_update_in_envelope.pb
docker exec cli.brangus.de peer channel update -f Pinzgauer_update_in_envelope.pb -c trackandtrace -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
### Peer join a channel ###
sleep 2s
echo -e "\n Peer Pinzgauer joining channel"
./peer_channel_join.sh -n cli.pinzgauer.de


echo -e "\n \n Organisation Authority joining channel"
./org_join_channel.sh -o Authority -n cli.deoni.de
docker exec cli.salers.de peer channel signconfigtx -f Authority_update_in_envelope.pb
docker exec cli.tuxer.de peer channel signconfigtx -f Authority_update_in_envelope.pb
docker exec cli.brangus.de peer channel update -f Authority_update_in_envelope.pb -c trackandtrace -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
### Peer join a channel ###
sleep 2s
echo -e "\n Peer Authority joining channel"
./peer_channel_join.sh -n cli.authority.de



######################################################## Second Channel #####################################################################################

### Create new consortium
echo -e "\n Create new consortium"
cd ../orderingService/consortium
./create_consortium.sh
docker exec cli.unibw.de peer channel update -f Logistics_creation.pb -c nutrisafesystemchannel -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/orderer/tls/ca.crt



### Organisation Tuxer joining consortium
echo -e "\n Tuxer joining new consortium"
./org_join_consortium.sh -o Tuxer -c Logistics
docker exec cli.unibw.de peer channel update -f Tuxer_update_in_envelope.pb -c nutrisafesystemchannel -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/orderer/tls/ca.crt


### Create Channel from the consortium ###
### Use of CFG_PATH, CHANNEL_ID, TRANSACTION_FILE, CONFIG_PROFILE ###
echo -e "\n \n Creating channel"
cd ../../channelOperation/
./create_channel.sh -o NewChannel -c logistics
docker exec cli.tuxer.de peer channel update -f ./logistics_creation.tx -o orderer.unibw.de:7050 -c logistics --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem

echo "Sleeping for 8 seconds"
sleep 5s

### Peer join a channel ###
### Use of CONTAINER_NAME, CHANNEL_ID, ORDERER_ADDRESS ###
echo -e "\n \n Peer joining channel"
./peer_channel_join.sh -c logistics -n cli.tuxer.de
./anchor_peer_update.sh -o Tuxer -c cli.tuxer.de -i logistics
docker exec cli.tuxer.de peer channel update -f Tuxer_update_in_envelope.pb -c logistics -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
sleep 2s


### Org join a channel ###
### Use of CFG_PATH, JOINING_ORGANISATION, CONTAINER_NAME, CHANNEL_ID, ORDERER_ADDRESS,TRANSACTION_FILE ###
echo -e "\n \n Organisation Duroc joining channel"
./org_join_channel.sh -o Duroc -n cli.tuxer.de -c logistics
docker exec cli.tuxer.de peer channel update -f Duroc_update_in_envelope.pb -c logistics -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
### Peer join a channel ###

sleep 2s
echo -e "\n \n Peer Duroc joining channel"
./peer_channel_join.sh -c logistics -n cli.duroc.de


### Org join a channel ###
### Use of CFG_PATH, JOINING_ORGANISATION, CONTAINER_NAME, CHANNEL_ID, ORDERER_ADDRESS,TRANSACTION_FILE ###
echo -e "\n \n Organisation Schwarzfuss joining channel"
./org_join_channel.sh -o Schwarzfuss -n cli.duroc.de -c logistics
docker exec cli.tuxer.de peer channel signconfigtx -f Schwarzfuss_update_in_envelope.pb
docker exec cli.duroc.de peer channel update -f Schwarzfuss_update_in_envelope.pb -c logistics -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem
### Peer join a channel ###

sleep 2s
echo -e "\n \n Peer Schwarzfuss joining channel"
./peer_channel_join.sh -c logistics -n cli.schwarzfuss.de

sleep 2s
cd ../operationsService/
./start_prometheus.sh

echo -e "🚀 Successfully started 🚀"
