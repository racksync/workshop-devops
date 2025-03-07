import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');

export const options = {
  // Basic test configuration
  vus: 10,
  duration: '30s',
  
  // Advanced configuration with stages (ramping pattern)
  stages: [
    { duration: '1m', target: 20 },  // Ramp up to 20 users over 1 minute
    { duration: '3m', target: 20 },  // Stay at 20 users for 3 minutes
    { duration: '1m', target: 0 },   // Ramp down to 0 users over 1 minute
  ],
  
  // Performance thresholds
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% of requests should be below 500ms
    errors: ['rate<0.1'],              // Error rate should be less than 10%
  }
};

const BASE_URL = 'https://test-api.k6.io'; // Using k6's test API

export default function() {
  let authToken;
  
  group('Authentication Flow', () => {
    // Login request
    const loginRes = http.post(`${BASE_URL}/auth/token/login/`, {
      username: 'testuser',
      password: 'testpassword'
    });
    
    // Verify successful login and extract token
    const checkLogin = check(loginRes, {
      'login status is 200': (r) => r.status === 200,
      'has access token': (r) => r.json('access_token') !== undefined,
    });
    
    if (!checkLogin) {
      errorRate.add(1);
      return;
    }
    
    authToken = loginRes.json('access_token');
  });
  
  // Set up authorization header for subsequent requests
  const headers = {
    'Authorization': `Bearer ${authToken || 'invalid-token'}`,
    'Content-Type': 'application/json'
  };
  
  group('Product API Calls', () => {
    // Get list of products
    const productsRes = http.get(`${BASE_URL}/products`, {
      headers: headers,
    });
    
    check(productsRes, {
      'products status is 200': (r) => r.status === 200,
      'has products': (r) => Array.isArray(r.json()),
    });
    
    // If products exist, get details for first product
    if (productsRes.status === 200 && Array.isArray(productsRes.json()) && productsRes.json().length > 0) {
      const productId = productsRes.json()[0].id;
      
      const productDetailRes = http.get(`${BASE_URL}/products/${productId}`, {
        headers: headers,
      });
      
      check(productDetailRes, {
        'product detail status is 200': (r) => r.status === 200,
        'has product details': (r) => r.json('name') !== undefined,
      });
    }
  });
  
  group('User Profile', () => {
    // Get user profile information
    const profileRes = http.get(`${BASE_URL}/my/account`, {
      headers: headers,
    });
    
    check(profileRes, {
      'profile status is 200': (r) => r.status === 200,
      'has user info': (r) => r.json('email') !== undefined,
    });
  });
  
  // Simulate user think time between actions
  sleep(Math.random() * 3 + 1); // 1-4 seconds
}
