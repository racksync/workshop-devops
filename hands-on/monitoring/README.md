# แล็บปฏิบัติการระบบติดตามและเฝ้าระวัง

โปรเจกต์นี้ประกอบด้วยชุดเครื่องมือสำหรับการติดตามและเฝ้าระวังระบบแบบครบวงจร โดยใช้ Prometheus, Grafana, Node Exporter, cAdvisor และ Alertmanager พร้อมด้วยแอปพลิเคชันตัวอย่างที่เปิดเผย metrics

## องค์ประกอบ

- **Prometheus**: ฐานข้อมูลอนุกรมเวลาสำหรับจัดเก็บ metrics
- **Grafana**: แดชบอร์ดสำหรับแสดงผล metrics
- **Node Exporter**: ให้ข้อมูล metrics ของเครื่อง host
- **cAdvisor**: ให้ข้อมูล metrics ของ container
- **Alertmanager**: จัดการการแจ้งเตือนจาก Prometheus
- **แอปพลิเคชันตัวอย่าง**: แอปพลิเคชัน Python ที่เปิดเผย metrics แบบกำหนดเอง

## เริ่มต้นใช้งาน

### สิ่งที่ต้องเตรียม

- ติดตั้ง Docker และ Docker Compose บนเครื่องของคุณ

### การรันระบบติดตามและเฝ้าระวัง

1. โคลนโปรเจกต์
2. นำทางไปยังไดเรกทอรี monitoring
3. เริ่มต้นระบบติดตามและเฝ้าระวัง:

```bash
docker-compose up -d
```

4. เข้าถึงส่วนประกอบต่างๆ:
   - Prometheus: http://localhost:9090
   - Grafana: http://localhost:3000 (ชื่อผู้ใช้: admin, รหัสผ่าน: admin)
   - Alertmanager: http://localhost:9093
   - Metrics ของแอปพลิเคชันตัวอย่าง: http://localhost:8000

## การสำรวจระบบติดตามและเฝ้าระวัง

### การตั้งค่า Grafana

1. เปิด Grafana ที่ http://localhost:3000
2. เข้าสู่ระบบด้วยชื่อผู้ใช้ `admin` และรหัสผ่าน `admin`
3. เพิ่ม Prometheus เป็นแหล่งข้อมูล:
   - ไปที่ Configuration > Data Sources > Add data source
   - เลือก Prometheus
   - ตั้งค่า URL เป็น `http://prometheus:9090`
   - คลิก "Save & Test"
4. นำเข้าแดชบอร์ดตัวอย่าง:
   - ไปที่ Create > Import
   - อัปโหลดไฟล์ JSON จาก `dashboards/node_exporter_dashboard.json`
   - เลือกแหล่งข้อมูล Prometheus ของคุณ
   - คลิก "Import"

### การสำรวจ Prometheus

1. เปิด Prometheus ที่ http://localhost:9090
2. สำรวจ metrics ด้วยคำสั่ง PromQL:
   - การใช้ CPU: `100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)`
   - การใช้หน่วยความจำ: `(node_memory_MemTotal_bytes - node_memory_MemFree_bytes) / node_memory_MemTotal_bytes * 100`
   - จำนวนคำขอของแอปพลิเคชันตัวอย่าง: `rate(app_requests_total[1m])`
   - ระยะเวลาการตอบสนองของแอปพลิเคชันตัวอย่าง: `histogram_quantile(0.95, sum(rate(app_request_duration_seconds_bucket[5m])) by (le))`

### การทดสอบการแจ้งเตือน

1. คุณสามารถทดสอบการแจ้งเตือนโดยจำลองการใช้ CPU สูง:

```bash
# เปิดเทอร์มินัลใหม่และรันงานที่ใช้ CPU เยอะ
dd if=/dev/zero of=/dev/null
```

2. หลังจากผ่านไปสักครู่ ตรวจสอบการแจ้งเตือนของ Prometheus ที่ http://localhost:9090/alerts

## การเพิ่มแอปพลิเคชันของคุณเอง

การติดตามแอปพลิเคชันของคุณเอง:

1. เพิ่มไลบรารีไคลเอ็นต์ Prometheus ให้กับแอปพลิเคชันของคุณ
2. เปิดเผย metrics บน HTTP endpoint (โดยทั่วไปคือ `/metrics`)
3. เพิ่มแอปพลิเคชันของคุณในไฟล์ `docker-compose.yml`
4. อัปเดต `prometheus.yml` เพื่อรวมแอปพลิเคชันของคุณเป็นเป้าหมายในการเก็บข้อมูล

## การเรียนรู้เพิ่มเติม

- สำรวจ exporters ต่างๆ สำหรับบริการต่างๆ (MySQL, Redis, ฯลฯ)
- สร้างแดชบอร์ดกำหนดเองใน Grafana
- ตั้งค่ากฎการแจ้งเตือนที่ซับซ้อนมากขึ้น
- ทดลองกับกฎการบันทึกใน Prometheus

## การทำความสะอาด

การหยุดและลบ containers, networks และ volumes ทั้งหมด:

```bash
docker-compose down -v
```

---

© 2023 RackSync Co., Ltd. สงวนลิขสิทธิ์ทั้งหมด
ห้ามทำซ้ำหรือเผยแพร่โดยไม่ได้รับอนุญาต
