const express = require('express');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// สร้าง Express app
const app = express();
const port = 3000;

// สร้างฐานข้อมูล SQLite ในหน่วยความจำ
const db = new sqlite3.Database(':memory:');

// ตั้งค่า middleware
app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json());
app.use(cookieParser());
app.use(express.static('public'));

// สร้างตารางและข้อมูลตัวอย่างในฐานข้อมูล
db.serialize(() => {
  // สร้างตารางผู้ใช้
  db.run(`CREATE TABLE users (
    id INTEGER PRIMARY KEY, 
    username TEXT, 
    password TEXT,
    role TEXT
  )`);
  
  // เพิ่มข้อมูลตัวอย่าง - เก็บรหัสผ่านแบบ plaintext (ช่องโหว่!)
  db.run("INSERT INTO users VALUES (1, 'admin', 'admin123', 'admin')");
  db.run("INSERT INTO users VALUES (2, 'user1', 'password123', 'user')");
  
  // สร้างตารางข้อความ
  db.run(`CREATE TABLE messages (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    message TEXT
  )`);
  
  // เพิ่มข้อความตัวอย่าง
  db.run("INSERT INTO messages VALUES (1, 1, 'ยินดีต้อนรับ Admin!')");
  db.run("INSERT INTO messages VALUES (2, 2, 'ยินดีต้อนรับ User!')");
});

// หน้าหลัก
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '/public/index.html'));
});

// ช่องโหว่ที่ 1: SQL Injection ในการล็อกอิน
app.post('/login', (req, res) => {
  const { username, password } = req.body;
  
  // ช่องโหว่! ไม่มีการทำ parameterization
  const query = `SELECT * FROM users WHERE username = '${username}' AND password = '${password}'`;
  
  db.get(query, (err, user) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    
    if (user) {
      // ใช้คุกกี้ไม่ปลอดภัย (ไม่มีการตั้งค่า HttpOnly, Secure, SameSite)
      res.cookie('user_id', user.id);
      res.cookie('role', user.role);
      
      return res.json({
        success: true,
        message: `เข้าสู่ระบบสำเร็จ, ยินดีต้อนรับ ${username}!`,
        role: user.role
      });
    } else {
      return res.status(401).json({ 
        success: false, 
        message: 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง' 
      });
    }
  });
});

// ช่องโหว่ที่ 2: XSS (Cross-Site Scripting)
app.post('/messages', (req, res) => {
  const { message } = req.body;
  const userId = req.cookies.user_id || 1;
  
  // ไม่มีการตรวจสอบหรือ sanitize ข้อความ
  db.run("INSERT INTO messages (user_id, message) VALUES (?, ?)", [userId, message], function(err) {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    
    res.json({
      success: true,
      message: 'บันทึกข้อความสำเร็จ',
      id: this.lastID
    });
  });
});

// ช่องโหว่ที่ 3: IDOR (Insecure Direct Object References)
app.get('/messages/:id', (req, res) => {
  const messageId = req.params.id;
  
  // ไม่มีการตรวจสอบว่าผู้ใช้มีสิทธิ์เข้าถึงข้อความนี้หรือไม่
  db.get("SELECT * FROM messages WHERE id = ?", [messageId], (err, message) => {
    if (err) {
      return res.status(500).json({ error: err.message });
    }
    
    if (message) {
      return res.json(message);
    } else {
      return res.status(404).json({ message: 'ไม่พบข้อความ' });
    }
  });
});

// ช่องโหว่ที่ 4: Broken Access Control
app.get('/admin/users', (req, res) => {
  const role = req.cookies.role;
  
  // ตรวจสอบสิทธิ์อย่างไม่ปลอดภัยโดยใช้คุกกี้ที่ผู้ใช้สามารถแก้ไขได้
  if (role === 'admin') {
    db.all("SELECT id, username, role FROM users", (err, users) => {
      if (err) {
        return res.status(500).json({ error: err.message });
      }
      
      res.json({ users });
    });
  } else {
    res.status(403).json({ message: 'ไม่ได้รับอนุญาต' });
  }
});

// เริ่มเซิร์ฟเวอร์
app.listen(port, () => {
  console.log(`แอปทดสอบ OWASP ทำงานที่ http://localhost:${port}`);
});
