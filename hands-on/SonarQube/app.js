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
const fs = require('fs');
const xml2js = require('xml2js');
// Removed libxmljs import as it's not needed for functionality

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

  // สร้างตารางบัตรเครดิต
  db.run(`CREATE TABLE credit_cards (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    card_number TEXT,
    expiry TEXT,
    cvv TEXT
  )`);
  
  // สร้างตารางบัญชีธนาคาร
  db.run(`CREATE TABLE accounts (
    id INTEGER PRIMARY KEY,
    user_id INTEGER,
    balance REAL DEFAULT 1000
  )`);
  
  // เพิ่มข้อมูลตัวอย่าง
  db.run("INSERT INTO accounts VALUES (1, 1, 5000)");
  db.run("INSERT INTO accounts VALUES (2, 2, 1000)");
  
  // สร้างตารางประวัติการโอน
  db.run(`CREATE TABLE transfers (
    id INTEGER PRIMARY KEY,
    from_user_id INTEGER,
    to_recipient TEXT,
    amount REAL,
    timestamp TEXT
  )`);
  
  // สร้างตารางประวัติการล็อกอิน
  db.run(`CREATE TABLE login_attempts (
    id INTEGER PRIMARY KEY,
    username TEXT,
    success INTEGER,
    ip TEXT,
    timestamp TEXT
  )`);
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

// 5. ช่องโหว่ Security Misconfiguration
app.get('/server-info', (req, res) => {
  // เปิดเผยข้อมูลการตั้งค่าเซิร์ฟเวอร์มากเกินไป
  const serverInfo = {
    hostname: require('os').hostname(),
    platform: process.platform,
    architecture: process.arch,
    nodeVersion: process.version,
    environment: process.env.NODE_ENV,
    dependencies: process.versions,
    envVars: process.env,  // รั่วไหลข้อมูลสภาพแวดล้อมทั้งหมด!
    serverUptime: process.uptime()
  };
  
  res.json(serverInfo);
});

// 6. ช่องโหว่ Sensitive Data Exposure
app.post('/save-card', (req, res) => {
  if (!req.session.userId) {
    return res.status(401).json({ error: 'กรุณาเข้าสู่ระบบ' });
  }
  
  const { cardNumber } = req.body;
  
  // เก็บข้อมูลบัตรเครดิตในรูปแบบที่ไม่เข้ารหัส
  db.run(
    "INSERT INTO credit_cards (user_id, card_number) VALUES (?, ?)",
    [req.session.userId, cardNumber],
    function(err) {
      if (err) {
        logger.error('Error saving card', { error: err.message });
        return res.status(500).json({ error: 'Internal server error' });
      }
      
      res.json({
        success: true,
        message: 'บันทึกข้อมูลบัตรสำเร็จ',
        cardId: this.lastID
      });
    }
  );
});

app.get('/cards', (req, res) => {
  if (!req.session.userId) {
    return res.status(401).json({ error: 'กรุณาเข้าสู่ระบบ' });
  }
  
  // ส่งข้อมูลบัตรเครดิตที่ไม่เข้ารหัสกลับไป
  db.all(
    "SELECT * FROM credit_cards WHERE user_id = ?",
    [req.session.userId],
    (err, cards) => {
      if (err) {
        logger.error('Error fetching cards', { error: err.message });
        return res.status(500).json({ error: 'Internal server error' });
      }
      
      // ส่งกลับโดยไม่มีการปกปิดข้อมูลที่ละเอียดอ่อน
      res.json({ cards });
    }
  );
});

