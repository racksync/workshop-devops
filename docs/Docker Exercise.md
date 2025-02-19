<!-----



Conversion time: 1.766 seconds.


Using this Markdown file:

1. Paste this output into your source file.
2. See the notes and action items below regarding this conversion run.
3. Check the rendered output (headings, lists, code blocks, tables) for proper
   formatting and use a linkchecker before you publish this page.

Conversion notes:

* Docs to Markdown version 1.0β44
* Wed Feb 19 2025 10:27:29 GMT-0800 (PST)
* Source doc: DevOps Basic - Docker Exercise
* Tables are currently converted to HTML tables.
----->


**<span style="text-decoration:underline;">Docker Command Line Exercise</span>**


## **บทที่ 1: บทนำสู่ Docker**


### **1.1 ความเป็นมาของ Docker**

Docker เป็นแพลตฟอร์มสำหรับการทำ containerization ซึ่งช่วยให้การพัฒนา ทดสอบ และนำไปใช้งานแอปพลิเคชันในสภาพแวดล้อมที่แยกออกจากกันเป็นไปได้อย่างง่ายดาย



* **Containerization:** แนวคิดการแยกส่วนแอปพลิเคชันและ dependencies ออกจากระบบปฏิบัติการหลัก
* **ข้อดี:** สามารถใช้งานได้ทั้งในเครื่องพัฒนาและระบบ production, เพิ่มความสามารถในการย้ายข้ามแพลตฟอร์ม, ลดปัญหา “works on my machine”


### **1.2 แนวคิดหลักของ Docker**



* **Images:** เป็นแม่แบบของ container ที่มีการกำหนดค่าต่าง ๆ ที่จำเป็น
* **Containers:** เป็น instance ที่รันจาก image ซึ่งแยกออกจากกัน
* **Dockerfile:** ไฟล์ที่ใช้สำหรับสร้าง Docker image ผ่านคำสั่งต่าง ๆ ที่กำหนดไว้
* **Docker Hub:** แหล่งเก็บ Docker image ที่สามารถดึง image จากที่อื่นมาใช้งาน


### **1.3 วัตถุประสงค์ของเอกสารนี้**

เอกสารนี้มีวัตถุประสงค์เพื่อให้ผู้อ่านได้เข้าใจและปฏิบัติการใช้งาน Docker ผ่านตัวอย่างที่เป็นขั้นตอน โดยจะครอบคลุมหัวข้อต่าง ๆ ตั้งแต่การติดตั้งจนถึงการปรับใช้แอปพลิเคชันในระบบ production


---


## **บทที่ 2: การติดตั้งและตั้งค่า Docker**


### **2.1 การติดตั้ง Docker บนระบบปฏิบัติการต่าง ๆ**


#### **2.1.1 บน Linux (Ubuntu)**

อัพเดตแพ็คเกจ: \



```
 apt update
 apt upgrade -y
```


 \
ติดตั้งแพ็คเกจที่จำเป็น: \



```
apt install apt-transport-https ca-certificates curl gnupg lsb-release
```


 \
เพิ่ม Docker GPG key: \



```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```


 \
เพิ่ม repository: \



```
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" |  tee /etc/apt/sources.list.d/docker.list > /dev/null
```


 \


ติดตั้ง Docker Engine: \



```
apt update
apt install docker-ce docker-ce-cli containerd.io
```


 \
ตรวจสอบการติดตั้ง: \



```
docker --version
```



#### **2.1.2 บน Windows และ macOS**

**Docker Desktop: \
**ผู้ใช้ Windows และ macOS สามารถดาวน์โหลด Docker Desktop จาก Docker Hub และทำตามขั้นตอนการติดตั้งที่มีในเอกสารประกอบ


### **2.2 การตั้งค่าพื้นฐานหลังการติดตั้ง**

**การรัน Docker โดยไม่ต้องใช้  (สำหรับ Linux): \
**


```
usermod -aG docker $USER
```


แล้วออกจากระบบแล้วกลับเข้าสู่ระบบใหม่

**การตั้งค่า Docker Compose: \
**Docker Compose มักติดตั้งมาพร้อมกับ Docker Desktop แต่ใน Linux อาจต้องติดตั้งแยก \



```
 curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
 chmod +x /usr/local/bin/docker-compose
docker-compose --version
```



---


## **บทที่ 3: การใช้งาน Docker เบื้องต้น**


### **3.1 คำสั่งพื้นฐานของ Docker**

**docker run:** รัน container จาก image \



```
docker run hello-world
```


**docker ps:** แสดง container ที่กำลังรันอยู่ \



```
docker ps
```


**docker stop:** หยุด container \



```
docker stop <container_id>
```


**docker rm:** ลบ container ที่ไม่ใช้งาน \



```
docker rm <container_id>
```


**docker images:** แสดง image ที่มีอยู่ในเครื่อง \



```
docker images
```


**docker rmi:** ลบ image \



```
docker rmi <image_id>
```



