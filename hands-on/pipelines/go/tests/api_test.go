package tests

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gorilla/mux"
	"github.com/racksync/workshop-devops/hands-on/pipelines/go/pkg/api"
	"github.com/racksync/workshop-devops/hands-on/pipelines/go/pkg/models"
)

func TestGetStatus(t *testing.T) {
	// Create a new router and register routes
	r := mux.NewRouter()
	api.RegisterRoutes(r)

	// Create a request to /api/status
	req, err := http.NewRequest("GET", "/api/status", nil)
	if err != nil {
		t.Fatal(err)
	}

	// Create a recorder to capture the response
	rr := httptest.NewRecorder()
	r.ServeHTTP(rr, req)

	// Check the status code
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	// Check the response body
	var status models.Status
	if err := json.Unmarshal(rr.Body.Bytes(), &status); err != nil {
		t.Errorf("failed to unmarshal response: %v", err)
	}

	if status.Status != "operational" {
		t.Errorf("expected status to be 'operational', got %s", status.Status)
	}
}

func TestGetItems(t *testing.T) {
	// Create a new router and register routes
	r := mux.NewRouter()
	api.RegisterRoutes(r)

	// Create a request to /api/items
	req, err := http.NewRequest("GET", "/api/items", nil)
	if err != nil {
		t.Fatal(err)
	}

	// Create a recorder to capture the response
	rr := httptest.NewRecorder()
	r.ServeHTTP(rr, req)

	// Check the status code
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	// Check the response body
	var items []models.Item
	if err := json.Unmarshal(rr.Body.Bytes(), &items); err != nil {
		t.Errorf("failed to unmarshal response: %v", err)
	}

	if len(items) < 1 {
		t.Errorf("expected at least one item, got %d", len(items))
	}
}

func TestGetItemByID(t *testing.T) {
	// Create a new router and register routes
	r := mux.NewRouter()
	api.RegisterRoutes(r)

	// Create a request to /api/items/1
	req, err := http.NewRequest("GET", "/api/items/1", nil)
	if err != nil {
		t.Fatal(err)
	}

	// Create a recorder to capture the response
	rr := httptest.NewRecorder()
	r.ServeHTTP(rr, req)

	// Check the status code
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	// Check the response body
	var item models.Item
	if err := json.Unmarshal(rr.Body.Bytes(), &item); err != nil {
		t.Errorf("failed to unmarshal response: %v", err)
	}

	if item.ID != "1" {
		t.Errorf("expected item ID to be '1', got %s", item.ID)
	}
}
