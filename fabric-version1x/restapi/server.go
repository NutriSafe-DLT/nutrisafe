
/*
# This work is licensed under a Creative Commons Attribution 4.0 International License
# (http://creativecommons.org/licenses/by/4.0/).
#
# Author(s): Tim Reimers, Andreas Hermann
# NutriSafe Research Project
# Institute for Protection and Dependability
# Department of Computer Science
# Bundeswehr University Munich
*/


package main

import (
	"encoding/json"
	"log"
	"net/http"
	"strconv"

	"github.com/gorilla/mux"
)

type Product struct {
	ID			string `json:"id"`
	ImageNumber string `json:"imageNumber"`
	Name		string `json:"name"`
	Ingredients string `json:"ingredients"`
}

var products []Product

func getAllProducts(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(products)
}

func getProduct(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	params := mux.Vars(r)
	for _, item := range products {
		if item.ID == params["id"] {
			json.NewEncoder(w).Encode(item)
			return
		}
	}
}


func createProduct(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	var newProduct Product
	json.NewDecoder(r.Body).Decode(&newProduct)
	newProduct.ID = strconv.Itoa(len(products) + 1)

	products = append(products, newProduct)

	json.NewEncoder(w).Encode(newProduct)
}

func updateProduct(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	params := mux.Vars(r)
	for i, item := range products {
		if item.ID == params["id"] {
			products = append(products[:i], products[i+1:]...)
			var newProduct Product
			json.NewDecoder(r.Body).Decode(&newProduct)
			newProduct.ID = params["id"]
			products = append(products, newProduct)
			json.NewEncoder(w).Encode(newProduct)
			return
		}
	}
}


func deleteProduct(w http.ResponseWriter, r *http.Request) {
 w.Header().Set("Content-Type", "application/json")
 params := mux.Vars(r)
 for i, item := range products {
	 if item.ID == params["id"] {
		 products = append(products[:i], products[i+1:]...)
		 break
	 }
 }
 json.NewEncoder(w).Encode(products)
}

func main() {

	products = append(products, Product{ID: "1", ImageNumber: "8", Name: "Milk", Ingredients: "Milk, Water"})

	router := mux.NewRouter()

	router.HandleFunc("/product", getAllProducts).Methods("GET")
	router.HandleFunc("/product/{id}", getProduct).Methods("GET")
	router.HandleFunc("/product", createProduct).Methods("POST")
	router.HandleFunc("/product/{id}", updateProduct).Methods("POST")
	router.HandleFunc("/product/{id}", deleteProduct).Methods("DELETE")

	log.Fatal(http.ListenAndServe(":5000", router))
}
