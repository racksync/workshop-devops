import http from 'k6/http';
import { check, sleep } from 'k6';

// Track how many times we saw Version 1 vs. Version 2
let version1Count = 0;
let version2Count = 0;
let unknownVersionCount = 0;

// (Optional) keep a record of which Pod we hit
let podHits = {};

export let options = {
  vus: 600,         // number of virtual users
  duration: '30s', // total test duration
};

export default function () {
  let res = http.get('http://lb.k8s.local'); // or your LB's hostname / IP

  // Add detailed logging for troubleshooting
  console.log(`Status: ${res.status}, Content length: ${res.body.length}, Type: ${res.headers['Content-Type']}`);
  
  if (res.status !== 200) {
    console.log(`Error: Non-200 response: ${res.status}`);
    return;
  }

  // Log a small sample of the body for debugging
  console.log(`Response sample: ${res.body.substring(0, 100)}...`);

  // 1) Detect which version we got
  if (res.body.includes('Version 1')) {
    version1Count++;
    console.log('Detected Version 1');
  } else if (res.body.includes('Version 2')) {
    version2Count++;
    console.log('Detected Version 2');
  } else {
    unknownVersionCount++;
    console.log('Unknown version detected');
  }

  // 2) Extract Pod name from the HTML:
  //    Modified to match the format: <p>Pod: #2</p>
  let match = /<p>Pod:\s*(.*?)<\/p>/.exec(res.body);
  if (match) {
    let podName = match[1].trim();      // e.g. "#2"
    podHits[podName] = (podHits[podName] || 0) + 1;
  }

  sleep(1);
}

// At the end of the test, we print a summary
export function handleSummary(data) {
  console.log(`\n===== Test Summary =====`);
  console.log(`Version 1 responses: ${version1Count}`);
  console.log(`Version 2 responses: ${version2Count}`);
  console.log(`Unknown version responses: ${unknownVersionCount}`);
  console.log(`\nPod Hits:\n`, podHits);
  
  // Log more detailed info if we have an issue
  if (version1Count === 0 && version2Count === 0) {
    console.log("\nPossible issues:");
    console.log("1. Load balancer URL may be incorrect");
    console.log("2. Both version deployments might not be running");
    console.log("3. Network connectivity issues between k6 and the cluster");
    console.log("4. HTML format may have changed (check if 'Version X' text exists)");
  }

  // Return an empty object to avoid saving any special output
  return {};
}