### **3.2 การทำงานกับ Container แบบ Interactive**

การรัน container ในโหมด interactive ช่วยให้เราสามารถเข้าถึง shell ภายใน container


```
docker run -it ubuntu /bin/bash
```



### **3.3 การจัดการ Volume**

Volume เป็นการเก็บข้อมูลที่อยู่นอก container เพื่อให้ข้อมูลคงอยู่แม้ container จะถูกลบ

สร้าง volume: \



```
docker run -d -v mydata:/data ubuntu
```


รัน container โดย mount volume: \



```
docker run -d -v mydata:/data ubuntu
```



---


## **บทที่ 4: การสร้าง Docker Image ด้วย Dockerfile**


### **4.1 ความสำคัญของ Dockerfile**

Dockerfile คือไฟล์ที่ใช้สำหรับบรรยายขั้นตอนการสร้าง Docker image ซึ่งช่วยให้การสร้าง image มีความสม่ำเสมอและสามารถทำซ้ำได้


### **4.2 โครงสร้างพื้นฐานของ Dockerfile**

ตัวอย่าง Dockerfile สำหรับแอปพลิเคชัน Node.js:

dockerfile


```
# เริ่มต้นด้วย base image
FROM node:14

# กำหนด working directory
WORKDIR /app

# คัดลอกไฟล์ package.json และ package-lock.json
COPY package*.json ./

# ติดตั้ง dependencies
RUN npm install

# คัดลอกโค้ดแอปพลิเคชันทั้งหมดไปยัง container
COPY . .

# กำหนด port ที่จะ expose
EXPOSE 3000

# กำหนดคำสั่งรันเมื่อ container ถูกสร้างขึ้น
CMD ["node", "app.js"]
```



### **4.3 การสร้าง Image จาก Dockerfile**

สร้างไฟล์ `Dockerfile` ใน directory ของโปรเจค

รันคำสั่งต่อไปนี้เพื่อสร้าง image \



```
docker build -t my-node-app .
```


ตรวจสอบ image ที่สร้างขึ้น \



```
docker images
```


 \


---



## **บทที่ 5: Docker Compose – การจัดการ Multi-Container Application**


### **5.1 บทนำสู่ Docker Compose**

Docker Compose คือเครื่องมือสำหรับการจัดการและตั้งค่าการรันหลาย container ในแอปพลิเคชันเดียวกัน โดยใช้ไฟล์ `docker-compose.yml`


### **5.2 โครงสร้างไฟล์ docker-compose.yml**

ตัวอย่างการตั้งค่า Docker Compose สำหรับแอปพลิเคชันที่ประกอบด้วย Web Server และ Database:


```
version: '3'
services:
  web:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - db
  db:
    image: postgres:13
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: mydb
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```



### **5.3 การใช้งาน Docker Compose**

**การรัน: \
**


```
docker-compose up -d
```


<code> \
</code>**การตรวจสอบ log: \
**


```
docker-compose up -d
docker-compose logs
```


**การหยุดและลบ container ที่รันด้วย Compose: \
**


```
docker-compose down
```



---


## **บทที่ 6: ตัวอย่างการสร้างโปรเจค Docker แบบ End-to-End**


### **6.1 ตัวอย่างโปรเจค: Web Application ด้วย Node.js และ PostgreSQL**

ในบทนี้เราจะสร้างโปรเจคที่มีแอปพลิเคชัน Node.js ติดต่อกับฐานข้อมูล PostgreSQL โดยใช้ Docker และ Docker Compose


#### **ขั้นตอนที่ 1: เตรียมโครงสร้างโปรเจค**


```
my-docker-project/
├── app.js
├── package.json
├── Dockerfile
└── docker-compose.yml
```



#### **ขั้นตอนที่ 2: เขียนโค้ดสำหรับแอปพลิเคชัน**

*app.js* (ตัวอย่างโค้ดเบื้องต้น):

javascript


```
const express = require('express');
const { Client } = require('pg');

const app = express();
const port = 3000;

// กำหนดการเชื่อมต่อฐานข้อมูล
const client = new Client({
  host: 'db',
  user: 'user',
  password: 'password',
  database: 'mydb'
});

client.connect()
  .then(() => console.log('Connected to PostgreSQL'))
  .catch(err => console.error('Connection error', err.stack));

app.get('/', async (req, res) => {
  try {
    const result = await client.query('SELECT NOW()');
    res.send(`Server time is: ${result.rows[0].now}`);
  } catch (err) {
    res.status(500).send(err.toString());
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
```



#### **ขั้นตอนที่ 3: เขียน Dockerfile**

ตามที่แสดงในบทที่ 4

dockerfile


```
FROM node:14
WORKDIR /app
 package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "app.js"]
```



#### **ขั้นตอนที่ 4: เขียน docker-compose.yml**


```
version: '3'
services:
  web:
    build: .
    ports:
      - "3000:3000"
    depends_on:
      - db
  db:
    image: postgres:13
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
      POSTGRES_DB: mydb
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:
```



