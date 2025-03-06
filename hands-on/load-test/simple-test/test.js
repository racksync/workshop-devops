import http from 'k6/http';
import { sleep } from 'k6';

export let options = {
  vus: 10,         // จำนวน Virtual Users
  duration: '30s', // ระยะเวลาทดสอบ 30 วินาที
};

export default function () {
  http.get('https://test.k6.io'); // URL ที่ต้องการทดสอบ
  sleep(1); // พัก 1 วินาทีระหว่างคำขอ
}
