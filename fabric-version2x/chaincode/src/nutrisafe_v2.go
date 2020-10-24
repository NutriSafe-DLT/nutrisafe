/*
# This work is licensed under a Creative Commons Attribution 4.0 International License
# (http://creativecommons.org/licenses/by/4.0/).
#
# Author(s): Tim Hoiß, Andreas Hermann
# NutriSafe Research Project
# Institute for Protection and Dependability
# Department of Computer Science
# Bundeswehr University Munich
#
# Original file (from https://github.com/hyperledger/fabric-samples) by IBM Corp:
# License SPDX-License-Identifier: Apache-2.0
CHANGELOG
tho --- Removed structs Organisation, Product from types Lot and StorageSpace and added string field
tho --- Changed name of queryByID to queryByKey
tho --- Removed type Unit, Status, SpaceStorageType and changed every reference to string
tho --- PrecessorLotIDs in CreateLot added
tho --- Changed GTIN to ProductID
tho --- Added Location to struct Organisation
*/

package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"strconv"
	"strings"
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

// SmartContract provides functions for managing a car
type SmartContract struct {
	contractapi.Contract
}

const (
	//Units
	kilogramm string = "kg"
	liter     string = "ltr"
	pieces    string = "pcs"

	//Status
	empty      string = "Empty Lot" //Für Lots welche leer sind, diese können später auch gelöscht werden
	production string = "In Production"
	shipping   string = "In Shipping"
	sold       string = "Sold"

	//StorageSpaceType
	milkTank   string = "Milk tank"
	milkTanker string = "Milk tanker"
	milkSilo   string = "Milk silo"
	truck      string = "Truck"
	warehouse  string = "Warehouse"
	shelf      string = "Shelf"
)

// Product should not identify one explicit product instance
// It should identify a class of products
type Product struct {
	//ProductID   int    `json:"productid"` // We could use here a standard classification schema for products
	Name        string `json:"name"`      // e. g. Milk
	Description string `json:"description"`
	Ean         string `json:"ean"`
}

// Lot is he central element in this chaincode. It respresents an actual physical product.
type Lot struct {
	SGTIN           int     `json:"sgtin"` //Serialized Global Trade Item Number, GS1
	Product         string  `json:"product"`
	Quantity        float64 `json:"quantity"`
	Unit            string  `json:"unit"`
	OrganisationID  string  `json:"owner"`
	Status          string  `json:"status"`
	PrecessorLotIDs []int   `json:"precessorLotIds"`
	SuccessorLotIDs []int   `json:"successorLotIds"`
	SpaceID         string  `json:"spaceId"` //z. B. Milchsammelwagen, Lager
	Mhd             string  `json:"mhd"`
}

// Organisation TBF
type Organisation struct {
	SGLN     int    `json:"sgln"` // Global Location Number with or without Extension
	Name     string `json:"orgName"`
	Location `json:"location"`
}

// Location TBF
type Location struct {
	Latitude  float64 `json:"latitude"`
	Longitude float64 `json:"longitude"`
}

//StorageSpace TBF
type StorageSpace struct {
	GRAI           int     `json:"grai"` //Global Returnable Asset Identifier --> wird für Palleten oder ähnliches verwendet
	Capacity       int     `json:"capacity"`
	OrganisationID string  `json:"ownerStorage"`
	FillLevel      float64 `json:"fillLevel"` // 0 - 1
	StrorageType   string  `json:"storageSpaceType"`
}

//////////////////////////////Functions////////////////////////////////////////////////////////

func main() {
	chaincode, err := contractapi.NewChaincode(new(SmartContract))

	if err != nil {
		fmt.Printf("Error create nutrisafe chaincode: %s", err.Error())
		return
	}

	if err := chaincode.Start(); err != nil {
		fmt.Printf("Error starting nutrisafe chaincode: %s", err.Error())
	}
}


//queryByID is used to get the value of a key
func (s *SmartContract) queryProduct(ctx contractapi.TransactionContextInterface, productID string) (*Product, error)) {

	if productID == "" {
		return shim.Error("ProductID is empty!")
	}

	productAsBytes, err := ctx.GetStub().GetState(productID)

	if err != nil {
		return nil, fmt.Errorf("Failed to read from world state. %s", err.Error())
	}

	if productAsBytes == nil {
		return nil, fmt.Errorf("%s does not exist", productID)
	}


	product := new(Product)
	_ = json.Unmarshal(productAsBytes, product)

	return product, nil
}

