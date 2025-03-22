import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom business metrics
const checkoutSuccessRate = new Rate('checkout_success_rate');
const cartAbandonmentRate = new Rate('cart_abandonment_rate');
const productViewRate = new Rate('product_view_rate');
const sessionDuration = new Trend('session_duration');

// Test configuration with multiple scenarios
export const options = {
  scenarios: {
    // Browsers: users who just browse products
    browsers: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '1m', target: 50 },   // Ramp up to 50 browsers
        { duration: '3m', target: 50 },   // Stay at 50 browsers
        { duration: '1m', target: 0 },    // Ramp down to 0
      ],
      exec: 'browserFlow',                // Use the browserFlow function
    },
    // Buyers: users who complete purchases
    buyers: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '1m', target: 10 },   // Ramp up to 10 buyers
        { duration: '3m', target: 10 },   // Stay at 10 buyers
        { duration: '1m', target: 0 },    // Ramp down to 0
      ],
      exec: 'buyerFlow',                  // Use the buyerFlow function
    },
  },
  thresholds: {
    http_req_duration: ['p(95)<3000'],     // 95% of requests under 3s
    'http_req_duration{page:home}': ['p(95)<1000'],      // Homepage loads under 1s
    'http_req_duration{page:product}': ['p(95)<2000'],   // Product page under 2s
    'http_req_duration{page:checkout}': ['p(95)<3000'],  // Checkout under 3s
    'checkout_success_rate': ['rate>0.9'],               // 90% checkout success
    'cart_abandonment_rate': ['rate<0.2'],               // Less than 20% abandonment
  },
};

// Base URL of the e-commerce site
const BASE_URL = 'https://ecommerce-sample.k6.io'; // Fictional example URL

// Categories and popular products for realistic browsing
const categories = ['electronics', 'clothing', 'home', 'books', 'toys'];
const popularProducts = [
  'smartphone-deluxe',
  'wireless-earbuds',
  'cotton-t-shirt',
  'chef-cooking-set',
  'bestseller-novel',
];
const searchTerms = ['gadget', 'gift', 'sale', 'new', 'popular'];

// Browser user flow - browsing but not buying
export function browserFlow() {
  const sessionStart = new Date().getTime();
  
  group('Homepage Visit', () => {
    const homeRes = http.get(`${BASE_URL}/`, {
      tags: { page: 'home' },
    });
    
    check(homeRes, {
      'homepage loaded': (r) => r.status === 200,
    });
  });
  
  // 50% chance to use search, 50% chance to browse categories
  if (Math.random() < 0.5) {
    group('Product Search', () => {
      const searchTerm = searchTerms[Math.floor(Math.random() * searchTerms.length)];
      const searchRes = http.get(`${BASE_URL}/search?q=${searchTerm}`, {
        tags: { page: 'search' },
      });
      
      check(searchRes, {
        'search results loaded': (r) => r.status === 200,
      });
      
      sleep(Math.random() * 3 + 2); // 2-5 seconds viewing search results
    });
  } else {
    group('Category Browsing', () => {
      const category = categories[Math.floor(Math.random() * categories.length)];
      const categoryRes = http.get(`${BASE_URL}/category/${category}`, {
        tags: { page: 'category' },
      });
      
      check(categoryRes, {
        'category page loaded': (r) => r.status === 200,
      });
      
      sleep(Math.random() * 3 + 2); // 2-5 seconds viewing category
    });
  }
  
  // View 1-3 products
  const numProductsToView = Math.floor(Math.random() * 3) + 1;
  
  for (let i = 0; i < numProductsToView; i++) {
    group('Product View', () => {
      const product = popularProducts[Math.floor(Math.random() * popularProducts.length)];
      const productRes = http.get(`${BASE_URL}/product/${product}`, {
        tags: { page: 'product' },
      });
      
      check(productRes, {
        'product page loaded': (r) => r.status === 200,
      });
      
      productViewRate.add(1);
      sleep(Math.random() * 10 + 5); // 5-15 seconds viewing the product
    });
  }
  
  // Record session duration
  const sessionEnd = new Date().getTime();
  sessionDuration.add((sessionEnd - sessionStart) / 1000);
}

