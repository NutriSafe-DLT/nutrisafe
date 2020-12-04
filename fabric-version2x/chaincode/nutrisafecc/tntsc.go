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
	"encoding/json"
	"errors"
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

//TNTSC provides functions for managing a car
type TNTSC struct {
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

//Product should not identify one explicit product instance
type Product struct {
	ProductID   string `json:"productid"` // We could use here a standard classification schema for products
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

//QueryProduct is used to get the value of a key
func (s *TNTSC) QueryProduct(ctx CustomTransactionContextInterface, productID string) (*Product, error) {

	existing := ctx.GetData()

	if existing == nil {
		return nil, fmt.Errorf("Cannot read world state pair with key %s. Does not exist", productID)
	}

	product := new(Product)

	err := json.Unmarshal(existing, product)

	if err != nil {
		return nil, fmt.Errorf("Data retrieved from world state for key %s was not of type BasicAsset", productID)
	}

	return product, nil
}

//CreateProduct is used to create a product
func (s *TNTSC) CreateProduct(ctx CustomTransactionContextInterface, productID string, name string, description string, ean string) error {
	existing := ctx.GetData()

	if existing != nil {
		return fmt.Errorf("Cannot create new basic asset in world state as key %s already exists", productID)
	}

	product := new(Product)
	product.ProductID = productID
	product.Name = name
	product.Description = description
	product.Ean = ean

	productAsBytes, _ := json.Marshal(product)

	err := ctx.GetStub().PutState(productID, []byte(productAsBytes))

	if err != nil {
		return errors.New("Unable to interact with world state")
	}

	return nil
}

// GetEvaluateTransactions returns functions of ComplexContract not to be tagged as submit
func (s *TNTSC) GetEvaluateTransactions() []string {
	return []string{"GetAsset"}
}
