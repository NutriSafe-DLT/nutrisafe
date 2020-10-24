# This work is licensed under a Creative Commons Attribution 4.0 International License
# (http://creativecommons.org/licenses/by/4.0/).
#
# Author(s): Tim Reimers, Andreas Hermann
# NutriSafe Research Project
# Institute for Protection and Dependability
# Department of Computer Science
# Bundeswehr University Munich
#
# Original file (from https://github.com/hyperledger/fabric-samples) by IBM Corp:
# License SPDX-License-Identifier: Apache-2.0


### Parameter
SLEEP_TIME=2
SLEEP_TIME_QUERY=5



### Install Chaincode and instantiate
peer chaincode install -p chaincodedev/chaincode/sacc -n mycc -v 0
sleep $SLEEP_TIME
peer chaincode instantiate -n mycc -v 0 -c '{"Args":[]}' -C myc
sleep $SLEEP_TIME

### Create Samples for organisations, products and storage spaces
peer chaincode invoke -n mycc -c '{"Args":["initOrganisations",""]}' -C myc
sleep $SLEEP_TIME
peer chaincode invoke -n mycc -c '{"Args":["initProducts",""]}' -C myc
sleep $SLEEP_TIME
peer chaincode invoke -n mycc -c '{"Args":["initStorageSpaces",""]}' -C myc
sleep $SLEEP_TIME


### Sample Data for some Lots ###

#createLot (Brangus 100)
peer chaincode invoke -n mycc -c '{"Args":["createLot", "100", "123", "20", "liter", "111", "222100", "26.11.2019", ""]}' -C myc
sleep $SLEEP_TIME
#createLot (Pinzgauer 200)
peer chaincode invoke -n mycc -c '{"Args":["createLot", "200", "123", "20", "liter", "222", "222100", "21.11.2019", ""]}' -C myc
sleep $SLEEP_TIME
#ChangeLot (Brangus 100 -> Pinzgauer 200)
peer chaincode invoke -n mycc -c '{"Args":["changeLot", "100", "200", "18.25"]}' -C myc
sleep $SLEEP_TIME
#createLot (Brangus 101)
peer chaincode invoke -n mycc -c '{"Args":["createLot", "101", "123", "20", "liter", "111", "222100", "22.11.2019", ""]}' -C myc
sleep $SLEEP_TIME
#changeLot (Brangus 101 -> Pinzgauer 200)
peer chaincode invoke -n mycc -c '{"Args":["changeLot", "101", "200", "18.25"]}' -C myc
sleep $SLEEP_TIME
#createLot (Deoni 300)
peer chaincode invoke -n mycc -c '{"Args":["createLot", "300", "123", "20", "liter", "333", "222100", "23.11.2019", ""]}' -C myc
sleep $SLEEP_TIME
#createLot (Pinzgauer 201)
peer chaincode invoke -n mycc -c '{"Args":["createLot", "201", "123", "20", "liter", "222", "222100", "24.11.2019", ""]}' -C myc
sleep $SLEEP_TIME
#changeLot (Pinzgauer 200 -> Deoni 300)
peer chaincode invoke -n mycc -c '{"Args":["changeLot", "200", "300", "18.25"]}' -C myc
sleep $SLEEP_TIME
#changeLot (Pinzgauer 201 -> Deoni 300)
peer chaincode invoke -n mycc -c '{"Args":["changeLot", "201", "300", "18.25"]}' -C myc
sleep $SLEEP_TIME
#createLot (Deoni 350)
peer chaincode invoke -n mycc -c '{"Args":["createLot", "350", "123", "200", "liter", "333", "222100", "25.11.2019", ""]}' -C myc
sleep $SLEEP_TIME
#produceProduct (Deoni 300 350)
peer chaincode invoke -n mycc -c '{"Args":["produceProduct", "300","10", "350", "22.75"]}' -C myc
sleep $SLEEP_TIME
#createLot (Deoni 351)
peer chaincode invoke -n mycc -c '{"Args":["createLot", "351", "123", "200", "liter", "333", "222100", "26.11.2019", ""]}' -C myc
sleep $SLEEP_TIME
#produceProduct (Deoni 300 351)
peer chaincode invoke -n mycc -c '{"Args":["produceProduct", "300","10", "351", "33.75"]}' -C myc
sleep $SLEEP_TIME
#createLot (Tuxer 400)
peer chaincode invoke -n mycc -c '{"Args":["createLot", "400", "123", "20", "liter", "444", "222100", "27.11.2019", ""]}' -C myc
sleep $SLEEP_TIME
#aggregateLot (Tuxer 400, Deoni 350 351)
peer chaincode invoke -n mycc -c '{"Args":["aggregateLots", "400", "350 351"]}' -C myc
sleep $SLEEP_TIME
#unloadLot (Tuxer 400, Salers 350 351)
peer chaincode invoke -n mycc -c '{"Args":["unloadLot", "400", "350 351", "444", "222100"]}' -C myc
sleep $SLEEP_TIME
#changeStorageSpace (Salers 350 351)
peer chaincode invoke -n mycc -c '{"Args":["changeStorageSpace", "350", "222100"]}' -C myc
sleep $SLEEP_TIME
peer chaincode invoke -n mycc -c '{"Args":["changeStorageSpace", "351", "222100"]}' -C myc
sleep $SLEEP_TIME
#removeQuantity (Salers 350 351)
peer chaincode invoke -n mycc -c '{"Args":["removeQuantity", "350", "0.25"]}' -C myc
sleep $SLEEP_TIME
peer chaincode invoke -n mycc -c '{"Args":["removeQuantity", "351", "2.25"]}' -C myc
sleep $SLEEP_TIME
#createOrganisation
peer chaincode invoke -n mycc -c '{"Args":["createOrganisation", "666", "Holsteiner", "1.0", "2.0"]}' -C myc
sleep $SLEEP_TIME
#createProduct
peer chaincode invoke -n mycc -c '{"Args":["createProduct", "300", "Salat", "Salat mit Kaese"]}' -C myc
sleep $SLEEP_TIME
#createStorageSpace
peer chaincode invoke -n mycc -c '{"Args":["createStorageSpace", "300", "10000", "111", "15.75", "warehouse"]}' -C myc
sleep $SLEEP_TIME

