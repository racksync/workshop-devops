import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Trend, Rate, Counter } from 'k6/metrics';
import { randomString } from 'https://jslib.k6.io/k6-utils/1.2.0/index.js';

// สร้าง custom metrics เพื่อติดตามข้อมูลเพิ่มเติม
const customTrend = new Trend('custom_trend_metric');
const customRate = new Rate('custom_rate_metric');
const customCounter = new Counter('custom_counter');

// กำหนดค่า options สำหรับการทดสอบ
export let options = {
  // กำหนดรูปแบบการเพิ่มโหลด (load stages)
  stages: [
    { duration: '20s', target: 10 },  // ค่อยๆ เพิ่มจำนวน VU เป็น 10
    { duration: '30s', target: 20 },  // เพิ่มจำนวน VU เป็น 20
    { duration: '20s', target: 0 },   // ค่อยๆ ลดจำนวน VU เป็น 0
  ],
  
  // กำหนดเกณฑ์การวัดผลการทดสอบ (thresholds)
  thresholds: {
    http_req_duration: ['p(95)<500', 'p(99)<1000'], // 95% ของ requests ต้องเสร็จภายใน 500ms และ 99% ภายใน 1วินาที
    http_req_failed: ['rate<0.1'],                  // อัตราความล้มเหลวต้องน้อยกว่า 10%
    'custom_trend_metric': ['avg<300', 'p(95)<500'], // ค่าเฉลี่ยของ metric ที่กำหนดเองต้องน้อยกว่า 300
  },
  
  // กำหนดชนิดของ tags ที่จะแสดงในรายงาน
  tags: {
    testName: 'advanced-api-test',
    environment: 'staging'
  }
};

export default function () {
  group('การทดสอบ API หลัก', function () {
    // ทดสอบ GET request
    const getResponse = http.get('https://test.k6.io/');
    
    // ตรวจสอบการตอบสนอง
    check(getResponse, {
      'GET status เป็น 200': (r) => r.status === 200,
      'GET response มีข้อมูล': (r) => r.body.length > 0,
    });
    
    // บันทึกค่าสำหรับ metrics ที่กำหนดเอง
    customTrend.add(getResponse.timings.duration);
    customRate.add(getResponse.status === 200);
    customCounter.add(1);
    
    // พัก 1 วินาที
    sleep(1);
  });
  
  group('การทดสอบ POST request', function () {
    // สร้างข้อมูลสำหรับส่ง POST
    const payload = JSON.stringify({
      username: `user_${randomString(5)}`,
      password: `pass_${randomString(8)}`
    });
    
    const params = {
      headers: { 'Content-Type': 'application/json' }
    };
    
    // ทดสอบ POST request
    const postResponse = http.post('https://test.k6.io/my_messages.php', payload, params);
    
    // ตรวจสอบการตอบสนอง
    check(postResponse, {
      'POST status เป็น 404 (เนื่องจากเป็น endpoint ที่ไม่มีอยู่จริง)': (r) => r.status === 404,
    });
    
    // พัก 2 วินาที
    sleep(2);
  });
  
  group('การทดสอบ API ที่มีความล่าช้า', function () {
    // ทดสอบ API ที่มีความล่าช้า
    const slowResponse = http.get('https://test.k6.io/sleep/2');
    
    // ตรวจสอบความล่าช้า
    check(slowResponse, {
      'API ตอบกลับภายใน 3 วินาที': (r) => r.timings.duration < 3000,
    });
    
    // บันทึกข้อมูลเพิ่มเติม
    console.log(`เวลาที่ใช้: ${slowResponse.timings.duration} ms`);
    
    // พัก 1 วินาที
    sleep(1);
  });
}
