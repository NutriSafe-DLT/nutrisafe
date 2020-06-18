#!/bin/bash
#
#####################################################################################################################
# DESCRIPTION                                                                                                       #
# This script installs a chaincode in the network                                                                   #
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


#### Package Chaincode
cd chaincode/nutrisafecc
rm go.sum
GO111MODULE=on go mod vendor
docker exec cli.deoni.de sh -c "peer lifecycle chaincode package /opt/gopath/src/github.com/nutrisafecc/nutrisafecc.tar.gz --path ./ --lang golang --label nutrisafecc_1"



#### Install Chaincode on every CLI: 
array=( cli.deoni.de cli.brangus.de cli.pinzgauer.de cli.tuxer.de cli.salers.de)
for i in "${array[@]}"
do
  docker exec $i sh -c "peer lifecycle chaincode install /opt/gopath/src/github.com/nutrisafecc/nutrisafecc.tar.gz"
  docker exec $i sh -c "export CC_PACKAGE_ID=$(peer lifecycle chaincode queryinstalled | grep Label| tr -s ' '| cut -d ' ' -f 3 | cut -d , -f 1)"
  docker exec $i sh -c "peer lifecycle chaincode approveformyorg -o orderer.unibw.de:7050 --channelID cheese --name nutrisafecc --version 1.0 --package-id $CC_PACKAGE_ID --sequence 1 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem"
done


#### Commit Chaincode
docker exec cli.deoni.de sh -c "peer lifecycle chaincode checkcommitreadiness --channelID cheese --name nutrisafecc --version 1.0 --sequence 1 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem --output json"
docker exec cli.deoni.de sh -c "peer lifecycle chaincode commit -o orderer.unibw.de:7050 --channelID cheese --name nutrisafecc --version 1.0 --sequence 1 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem --peerAddresses peer0.deoni.de:7051 --tlsRootCertFiles /etc/hyperledger/msp/users/admin/tls/ca.crt --peerAddresses peer0.tuxer.de:7051 --tlsRootCertFiles /etc/hyperledger/msp/users/admin/msp/tlscacerts/tlsca.tuxer.de-cert.pem --peerAddresses peer0.pinzgauer.de:7051 --tlsRootCertFiles /etc/hyperledger/msp/users/admin/msp/tlscacerts/tlsca.pinzgauer.de-cert.pem --peerAddresses peer0.brangus.de:7051 --tlsRootCertFiles /etc/hyperledger/msp/users/admin/msp/tlscacerts/tlsca.brangus.de-cert.pem --peerAddresses peer0.salers.de:7051 --tlsRootCertFiles /etc/hyperledger/msp/users/admin/msp/tlscacerts/tlsca.salers.de-cert.pem"
docker exec cli.deoni.de sh -c "peer lifecycle chaincode querycommitted --channelID cheese --name nutrisafecc --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem"


echo -e "🚀 Successfully installed and committed 🚀"