// 7. ช่องโหว่ Cross-Site Request Forgery (CSRF)
app.post('/transfer', (req, res) => {
  if (!req.session.userId) {
    return res.status(401).json({ error: 'กรุณาเข้าสู่ระบบ' });
  }
  
  const userId = req.session.userId;
  const { recipient, amount } = req.body;
  
  // ไม่มีการตรวจสอบ CSRF token!
  
  db.get(
    "SELECT balance FROM accounts WHERE user_id = ?",
    [userId],
    (err, account) => {
      if (err || !account) {
        logger.error('Error fetching account', { error: err?.message });
        return res.status(500).json({ error: 'Internal server error' });
      }
      
      if (account.balance < amount) {
        return res.status(400).json({ error: 'ยอดเงินไม่เพียงพอ' });
      }
      
      // ทำธุรกรรม
      db.run(
        "UPDATE accounts SET balance = balance - ? WHERE user_id = ?",
        [amount, userId],
        function(err) {
          if (err) {
            logger.error('Error updating balance', { error: err.message });
            return res.status(500).json({ error: 'Internal server error' });
          }
          
          // บันทึกการโอน
          db.run(
            "INSERT INTO transfers (from_user_id, to_recipient, amount, timestamp) VALUES (?, ?, ?, datetime('now'))",
            [userId, recipient, amount],
            function(err) {
              if (err) {
                logger.error('Error recording transfer', { error: err.message });
                return res.status(500).json({ error: 'Internal server error' });
              }
              
              res.json({
                success: true,
                message: `โอนเงินไปยัง ${recipient} จำนวน ${amount} บาท สำเร็จ`,
                newBalance: account.balance - amount
              });
            }
          );
        }
      );
    }
  );
});

// 8. ช่องโหว่ Using Components with Known Vulnerabilities
app.get('/dependencies', (req, res) => {
  // จำลองการแสดงข้อมูลไลบรารีที่มีช่องโหว่
  const vulnerableDependencies = [
    {
      name: 'hypothetical-libxmljs',
      version: '0.18.0',
      vulnerabilities: [
        {
          id: 'CVE-2019-1234',
          severity: 'Critical',
          description: 'Memory corruption vulnerability in XML parsing'
        }
      ]
    },
    {
      name: 'body-parser',
      version: '1.18.2',
      vulnerabilities: [
        {
          id: 'CVE-2018-5678',
          severity: 'High',
          description: 'Denial of service via large JSON payloads'
        }
      ]
    },
    {
      name: 'express',
      version: '4.16.0',
      vulnerabilities: [
        {
          id: 'CVE-2017-9876',
          severity: 'Medium',
          description: 'Path traversal vulnerability'
        }
      ]
    }
  ];
  
  res.json({ dependencies: vulnerableDependencies });
});

// 9. ช่องโหว่ Insufficient Logging & Monitoring
// เพิ่มการบันทึกความพยายามในการล็อกอิน แต่บันทึกไม่ครบถ้วน
app.get('/logs', (req, res) => {
  if (!req.session.userId) {
    return res.status(401).json({ error: 'กรุณาเข้าสู่ระบบ' });
  }
  
  if (req.session.role !== 'admin') {
    return res.status(403).json({ error: 'ไม่มีสิทธิ์เข้าถึง' });
  }
  
  db.all("SELECT * FROM login_attempts ORDER BY id DESC LIMIT 10", (err, logs) => {
    if (err) {
      logger.error('Error fetching logs', { error: err.message });
      return res.status(500).json({ error: 'Internal server error' });
    }
    
    res.json({ logs });
  });
});

// 10. ช่องโหว่ XML External Entities (XXE)
app.post('/process-xml', (req, res) => {
  let rawData = '';
  req.on('data', chunk => {
    rawData += chunk;
  });
  
  req.on('end', () => {
    try {
      // ใช้ XML parser ที่มีการเปิดใช้ DTD และ external entities โดยไม่มีการป้องกัน
      const parser = new xml2js.Parser({
        explicitCharkey: true,
        explicitArray: false
      });
      
      parser.parseString(rawData, (err, result) => {
        if (err) {
          logger.error('XML parsing error', { error: err.message });
          return res.status(400).json({ error: 'Invalid XML', details: err.message });
        }
        
        res.json({
          success: true,
          message: 'ประมวลผล XML สำเร็จ',
          parsedData: result
        });
      });
    } catch (error) {
      logger.error('Error processing XML', { error: error.message });
      res.status(500).json({ error: 'Internal server error' });
    }
  });
});

// เริ่มเซิร์ฟเวอร์
app.listen(port, () => {
  console.log(`แอปทดสอบ OWASP ทำงานที่ http://localhost:${port}`);
});
