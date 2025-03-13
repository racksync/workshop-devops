const express = require('express');
const bodyParser = require('body-parser');
const cookieParser = require('cookie-parser');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const helmet = require('helmet');
const winston = require('winston');
const bcrypt = require('bcrypt');
const session = require('express-session');
const sanitizeHtml = require('sanitize-html');

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

// เพิ่ม security middleware
app.use(helmet());
app.use(session({
  secret: process.env.SESSION_SECRET || 'default_secret',
  resave: false,
  saveUninitialized: false,
  cookie: { 
    secure: process.env.NODE_ENV === 'production',
    httpOnly: true,
    sameSite: 'strict'
  }
}));

// ตั้งค่า logger
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  defaultMeta: { service: 'user-service' },
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'combined.log' })
  ]
});

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

// แก้ไขการล็อกอินให้ใช้ parameterized query
app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  
  logger.info('Login attempt', {
    username,
    ip: req.ip,
    userAgent: req.headers['user-agent']
  });

  try {
    db.get("SELECT * FROM users WHERE username = ?", [username], async (err, user) => {
      if (err) {
        logger.error('Database error during login', { error: err.message });
        return res.status(500).json({ error: 'Internal server error' });
      }
      
      if (user && await bcrypt.compare(password, user.password)) {
        req.session.userId = user.id;
        req.session.role = user.role;
        
        return res.json({
          success: true,
          message: `เข้าสู่ระบบสำเร็จ, ยินดีต้อนรับ ${username}!`
        });
      } else {
        return res.status(401).json({ 
          success: false, 
          message: 'ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง' 
        });
      }
    });
  } catch (error) {
    logger.error('Error in login process', { error: error.message });
    res.status(500).json({ error: 'Internal server error' });
  }
});

// แก้ไขการจัดการข้อความให้มีการ sanitize input
app.post('/messages', (req, res) => {
  if (!req.session.userId) {
    return res.status(401).json({ error: 'กรุณาเข้าสู่ระบบ' });
  }

  const message = sanitizeHtml(req.body.message, {
    allowedTags: [ 'b', 'i', 'em', 'strong', 'a' ],
    allowedAttributes: {
      'a': [ 'href' ]
    }
  });

  db.run("INSERT INTO messages (user_id, message) VALUES (?, ?)", 
    [req.session.userId, message], 
    function(err) {
      if (err) {
        logger.error('Error saving message', { error: err.message });
        return res.status(500).json({ error: 'Internal server error' });
      }
      
      res.json({
        success: true,
        message: 'บันทึกข้อความสำเร็จ',
        id: this.lastID
      });
    }
  );
});

// แก้ไข IDOR vulnerability
app.get('/messages/:id', (req, res) => {
  if (!req.session.userId) {
    return res.status(401).json({ error: 'กรุณาเข้าสู่ระบบ' });
  }

  const messageId = req.params.id;
  const userId = req.session.userId;
  
  db.get(
    "SELECT * FROM messages WHERE id = ? AND (user_id = ? OR ? IN (SELECT id FROM users WHERE role = 'admin'))",
    [messageId, userId, userId],
    (err, message) => {
      if (err) {
        logger.error('Error fetching message', { error: err.message });
        return res.status(500).json({ error: 'Internal server error' });
      }
      
      if (message) {
        return res.json(message);
      } else {
        return res.status(404).json({ message: 'ไม่พบข้อความหรือไม่มีสิทธิ์เข้าถึง' });
      }
    }
  );
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
