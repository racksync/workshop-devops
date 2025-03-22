# WordPress with Docker Compose

คู่มือนี้จะช่วยให้คุณเริ่มต้นใช้งาน WordPress ด้วย Docker Compose โดยมีสภาพแวดล้อมทั้ง Development/Testing และ Production

## สิ่งที่ต้องการ

- Docker และ Docker Compose
- Git (เพื่อโคลนโปรเจ็กต์นี้)
- พื้นที่ดิสก์อย่างน้อย 1GB สำหรับ image และข้อมูล

## การติดตั้ง

### 1. โคลนโปรเจ็กต์

```bash
git clone <repository-url>
cd wordpress
```

### 2. สร้างไฟล์ .env

คัดลอกไฟล์ `.env.example` เป็น `.env`:

```bash
cp .env.example .env
```

หรือสร้างไฟล์ `.env` ในโฟลเดอร์หลักของโปรเจ็กต์ด้วยเนื้อหาดังต่อไปนี้ (อย่าลืมเปลี่ยนค่ารหัสผ่านให้ปลอดภัย):

```
MYSQL_DATABASE=wp_db
MYSQL_USER=wp_user
MYSQL_PASSWORD=db_password
MYSQL_ROOT_PASSWORD=root_password
```

### 3. สร้าง Network

โปรเจ็กต์นี้ต้องการ external network ชื่อ `backend_network` ให้สร้างโดยใช้คำสั่ง:

```bash
docker network create backend_network
```

### 4. เริ่มต้นใช้งาน WordPress

#### การเริ่มต้นระบบทั้งหมด

```bash
docker compose up -d
```

#### การเริ่มต้นเฉพาะสภาพแวดล้อม Test

```bash
docker compose up -d wordpress-test db phpmyadmin
```

#### การเริ่มต้นเฉพาะสภาพแวดล้อม Production

```bash
docker compose up -d wordpress-prod db phpmyadmin
```

## การเข้าถึง

หลังจากรันแล้ว คุณสามารถเข้าถึงแต่ละส่วนได้ดังนี้:

- **WordPress Test Environment**: http://localhost:8088
- **WordPress Production Environment**: http://localhost:80
- **phpMyAdmin**: http://localhost:7077 (ใช้ username: root, password: ตามที่ตั้งใน MYSQL_ROOT_PASSWORD หรือ username: wp_user, password: ตามที่ตั้งใน MYSQL_PASSWORD)

## โครงสร้างไฟล์

โปรเจ็กต์นี้มีการแยกข้อมูลดังนี้:

- `wordpress_test/`: โฟลเดอร์สำหรับไฟล์ WordPress ในสภาพแวดล้อม Test
- `wordpress_production/`: โฟลเดอร์สำหรับไฟล์ WordPress ในสภาพแวดล้อม Production
- `db_data/`: โฟลเดอร์สำหรับเก็บข้อมูลฐานข้อมูล MariaDB

## การหยุดการทำงาน

```bash
docker compose down
```

หากต้องการลบ Volume ด้วย:

```bash
docker compose down -v
```

## การแก้ไขปัญหาเบื้องต้น

- **ปัญหาการเข้าถึงฐานข้อมูล**: ตรวจสอบให้แน่ใจว่า `.env` file มีค่าตัวแปรถูกต้อง
- **ปัญหาการเชื่อมต่อเครือข่าย**: ตรวจสอบว่าได้สร้าง `backend_network` แล้ว
- **การดูข้อมูล log**: `docker compose logs -f [service-name]` (เช่น `docker compose logs -f wordpress-test`)

## การปรับแต่ง

- สามารถแก้ไขพอร์ตได้ในไฟล์ `docker-compose.yml`
- สามารถเพิ่ม plugin หรือธีมได้โดยอัปโหลดผ่าน WordPress Admin หรือวางไฟล์โดยตรงในโฟลเดอร์ `wordpress_test/` หรือ `wordpress_production/`

## หมายเหตุ

- ระบบใช้ MariaDB 10.6 เป็นฐานข้อมูล
- ฐานข้อมูลถูกแชร์ระหว่างสภาพแวดล้อม Test และ Production
- หากใช้ Apple Silicon (M1/M2) อาจต้องปลดคอมเมนต์บรรทัด `platform: linux/arm64/v8` ในไฟล์ docker-compose.yml

