# 🛒 E-commerce Website Load Testing

This exercise demonstrates how to load test an e-commerce website with realistic user behavior.

## 📋 Scenario

We'll simulate real users performing these actions:
1. Browsing the homepage
2. Searching for products
3. Adding products to cart
4. Proceeding to checkout
5. Completing a purchase

## 🔄 Test Scenarios

The test includes two separate user flows:
- **Browsers**: Users who only browse products but don't buy
- **Buyers**: Users who complete the full purchase flow

## 🛠️ Running the Test

### Using k6 directly

```bash
# Run the standard test
k6 run ecommerce-test.js

# Run with custom parameters and output to JSON
k6 run --out json=results.json ecommerce-test.js
```

### Using Docker with InfluxDB and Grafana

We've provided a Docker Compose setup to visualize results in real-time:

```bash
# Start the monitoring stack
docker-compose up -d influxdb grafana

# Run the test with output to InfluxDB
docker-compose run k6 run /scripts/ecommerce-test.js

# Access Grafana at http://localhost:3000
# Default credentials: admin/admin
```

## 📊 Analyzing Results

Look for these key metrics:
- **Shopping cart conversion rate**: How many users complete a purchase
- **Response times during checkout**: Critical for user experience
- **Error rates during high load**: When the system starts to fail

## 🎯 Business Metrics

The test includes custom metrics for business analysis:
- `checkout_success_rate`: Successful checkout transactions
- `cart_abandonment_rate`: Users who abandon their cart
- `product_view_rate`: Product page views

This helps connect technical performance to business impact.