// Buyer user flow - complete purchase journey
export function buyerFlow() {
  const sessionStart = new Date().getTime();
  let cartAbandoned = false;
  
  group('Homepage Visit', () => {
    const homeRes = http.get(`${BASE_URL}/`, {
      tags: { page: 'home' },
    });
    
    check(homeRes, {
      'homepage loaded': (r) => r.status === 200,
    });
    
    sleep(Math.random() * 3 + 1); // 1-4 seconds on homepage
  });
  
  // Browse products
  group('Product Browsing', () => {
    // First look at a category
    const category = categories[Math.floor(Math.random() * categories.length)];
    const categoryRes = http.get(`${BASE_URL}/category/${category}`, {
      tags: { page: 'category' },
    });
    
    sleep(Math.random() * 5 + 2); // 2-7 seconds on category page
    
    // Then view a specific product
    const product = popularProducts[Math.floor(Math.random() * popularProducts.length)];
    const productRes = http.get(`${BASE_URL}/product/${product}`, {
      tags: { page: 'product' },
    });
    
    check(productRes, {
      'product page loaded': (r) => r.status === 200,
    });
    
    productViewRate.add(1);
    sleep(Math.random() * 8 + 5); // 5-13 seconds viewing the product
  });
  
  // Add to cart
  group('Add to Cart', () => {
    const addToCartRes = http.post(`${BASE_URL}/cart/add`, JSON.stringify({
      productId: 'product-12345',
      quantity: 1,
    }), {
      headers: { 'Content-Type': 'application/json' },
      tags: { page: 'cart' },
    });
    
    check(addToCartRes, {
      'item added to cart': (r) => r.status === 200,
    });
    
    sleep(Math.random() * 2 + 1); // 1-3 seconds after adding to cart
    
    // View cart
    const cartRes = http.get(`${BASE_URL}/cart`, {
      tags: { page: 'cart' },
    });
    
    check(cartRes, {
      'cart page loaded': (r) => r.status === 200,
    });
    
    sleep(Math.random() * 5 + 3); // 3-8 seconds reviewing the cart
    
    // 80% chance to proceed to checkout, 20% to abandon
    if (Math.random() < 0.8) {
      // Proceed to checkout
    } else {
      cartAbandoned = true;
      cartAbandonmentRate.add(1);
      return; // End the session here - cart abandoned
    }
  });
  
  // Proceed with checkout if cart wasn't abandoned
  if (!cartAbandoned) {
    group('Checkout', () => {
      // Checkout step 1: Shipping information
      const checkoutStep1Res = http.post(`${BASE_URL}/checkout/shipping`, JSON.stringify({
        name: 'Test User',
        address: '123 Test St',
        city: 'Test City',
        country: 'Test Country',
        zipCode: '12345',
      }), {
        headers: { 'Content-Type': 'application/json' },
        tags: { page: 'checkout' },
      });
      
      check(checkoutStep1Res, {
        'shipping info accepted': (r) => r.status === 200,
      });
      
      sleep(Math.random() * 5 + 5); // 5-10 seconds filling shipping info
      
      // Checkout step 2: Payment information
      const checkoutStep2Res = http.post(`${BASE_URL}/checkout/payment`, JSON.stringify({
        cardType: 'visa',
        cardNumber: '4111111111111111',
        expMonth: '12',
        expYear: '2030',
        cvv: '123',
      }), {
        headers: { 'Content-Type': 'application/json' },
        tags: { page: 'checkout' },
      });
      
      let paymentSuccessful = check(checkoutStep2Res, {
        'payment info accepted': (r) => r.status === 200,
      });
      
      sleep(Math.random() * 3 + 2); // 2-5 seconds processing payment
      
      // Checkout step 3: Confirmation
      if (paymentSuccessful) {
        const confirmationRes = http.post(`${BASE_URL}/checkout/confirm`, {}, {
          tags: { page: 'confirmation' },
        });
        
        const orderSuccess = check(confirmationRes, {
          'order confirmed': (r) => r.status === 200,
          'order has confirmation number': (r) => r.json('orderNumber') !== undefined,
        });
        
        checkoutSuccessRate.add(orderSuccess ? 1 : 0);
        
        sleep(Math.random() * 3 + 2); // 2-5 seconds on confirmation page
      } else {
        checkoutSuccessRate.add(0);
        cartAbandonmentRate.add(1);
      }
    });
  }
  
  // Record session duration
  const sessionEnd = new Date().getTime();
  sessionDuration.add((sessionEnd - sessionStart) / 1000);
}

// Default function that k6 calls if no specific scenario exec is defined
export default function() {
  // 80% of users are browsers, 20% are buyers
  if (Math.random() < 0.8) {
    browserFlow();
  } else {
    buyerFlow();
  }
}
