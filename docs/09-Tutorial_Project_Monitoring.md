# 📊 Monitoring Deployed Projects & Containers

## 📋 สารบัญ
- [1. บทนำสู่การ Monitoring](#1-บทนำสู่การ-monitoring)
- [2. Prometheus: ระบบเก็บข้อมูล Metrics](#2-prometheus-ระบบเก็บข้อมูล-metrics)
- [3. Grafana: การสร้าง Dashboard](#3-grafana-การสร้าง-dashboard)
- [4. Uptime Monitoring](#4-uptime-monitoring)
- [5. แนวทางการติดตั้งและใช้งาน](#5-แนวทางการติดตั้งและใช้งาน)
- [6. การประยุกต์ใช้กับ Real-World Projects](#6-การประยุกต์ใช้กับ-real-world-projects)
- [7. Best Practices ในการ Monitoring](#7-best-practices-ในการ-monitoring)
- [8. แนวโน้มในอนาคตของ Monitoring](#8-แนวโน้มในอนาคตของ-monitoring)

## 1. บทนำสู่การ Monitoring

### 1.1 ความสำคัญของการ Monitoring

ในโลกของ DevOps และ Cloud Native ที่แอปพลิเคชันมีความซับซ้อนมากขึ้น การ monitoring จึงมีความสำคัญอย่างยิ่งต่อความสำเร็จของการให้บริการดิจิทัล การ monitoring ช่วยให้ทีมพัฒนาและ operations สามารถ:

- **เฝ้าระวังสถานะ** ของระบบแบบเรียลไทม์
- **วินิจฉัยปัญหา** ได้รวดเร็ว ก่อนที่ผู้ใช้จะได้รับผลกระทบ
- **วิเคราะห์แนวโน้ม** การใช้งานทรัพยากรในระยะยาว
- **ติดตามประสิทธิภาพ** ของการเปลี่ยนแปลงหรือการอัปเดตระบบ
- **วางแผนการขยายระบบ** ได้อย่างมีประสิทธิภาพ

### 1.2 พัฒนาการของระบบ Monitoring

#### ในอดีต:
ในอดีตการ monitoring ระบบมีลักษณะดังนี้:

- **แบบรวมศูนย์ (Centralized)**: มักใช้เครื่องมือรวมศูนย์ที่ราคาแพงและขาดความยืดหยุ่น
- **ไม่เรียลไทม์**: ข้อมูลมักล่าช้า ทำให้ไม่สามารถแก้ไขปัญหาได้ทันท่วงที
- **ต้องใช้ผู้เชี่ยวชาญ**: การตั้งค่าและบำรุงรักษาระบบต้องใช้ผู้เชี่ยวชาญเฉพาะทาง
- **แยกส่วน**: การ monitoring แต่ละส่วน (เซิร์ฟเวอร์, เครือข่าย, แอปพลิเคชัน) มักแยกจากกัน
- **ขาดความยืดหยุ่น**: ปรับเปลี่ยนหรือขยายระบบได้ยาก

#### ในปัจจุบัน:
ปัจจุบันระบบ monitoring ได้พัฒนาไปอย่างมาก:

- **แบบกระจาย (Distributed)**: รองรับการทำงานแบบกระจายศูนย์และ microservices
- **เรียลไทม์**: ให้ข้อมูลแบบเรียลไทม์ ช่วยให้ตอบสนองต่อปัญหาได้ทันที
- **Open Source**: มีเครื่องมือ open source คุณภาพสูง เช่น Prometheus และ Grafana
- **Self-service**: ทีมพัฒนาสามารถตั้งค่าและจัดการการ monitor ได้เอง
- **บูรณาการ**: สามารถบูรณาการกับระบบอื่นๆ เช่น CI/CD และระบบแจ้งเตือนได้ง่าย
- **รองรับ Container**: ออกแบบมาให้ทำงานกับ containers และ orchestration platforms

```mermaid
graph TB
    subgraph "อดีต"
    A1[เครื่องมือ Monitoring<br>แบบรวมศูนย์] --> B1[เซิร์ฟเวอร์ 1]
    A1 --> B2[เซิร์ฟเวอร์ 2]
    A1 --> B3[เซิร์ฟเวอร์ 3]
    B1 --> C1[รายงานไม่เรียลไทม์]
    B2 --> C1
    B3 --> C1
    C1 --> D1[ทีม Ops วิเคราะห์<br>และแก้ไขปัญหา]
    end
    
    subgraph "ปัจจุบัน"
    A2[Prometheus] --> B4[Container 1<br>+Exporter]
    A2 --> B5[Container 2<br>+Exporter]
    A2 --> B6[Container N<br>+Exporter]
    A2 --> B7[Node<br>Exporter]
    A2 --> Grafana
    Grafana --> D2[Dashboard<br>เรียลไทม์]
    A2 --> AlertManager
    AlertManager --> E1[Slack<br>Notification]
    AlertManager --> E2[Email<br>Alert]
    AlertManager --> E3[PagerDuty]
    D2 --> F1[DevOps Team]
    E1 --> F1
    E2 --> F1
    E3 --> F1
    end
```

### 1.3 ทำไมปัจจุบันถึงดีกว่า และจำเป็นอย่างไร

**เหตุผลที่วิธีการปัจจุบันดีกว่า:**

1. **รองรับ Cloud Native**: เหมาะกับสถาปัตยกรรมแบบไมโครเซอร์วิส และ cloud native applications
2. **ปรับขนาดได้**: สามารถปรับขนาดเพื่อรองรับระบบขนาดใหญ่ได้อย่างมีประสิทธิภาพ
3. **ต้นทุนต่ำ**: ลดต้นทุนด้วยการใช้ open-source solutions
4. **ชุมชนขนาดใหญ่**: มีชุมชนนักพัฒนาที่คอยสนับสนุนและพัฒนาเครื่องมือต่างๆ
5. **วิเคราะห์ข้อมูลขั้นสูง**: มีความสามารถในการวิเคราะห์และสร้างภาพข้อมูลที่ซับซ้อน
6. **อัตโนมัติ**: รองรับการทำงานแบบอัตโนมัติ เช่น auto-scaling ตามข้อมูล metrics

**เหตุผลที่จำเป็น:**

1. **ความซับซ้อนของระบบ**: แอปพลิเคชันสมัยใหม่มีความซับซ้อนสูง มีหลายส่วนประกอบ
2. **ความคาดหวังของผู้ใช้**: ผู้ใช้คาดหวังให้บริการพร้อมใช้งานตลอด 24/7
3. **การแข่งขันสูง**: องค์กรต้องรับประกันว่าบริการของพวกเขามีเสถียรภาพและประสิทธิภาพสูง
4. **การปรับขนาดอัตโนมัติ**: จำเป็นต้องมีข้อมูลสำหรับการตัดสินใจเพิ่มหรือลดขนาดระบบ
5. **ต้นทุนการดำเนินงาน**: ช่วยลดต้นทุนโดยการระบุปัญหาก่อนที่จะกระทบกับธุรกิจ
6. **การตัดสินใจบนพื้นฐานของข้อมูล**: ทำให้การตัดสินใจทางเทคนิคและธุรกิจอยู่บนพื้นฐานของข้อมูลจริง

## 2. Prometheus: ระบบเก็บข้อมูล Metrics

### 2.1 Prometheus คืออะไร

Prometheus เป็นระบบ monitoring และ time series database แบบ open-source ที่ออกแบบมาเพื่อความน่าเชื่อถือสูงในการ monitoring ระบบแบบเรียลไทม์ โดยเฉพาะในสภาพแวดล้อมแบบ dynamic เช่น Kubernetes และ cloud environments

Prometheus ทำงานด้วยหลักการ "pull-based" คือจะไปดึงข้อมูล metrics จากเป้าหมายที่กำหนดไว้ตามช่วงเวลาที่กำหนด แทนที่จะรอให้แอปพลิเคชันส่งข้อมูลมาให้แบบ "push-based"

### 2.2 สถาปัตยกรรมของ Prometheus

```mermaid
graph TD
    subgraph "Prometheus Ecosystem"
    A[Prometheus Server] -->|Scrape| B1[Service 1<br>+Exporter]
    A -->|Scrape| B2[Service 2<br>+Exporter]
    A -->|Scrape| B3[Node Exporter]
    A -->|Scrape| B4[Service Discovery]
    B4 --> C1[Kubernetes]
    B4 --> C2[Consul]
    B4 --> C3[AWS EC2]
    A --> D[Storage]
    A --> E[PromQL<br>Query Language]
    E --> F[Alertmanager]
    F --> G1[Email]
    F --> G2[Slack]
    F --> G3[PagerDuty]
    E --> H[Grafana]
    end
```

### 2.3 องค์ประกอบหลักของ Prometheus

1. **Prometheus Server**: ทำหน้าที่เก็บข้อมูล time series และประมวลผลข้อมูล
2. **Exporters**: ตัวดึงข้อมูลจากระบบต่างๆ เช่น Node Exporter (ข้อมูล server), MySQL Exporter, Redis Exporter
3. **Alertmanager**: จัดการและรวมการแจ้งเตือน แล้วส่งไปยังช่องทางต่างๆ
4. **PromQL**: ภาษาสำหรับ query ข้อมูล metrics โดยเฉพาะ
5. **Service Discovery**: ค้นหาเป้าหมายที่ต้องการเก็บ metrics โดยอัตโนมัติ

### 2.4 ประเภทของ Metrics ใน Prometheus

1. **Counter**: ค่าที่เพิ่มขึ้นเรื่อยๆ ไม่ลดลง (เช่น จำนวน HTTP requests)
2. **Gauge**: ค่าที่สามารถขึ้นและลงได้ (เช่น การใช้ CPU หรือ RAM)
3. **Histogram**: การกระจายของค่าในช่วงเวลา (เช่น latency ของ request)
4. **Summary**: คล้าย Histogram แต่คำนวณ percentiles บนเซิร์ฟเวอร์ต้นทาง

### 2.5 ข้อดีของ Prometheus

- **ใช้งานง่าย**: ติดตั้งและเริ่มต้นใช้งานได้อย่างรวดเร็ว
- **ออกแบบมาสำหรับ containers**: เหมาะกับการใช้ใน Kubernetes และ cloud environment
- **Multi-dimensional data**: เก็บ metrics พร้อม labels ที่หลากหลาย
- **มีชุมชนที่ใหญ่**: มีการพัฒนาและสนับสนุนจากชุมชนอย่างต่อเนื่อง
- **เสถียร**: ออกแบบให้ทำงานได้อย่างน่าเชื่อถือแม้ในสภาพแวดล้อมที่มีปัญหา
- **Pull-based model**: ง่ายต่อการทำ monitoring และการค้นพบปัญหา

### 2.6 การตั้งค่า Prometheus พื้นฐาน

ตัวอย่าง configuration file สำหรับ Prometheus (`prometheus.yml`):

```yaml
global:
  scrape_interval:     15s # How often to scrape targets
  evaluation_interval: 15s # How often to evaluate rules

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['node_exporter:9100']

  - job_name: 'api_service'
    static_configs:
      - targets: ['api:8080']
    metrics_path: '/metrics'
```

## 3. Grafana: การสร้าง Dashboard

### 3.1 Grafana คืออะไร

Grafana เป็นแพลตฟอร์ม open source สำหรับการสร้าง dashboard และการวิเคราะห์ข้อมูล โดยสามารถเชื่อมต่อกับแหล่งข้อมูลหลายประเภท เช่น Prometheus, Elasticsearch, InfluxDB และอื่นๆ Grafana มีเครื่องมือที่ช่วยให้สามารถสร้างภาพที่เข้าใจง่าย และกราฟที่มีประสิทธิภาพเพื่อแสดงข้อมูล metrics

### 3.2 ความสามารถหลักของ Grafana

- **Data Visualization**: สร้างกราฟและภาพแสดงข้อมูลที่ซับซ้อนได้อย่างง่ายดาย
- **Dashboard**: สร้าง dashboard ที่มีข้อมูลจากหลายแหล่งรวมกัน
- **Alerting**: กำหนดการแจ้งเตือนตามเงื่อนไขที่กำหนด
- **Multi-data sources**: เชื่อมต่อกับแหล่งข้อมูลหลายประเภทในคราวเดียว
- **Plugins**: ขยายความสามารถด้วย plugins ที่หลากหลาย
- **Templating**: สร้าง dashboard ที่แสดงผลตามตัวแปรที่กำหนด เช่น เลือกเซิร์ฟเวอร์

### 3.3 การสร้าง Dashboard สำหรับ Container และ Services

#### ตัวอย่าง Dashboard ที่ควรมี:

1. **System Overview Dashboard**:
   - CPU, Memory, Disk และ Network ของระบบ
   - จำนวน containers ที่ทำงานหรือล้มเหลว
   - ปริมาณการใช้งานทรัพยากร

```mermaid
graph LR
    subgraph "System Overview Dashboard"
    A[CPU Usage] --> B[Memory Usage]
    B --> C[Disk I/O]
    C --> D[Network Traffic]
    D --> E[Running Containers]
    E --> F[Failed Containers]
    end
```

2. **Service-specific Dashboard**:
   - Response time ของแต่ละ service
   - Error rates
   - Request rates
   - Success rates
   - Custom metrics

3. **Database Dashboard**:
   - Query performance
   - Connection counts
   - Transaction rates
   - Replication status

### 3.4 การสร้าง Dashboard ที่มีประสิทธิภาพ

1. **ใช้หลัก USE Method**:
   - Utilization: ทรัพยากรถูกใช้มากแค่ไหน
   - Saturation: ทรัพยากรมีงานค้างอยู่มากแค่ไหน
   - Errors: มีข้อผิดพลาดเกิดขึ้นหรือไม่

2. **ใช้หลัก RED Method** สำหรับ Service Monitoring:
   - Rate: จำนวน request ต่อวินาที
   - Errors: จำนวน failed requests
   - Duration: เวลาในการตอบสนอง

3. **สร้างความชัดเจนด้วยการจัดระเบียบ**:
   - จัดกลุ่มข้อมูลที่เกี่ยวข้องไว้ด้วยกัน
   - ลำดับความสำคัญของข้อมูล (สิ่งสำคัญอยู่ด้านบน)
   - ใช้สีและขนาดเพื่อเน้นข้อมูลที่สำคัญ

4. **เพิ่มการอธิบาย**:
   - เพิ่ม annotation เพื่ออธิบายเหตุการณ์สำคัญ
   - เพิ่มคำอธิบายใต้กราฟเพื่อให้เข้าใจง่าย
   - ระบุเกณฑ์สำหรับสถานะปกติและผิดปกติ

### 3.5 การตั้งค่า Grafana กับ Prometheus

1. **เพิ่ม Prometheus เป็น Data Source**:
   - ไปที่ Configuration > Data Sources > Add data source
   - เลือก Prometheus
   - กำหนด URL (เช่น http://prometheus:9090)
   - บันทึกและทดสอบ

2. **สร้าง Dashboard**:
   - เลือก Create > Dashboard
   - เพิ่ม panel และเลือก query แบบ PromQL
   - ตัวอย่าง query:
     - CPU usage: `100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)`
     - Memory usage: `node_memory_MemTotal_bytes - node_memory_MemFree_bytes - node_memory_Buffers_bytes - node_memory_Cached_bytes`
     - Disk usage: `100 - ((node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100)`

## 4. Uptime Monitoring

### 4.1 ความสำคัญของ Uptime Monitoring

Uptime monitoring เป็นการติดตามว่าเซิร์ฟเวอร์หรือบริการยังทำงานอยู่หรือไม่ และแจ้งเตือนเมื่อเกิดปัญหา ซึ่งมีความสำคัญอย่างยิ่งในการรักษา SLA (Service Level Agreement) และความพึงพอใจของผู้ใช้

ข้อมูลที่ได้จาก uptime monitoring ยังช่วยในการคำนวณ:
- **Uptime Percentage**: เปอร์เซ็นต์เวลาที่บริการพร้อมใช้งาน
- **MTBF (Mean Time Between Failures)**: ระยะเวลาเฉลี่ยระหว่างความล้มเหลว
- **MTTR (Mean Time To Recovery)**: ระยะเวลาเฉลี่ยในการกู้คืนระบบ

### 4.2 วิธีการทำ Uptime Monitoring

#### 4.2.1 การ Check แบบพื้นฐาน

1. **HTTP/HTTPS Check**: ตรวจสอบว่าเว็บไซต์ตอบสนองด้วย status code ที่ถูกต้องหรือไม่
2. **TCP Port Check**: ตรวจสอบว่า port ที่ต้องการเปิดอยู่หรือไม่
3. **ICMP (Ping) Check**: ตรวจสอบว่าเซิร์ฟเวอร์ตอบสนองต่อ ping หรือไม่
4. **DNS Check**: ตรวจสอบว่า DNS resolver ทำงานถูกต้องหรือไม่

#### 4.2.2 การ Check แบบขั้นสูง

1. **Transaction Check**: จำลองการทำธุรกรรมของผู้ใช้ เช่น การ login หรือการทำธุรกรรม
2. **API Check**: ตรวจสอบว่า API ตอบสนองถูกต้องทั้งในแง่ของ status code และ content
3. **Content Check**: ตรวจสอบว่าเนื้อหาที่ส่งกลับมามีข้อมูลที่ถูกต้องหรือไม่
4. **Certificate Check**: ตรวจสอบอายุและความถูกต้องของ SSL/TLS certificates

### 4.3 เครื่องมือสำหรับ Uptime Monitoring

#### 4.3.1 Blackbox Exporter (Prometheus)

Blackbox Exporter เป็น exporter ของ Prometheus ที่ทำหน้าที่ตรวจสอบ endpoints จากภายนอก (black box testing) และรายงานผลลัพธ์เป็น metrics ที่ Prometheus สามารถเก็บได้

ตัวอย่างการตั้งค่า:

```yaml
scrape_configs:
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
        - https://example.com
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: blackbox-exporter:9115
```

#### 4.3.2 เครื่องมือ External

- **Uptime Robot**: บริการฟรีที่ตรวจสอบทุก 5 นาที
- **Pingdom**: บริการระดับองค์กรที่มีการรายงานละเอียด
- **Statuspage.io**: ช่วยในการสื่อสารสถานะของบริการกับผู้ใช้
- **Grafana Cloud**: ให้บริการ synthetic monitoring รวมกับ dashboard

### 4.4 การตั้งค่าระบบแจ้งเตือนสำหรับ Uptime Monitoring

1. **กำหนดเกณฑ์**:
   - บริการไม่ตอบสนองภายใน X วินาที
   - มี error response มากกว่า Y% ในช่วง Z นาที
   - Response time มากกว่า N มิลลิวินาที

2. **ช่องทางการแจ้งเตือน**:
   - Email
   - SMS
   - Slack หรือ Teams
   - PagerDuty หรือ OpsGenie สำหรับการ escalation

3. **ระดับความรุนแรง (Severity Levels)**:
   - Critical: ต้องรีบแก้ไขทันที
   - Warning: ต้องตรวจสอบแต่ยังไม่มีผลกระทบกับผู้ใช้
   - Info: ข้อมูลที่ควรทราบแต่ไม่ต้องดำเนินการใดๆ

```mermaid
sequenceDiagram
    participant Monitor as Uptime Monitor
    participant Service as Web Service
    participant Alert as Alert System
    participant Team as DevOps Team
    
    loop Every minute
        Monitor->>Service: HTTP Check
        alt Service Down
            Service--xMonitor: Timeout/5xx Error
            Monitor->>Alert: Send Alert
            Alert->>Team: Notification
        else Service Degraded
            Service-->>Monitor: Slow Response (>2s)
            Monitor->>Alert: Send Warning
            Alert->>Team: Warning Notification
        else Service OK
            Service-->>Monitor: 2xx Response (<1s)
        end
    end
```

## 5. แนวทางการติดตั้งและใช้งาน

### 5.1 การติดตั้งระบบ Monitoring ด้วย Docker Compose

สร้างไฟล์ `docker-compose.yml` สำหรับระบบ monitoring แบบพื้นฐาน:

```yaml
version: '3'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./prometheus/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--web.console.libraries=/etc/prometheus/console_libraries'
      - '--web.console.templates=/etc/prometheus/consoles'
    ports:
      - "9090:9090"
    restart: always

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    volumes:
      - grafana_data:/var/lib/grafana
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    ports:
      - "3000:3000"
    depends_on:
      - prometheus
    restart: always

  node_exporter:
    image: prom/node-exporter:latest
    container_name: node_exporter
    volumes:
      - /proc:/host/proc:ro
      - /sys:/host/sys:ro
      - /:/rootfs:ro
    command:
      - '--path.procfs=/host/proc'
      - '--path.sysfs=/host/sys'
      - '--collector.filesystem.ignored-mount-points=^/(sys|proc|dev|host|etc)($$|/)'
    ports:
      - "9100:9100"
    restart: always

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
    ports:
      - "8080:8080"
    restart: always

  alertmanager:
    image: prom/alertmanager:latest
    container_name: alertmanager
    volumes:
      - ./alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml
    command:
      - '--config.file=/etc/alertmanager/alertmanager.yml'
    ports:
      - "9093:9093"
    restart: always

volumes:
  prometheus_data
  grafana-data:
```

### 5.2 การตั้งค่า Prometheus

สร้างไฟล์ `prometheus.yml` สำหรับกำหนดค่า Prometheus:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets: ['alertmanager:9093']

rule_files:
  - "alert_rules.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['node_exporter:9100']

  - job_name: 'cadvisor'
    static_configs:
      - targets: ['cadvisor:8080']

  - job_name: 'app'
    static_configs:
      - targets: ['app:8000']  # พอร์ตของแอปพลิเคชัน
```

### 5.3 การตั้งค่า Alert Manager

สร้างไฟล์ `alertmanager.yml` เพื่อกำหนดค่า Alert Manager:

```yaml
global:
  resolve_timeout: 5m

route:
  group_by: ['alertname']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 1h
  receiver: 'email-notifications'

receivers:
- name: 'email-notifications'
  email_configs:
  - to: 'alerts@example.com'
    from: 'alertmanager@example.com'
    smarthost: 'smtp.example.com:587'
    auth_username: 'alertmanager'
    auth_password: 'password'

- name: 'slack-notifications'
  slack_configs:
  - api_url: 'https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX'
    channel: '#alerts'
    send_resolved: true
```

### 5.4 การสร้าง Alert Rules

สร้างไฟล์ `alert_rules.yml` เพื่อกำหนดกฎการแจ้งเตือน:

```yaml
groups:
- name: example
  rules:
  - alert: HighCPULoad
    expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[1m])) * 100) > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High CPU load (instance {{ $labels.instance }})"
      description: "CPU load is > 80%\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"

  - alert: HighMemoryUsage
    expr: (node_memory_MemTotal_bytes - node_memory_MemFree_bytes - node_memory_Buffers_bytes - node_memory_Cached_bytes) / node_memory_MemTotal_bytes * 100 > 80
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High memory usage (instance {{ $labels.instance }})"
      description: "Memory usage is > 80%\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"

  - alert: HighDiskUsage
    expr: 100 - ((node_filesystem_avail_bytes * 100) / node_filesystem_size_bytes) > 85
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High disk usage (instance {{ $labels.instance }})"
      description: "Disk usage is > 85%\n  VALUE = {{ $value }}\n  LABELS: {{ $labels }}"
```

### 5.5 ตั้งค่า Application สำหรับ Monitoring

#### 5.5.1 Python Application

หากคุณใช้ Python, คุณสามารถใช้ `prometheus-client` package:

```python
from prometheus_client import start_http_server, Counter, Gauge, Histogram
import random
import time

# สร้าง metrics
REQUEST_COUNT = Counter('app_requests_total', 'Total app HTTP requests')
REQUEST_INPROGRESS = Gauge('app_requests_inprogress', 'Number of in-progress HTTP requests')
REQUEST_DURATION = Histogram('app_request_duration_seconds', 'HTTP request duration in seconds')

# ฟังก์ชันจำลองการทำงาน
def process_request():
    REQUEST_COUNT.inc()
    REQUEST_INPROGRESS.inc()
    
    duration = random.uniform(0.1, 0.5)
    time.sleep(duration)
    
    REQUEST_INPROGRESS.dec()
    REQUEST_DURATION.observe(duration)

if __name__ == '__main__':
    # เริ่มต้น metrics server ที่พอร์ต 8000
    start_http_server(8000)
    
    # จำลองการทำงานของแอปพลิเคชัน
    while True:
        process_request()
        time.sleep(random.uniform(0.1, 0.3))
```

#### 5.5.2 Node.js Application

สำหรับ Node.js, คุณสามารถใช้ `prom-client`:

```javascript
const express = require('express');
const promClient = require('prom-client');

const app = express();
const register = new promClient.Registry();
promClient.collectDefaultMetrics({ register });

const httpRequestDurationMicroseconds = new promClient.Histogram({
  name: 'http_request_duration_seconds',
  help: 'HTTP request duration in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.1, 0.3, 0.5, 0.7, 1, 3, 5, 7, 10]
});

register.registerMetric(httpRequestDurationMicroseconds);

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.get('/', (req, res) => {
  const end = httpRequestDurationMicroseconds.startTimer();
  res.send('Hello World!');
  end({ method: 'GET', route: '/', status_code: 200 });
});

app.listen(8000, () => {
  console.log('Server listening on port 8000');
});
```

## 6. การประยุกต์ใช้กับ Real-World Projects

### 6.1 การ Monitor Microservices Architecture

การทำ monitoring สำหรับ microservices มีความซับซ้อนมากกว่า monolithic applications เนื่องจากมีหลายส่วนประกอบที่ต้องติดตาม และต้องสามารถเชื่อมโยง request ที่ผ่านบริการต่างๆ เข้าด้วยกัน

#### 6.1.1 การใช้ Service Mesh

Service Mesh เช่น Istio หรือ Linkerd ช่วยให้สามารถ monitor ได้แบบอัตโนมัติ โดยไม่ต้องแก้ไขโค้ด โดยจะให้ข้อมูลเช่น:

- Request volume
- Success/error rates
- Latency
- Service dependencies
- Traffic flow

#### 6.1.2 Distributed Tracing

Distributed Tracing ช่วยให้ติดตาม request ที่ผ่านระบบ microservices ได้อย่างต่อเนื่อง เพื่อเข้าใจการทำงานของระบบและหาปัญหาได้ง่ายขึ้น

เครื่องมือที่นิยมใช้:
- Jaeger
- Zipkin
- OpenTelemetry

ตัวอย่างการตั้งค่า OpenTelemetry สำหรับ Python:

```python
from opentelemetry import trace
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
from opentelemetry.sdk.resources import SERVICE_NAME, Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

# ตั้งค่า tracer
resource = Resource(attributes={
    SERVICE_NAME: "my-service"
})

jaeger_exporter = JaegerExporter(
    agent_host_name="jaeger",
    agent_port=6831,
);

provider = TracerProvider(resource=resource)
processor = BatchSpanProcessor(jaeger_exporter)
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)

tracer = trace.get_tracer(__name__)

# ใช้งาน tracer
with tracer.start_as_current_span("my_function") as span:
    span.set_attribute("operation.name", "processing")
    # ดำเนินการบางอย่าง
    result = do_something()
    span.set_attribute("operation.result", result)
```

#### 6.1.3 Dashboard สำหรับ Microservices

ตัวอย่าง Grafana dashboard ที่ควรมีสำหรับ microservices:

1. **Service Overview**: แสดงภาพรวมของทุกบริการ
2. **Service Detail**: รายละเอียดของแต่ละบริการ
3. **Dependency Map**: แผนผังการพึ่งพากันระหว่างบริการ
4. **Error Analysis**: วิเคราะห์ error โดยละเอียด
5. **Trace Analysis**: แสดง trace ของ request ที่น่าสนใจ

### 6.2 การ Monitor ระบบ Containerized

การ monitor containers มีความแตกต่างจากการ monitor เซิร์ฟเวอร์ทั่วไป เนื่องจาก containers มีลักษณะเป็น ephemeral และมีการเปลี่ยนแปลงบ่อย

#### 6.2.1 การใช้ cAdvisor

cAdvisor เป็นเครื่องมือที่ออกแบบมาสำหรับเก็บ metrics จาก containers โดยเฉพาะ โดยจะให้ข้อมูลเช่น:

- CPU usage
- Memory usage
- Network I/O
- Disk I/O

#### 6.2.2 การ Monitor Kubernetes

สำหรับ Kubernetes ควรใช้ kube-state-metrics และ Prometheus เพื่อเก็บข้อมูลเกี่ยวกับ:

- Node status
- Pod status
- Deployment status
- ReplicaSet status
- Resource usage vs. requests/limits

ตัวอย่างการตั้งค่า kube-prometheus-stack ด้วย Helm:

```bash
# เพิ่ม Helm repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# ติดตั้ง kube-prometheus-stack
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.adminPassword=admin
```

#### 6.2.3 การสร้าง Custom Metrics สำหรับ Auto-scaling

Kubernetes สามารถใช้ custom metrics สำหรับ auto-scaling ได้ด้วย Prometheus Adapter:

```yaml
apiVersion: autoscaling/v2beta2
kind: HorizontalPodAutoscaler
metadata:
  name: my-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: my-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: 100
```

### 6.3 Case Studies

#### 6.3.1 E-commerce Platform

บริษัท ABC ประสบปัญหา performance และ downtime บนแพลตฟอร์ม e-commerce ของพวกเขา โดยเฉพาะในช่วงการขายที่มีปริมาณสูง

**แนวทางแก้ไข**:

1. ติดตั้ง Prometheus และ Grafana เพื่อ monitor:
   - API response times
   - Database query performance
   - Cache hit/miss rates
   - Error rates

2. สร้าง dashboards เฉพาะสำหรับ:
   - Real-time sales monitoring
   - Inventory system performance
   - Payment gateway status
   - User activity

3. ตั้งค่าการแจ้งเตือนสำหรับ:
   - Latency เกิน 500ms
   - Error rate เกิน 1%
   - CPU/Memory usage เกิน 80%

**ผลลัพธ์**:
- ลดเวลาในการตรวจจับปัญหาลง 75%
- ลด downtime ลง 90%
- เพิ่มความสามารถในการรองรับผู้ใช้ 3 เท่า
- เพิ่มรายได้ในช่วงการขายพิเศษ 30%

#### 6.3.2 SaaS Application

บริษัท XYZ มี SaaS application ที่ให้บริการลูกค้าหลายราย โดยแต่ละรายใช้ทรัพยากรไม่เท่ากัน ทำให้ยากในการ monitor และ billing

**แนวทางแก้ไข**:

1. ใช้ Prometheus with multi-tenancy:
   - เพิ่ม tenant_id เป็น label ใน metrics ทั้งหมด
   - แยก Grafana dashboard ตาม tenant

2. สร้าง custom metrics สำหรับ billing:
   - API call counts per tenant
   - Storage usage per tenant
   - Processing time per tenant

3. ส่ง metrics ไปยัง time-series database สำหรับเก็บข้อมูลระยะยาว (เช่น InfluxDB, TimescaleDB)

**ผลลัพธ์**:
- สามารถคิดค่าบริการตามการใช้จริงได้อย่างแม่นยำ
- เพิ่มความโปร่งใสให้ลูกค้าเห็นการใช้งานของตัวเอง
- ลดการใช้ทรัพยากรที่ไม่จำเป็น 25%
- เพิ่มอัตรากำไร 15%

## 7. Best Practices ในการ Monitoring

### 7.1 Four Golden Signals

Google SRE (Site Reliability Engineering) แนะนำให้ focus ที่ "Four Golden Signals":

1. **Latency**: เวลาที่ใช้ในการตอบสนองต่อ request
   - ควรแยกระหว่าง successful responses และ failed responses
   - ควรใช้ percentiles (p50, p95, p99) แทน averages

2. **Traffic**: ปริมาณงานที่เข้ามาในระบบ
   - HTTP requests per second
   - Queries per second
   - Network bandwidth
   - Concurrent sessions

3. **Errors**: อัตราส่วนของ requests ที่ล้มเหลว
   - HTTP 5xx errors
   - Application errors
   - Failed validations
   - Timeout errors

4. **Saturation**: ระดับการใช้งานของทรัพยากรในระบบ
   - CPU usage
   - Memory usage
   - Disk I/O
   - Network bandwidth
   - Connection pool usage

ตัวอย่างการ query ใน Prometheus:

```
# Latency
histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[5m])) by (le))

# Traffic
sum(rate(http_requests_total[5m]))

# Errors
sum(rate(http_requests_total{status=~"5.."}[5m])) / sum(rate(http_requests_total[5m]))

# Saturation
100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[1m])) * 100)
```

### 7.2 USE Method

USE Method ถูกพัฒนาโดย Brendan Gregg สำหรับการวิเคราะห์ประสิทธิภาพของทรัพยากรระบบ:

- **Utilization**: เปอร์เซ็นต์ของเวลาที่ทรัพยากรถูกใช้งาน
- **Saturation**: ปริมาณงานที่รอคิวเพื่อใช้ทรัพยากร
- **Errors**: จำนวนข้อผิดพลาดที่เกิดขึ้น

ตัวอย่างการนำ USE Method ไปใช้:

| ทรัพยากร | Utilization | Saturation | Errors |
|---------|-------------|------------|--------|
| CPU | `avg by (instance) (irate(node_cpu_seconds_total{mode!="idle"}[1m]))` | `node_load1`, `node_load5`, `node_load15` | `node_context_switches_total` |
| Memory | `node_memory_MemTotal_bytes - node_memory_MemFree_bytes - node_memory_Buffers_bytes - node_memory_Cached_bytes` | `node_memory_SwapTotal_bytes - node_memory_SwapFree_bytes` | `oom_kills` |
| Disk | `rate(node_disk_io_time_seconds_total[1m])` | `node_disk_io_time_weighted_seconds_total` | `node_disk_io_time_weighted_seconds_total - node_disk_io_time_seconds_total` |
| Network | `rate(node_network_transmit_bytes_total[1m]) + rate(node_network_receive_bytes_total[1m])` | `node_network_transmit_queue_length`, `node_network_receive_queue_length` | `node_network_transmit_errs_total`, `node_network_receive_errs_total` |

### 7.3 Alert Design

การออกแบบการแจ้งเตือนที่ดีควรมีลักษณะดังนี้:

1. **Actionable**: ควรมีการกระทำที่ชัดเจนที่ต้องทำเมื่อได้รับการแจ้งเตือน
2. **Accurate**: ลดการเกิด false positives และ false negatives
3. **Contextual**: มีข้อมูลที่เพียงพอที่จะเข้าใจและแก้ไขปัญหา
4. **Meaningful**: แจ้งเตือนเฉพาะเรื่องที่มีผลกระทบต่อผู้ใช้หรือธุรกิจ

ตัวอย่างการตั้งค่าการแจ้งเตือนที่ดี:

```yaml
- alert: APIHighLatency
  expr: histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket{job="api-service"}[5m])) by (le)) > 0.5
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "API latency is above threshold"
    description: "95th percentile of API response time is above 500ms for 5 minutes"
    dashboard: "https://grafana.example.com/d/api-performance"
    playbook: "https://wiki.example.com/playbooks/high-api-latency"
