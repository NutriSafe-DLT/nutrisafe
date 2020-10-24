package main

import (
	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func main() {

	tntsc := new(TNTSC)
	tntsc.TransactionContextHandler = new(CustomTransactionContext)
	tntsc.BeforeTransaction = GetWorldState
	tntsc.UnknownTransaction = UnknownTransactionHandler

	cc, err := contractapi.NewChaincode(tntsc)

	if err != nil {
		panic(err.Error())
	}

	if err := cc.Start(); err != nil {
		panic(err.Error())
	}
}