#### **ขั้นตอนที่ 5: รันโปรเจคด้วย Docker Compose**

เปิด terminal ไปที่ directory ของโปรเจค

รันคำสั่ง: \



```
docker-compose up -d
```


ตรวจสอบว่าแอปพลิเคชันและฐานข้อมูลทำงานได้อย่างถูกต้องโดยเข้าเว็บเบราว์เซอร์ที่ 


```
http://localhost:3000
```



---


## **บทที่ 7: การจัดการและ Debug Container**


### **7.1 การดู Log ของ Container**

ดู log ของ container ที่ระบุ: \



```
docker logs <container_id>
```


ดู log แบบเรียลไทม์: \



```
docker exec -it <container_id> /bin/bash
```



### **7.2 การเข้าไปใน Container (Exec)**

หากต้องการตรวจสอบหรือ debug ภายใน container สามารถใช้คำสั่ง exec:


```
docker exec -it <container_id> /bin/bash
```



### **7.3 การแก้ปัญหาที่พบบ่อย**



* **ปัญหา Port Conflict:** ตรวจสอบว่า port ที่ระบุใน `docker-compose.yml` หรือ `docker run` ไม่ถูกใช้งานโดยโปรเซสอื่น
* **ปัญหา Image Build:** ตรวจสอบ Dockerfile และ cache ด้วยคำสั่ง `docker build --no-cache`
* **ปัญหา Network:** ตรวจสอบ network ของ container โดยใช้คำสั่ง 

    ```
docker network ls และ docker network inspect
```




---


## **บทที่ 8: แนวทางการ Deploy Docker ใน Production**


### **8.1 การจัดการ Container ใน Production**



* **การใช้ Docker Swarm หรือ Kubernetes:** สำหรับการจัดการ container ที่มีจำนวนมากและต้องการ scaling แบบอัตโนมัติ
* **การ Monitor Container:** ใช้เครื่องมือเช่น Prometheus, Grafana ในการติดตามสถานะ container
* **การ Log และ Centralized Logging:** ใช้ ELK Stack (Elasticsearch, Logstash, Kibana) หรือ Splunk ในการรวบรวม log


### **8.2 Best Practices ในการ Deploy**



* ใช้ multi-stage builds เพื่อลดขนาด image
* ไม่เก็บข้อมูลสำคัญใน image โดยตรง
* กำหนด resource limits (CPU, Memory) ในไฟล์ compose หรือใน orchestration tool
* ตรวจสอบความปลอดภัยของ container ด้วยการสแกน vulnerabilities


---


## **บทที่ 9: การปรับปรุงและขยายความสามารถของ Docker**


### **9.1 การสร้าง Custom Network**

สร้าง custom network เพื่อให้ container สามารถสื่อสารกันได้ง่ายและแยกออกจาก network ภายนอก


```
docker network create my_custom_network
docker run -d --network my_custom_network my-node-app
```



### **9.2 การใช้ Environment Variables**

กำหนด environment variables ใน container เพื่อความยืดหยุ่นในการปรับเปลี่ยนค่า config

ผ่าน Dockerfile: \
dockerfile \



```
ENV NODE_ENV=production
```


 \
ผ่าน docker-compose.yml: \



```
environment:
  - NODE_ENV=production
```



### ** \
9.3 การจัดการ Secret และ Config**



* ใช้ Docker Secrets (สำหรับ swarm) หรือจัดการไฟล์ config ที่ปลอดภัย
* ป้องกันข้อมูลสำคัญ (เช่น รหัสผ่าน) ไม่ให้ถูก hard-coded ลงใน Dockerfile


---


## **บทที่ 10: สรุปและแนวทางการเรียนรู้ต่อยอด**


### **10.1 สรุปเนื้อหาที่ได้เรียนรู้**

ในเอกสารนี้เราได้เรียนรู้:



* พื้นฐานและแนวคิดของ Docker
* การติดตั้งและตั้งค่า Docker บนระบบปฏิบัติการต่าง ๆ
* คำสั่งพื้นฐานสำหรับการจัดการ container และ image
* การสร้าง Dockerfile และการสร้าง Docker Image
* การใช้งาน Docker Compose สำหรับ multi-container applications
* ตัวอย่างโปรเจคจริงแบบ End-to-End
* เคล็ดลับในการ debug, monitoring และ deployment ใน production


### **10.2 แนวทางการพัฒนา**



* ลองสร้างโปรเจคใหม่ ๆ โดยนำ Docker เข้ามาช่วยจัดการ environment
* สำรวจเครื่องมือ orchestration อย่าง Kubernetes สำหรับการจัดการ container ในระดับ production
* เรียนรู้การ Integrate Docker กับ CI/CD Pipeline (เช่น Jenkins, GitLab CI) เพื่อให้การ deploy เป็นไปโดยอัตโนมัติ
* ศึกษา Docker Security เพื่อให้แอปพลิเคชันของคุณปลอดภัยมากขึ้น