```

### 7.4 Dashboard Design

การออกแบบ dashboard ที่มีประสิทธิภาพควรคำนึงถึง:

1. **Keep it simple**: แสดงเฉพาะข้อมูลที่สำคัญ ไม่แน่นเกินไป
2. **Hierarchy of information**: จัดข้อมูลตามลำดับความสำคัญ
3. **Consistency**: ใช้สี, หน่วย, และการจัดวางที่สอดคล้องกัน
4. **Context**: ให้ข้อมูลพื้นฐานเพียงพอที่จะเข้าใจ dashboard
5. **Time alignment**: ใช้ช่วงเวลาเดียวกันในทุก panel เพื่อให้เปรียบเทียบได้
6. **Annotations**: เพิ่มเหตุการณ์สำคัญ เช่น deployments หรือการเปลี่ยนแปลงระบบ

### 7.5 Monitoring as Code

การจัดการระบบ monitoring ด้วย code (Infrastructure as Code) มีข้อดีหลายประการ:

1. **Version control**: เก็บประวัติการเปลี่ยนแปลงในระบบ monitoring
2. **Consistency**: ทำให้แน่ใจว่าการตั้งค่าเหมือนกันในทุกสภาพแวดล้อม
3. **Automation**: ลดข้อผิดพลาดจากการตั้งค่าด้วยมือ
4. **Scalability**: สามารถจัดการระบบ monitoring ขนาดใหญ่ได้อย่างมีประสิทธิภาพ

ตัวอย่าง Monitoring as Code ด้วย Jsonnet สำหรับ Grafana dashboard:

```jsonnet
local grafana = import 'grafonnet/grafana.libsonnet';
local dashboard = grafana.dashboard;
local row = grafana.row;
local prometheus = grafana.prometheus;
local template = grafana.template;
local graphPanel = grafana.graphPanel;