### QUERIES
sleep $SLEEP_TIME_QUERY
peer chaincode invoke -n mycc -c '{"Args":["queryByKey", "LOT100"]}' -C myc

sleep $SLEEP_TIME_QUERY
peer chaincode invoke -n mycc -c '{"Args":["queryByKey", "LOT200"]}' -C myc

sleep $SLEEP_TIME_QUERY
peer chaincode invoke -n mycc -c '{"Args":["queryByKey", "LOT101"]}' -C myc

sleep $SLEEP_TIME_QUERY
peer chaincode invoke -n mycc -c '{"Args":["queryByKey", "LOT200"]}' -C myc

sleep $SLEEP_TIME_QUERY
peer chaincode invoke -n mycc -c '{"Args":["queryByKey", "LOT300"]}' -C myc

sleep $SLEEP_TIME_QUERY
peer chaincode invoke -n mycc -c '{"Args":["queryByKey", "LOT201"]}' -C myc

sleep $SLEEP_TIME_QUERY
peer chaincode invoke -n mycc -c '{"Args":["queryByKey", "LOT300"]}' -C myc

sleep $SLEEP_TIME_QUERY
peer chaincode invoke -n mycc -c '{"Args":["queryByKey", "LOT350"]}' -C myc

#sleep $SLEEP_TIME_QUERY
#peer chaincode invoke -n mycc -c '{"Args":["queryByKey", "PRO300"]}' -C myc

sleep $SLEEP_TIME_QUERY
peer chaincode invoke -n mycc -c '{"Args":["queryByKey", "LOT351"]}' -C myc

sleep $SLEEP_TIME_QUERY
peer chaincode invoke -n mycc -c '{"Args":["queryByKey", "PRO300"]}' -C myc

sleep $SLEEP_TIME_QUERY
peer chaincode invoke -n mycc -c '{"Args":["queryByKey", "LOT400"]}' -C myc

sleep $SLEEP_TIME_QUERY
peer chaincode invoke -n mycc -c '{"Args":["queryByKey", "STS350"]}' -C myc

sleep $SLEEP_TIME_QUERY
peer chaincode invoke -n mycc -c '{"Args":["queryByKey", "STS351"]}' -C myc

sleep $SLEEP_TIME_QUERY
peer chaincode invoke -n mycc -c '{"Args":["queryByKey", "ORG666"]}' -C myc

sleep $SLEEP_TIME_QUERY
peer chaincode invoke -n mycc -c '{"Args":["queryByKey", "PRO300"]}' -C myc

sleep $SLEEP_TIME_QUERY
peer chaincode invoke -n mycc -c '{"Args":["queryByKey", "STS111300"]}' -C myc
