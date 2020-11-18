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
# Author(s): Tim Hoiß, Andreas Hermann, Razvan Hrestic
# NutriSafe Research Project
# Institute for Protection and Dependability
# Department of Computer Science
# Bundeswehr University Munich
#####################################################################################################################


#####################################################################################################################
# Parameters                                                                                                        #
#####################################################################################################################

# CCNAME has to be a directory under chaincode 

LANGUAGE="java"
LABEL="metaChain_"
CCNAME="nutrisafe-chaincode"
CCVERSION="1"
CHANNEL="cheese"
CCSEQUENCE=1


# Parameters for organization and container
while getopts "h?l:c:v:s:q" opt; do
  case "$opt" in
  l)
    LABEL=$OPTARG
    ;;
  c)
    CCNAME=$OPTARG
    ;;
  v)
    CCVERSION=$OPTARG
    ;;
  s)
    CCSEQUENCE=$OPTARG
    ;;
  esac
done


#####################################################################################################################
# Code                                                                                                              #
#####################################################################################################################

cd chaincode/$CCNAME
###Build chaincode
if [ $LANGUAGE = "java" ]
then
  rm -R build
  find . -type f -name $CCNAME."*" -delete
  echo "Building jar..."
  ./gradlew shadowJar
  echo "Finished Building"
elif [ $LANGUAGE = "go" ]
then
  sudo rm go.sum
  sudo rm -R vendor
  docker exec cli.deoni.de bash -c "cd /opt/gopath/src/github.com/'$CCNAME'/ && GO111MODULE=on go mod vendor"
fi


# Get sequence value from first org or use default values
docker exec cli.deoni.de bash -c "peer lifecycle chaincode querycommitted --channelID $CHANNEL --name '$CCNAME'">&sequence.txt
sleep 5s
if [ $? -eq 0 ]
then
  seq=$(awk '{for(i=1;i<=NF;i++)if($i=="Sequence:")print $(i+1)}' sequence.txt)
  SEQUENCE=$(echo "${seq//,}")
fi

if [ -z $SEQUENCE ] ; 
then
  SEQUENCE=1
  echo 'No sequence yet for chaincode '$CCNAME', initializing with 1'
else
  SEQUENCE=$(($SEQUENCE + 1))
  echo 'Incrementing sequence by 1 for chaincode '$CCNAME'. Sequence value to be installed is: '$SEQUENCE
fi

#### Package Chaincode
echo "Start Packaging"
sleep 2s
echo "Packaging..."
docker exec cli.deoni.de bash -c "cd /opt/gopath/src/github.com/'$CCNAME'/ && peer lifecycle chaincode package '$CCNAME'.tar.gz --path ./ --lang '$LANGUAGE' --label '$LABEL$SEQUENCE'"
echo "Finished Packaging"


#### Install Chaincode on every CLI: 
array=( cli.deoni.de cli.brangus.de cli.pinzgauer.de cli.tuxer.de cli.salers.de)
for i in "${array[@]}"
do
  echo "Install on '$i'"
  docker exec $i bash -c "peer lifecycle chaincode install /opt/gopath/src/github.com/'$CCNAME'/'$CCNAME'.tar.gz"
  if [ $? -eq 1 ]
  then
     echo "There was an error reported during install. Continue? (y/n)"
     read -s key
     if [ $key = n ]
     then
         echo "Exiting..."
         exit 1
     fi
  fi
  sleep 2s
 CC_PACKAGE_ID=$(docker exec cli.deoni.de bash -c "peer lifecycle chaincode queryinstalled | grep Label| tr -s ' '| cut -d ' ' -f 3 | cut -d , -f 1 | tail -n1")
  echo "Chaincode ID ${CC_PACKAGE_ID}"
  echo "Approve on '$i'"
  docker exec $i bash -c "peer lifecycle chaincode approveformyorg -o orderer.unibw.de:7050  --channelID '$CHANNEL' --name '$CCNAME' --version '$CCVERSION' --package-id '${CC_PACKAGE_ID}' --sequence '$SEQUENCE' --collections-config /opt/gopath/src/github.com/'$CCNAME'/collections.json --signature-policy \"OR('DeoniMSP.member','TuxerMSP.member','BrangusMSP.member','SalersMSP.member','PinzgauerMSP.member')\"  --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem"
done

#--signature-policy \"OR('DeoniMSP.member','TuxerMSP.member','BrangusMSP.member','SalersMSP.member','PinzgauerMSP.member')\"


#### Commit Chaincode
echo "Commit Chaincode"
docker exec cli.deoni.de bash -c "peer lifecycle chaincode checkcommitreadiness --channelID '$CHANNEL' --name '$CCNAME' --version '$CCVERSION' --sequence '$SEQUENCE' --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem --output json"
docker exec cli.deoni.de bash -c "peer lifecycle chaincode commit --collections-config /opt/gopath/src/github.com/'$CCNAME'/collections.json --signature-policy \"OR('DeoniMSP.member','TuxerMSP.member','BrangusMSP.member','SalersMSP.member','PinzgauerMSP.member')\" -o orderer.unibw.de:7050 --channelID '$CHANNEL' --name '$CCNAME' --version '$CCVERSION' --sequence '$SEQUENCE' --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem --peerAddresses peer0.deoni.de:7051 --tlsRootCertFiles /etc/hyperledger/msp/users/admin/tls/ca.crt --peerAddresses peer0.tuxer.de:7051 --tlsRootCertFiles /etc/hyperledger/msp/users/admin/msp/tlscacerts/tlsca.tuxer.de-cert.pem --peerAddresses peer0.pinzgauer.de:7051 --tlsRootCertFiles /etc/hyperledger/msp/users/admin/msp/tlscacerts/tlsca.pinzgauer.de-cert.pem --peerAddresses peer0.brangus.de:7051 --tlsRootCertFiles /etc/hyperledger/msp/users/admin/msp/tlscacerts/tlsca.brangus.de-cert.pem --peerAddresses peer0.salers.de:7051 --tlsRootCertFiles /etc/hyperledger/msp/users/admin/msp/tlscacerts/tlsca.salers.de-cert.pem"
docker exec cli.deoni.de bash -c "peer lifecycle chaincode querycommitted --channelID '$CHANNEL' --name '$CCNAME' --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem"


echo -e "🚀 Successfully installed and committed 🚀"