dashboard.new(
  'API Service Dashboard',
  tags=['api', 'service'],
  time_from='now-1h',
)
.addTemplate(
  template.new(
    'instance',
    'Prometheus',
    'label_values(api_requests_total, instance)',
    label='Instance',
    refresh='time',
  )
)
.addRow(
  row.new(
    title='Request Rate'
  )
  .addPanel(
    graphPanel.new(
      'Requests per Second',
      datasource='Prometheus',
      min=0,
    )
    .addTarget(
      prometheus.target(
        'sum(rate(api_requests_total{instance=~"$instance"}[1m]))',
        legendFormat='{{instance}}',
      )
    )
  )
)
```

## 8. แนวโน้มในอนาคตของ Monitoring

### 8.1 AIOps และ Machine Learning

AIOps (Artificial Intelligence for IT Operations) กำลังเปลี่ยนแปลงวิธีการ monitoring ระบบ โดยใช้ AI และ machine learning:

1. **Anomaly Detection**: ตรวจจับรูปแบบที่ผิดปกติโดยอัตโนมัติ
2. **Root Cause Analysis**: วิเคราะห์หาสาเหตุที่แท้จริงของปัญหา
3. **Predictive Monitoring**: คาดการณ์ปัญหาก่อนที่จะเกิดขึ้น
4. **Noise Reduction**: ลดการแจ้งเตือนที่ไม่จำเป็น
5. **Auto-remediation**: แก้ไขปัญหาโดยอัตโนมัติ

เครื่องมือที่น่าสนใจ:
- Dynatrace
- Datadog
- New Relic
- Elastic Observability
- Splunk IT Service Intelligence

### 8.2 eBPF (Extended Berkeley Packet Filter)

eBPF เป็นเทคโนโลยีที่กำลังเปลี่ยนแปลงการ monitoring ใน Linux kernel โดยมีความสามารถ:

1. **Performance Observability**: เก็บ metrics โดยไม่ต้องแก้ไขโค้ดแอปพลิเคชัน
2. **Deep Inspection**: สามารถดูข้อมูลระดับลึกของ kernel และ application
3. **Low Overhead**: มี overhead ต่ำมากเมื่อเทียบกับวิธีการแบบเดิม
4. **Dynamic Deployment**: สามารถเพิ่มหรือลบการ monitoring ได้แบบ runtime

เครื่องมือที่ใช้ eBPF:
- Falco
- Cilium
- Pixie
- bpftrace

### 8.3 OpenTelemetry

OpenTelemetry เป็นมาตรฐานเปิดสำหรับ telemetry ที่กำลังได้รับความนิยมมากขึ้น:

1. **Vendor Neutral**: ไม่ผูกติดกับผู้ให้บริการรายใดรายหนึ่ง
2. **Unified Approach**: รวม metrics, logs และ traces ไว้ในมาตรฐานเดียวกัน
3. **Wide Adoption**: มีการสนับสนุนจากผู้ให้บริการ cloud และ observability หลายราย
4. **Cross-language**: รองรับหลายภาษาโปรแกรม

ตัวอย่างการใช้ OpenTelemetry กับ Node.js:

```javascript
const { NodeTracerProvider } = require('@opentelemetry/node');
const { SimpleSpanProcessor } = require('@opentelemetry/tracing');
const { JaegerExporter } = require('@opentelemetry/exporter-jaeger');
const { registerInstrumentations } = require('@opentelemetry/instrumentation');
const { ExpressInstrumentation } = require('@opentelemetry/instrumentation-express');
const { HttpInstrumentation } = require('@opentelemetry/instrumentation-http');

