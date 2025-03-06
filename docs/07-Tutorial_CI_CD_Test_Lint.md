# CI/CD Testing & Linting Workshop

## 📑 สารบัญ

- [1. บทนำสู่การทดสอบและ Linting ใน CI/CD](#-1-บทนำสู่การทดสอบและ-linting-ใน-cicd)
- [2. พื้นฐานของ Unit Testing](#-2-พื้นฐานของ-unit-testing)
- [3. Integration Testing ใน CI/CD](#-3-integration-testing-ใน-cicd)
- [4. Code Linting และการวิเคราะห์โค้ดแบบ Static](#-4-code-linting-และการวิเคราะห์โค้ดแบบ-static)
- [5. Code Coverage](#-5-code-coverage)
- [6. การสแกนความปลอดภัย](#-6-การสแกนความปลอดภัย)
- [7. การทดสอบประสิทธิภาพ](#-7-การทดสอบประสิทธิภาพ)
- [8. การใช้งาน GitHub Actions](#-8-การใช้งาน-github-actions)
- [9. การใช้งาน GitLab CI](#-9-การใช้งาน-gitlab-ci)
- [10. การใช้งาน Bitbucket Pipelines](#-10-การใช้งาน-bitbucket-pipelines)
- [11. แนวทางปฏิบัติที่ดีที่สุด](#-11-แนวทางปฏิบัติที่ดีที่สุด)
- [12. การตั้งค่าขั้นสูง](#-12-การตั้งค่าขั้นสูง)

## 🔹 1. บทนำสู่การทดสอบและ Linting ใน CI/CD

### การทดสอบใน CI/CD คืออะไร?

การทดสอบใน Continuous Integration และ Continuous Deployment (CI/CD) คือกระบวนการอัตโนมัติที่ตรวจสอบว่าโค้ดของคุณทำงานได้ตามที่คาดหวังก่อนที่จะถูกรวมเข้ากับโค้ดหลักหรือนำไปใช้งานบนระบบ Production การทดสอบอัตโนมัติช่วยให้คุณ:

- ค้นพบข้อบกพร่องตั้งแต่ช่วงต้นของการพัฒนา
- ป้องกันการเกิดข้อผิดพลาดซ้ำ (regression bugs)
- ปรับปรุงคุณภาพของโค้ด
- เพิ่มความมั่นใจในการ Deploy
- ช่วยให้พัฒนาได้รวดเร็วมากขึ้น

### Linting คืออะไร?

Linting คือกระบวนการรันโปรแกรมที่วิเคราะห์โค้ดเพื่อหาข้อผิดพลาดเชิงไวยากรณ์และรูปแบบ เครื่องมือ linter จะ:

- ระบุข้อผิดพลาดที่อาจเกิดขึ้น
- บังคับใช้มาตรฐานและข้อกำหนดในการเขียนโค้ด
- เน้นความไม่สอดคล้องของรูปแบบ
- แจ้งเตือนโครงสร้างที่น่าสงสัย
- บังคับใช้แนวทางปฏิบัติที่ดีที่สุด

### ทำไมต้องทำ Testing และ Linting ใน CI/CD?

```mermaid
graph TD
    A[การเปลี่ยนแปลงโค้ด] --> B[การทดสอบและ Linting อัตโนมัติ]
    B -->|ล้มเหลว| C[แก้ไขปัญหา]
    C --> A
    B -->|ผ่าน| D[Merge/Deploy]
    D --> E[Production]
```

- **คุณภาพ**: การทดสอบและ linting อัตโนมัติทำหน้าที่เป็นตัวช่วยตรวจสอบคุณภาพที่ป้องกันไม่ให้โค้ดที่มีปัญหาเข้าถึงระบบ production
- **ความสม่ำเสมอ**: ทำให้แน่ใจว่าโค้ดทั้งหมดเป็นไปตามมาตรฐานเดียวกันโดยไม่ขึ้นอยู่กับว่าใครเป็นคนเขียน
- **เอกสาร**: การทดสอบทำหน้าที่เป็นเอกสารประกอบว่าโค้ดควรทำงานอย่างไร
- **ความมั่นใจ**: เพิ่มความมั่นใจในการเปลี่ยนแปลงและปรับโครงสร้างโค้ด
- **ความเร็ว**: ทำให้การตรวจสอบที่ซ้ำซากเป็นไปโดยอัตโนมัติซึ่งหากทำด้วยมือจะใช้เวลามาก

### ประเภทของการทดสอบใน CI/CD

| ประเภท | คำอธิบาย | เครื่องมือ | ควรรันเมื่อไหร่ |
|------|-------------|-------|------------|
| Unit Testing | ทดสอบฟังก์ชันหรือคอมโพเนนต์แยกเป็นหน่วยเล็กๆ | Jest, JUnit, pytest | ทุกครั้งที่มีการ commit |
| Integration Testing | ทดสอบการทำงานร่วมกันระหว่างคอมโพเนนต์ | Supertest, TestContainers | ทุกครั้งที่มีการ commit |
| End-to-End Testing | ทดสอบการไหลของงานทั้งหมดในมุมมองของผู้ใช้ | Cypress, Selenium | เมื่อ merge เข้า branch หลัก |
| Security Scanning | ตรวจหาช่องโหว่ด้านความปลอดภัย | OWASP ZAP, Snyk | ทุกครั้งที่ commit หรือรายวัน |
| Performance Testing | วัดประสิทธิภาพของแอปพลิเคชัน | k6, JMeter | เมื่อ merge เข้า branch หลัก |
| Static Analysis | วิเคราะห์โค้ดโดยไม่ต้องรันโปรแกรม | ESLint, SonarQube | ทุกครั้งที่มีการ commit |

## 🔹 2. พื้นฐานของ Unit Testing

### Unit Tests คืออะไร?

Unit tests คือการทดสอบที่ตรวจสอบว่าส่วนย่อยของโค้ด (ฟังก์ชัน, เมธอด, คลาส) ทำงานอย่างถูกต้องแบบแยกจากระบบอื่น โดยมีลักษณะดังนี้:

- รันได้รวดเร็ว
- เขียนง่าย
- มุ่งเน้นที่ฟังก์ชันการทำงานเดียว
- เป็นอิสระจากระบบภายนอก

### เฟรมเวิร์คสำหรับ Unit Testing แยกตามภาษา

| ภาษา | เฟรมเวิร์คยอดนิยม | รูปแบบการตั้งชื่อไฟล์ทดสอบ |
|----------|-------------------|-----------------|
| JavaScript | Jest, Mocha, Jasmine | `*.test.js`, `*.spec.js` |
| Python | pytest, unittest | `test_*.py`, `*_test.py` |
| Java | JUnit, TestNG | `*Test.java` |
| Go | built-in testing package | `*_test.go` |
| C# | NUnit, xUnit.NET | `*.Tests.cs` |
| Ruby | RSpec, Minitest | `*_spec.rb`, `*_test.rb` |

### ตัวอย่าง: การทดสอบ JavaScript ด้วย Jest

```javascript
// functions.js
function add(a, b) {
  return a + b;
}

function multiply(a, b) {
  return a * b;
}

module.exports = { add, multiply };
```

```javascript
// functions.test.js
const { add, multiply } = require('./functions');

describe('ฟังก์ชันคณิตศาสตร์', () => {
  test('add คำนวณ a + b ได้ถูกต้อง', () => {
    expect(add(1, 2)).toBe(3);
    expect(add(-1, 1)).toBe(0);
    expect(add(5, 0)).toBe(5);
  });

  test('multiply คำนวณ a * b ได้ถูกต้อง', () => {
    expect(multiply(1, 2)).toBe(2);
    expect(multiply(-1, 1)).toBe(-1);
    expect(multiply(5, 0)).toBe(0);
  });
});
```

### ตัวอย่าง: การทดสอบ Python ด้วย pytest

```python
# functions.py
def add(a, b):
    return a + b

def multiply(a, b):
    return a * b
```

```python
# test_functions.py
import pytest
from functions import add, multiply

def test_add():
    assert add(1, 2) == 3
    assert add(-1, 1) == 0
    assert add(5, 0) == 5

def test_multiply():
    assert multiply(1, 2) == 2
    assert multiply(-1, 1) == -1
    assert multiply(5, 0) == 0
```

### การรัน Unit Tests ใน CI

ตัวอย่างการตั้งค่าพื้นฐานเพื่อรัน unit tests ใน CI:

```yaml
# ตัวอย่างขั้นตอนสำหรับ GitHub Actions
steps:
  - uses: actions/checkout@v3
  - name: ตั้งค่า Node.js
    uses: actions/setup-node@v3
    with:
      node-version: '16'
  - name: ติดตั้ง dependencies
    run: npm ci
  - name: รัน unit tests
    run: npm test
```

## 🔹 3. Integration Testing ใน CI/CD

### Integration Tests คืออะไร?

Integration tests คือการทดสอบที่ตรวจสอบว่าส่วนต่างๆ ของแอปพลิเคชันของคุณทำงานร่วมกันได้อย่างถูกต้อง ซึ่งแตกต่างจาก unit tests ตรงที่:

- ทดสอบการทำงานร่วมกันระหว่างคอมโพเนนต์
- อาจต้องใช้ dependencies ภายนอก (ฐานข้อมูล, APIs)
- ใช้เวลารันนานกว่า
- ทดสอบสถานการณ์ที่สมจริงมากขึ้น

### เครื่องมือ Integration Testing ที่นิยมใช้

- **API Testing**: Supertest, REST Assured, Postman
- **Database Testing**: TestContainers, Database Rider
- **Message Queues**: LocalStack (สำหรับบริการ AWS)
- **Mocking External Services**: WireMock, MSW (Mock Service Worker)

### ตัวอย่าง: การทดสอบ API ด้วย Supertest (Node.js)

```javascript
// app.js
const express = require('express');
const app = express();

app.get('/api/users', (req, res) => {
  res.json([
    { id: 1, name: 'อลิซ' },
    { id: 2, name: 'บ็อบ' }
  ]);
});

module.exports = app;
```

```javascript
// app.test.js
const request = require('supertest');
const app = require('./app');

describe('User API', () => {
  test('GET /api/users ส่งคืนรายการผู้ใช้', async () => {
    const response = await request(app)
      .get('/api/users')
      .expect('Content-Type', /json/)
      .expect(200);
    
    expect(response.body).toHaveLength(2);
    expect(response.body[0].name).toBe('อลิซ');
    expect(response.body[1].name).toBe('บ็อบ');
  });
});
```

### การใช้ Docker สำหรับ Integration Testing

Docker containers สามารถสร้างสภาพแวดล้อมที่แยกสำหรับการทดสอบแบบ integration:

```yaml
# ตัวอย่าง GitHub Actions workflow ที่ใช้ Docker
name: Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_USER: postgres
          POSTGRES_DB: test_db
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v3
      - name: ตั้งค่า Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '16'
      - name: ติดตั้ง dependencies
        run: npm ci
      - name: รัน integration tests
        run: npm run test:integration
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
```

## 🔹 4. Code Linting และการวิเคราะห์โค้ดแบบ Static

### Code Linting คืออะไร?

Code Linting คือกระบวนการตรวจสอบซอร์สโค้ดเพื่อหาข้อผิดพลาดทางไวยากรณ์และรูปแบบ ซึ่งมีประโยชน์ดังนี้:

- รักษาความสม่ำเสมอของรูปแบบโค้ดในทีม
- ค้นพบข้อผิดพลาดที่อาจเกิดขึ้นตั้งแต่เนิ่นๆ
- บังคับใช้แนวปฏิบัติที่ดีที่สุด
- ปรับปรุงคุณภาพโค้ด
- ทำให้อ่านได้ง่ายขึ้น

### เครื่องมือ Linting ยอดนิยมตามภาษา

| ภาษา | เครื่องมือ | ไฟล์การตั้งค่า |
|----------|-------|---------------------|
| JavaScript/TypeScript | ESLint, JSHint, StandardJS | `.eslintrc`, `.jshintrc` |
| Python | Pylint, Flake8, Black | `.pylintrc`, `setup.cfg` |
| Java | Checkstyle, PMD, SpotBugs | `checkstyle.xml`, `pmd.xml` |
| Ruby | RuboCop | `.rubocop.yml` |
| Go | golint, golangci-lint | `.golangci.yml` |
| CSS/SCSS | Stylelint | `.stylelintrc` |

### ตัวอย่าง: JavaScript Linting ด้วย ESLint

**การติดตั้ง**:
```bash
npm install --save-dev eslint
```

**การตั้งค่า (.eslintrc.js)**:
```javascript
module.exports = {
  env: {
    node: true,
    es2021: true,
    jest: true,
  },
  extends: ['eslint:recommended'],
  parserOptions: {
    ecmaVersion: 12,
    sourceType: 'module',
  },
  rules: {
    'no-unused-vars': 'warn',
    'no-console': 'warn',
    'quotes': ['error', 'single'],
    'semi': ['error', 'always'],
  },
};
```

**การรัน ESLint**:
```bash
npx eslint src/
```

### ตัวอย่าง: Python Linting ด้วย Flake8

**การติดตั้ง**:
```bash
pip install flake8
```

**การตั้งค่า (setup.cfg)**:
```ini
[flake8]
max-line-length = 100
exclude = .git,__pycache__,build,dist
ignore = E203, W503
```

**การรัน Flake8**:
```bash
flake8 .
```

### การวิเคราะห์แบบ Static ด้วย SonarQube

SonarQube เป็นแพลตฟอร์มสำหรับการตรวจสอบคุณภาพโค้ดอย่างต่อเนื่อง:

```yaml
# ตัวอย่าง GitHub Actions workflow ที่ใช้ SonarCloud
name: SonarCloud Analysis

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  sonarcloud:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
        with:
          args: >
            -Dsonar.projectKey=my-project
            -Dsonar.organization=my-organization
```

## 🔹 5. Code Coverage

### Code Coverage คืออะไร?

Code Coverage วัดว่าโค้ดของคุณถูกทดสอบมากน้อยเพียงใดในระหว่างการรันเทสต์ ช่วยให้สามารถระบุส่วนของโค้ดที่ยังไม่ได้รับการทดสอบและประเมินคุณภาพของการทดสอบ

ประเภทของเมตริก code coverage:
- **Line coverage**: เปอร์เซ็นต์ของบรรทัดโค้ดที่ถูกรัน
- **Branch coverage**: เปอร์เซ็นต์ของเงื่อนไข (if/else) ที่ถูกทดสอบ
- **Function coverage**: เปอร์เซ็นต์ของฟังก์ชันที่ถูกเรียกใช้
- **Statement coverage**: เปอร์เซ็นต์ของคำสั่งที่ถูกทดสอบ

### การตั้งค่าเป้าหมาย Code Coverage

เฟรมเวิร์คการทดสอบส่วนใหญ่อนุญาตให้ตั้งค่าข้อกำหนด coverage ขั้นต่ำ:

**Jest (JavaScript)**:
```json
{
  "jest": {
    "coverageThreshold": {
      "global": {
        "branches": 80,
        "functions": 80,
        "lines": 80,
        "statements": 80
      }
    }
  }
}
```

**pytest-cov (Python)**:
```ini
[coverage:report]
fail_under = 80
```

### การสร้างรายงาน Coverage

**JavaScript ด้วย Jest**:
```bash
jest --coverage
```

**Python ด้วย pytest**:
```bash
pytest --cov=src --cov-report=xml
```

### การเผยแพร่รายงาน Coverage

**ตัวอย่างกับ GitHub Actions**:
```yaml
steps:
  # รันเทสต์พร้อม coverage
  - name: รัน tests พร้อม coverage
    run: npm test -- --coverage
  
  # อัปโหลดรายงาน coverage
  - name: อัปโหลดรายงาน coverage
    uses: codecov/codecov-action@v3
    with:
      token: ${{ secrets.CODECOV_TOKEN }}
      file: ./coverage/coverage-final.json
      fail_ci_if_error: true
```

## 🔹 6. การสแกนความปลอดภัย

### ประเภทของการสแกนความปลอดภัย

1. **Static Application Security Testing (SAST)**:
   - วิเคราะห์ซอร์สโค้ดเพื่อค้นหาช่องโหว่ด้านความปลอดภัย
   - รันโดยไม่ต้องทำงานแอปพลิเคชัน
   - ตัวอย่าง: SonarQube, Checkmarx, Snyk Code

2. **Software Composition Analysis (SCA)**:
   - สแกนการพึ่งพา (dependencies) เพื่อหาช่องโหว่ที่รู้จัก
   - ระบุแพ็คเกจที่ล้าสมัยหรือไม่ปลอดภัย
   - ตัวอย่าง: Snyk, OWASP Dependency-Check, WhiteSource

3. **Dynamic Application Security Testing (DAST)**:
   - ทดสอบแอปพลิเคชันที่กำลังทำงานเพื่อหาช่องโหว่
   - จำลองการโจมตีจากภายนอก
   - ตัวอย่าง: OWASP ZAP, Burp Suite

4. **Infrastructure as Code (IaC) Scanning**:
   - สแกนการกำหนดโครงสร้างพื้นฐานเพื่อหาปัญหาด้านความปลอดภัย
   - ตัวอย่าง: Checkov, tfsec, Snyk IaC

### ตัวอย่าง: การสแกนการพึ่งพา (Dependencies) ด้วย Snyk

**GitHub Actions**:
```yaml
name: การสแกนความปลอดภัย

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 0 * * 0'  # สแกนรายสัปดาห์

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: รัน Snyk เพื่อตรวจหาช่องโหว่
        uses: snyk/actions/node@master
        env:
          SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
        with:
          args: --severity-threshold=high
```

### ตัวอย่าง: การสแกนด้วย OWASP ZAP

**GitHub Actions**:
```yaml
name: OWASP ZAP Scan

on:
  workflow_dispatch:
  schedule:
    - cron: '0 0 * * 0'  # สแกนรายสัปดาห์

jobs:
  zap_scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      
      - name: ZAP Scan
        uses: zaproxy/action-baseline@v0.7.0
        with:
          target: 'https://www.example.com'
          rules_file_name: '.zap/rules.tsv'
```

**GitLab CI**:
```yaml
zap_scan:
  image: owasp/zap2docker-stable
  stage: security
  script:
    - zap-baseline.py -t https://www.example.com -r zap_report.html
  artifacts:
    paths:
      - zap_report.html
```

### ตัวอย่าง: การสแกนหาข้อมูลที่ละเอียดอ่อน (Secrets) ด้วย GitLeaks

**GitHub Actions**:
```yaml
name: Secret Scanning

on: [push, pull_request]

jobs:
  gitleaks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - name: รัน Gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**GitLab CI**:
```yaml
gitleaks_scan:
  image: zricethezav/gitleaks
  stage: security
  script:
    - gitleaks --path . --report-format json --report-path gitleaks_report.json
  artifacts:
    paths:
      - gitleaks_report.json
```

## 🔹 7. การทดสอบประสิทธิภาพ

### บทนำสู่การทดสอบประสิทธิภาพใน CI/CD

การทดสอบประสิทธิภาพใน CI/CD pipelines ช่วยให้มั่นใจว่าการเปลี่ยนแปลงโค้ดไม่ส่งผลเสียต่อประสิทธิภาพของแอปพลิเคชัน ประเภทของการทดสอบมีดังนี้:

- **Load testing**: ทดสอบการทำงานของระบบภายใต้โหลดที่คาดหวัง
- **Stress testing**: ค้นหาจุดล้มเหลวภายใต้สภาวะสุดขีด
- **Endurance testing**: ทดสอบพฤติกรรมของระบบในช่วงเวลายาวนาน
- **Spike testing**: ทดสอบการตอบสนองของระบบต่อการเพิ่มโหลดอย่างฉับพลัน

### ตัวอย่าง: การทดสอบโหลดด้วย k6

**ติดตั้ง k6**:
```bash
npm install -g k6
```

**สร้างสคริปต์ทดสอบ (load-test.js)**:
```javascript
import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  vus: 10,  // 10 virtual users
  duration: '30s',
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% ของคำขอต้องเสร็จสิ้นภายใน 500ms
  },
};

export default function () {
  http.get('https://test.example.com/api/users');
  sleep(1);
}
```

**การรวม k6 เข้ากับ GitHub Actions**:
```yaml
name: Performance Testing

on:
  push:
    branches: [ main ]

jobs:
  k6_load_test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: รันการทดสอบโหลดด้วย k6
        uses: grafana/k6-action@v0.2.0
        with:
          filename: load-test.js
          flags: --out json=results.json
      - name: อัปโหลดผลการทดสอบประสิทธิภาพ
        uses: actions/upload-artifact@v3
        with:
          name: k6-report
          path: results.json
```

## 🔹 8. การใช้งาน GitHub Actions

### Workflow สำหรับโปรเจค JavaScript แบบสมบูรณ์

```yaml
name: JavaScript CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: ตั้งค่า Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '16'
          cache: 'npm'
          
      - name: ติดตั้ง dependencies
        run: npm ci
        
      - name: Lint code
        run: npm run lint
        
      - name: Run tests with coverage
        run: npm test -- --coverage
      
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
      
      - name: Check dependencies for vulnerabilities
        run: npm audit --audit-level=high
        continue-on-error: true

  sonarcloud:
    runs-on: ubuntu-latest
    needs: test
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

### Workflow สำหรับโปรเจค Python แบบสมบูรณ์

```yaml
name: Python CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8, 3.9, '3.10']
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_USER: postgres
          POSTGRES_DB: test_db
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
          cache: 'pip'
          
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install pytest pytest-cov flake8
          if [ -f requirements.txt ]; then pip install -r requirements.txt; fi
          
      - name: Lint with flake8
        run: |
          flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
          flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
          
      - name: Test with pytest
        run: |
          pytest --cov=./ --cov-report=xml
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
          
      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
          file: ./coverage.xml
          
      - name: Check dependencies for vulnerabilities
        run: |
          pip install safety
          safety check
```

## 🔹 9. การใช้งาน GitLab CI

### Workflow สำหรับโปรเจค JavaScript แบบสมบูรณ์

```yaml
image: node:16

stages:
  - lint
  - test
  - security

variables:
  npm_config_cache: "$CI_PROJECT_DIR/.npm"

cache:
  paths:
    - .npm/
    - node_modules/

lint:
  stage: lint
  script:
    - npm ci
    - npm run lint

test:
  stage: test
  script:
    - npm ci
    - npm test -- --coverage
  coverage: /All\s+files.*?\s+(\d+.\d+)/
  artifacts:
    paths:
      - coverage/
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

sonarqube-check:
  stage: test
  image:
    name: sonarsource/sonar-scanner-cli:latest
  variables:
    SONAR_USER_HOME: "${CI_PROJECT_DIR}/.sonar"
    GIT_DEPTH: "0"
  cache:
    key: "${CI_JOB_NAME}"
    paths:
      - .sonar/cache
  script:
    - sonar-scanner
  only:
    - main
    - merge_requests

dependency-scan:
  stage: security
  script:
    - npm ci
    - npm audit --audit-level=high
  allow_failure: true

sast:
  stage: security
  include:
    - template: Security/SAST.gitlab-ci.yml
```

### Workflow สำหรับโปรเจค Python แบบสมบูรณ์

```yaml
image: python:3.9

stages:
  - lint
  - test
  - security

variables:
  PIP_CACHE_DIR: "$CI_PROJECT_DIR/.pip"

cache:
  paths:
    - .pip/
    - venv/

before_script:
  - python -V
  - python -m venv venv
  - source venv/bin/activate
  - pip install -r requirements.txt

lint:
  stage: lint
  script:
    - pip install flake8
    - flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
    - flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

test:
  stage: test
  services:
    - postgres:14
  variables:
    POSTGRES_DB: test_db
    POSTGRES_USER: postgres
    POSTGRES_PASSWORD: postgres
    DATABASE_URL: "postgresql://postgres:postgres@postgres:5432/test_db"
  script:
    - pip install pytest pytest-cov
    - pytest --cov=./ --cov-report=xml --cov-report=term
  coverage: '/TOTAL.*\s+(\d+%)/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml

sonarqube-check:
  stage: test
  image:
    name: sonarsource/sonar-scanner-cli:latest
  variables:
    SONAR_USER_HOME: "${CI_PROJECT_DIR}/.sonar"
    GIT_DEPTH: "0"
  cache:
    key: "${CI_JOB_NAME}"
    paths:
      - .sonar/cache
  script:
    - sonar-scanner
  only:
    - main
    - merge_requests

dependency-scan:
  stage: security
  script:
    - pip install safety
    - safety check
  allow_failure: true

sast:
  stage: security
  include:
    - template: Security/SAST.gitlab-ci.yml
```

## 🔹 10. การใช้งาน Bitbucket Pipelines

### Workflow สำหรับโปรเจค JavaScript แบบสมบูรณ์

```yaml
image: node:16

definitions:
  caches:
    npm: ~/.npm
  
  steps:
    - step: &lint
        name: Lint
        caches:
          - npm
        script:
          - npm ci
          - npm run lint

    - step: &test
        name: Test
        caches:
          - npm
        script:
          - npm ci
          - npm test -- --coverage
        artifacts:
          - coverage/**

    - step: &security-check
        name: Security Check
        caches:
          - npm
        script:
          - npm ci
          - npm audit --audit-level=high
          - npx snyk test || true

pipelines:
  default:
    - step: *lint
    - step: *test
    - step: *security-check
  
  branches:
    main:
      - step: *lint
      - step: *test
      - step: *security-check
      - step:
          name: SonarQube Analysis
          image: sonarsource/sonar-scanner-cli:latest
          script:
            - sonar-scanner -Dsonar.projectKey=${BITBUCKET_REPO_SLUG} -Dsonar.organization=my-organization -Dsonar.host.url=https://sonarcloud.io -Dsonar.login=${SONAR_TOKEN}

  pull-requests:
    '**':
      - step: *lint
      - step: *test
      - step: *security-check
```

### Workflow สำหรับโปรเจค Python แบบสมบูรณ์

```yaml
image: python:3.9

definitions:
  caches:
    pip: ~/.cache/pip
  
  steps:
    - step: &lint
        name: Lint
        caches:
          - pip
        script:
          - pip install flake8
          - flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
          - flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

    - step: &test
        name: Test
        caches:
          - pip
        services:
          - postgres
        script:
          - pip install -r requirements.txt
          - pip install pytest pytest-cov
          - pytest --cov=./ --cov-report=xml --cov-report=term
        artifacts:
          - coverage.xml

    - step: &security-check
        name: Security Check
        caches:
          - pip
        script:
          - pip install safety
          - safety check || true

pipelines:
  default:
    - step: *lint
    - step: *test
    - step: *security-check
  
  branches:
    main:
      - step: *lint
      - step: *test
      - step: *security-check
      - step:
          name: SonarQube Analysis
          image: sonarsource/sonar-scanner-cli:latest
          script:
            - sonar-scanner -Dsonar.projectKey=${BITBUCKET_REPO_SLUG} -Dsonar.organization=my-organization -Dsonar.host.url=https://sonarcloud.io -Dsonar.login=${SONAR_TOKEN}

  pull-requests:
    '**':
      - step: *lint
      - step: *test
      - step: *security-check

definitions:
  services:
    postgres:
      image: postgres:14
      variables:
        POSTGRES_DB: 'test_db'
        POSTGRES_USER: 'postgres'
        POSTGRES_PASSWORD: 'postgres'
```

## 🔹 11. แนวทางปฏิบัติที่ดีที่สุด

### กลยุทธ์การทดสอบที่มีประสิทธิภาพ

1. **Test Pyramid Approach**:
   - Many unit tests (fast, cheap)
   - Fewer integration tests (slower, more expensive)
   - Few end-to-end tests (slowest, most expensive)

2. **Optimizing Test Performance**:
   - Run fast tests first
   - Parallelize test execution
   - Use test filtering/tagging
   - Cache dependencies

3. **Different Levels of Testing**:

```mermaid
graph TD
    A[End-to-End Tests] --> B[Integration Tests]
    B --> C[Unit Tests]
```

### การเพิ่มประสิทธิภาพ CI/CD Pipeline

1. **Pipeline Caching**:
   - Cache dependencies between runs
   - Cache test results where possible
   - Use build artifacts effectively

2. **Parallelization**:
   - Split tests across multiple runners
   - Use matrix builds for different environments
   - Run independent jobs concurrently

3. **Selective Testing**:
   - Only run relevant tests for changed files
   - Skip tests on documentation-only changes
   - Use test impact analysis tools

### ตัวอย่าง: การกรองการทดสอบใน GitHub Actions

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    # Skip linting if only docs are changed
    if: "!contains(github.event.head_commit.message, 'docs:')"
    steps:
      - uses: actions/checkout@v3
      - name: Run linting
        run: npm run lint

  test:
    runs-on: ubuntu-latest
    # Use matrix strategy for parallel testing
    strategy:
      matrix:
        shard: [1, 2, 3, 4]
    steps:
      - uses: actions/checkout@v3
      - name: Run tests (shard ${{ matrix.shard }}/4)
        run: npm test -- --shard=${{ matrix.shard }}/4
```

## 🔹 12. การตั้งค่าขั้นสูง

### กลยุทธ์การทดสอบ Monorepo

เมื่อทำงานกับ monorepos (หลายโปรเจคใน repository เดียว) คุณต้องใช้กลยุทธ์เฉพาะ:

```yaml
name: Monorepo CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  changes:
    runs-on: ubuntu-latest
    outputs:
      frontend: ${{ steps.filter.outputs.frontend }}
      backend: ${{ steps.filter.outputs.backend }}
      common: ${{ steps.filter.outputs.common }}
    steps:
      - uses: actions/checkout@v3
      - uses: dorny/paths-filter@v2
        id: filter
        with:
          filters: |
            frontend:
              - 'frontend/**'
            backend:
              - 'backend/**'
            common:
              - 'common/**'
              - 'package.json'

  frontend-tests:
    needs: changes
    if: ${{ needs.changes.outputs.frontend == 'true' || needs.changes.outputs.common == 'true' }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '16'
      - name: Install dependencies
        run: cd frontend && npm ci
      - name: Run tests
        run: cd frontend && npm test

  backend-tests:
    needs: changes
    if: ${{ needs.changes.outputs.backend == 'true' || needs.changes.outputs.common == 'true' }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '16'
      - name: Install dependencies
        run: cd backend && npm ci
      - name: Run tests
        run: cd backend && npm test
```

### การแยก Config และ Pipeline ตามสภาพแวดล้อม

การแยกการตั้งค่าการทดสอบตามสภาพแวดล้อมช่วยให้คุณมีกลยุทธ์การทดสอบที่แตกต่างกันสำหรับแต่ละสภาพแวดล้อม:

```yaml
name: Environment-specific CI

on:
  push:
    branches: [ main, staging, development ]
  pull_request:
    branches: [ main, staging, development ]

jobs:
  determine-environment:
    runs-on: ubuntu-latest
    outputs:
      env-name: ${{ steps.set-env.outputs.env-name }}
      node-version: ${{ steps.set-env.outputs.node-version }}
      run-e2e: ${{ steps.set-env.outputs.run-e2e }}
    steps:
      - id: set-env
        run: |
          if [[ $GITHUB_REF == refs/heads/main || $GITHUB_BASE_REF == main ]]; then
            echo "::set-output name=env-name::production"
            echo "::set-output name=node-version::16"
            echo "::set-output name=run-e2e::true"
          elif [[ $GITHUB_REF == refs/heads/staging || $GITHUB_BASE_REF == staging ]]; then
            echo "::set-output name=env-name::staging"
            echo "::set-output name=node-version::16"
            echo "::set-output name=run-e2e::true"
          else
            echo "::set-output name=env-name::development"
            echo "::set-output name=node-version::16"
            echo "::set-output name=run-e2e::false"
          fi

  test:
    needs: determine-environment
    runs-on: ubuntu-latest
    environment: ${{ needs.determine-environment.outputs.env-name }}
    steps:
      - uses: actions/checkout@v3
      - name: Use Node.js ${{ needs.determine-environment.outputs.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ needs.determine-environment.outputs.node-version }}
      - run: npm ci
      - run: npm run lint
      - run: npm run test:unit
      - name: Run E2E Tests
        if: ${{ needs.determine-environment.outputs.run-e2e == 'true' }}
        run: npm run test:e2e
```

### การใช้ Service Containers ขั้นสูง

การทดสอบที่มี dependencies หลายตัวอาจต้องใช้หลาย service containers:

```yaml
name: Advanced Integration Testing

on: [push, pull_request]

jobs:
  integration-test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_USER: postgres
          POSTGRES_DB: test_db
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
          
      redis:
        image: redis:6
        ports:
          - 6379:6379
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
          
      rabbitmq:
        image: rabbitmq:3-management
        ports:
          - 5672:5672
        options: >-
          --health-cmd "rabbitmqctl status"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
          
      elasticsearch:
        image: docker.elastic.co/elasticsearch/elasticsearch:7.17.0
        env:
          discovery.type: single-node
          ES_JAVA_OPTS: "-Xms512m -Xmx512m"
        ports:
          - 9200:9200
        options: >-
          --health-cmd "curl -s http://localhost:9200/_cluster/health | grep -q '\"status\":\"green\"'"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '16'
          
      - name: Install dependencies
        run: npm ci
        
      - name: Wait for all services to be ready
        run: |
          echo "Waiting for services to be fully operational..."
          sleep 10
          
      - name: Run integration tests
        run: npm run test:integration
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
          REDIS_URL: redis://localhost:6379
          RABBITMQ_URL: amqp://guest:guest@localhost:5672
          ELASTICSEARCH_URL: http://localhost:9200
```

### การรวมรายงานการทดสอบและ Metrics

การรวบรวมรายงานและ metrics จาก jobs ต่างๆ เพื่อดูภาพรวมของคุณภาพโค้ด:

```yaml
name: Test Reports Integration

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '16'
      - name: Install dependencies
        run: npm ci
      - name: Run unit tests with JUnit reporter
        run: npm test -- --ci --reporters=default --reporters=jest-junit
        env:
          JEST_JUNIT_OUTPUT_DIR: "./junit"
      - name: Run ESLint with SARIF output
        run: npx eslint --format @microsoft/eslint-formatter-sarif --output-file eslint-results.sarif .
      - name: Upload test results
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: junit/
      - name: Upload ESLint SARIF file
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: eslint-results.sarif
          category: linting
      - name: Generate coverage
        run: npm test -- --coverage
      - name: SonarCloud Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

### การใช้งาน Reusable Workflows

การสร้าง reusable workflow templates สำหรับการทดสอบที่ใช้ซ้ำได้ในหลายโปรเจค:

**Reusable workflow (`.github/workflows/reusable-testing.yml`):**

```yaml
name: Reusable Testing Workflow

on:
  workflow_call:
    inputs:
      node-version:
        required: false
        type: string
        default: '16'
      working-directory:
        required: false
        type: string
        default: '.'
      run-e2e:
        required: false
        type: boolean
        default: false
    secrets:
      npm-token:
        required: false

jobs:
  test:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ${{ inputs.working-directory }}
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Node.js ${{ inputs.node-version }}
        uses: actions/setup-node@v3
        with:
          node-version: ${{ inputs.node-version }}
          cache: 'npm'
          cache-dependency-path: ${{ inputs.working-directory }}/package-lock.json
      
      - name: Install dependencies
        run: npm ci
        env:
          NODE_AUTH_TOKEN: ${{ secrets.npm-token }}
      
      - name: Lint
        run: npm run lint
      
      - name: Unit Tests
        run: npm run test:unit
      
      - name: E2E Tests
        if: ${{ inputs.run-e2e }}
        run: npm run test:e2e
```

**ใช้งาน reusable workflow:**

```yaml
name: CI Tests

on: [push, pull_request]

jobs:
  test-frontend:
    uses: ./.github/workflows/reusable-testing.yml
    with:
      working-directory: './frontend'
    
  test-backend:
    uses: ./.github/workflows/reusable-testing.yml
    with:
      working-directory: './backend'
      run-e2e: true
    secrets:
      npm-token: ${{ secrets.NPM_TOKEN }}
```

### การใช้ Feature Flags ในการทดสอบ

การใช้ feature flags เพื่อควบคุมการเปิดใช้งานฟีเจอร์ใหม่ในการทดสอบ:

```yaml
name: Feature Flag Testing

on: [push, pull_request]

jobs:
  test-with-feature-flags:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        include:
          - name: "Legacy behavior"
            feature_flags: '{"newFeature": false, "experimentalUI": false}'
          - name: "New feature enabled"
            feature_flags: '{"newFeature": true, "experimentalUI": false}'
          - name: "Experimental UI"
            feature_flags: '{"newFeature": true, "experimentalUI": true}'
    
    name: Test (${{ matrix.name }})
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '16'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Create feature flags config
        run: |
          echo '${{ matrix.feature_flags }}' > config/feature-flags.json
      
      - name: Run tests
        run: npm test
```

การใช้แนวทางขั้นสูงเหล่านี้จะช่วยให้ CI/CD pipeline ของคุณมีประสิทธิภาพ ยืดหยุ่น และสามารถรองรับโปรเจคที่มีความซับซ้อนได้
````
