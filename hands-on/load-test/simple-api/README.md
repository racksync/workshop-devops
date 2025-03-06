# 🚀 Simple API Load Testing

This exercise demonstrates how to load test a REST API with authentication and multiple endpoints.

## 📋 Scenario

We'll test a REST API with the following workflow:
1. User authentication (login)
2. Retrieving a list of products
3. Getting product details
4. Checking user profile

## 🛠️ Running the Test

### Using k6 directly

```bash
# Run the standard test
k6 run load-test.js

# Run with custom parameters
k6 run --vus 50 --duration 30s load-test.js
```

### Using Docker

```bash
# Run the test using Docker
docker run -i grafana/k6 run - <load-test.js

# Run with custom parameters
docker run -i grafana/k6 run --vus 50 --duration 30s - <load-test.js
```

## 📊 Understanding the Results

After running the test, k6 will output metrics including:

- **http_req_duration**: How long requests take to complete (important!)
- **http_reqs**: Total number of requests made
- **vus**: Number of virtual users
- **iterations**: Total number of iterations completed

## 🧪 Test Variations

Try modifying the test with these variations:

1. **Increase load gradually**:
   - Edit the stages in the options to create a gradual ramp-up

2. **Add thresholds**:
   - Add performance requirements like `http_req_duration: ['p(95)<500']`

3. **Test error scenarios**:
   - Try with invalid credentials or endpoints