// ตั้งค่า tracer provider
const provider = new NodeTracerProvider();

// ตั้งค่า exporter
const exporter = new JaegerExporter({
  serviceName: 'my-service',
  host: 'jaeger',
  port: 6832,
});

// ตั้งค่า processor และเพิ่มเข้าไปใน provider
const processor = new SimpleSpanProcessor(exporter);
provider.addSpanProcessor(processor);
provider.register();

// ลงทะเบียน auto-instrumentations
registerInstrumentations({
  instrumentations: [
    new HttpInstrumentation(),
    new ExpressInstrumentation(),
  ],
});

// ทำงานต่อไปตามปกติ
const express = require('express');
const app = express();

app.get('/', (req, res) => {
  res.send('Hello World!');
});

app.listen(3000, () => {
  console.log('Server running on port 3000');
});
```

### 8.4 Real User Monitoring (RUM)

Real User Monitoring เป็นการติดตามประสบการณ์ของผู้ใช้จริง ซึ่งกำลังกลายเป็นส่วนสำคัญของระบบ monitoring:

1. **Frontend Performance**: ติดตามความเร็วในการโหลดหน้าเว็บและการทำงานของ frontend
2. **User Journey**: ติดตามเส้นทางการใช้งานของผู้ใช้
3. **Conversion Funnel**: ติดตามอัตราการเปลี่ยนแปลงในแต่ละขั้นตอน
4. **Error Tracking**: บันทึกข้อผิดพลาดที่เกิดขึ้นกับผู้ใช้

เครื่องมือที่น่าสนใจ:
- Google Analytics
- Sentry
- Datadog RUM
- LogRocket
- Mixpanel

ตัวอย่างการใช้งานกับ JavaScript:

```javascript
// ติดตั้ง script ที่ head ของเว็บไซต์
<script>
(function(c,l,a,r,i,t,y){
    c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
    t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
    y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
})(window, document, "clarity", "script", "YOUR_CLARITY_PROJECT_ID");
</script>

// เพิ่มการติดตาม custom events
document.getElementById('signup-button').addEventListener('click', function() {
  clarity('event', 'signup_click');
});