//queryTestData is used to check if the initialization worked correctly
/*func (t *SimpleChaincode) queryTestData(stub shim.ChaincodeStubInterface) pb.Response {
	keyList := [][]string{
		[]string{"PRO123", "PRO234"},
		[]string{"ORG111", "ORG222", "ORG333", "ORG444", "ORG555"},
		[]string{"STS111100", "STS222100", "STS222200", "STS333100", "STS333200", "STS333300", "STS444100", "STS444200", "STS555100", "STS555200", "STS555300"},
	}
	var buffer bytes.Buffer
	buffer.WriteString("[")
	i := 0
	for i < len(keyList) {
		j := 0
		for j < len(keyList[i]) {
			result, _ := stub.GetState(keyList[i][j])
			buffer.WriteString("{\"Key\":")
			buffer.WriteString("\"")
			buffer.WriteString(keyList[i][j])
			buffer.WriteString("\"")
			buffer.WriteString(", \"Value\":")
			buffer.WriteString(string(result))
			buffer.WriteString("}")
			j++
		}
		i++
	}
	buffer.WriteString("]")
	fmt.Printf("- queryTestData:\n%s\n", buffer.String())
	return shim.Success(buffer.Bytes())
}*/

//createLot is used to check if the initialization worked correctly
// createLot ("SGINT", "PRODUCTID", "QUANTITY", "UNIT", "SGLN", "GRAI", "PRECESSORLOTIDS")
// createLot("321", "123", "20", "liter", "111", "222100", "2 1")
/*func (t *SimpleChaincode) createLot(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	var err error
	////Checking if the inputs are set
	// checking if the number of arguments is correct
	if len(args) != 8 {
		return shim.Error("Incorrect number of arguments. Expecting 8")
	}
	// Checking if inputs are empty
	i := 0
	for i < (len(args))-1 {
		if len(args[i]) <= 0 {
			return shim.Error(strconv.Itoa(i) + "st argument must be a non-empty string")
		}
		i++
	}
	//// Assigning Inputs to vars and checking validity of them
	// First argument should be sgint for the new lot
	sgtin, err := strconv.Atoi(args[0])
	if err != nil {
		return shim.Error("SGTIN has to be an int number")
	}
	//Second argument should be a ProductID of which the lot is contained
	productID := "PRO" + args[1]
	productAsBytes, _ := stub.GetState(productID)
	if productAsBytes == nil {
		return shim.Error("Product ID does not exist or has not been initialized")
	}
	//Third argument should be the quantity of the product (depending on the unit) as a float
	quantity, err := strconv.ParseFloat(args[2], 32)
	if err != nil {
		return shim.Error("Quantity cannot be parsed to float")
	}
	//Fourth argument should be the unit in which the quantity is measured
	unit := ""
	if args[3] == "kilogramm" {
		unit = kilogramm
	} else if args[3] == "liter" {
		unit = liter
	} else if args[3] == "pieces" {
		unit = pieces
	} else {
		return shim.Error("Unit has to be kilogramm, liter or pieces")
	}
	//Fith argument should be the ID of the Organisation
	organisationID := "ORG" + args[4]
	organisationAsBytes, _ := stub.GetState(organisationID)
	if organisationAsBytes == nil {
		return shim.Error("Organisation ID does not exist or has not been initialized")
	}
	//Sixth argument should be the ID of the storagespace
	storageSpaceID := "STS" + args[5]
	storageSpaceAsBytes, _ := stub.GetState(storageSpaceID)
	if storageSpaceAsBytes == nil {
		return shim.Error("StorageSpace ID does not exist or has not been initialized")
	}
	//Seventh argument should be the list of precessorLotIDs, first lots do not have any precessors
	//Precessor Lot ID should be seperated by a space character
	var precessorLotIDs []int
	if args[7] != "" {
		strgs := strings.Split(args[7], " ")
		precessorLotIDs = make([]int, len(strgs))
		for j := range precessorLotIDs {
			precessorLotIDs[j], _ = strconv.Atoi(strgs[j])
			if !existKey(stub, "LOT"+strgs[j]) {
				return shim.Error("The key LOT" + strgs[j] + " does not exist.")
			}
		}
	}
	//Eight argument shoud be the MHD Date of the Product
	mhd := args[6]
	//Status is always production in the create transaction
	status := production
	//SuccessorLotIDs is always empty in the creat transaction
	var successorLotIds []int
	//// Create Lot and marshal to JSON
	lotKey := "LOT" + strconv.Itoa(sgtin)
	lot := Lot{sgtin, productID, quantity, unit, organisationID, status, precessorLotIDs, successorLotIds, storageSpaceID, mhd}
	lotAsBytes, _ := json.Marshal(lot)
	stub.PutState(lotKey, lotAsBytes)
	return shim.Success(nil)
}
//changeLot is used change the quantity of a lot
//changeLot("SGINT", "SGINT", "QUANTITY")
//changeLot("321", "432", "20.0")
func (t *SimpleChaincode) changeLot(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//check Input
	check, err := checkInput(3, args)
	if !check {
		return shim.Error(err)
	}
	//check values of the input
	//First input should be an existing Lot
	lotID1 := "LOT" + args[0]
	if !existKey(stub, lotID1) {
		return shim.Error("First Lot ID does not exist or has not been initialized")
	}
	//Second input should be an existing Lot
	lotID2 := "LOT" + args[1]
	if !existKey(stub, lotID2) {
		return shim.Error("Second Lot ID does not exist or has not been initialized")
	}
	//Third input should be an float
	quantity, erro := strconv.ParseFloat(args[2], 32)
	if erro != nil {
		return shim.Error("Quantity has to be an float number")
	}
	//checking if quantity is big enough
	lot1AsBytes, _ := stub.GetState(lotID1)
	var lot1 Lot
	json.Unmarshal(lot1AsBytes, &lot1)
	if lot1.Quantity < quantity {
		return shim.Error("Quantity is bigger than the lot")
	}
	//Removing quantity from Lot1
	lot1.Quantity = lot1.Quantity - quantity
	//Setting lot empty if there is nothing left
	if lot1.Quantity == 0 {
		lot1.Status = empty
	}
	lotid2, _ := strconv.Atoi(args[0])
	lot1.SuccessorLotIDs = append(lot1.SuccessorLotIDs, lotid2)
	//Put lot1 on the state
	lot1AsBytes, _ = json.Marshal(lot1)
	stub.PutState(lotID1, lot1AsBytes)
	//Add quantity to lot 2
	lot2AsBytes, _ := stub.GetState(lotID2)
	var lot2 Lot
	json.Unmarshal(lot2AsBytes, &lot2)
	lot2.Quantity = lot2.Quantity + quantity
	lotid1, _ := strconv.Atoi(args[0])
	lot2.PrecessorLotIDs = append(lot2.PrecessorLotIDs, lotid1)
	lot2AsBytes, _ = json.Marshal(lot2)
	stub.PutState(lotID2, lot2AsBytes)
	return shim.Success(nil)
}
//aggregateLots is used aggregate lots to with keeping them seperated, especially for the transportation (for a transporting or shipping unit)
//aggregateLots("SGINT", "SGINT SGINT")
//aggregateLots("321", "432 543")
//TODO
func (t *SimpleChaincode) aggregateLots(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//check Input
	check, err := checkInput(2, args)
	if !check {
		return shim.Error(err)
	}
	//check values of the input
	//First input should be an existing Lot
	lotID := "LOT" + args[0]
	if !existKey(stub, lotID) {
		return shim.Error("First Lot ID does not exist or has not been initialized")
	}
	//Second argument should be a number of x lot ids
	//Precessor Lot ID should be seperated by a space character
	lotAsBytes, _ := stub.GetState(lotID)
	var lot Lot
	json.Unmarshal(lotAsBytes, &lot)
	strgs := strings.Split(args[1], " ")
	for j := range strgs {
		lotIDs, _ := strconv.Atoi(strgs[j])
		lot.PrecessorLotIDs = append(lot.PrecessorLotIDs, lotIDs)
		if !existKey(stub, "LOT"+strgs[j]) {
			return shim.Error("The key LOT" + strgs[j] + " does not exist.")
		}
		lot1AsBytes, _ := stub.GetState("LOT" + strgs[j])
		var lot1 Lot
		json.Unmarshal(lot1AsBytes, &lot1)
		lotid1, _ := strconv.Atoi(args[0])
		lot1.SuccessorLotIDs = append(lot1.SuccessorLotIDs, lotid1)
		//Put lot1 on the state
		lot1AsBytes, _ = json.Marshal(lot1)
		stub.PutState("LOT"+strgs[j], lot1AsBytes)
	}
	lotAsBytes, _ = json.Marshal(lot)
	stub.PutState(lotID, lotAsBytes)
	return shim.Success(nil)
}
//produceProduct is used to make a new product out of other products
//produceProduct("SGINT", "QUANTITY", "SGINT SGINT", "QUANTITY QUANTITY")
//produceProduct("321", "10", "432 543", "10 90.2")
func (t *SimpleChaincode) produceProduct(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//check Input
	check, err := checkInput(4, args)
	if !check {
		return shim.Error(err)
	}
	//Check if first Lot is existing
	if !existKey(stub, "LOT"+args[0]) {
		return shim.Error("First Lot is not existing. Please create Lot with ID " + args[0])
	}
	//Check if second argument is an float
	producedQuan, errs := strconv.ParseFloat(args[1], 32)
	if errs != nil {
		return shim.Error("The Input " + args[1] + " is not an float number")
	}
	//Check if Lots in the third argument are existing
	strgsLot := strings.Split(args[2], " ")
	var precessorLotIDs []int
	for o := range strgsLot {
		lotIDs, _ := strconv.Atoi(strgsLot[o])
		precessorLotIDs = append(precessorLotIDs, lotIDs)
		if !existKey(stub, "LOT"+strgsLot[o]) {
			return shim.Error("The key LOT" + strgsLot[o] + " does not exist.")
		}
	}
	//Check if all values are float numbers (fourth argument)
	strgsQuan := strings.Split(args[3], " ")
	var quantities []float64
	for j := range strgsQuan {
		quantity, errs := strconv.ParseFloat(strgsQuan[j], 32)
		quantities = append(quantities, quantity)
		if errs != nil {
			return shim.Error("The Input " + strgsQuan[j] + " is not an float number")
		}
	}
	//Check if third argument has the same length as the fourth argument
	if len(quantities) != len(precessorLotIDs) {
		return shim.Error("Count of ID's and Quantities are different")
	}
	//addQuantity to the new productLot
	newLot := t.addQuantity(stub, "LOT"+args[0], producedQuan)
	//Precessor LotIDs add to the first Lot
	for p := range precessorLotIDs {
		newLot.PrecessorLotIDs = append(newLot.PrecessorLotIDs, precessorLotIDs[p])
	}
	//Writing the updated Lot to the world state
	lotAsBytes, _ := json.Marshal(newLot)
	stub.PutState("LOT"+args[0], lotAsBytes)
	//remove Quantity from the old lots //no error handling
	k := 0
	quantity := 0.0
	for k < len(precessorLotIDs) {
		quantity = quantities[k]
		lotBytes, _ := stub.GetState("LOT" + strconv.Itoa(precessorLotIDs[k]))
		var lot Lot
		json.Unmarshal(lotBytes, &lot)
		if lot.Quantity < quantity {
			return shim.Error("Quantity of product " + strconv.Itoa(precessorLotIDs[k]) + " is not enough")
		}
		//Removing quantity from Lot1
		lot.Quantity = lot.Quantity - quantity
		//Setting lot empty if there is nothing left
		if lot.Quantity == 0 {
			lot.Status = empty
		}
		lotIDold, _ := strconv.Atoi(args[0])
		lot.SuccessorLotIDs = append(lot.SuccessorLotIDs, lotIDold)
		//Put lot1 on the state
		lotBytes, _ = json.Marshal(lot)
		stub.PutState("LOT"+strconv.Itoa(precessorLotIDs[k]), lotAsBytes)
		k++
	}
	return shim.Success(nil)
}
//addQuantity is used to add quantity to an existing lot
//addQuantity("SGINT", "QUANTITY" )
//addQuantity("321", "10")
func (t *SimpleChaincode) addQuantity(stub shim.ChaincodeStubInterface, key string, quantity float64) Lot {
	lotAsBytes, _ := stub.GetState(key)
	var lot Lot
	json.Unmarshal(lotAsBytes, &lot)
	lot.Quantity = lot.Quantity + quantity
	return lot
}
//removeQuantity is used to remove quantity from an existing lot
//removeQuantity("SGINT", "QUANTITY" )
//removeQuantity("321", "10")
func (t *SimpleChaincode) removeQuantity(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//check Input
	check, err := checkInput(2, args)
	if !check {
		return shim.Error(err)
	}
	key := "LOT" + args[0]
	//Check if first Lot is existing
	if !existKey(stub, key) {
		return shim.Error("First Lot is not existing. Please create Lot with ID " + args[0])
	}
	//Check if second argument is an float
	quantity, errs := strconv.ParseFloat(args[1], 32)
	if errs != nil {
		return shim.Error("The Input " + args[1] + " is not an float number")
	}
	lotAsBytes, _ := stub.GetState(key)
	var lot Lot
	json.Unmarshal(lotAsBytes, &lot)
	if lot.Quantity < quantity {
		return shim.Error("Quantity of product " + key + " is not enough")
	}
	//Removing quantity from Lot1
	lot.Quantity = lot.Quantity - quantity
	//Setting lot empty if there is nothing left
	if lot.Quantity == 0 {
		lot.Status = empty
	}
	//Put lot1 on the state
	lotAsBytes, _ = json.Marshal(lot)
	stub.PutState(key, lotAsBytes)
	return shim.Success(nil)
}
//unloadLot is used to change the Organisationowner of one or more Lots which are aggregated to one Lot (most of the time Shipping or transportation unit)
//unloadLot("SGINT", "SGINT SGINT", "ORGANISATIONID", "GRAI" )
//unloadLot("321", "123 234", "111", "555100" )
func (t *SimpleChaincode) unloadLot(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//Check Input
	check, err := checkInput(4, args)
	if !check {
		return shim.Error(err)
	}
	//Check if Lot is existing
	keyLot := "LOT" + args[0]
	if !existKey(stub, keyLot) {
		return shim.Error("Lot is not existing. Please create Lot with ID " + args[0])
	}
	//Check if Org is existing
	keyOrg := "ORG" + args[2]
	if !existKey(stub, keyOrg) {
		return shim.Error("Organisation is not existing. Please create Lot with ID " + args[0])
	}
	//Check if StorageSpace is existing
	keyStorageSpace := "STS" + args[3]
	if !existKey(stub, keyStorageSpace) {
		return shim.Error("StorageSpace is not existing. Please create Lot with ID " + args[1])
	}
	//Write first argumunent LotID as precessor of the LotIDs in the second argument
	strgsLot := strings.Split(args[1], " ")
	var lot Lot
	var lotAsBytes []byte
	var precessorLotID int
	for i := range strgsLot {
		//Check if Lots in the second argument are existing
		if !existKey(stub, "LOT"+strgsLot[i]) {
			return shim.Error("The key LOT" + strgsLot[i] + " does not exist.")
		}
		lotAsBytes, _ = stub.GetState("LOT" + strgsLot[i])
		json.Unmarshal(lotAsBytes, &lot)
		lot.OrganisationID = args[2]
		lot.SpaceID = args[3]
		precessorLotID, _ = strconv.Atoi(args[0])
		lot.PrecessorLotIDs = append(lot.PrecessorLotIDs, precessorLotID)
		lotAsBytes, _ = json.Marshal(lot)
		stub.PutState(strgsLot[i], lotAsBytes)
	}
	//Change the Owner of the LotIDs in the second argument to the owner of the third argument
	return shim.Success(nil)
}
//changeStorageSpace is used to change the storage space of a lot
//changeStorageSpace("SGINT", "GRAI")
//changeStorageSpace("321", "333100")
func (t *SimpleChaincode) changeStorageSpace(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//Check Input
	check, err := checkInput(2, args)
	if !check {
		return shim.Error(err)
	}
	//Check if Lot is existing
	keyLot := "LOT" + args[0]
	if !existKey(stub, keyLot) {
		return shim.Error("Lot is not existing. Please create Lot with ID " + args[0])
	}
	//Check if StorageSpace is existing
	keyStorageSpace := "STS" + args[1]
	if !existKey(stub, keyStorageSpace) {
		return shim.Error("StorageSpace is not existing. Please create Lot with ID " + args[1])
	}
	lotAsBytes, _ := stub.GetState(keyLot)
	var lot Lot
	json.Unmarshal(lotAsBytes, &lot)
	//Setting new StorageSpace
	lot.SpaceID = args[1]
	//Put lot on the state
	lotAsBytes, _ = json.Marshal(lot)
	stub.PutState(keyLot, lotAsBytes)
	return shim.Success(nil)
}
*/
///////////////////////////Creation-Functions////////////////////////////////////////
/*
//createOrganisation is used to create a new organisation
//createOrganisation("SGINT", "NAME", "LATITUDE", "LONGITUDE")
//createOrganisation("666", "Holsteiner")
func (t *SimpleChaincode) createOrganisation(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//Check Input
	check, err := checkInput(4, args)
	if !check {
		return shim.Error(err)
	}
	orgID, _ := strconv.Atoi(args[0])
	lat, errs := strconv.ParseFloat(args[2], 32)
	long, errs := strconv.ParseFloat(args[3], 32)
	if errs != nil {
		return shim.Error("lat or long is not an float number")
	}
	organisation := Organisation{orgID, args[1], Location{lat, long}}
	organisationAsBytes, _ := json.Marshal(organisation)
	stub.PutState("ORG"+args[0], organisationAsBytes)
	return shim.Success(nil)
}
*/
//createProduct is used to create a new Produkt
//createProduct("PRODUCTID", "NAME", "DESCRIPTION")
//createProduct("300", "Salat", "Salat aus Käse und Schinken")
func (s *SmartContract) createProduct(ctx contractapi.TransactionContextInterface, productID int, name string, description string, ean string) error {


	productID, _ := strconv.Atoi(args[0])
	product := Product{
		Name: name,
		Description: description,
		Ean: ean,
	}
	productAsBytes, _ := json.Marshal(product)

	return ctx.GetStub().PutState(productID, productAsBytes)
}
/*
//createStorageSpace is used to create a new Produkt
//createStorageSpace("GRAI", "NAME", "DESCRIPTION")
//createStorageSpace("300", "10000", "111", "0.0", "warehouse")
func (t *SimpleChaincode) createStorageSpace(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//Check Input
	check, err := checkInput(5, args)
	if !check {
		return shim.Error(err)
	}
	grai, _ := strconv.Atoi(args[0])
	capacity, _ := strconv.Atoi(args[1])
	orgKey := "ORG" + args[2]
	if !existKey(stub, orgKey) {
		return shim.Error("ORG-ID doesn't exist")
	}
	fillLevel, _ := strconv.ParseFloat(args[3], 32)
	spaceType := ""
	if args[4] == "milkTank" {
		spaceType = milkTank
	} else if args[4] == "milkTanker" {
		spaceType = milkTanker
	} else if args[4] == "milkSilo" {
		spaceType = milkSilo
	} else if args[4] == "truck" {
		spaceType = truck
	} else if args[4] == "warehouse" {
		spaceType = warehouse
	} else if args[4] == "shelf" {
		spaceType = shelf
	} else {
		return shim.Error("StorageSpaceType has to be milkTank, milkTanker, milkSilo, truck, warehouse or shelf")
	}
	storageSpace := StorageSpace{grai, capacity, orgKey, fillLevel, spaceType}
	storageSpaceAsBytes, _ := json.Marshal(storageSpace)
	stub.PutState("STS"+args[2]+args[0], storageSpaceAsBytes)
	return shim.Success(nil)
}
///////////////////////////Helpful functions/////////////////////////////////////////
//checkInput returns true, "" if the quantity of arguments is correct and the strings are not empty
func checkInput(quantity int, args []string) (bool, string) {
	// checking if the number of arguments is correct
	if len(args) != quantity {
		return false, ("Incorrect number of arguments. Expecting " + strconv.Itoa(quantity))
	}
	// Checking if inputs are empty
	i := 0
	for i < quantity {
		if len(args[i]) <= 0 {
			return false, (strconv.Itoa(i) + "st argument must be a non-empty string")
		}
		i++
	}
	return true, ""
}
//Exist key checks if the key exist and has a value
func existKey(stub shim.ChaincodeStubInterface, key string) bool {
	value, _ := stub.GetState(key)
	if value != nil {
		return true
	}
	return false
}
////////////////////////////Init functions////////////////////////////////////////////////////
//initOrganisations creates sample key value pairs for organisations on the ledger
func (t *SimpleChaincode) initOrganisations(stub shim.ChaincodeStubInterface) pb.Response {
	// Create Organisation Sample Data
	organisations := []Organisation{
		Organisation{111, "Brangus", Location{1.0, 2.0}},
		Organisation{222, "Pinzgauer", Location{1.0, 2.0}},
		Organisation{333, "Deoni", Location{1.0, 2.0}},
		Organisation{444, "Tuxer", Location{1.0, 2.0}},
		Organisation{555, "Salers", Location{1.0, 2.0}},
	}
	// Writing the Data to the Ledger
	i := 0
	for i < len(organisations) {
		fmt.Println("i is ", i)
		organisationAsBytes, _ := json.Marshal(organisations[i])
		stub.PutState("ORG"+strconv.Itoa(organisations[i].SGLN), organisationAsBytes)
		fmt.Println("Added", organisations[i])
		i = i + 1
	}
	return shim.Success(nil)
}
//initProducts creates sample key value pairs for products on the ledger
func (t *SimpleChaincode) initProducts(stub shim.ChaincodeStubInterface) pb.Response {
	// Create Product Sample Data
	products := []Product{
		Product{123, "Milk", "Best milk ever produced in the World!", "555555555555555"},
		Product{234, "Cheese", "Cheesiest cheese in the universum!", "666666666666666"},
	}
	// Writing the Data to the Ledger
	i := 0
	for i < len(products) {
		fmt.Println("i is ", i)
		productAsBytes, _ := json.Marshal(products[i])
		stub.PutState("PRO"+strconv.Itoa(products[i].ProductID), productAsBytes)
		fmt.Println("Added", products[i])
		i = i + 1
	}
	return shim.Success(nil)
}
//initStorageSpaces creates sample key value pairs for products on the ledger
func (t *SimpleChaincode) initStorageSpaces(stub shim.ChaincodeStubInterface) pb.Response {
	// Create storageSpaces Sample Data
	storageSpaces := []StorageSpace{
		StorageSpace{100, 1000, "ORG111", 0.0, milkTank},
		StorageSpace{100, 15000, "ORG222", 0.0, milkTanker},
		StorageSpace{200, 15000, "ORG222", 0.0, milkTanker},
		StorageSpace{100, 1000000, "ORG333", 0.0, milkSilo},
		StorageSpace{200, 1000000, "ORG333", 0.0, milkSilo},
		StorageSpace{300, 1000000, "ORG333", 0.0, milkSilo},
		StorageSpace{100, 10000, "ORG444", 0.0, truck},
		StorageSpace{200, 10000, "ORG444", 0.0, truck},
		StorageSpace{100, 100000, "ORG555", 0.0, warehouse},
		StorageSpace{200, 10000, "ORG555", 0.0, shelf},
		StorageSpace{300, 10000, "ORG555", 0.0, shelf},
	}
	// Writing the Data to the Ledger
	i := 0
	for i < len(storageSpaces) {
		fmt.Println("i is ", i)
		storageSpaceAsBytes, _ := json.Marshal(storageSpaces[i])
		organisationAsBytes, _ := stub.GetState(storageSpaces[i].OrganisationID)
		if organisationAsBytes == nil {
			return shim.Error("Error in initStorageSpace in sample data or organisations have not been initialized")
		}
		var organisation Organisation
		json.Unmarshal(organisationAsBytes, &organisation)
		stub.PutState("STS"+strconv.Itoa(organisation.SGLN)+strconv.Itoa(storageSpaces[i].GRAI), storageSpaceAsBytes)
		fmt.Println("Added", storageSpaces[i])
		i = i + 1
	}
	return shim.Success(nil)
}
*/
