CCNAME=nutrisafecc
FUNCTION="CreateProduct"
ARGS="["PRO123","BROT","Brot mit Belag!", "1234568789"]"
CLI=cli.deoni.de


docker exec $CLI sh -c "peer chaincode invoke -o orderer.unibw.de:7050 --tls --cafile /etc/hyperledger/msp/users/admin/tls/tlsca.unibw.de-cert.pem -C cheese -n '$CCNAME' --peerAddresses peer0.deoni.de:7051 --tlsRootCertFiles /etc/hyperledger/msp/users/admin/msp/tlscacerts/tlsca.deoni.de-cert.pem --peerAddresses peer0.tuxer.de:7051 --tlsRootCertFiles /etc/hyperledger/msp/users/admin/msp/tlscacerts/tlsca.tuxer.de-cert.pem --peerAddresses peer0.brangus.de:7051 --tlsRootCertFiles /etc/hyperledger/msp/users/admin/msp/tlscacerts/tlsca.brangus.de-cert.pem --peerAddresses peer0.salers.de:7051 --tlsRootCertFiles /etc/hyperledger/msp/users/admin/msp/tlscacerts/tlsca.salers.de-cert.pem -c '{\"function\":\"'$FUNCTION'\",\"Args\":'$ARGS'}'"

