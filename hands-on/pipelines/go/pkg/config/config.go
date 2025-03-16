package config

import (
	"os"
)

// Config holds all configuration options
type Config struct {
	Port        string
	Environment string
}

// Load returns application configuration from environment variables
// or defaults if not specified
func Load() (*Config, error) {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	env := os.Getenv("ENVIRONMENT")
	if env == "" {
		env = "development"
	}

	return &Config{
		Port:        port,
		Environment: env,
	}, nil
}

// IsDevelopment returns true if the current environment is development
func (c *Config) IsDevelopment() bool {
	return c.Environment == "development"
}

// IsProduction returns true if the current environment is production
func (c *Config) IsProduction() bool {
	return c.Environment == "production"
}
