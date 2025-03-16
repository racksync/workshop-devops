package api

import (
	"encoding/json"
	"net/http"
	"time"

	"github.com/gorilla/mux"
	"github.com/racksync/devops-workshop/hands-on/pipelines/go/pkg/models"
)

// RegisterRoutes sets up all the API routes
func RegisterRoutes(r *mux.Router) {
	api := r.PathPrefix("/api").Subrouter()
	api.HandleFunc("/status", getStatus).Methods("GET")
	api.HandleFunc("/items", getItems).Methods("GET")
	api.HandleFunc("/items/{id}", getItemByID).Methods("GET")
}

// getStatus returns current API status
func getStatus(w http.ResponseWriter, r *http.Request) {
	status := models.Status{
		Status:    "operational",
		Timestamp: time.Now().Format(time.RFC3339),
		Version:   "1.0.0",
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(status)
}

// getItems returns a list of items
func getItems(w http.ResponseWriter, r *http.Request) {
	items := []models.Item{
		{ID: "1", Name: "Item 1", Description: "First test item"},
		{ID: "2", Name: "Item 2", Description: "Second test item"},
		{ID: "3", Name: "Item 3", Description: "Third test item"},
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(items)
}

// getItemByID returns a single item by ID
func getItemByID(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	id := vars["id"]

	// Demo items map for testing
	items := map[string]models.Item{
		"1": {ID: "1", Name: "Item 1", Description: "First test item"},
		"2": {ID: "2", Name: "Item 2", Description: "Second test item"},
		"3": {ID: "3", Name: "Item 3", Description: "Third test item"},
	}

	if item, ok := items[id]; ok {
		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(item)
	} else {
		w.WriteHeader(http.StatusNotFound)
		json.NewEncoder(w).Encode(map[string]string{
			"error": "Item not found",
		})
	}
}
