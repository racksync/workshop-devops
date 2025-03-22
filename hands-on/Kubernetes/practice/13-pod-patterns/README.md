# Kubernetes Multi-Container Pod Patterns Workshop

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | รูปแบบการออกแบบ Multi-Container Pods ใน Kubernetes |
| **วัตถุประสงค์** | เรียนรู้และประยุกต์ใช้รูปแบบการออกแบบ Pod ที่มีหลาย Container เช่น Sidecar, Ambassador และ Adapter |
| **ระดับความยาก** | ปานกลาง |

ในเวิร์คช็อปนี้ เราจะเรียนรู้เกี่ยวกับรูปแบบการออกแบบ Multi-Container Pods ใน Kubernetes ซึ่งเป็นเทคนิคที่ช่วยให้สามารถออกแบบแอปพลิเคชันได้ยืดหยุ่น แยกความรับผิดชอบ และเพิ่มความสามารถให้กับแอปพลิเคชันได้โดยไม่ต้องแก้ไขโค้ดหลัก

## สิ่งที่จะได้เรียนรู้

- หลักการและแนวคิดของ Multi-Container Pods
- รูปแบบ Sidecar Pattern สำหรับเสริมความสามารถให้กับแอปพลิเคชันหลัก
- รูปแบบ Ambassador Pattern สำหรับเป็นตัวแทนในการเชื่อมต่อกับระบบภายนอก
- รูปแบบ Adapter Pattern สำหรับแปลงข้อมูลระหว่างแอปพลิเคชันกับระบบภายนอก
- รูปแบบ Init Container สำหรับเตรียมสภาพแวดล้อมก่อนเริ่มแอปพลิเคชันหลัก
- การแชร์ทรัพยากรระหว่าง Containers ใน Pod เดียวกัน
- ข้อดีและข้อควรระวังของแต่ละรูปแบบ

## ขั้นตอนการทำงาน

### 1. สร้าง Namespace

สร้าง Namespace เพื่อแยกทรัพยากรที่ใช้ในบทเรียนนี้:

```bash
kubectl create namespace pod-patterns
kubectl config set-context --current --namespace=pod-patterns
```

### 2. Sidecar Pattern: Log Collection

Sidecar Pattern เป็นรูปแบบที่มี Container เสริมทำหน้าที่สนับสนุน Container หลัก ในตัวอย่างนี้ เราจะสร้าง Pod ที่มี Container หลักสร้างไฟล์ log และมี Container เสริมทำหน้าที่อ่านและส่ง log:

```bash
kubectl apply -f sidecar-pattern.yaml
```

**sidecar-pattern.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-pattern
  namespace: pod-patterns
spec:
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh", "-c", "while true; do echo \"$(date): Application log\" >> /var/log/app.log; sleep 5; done"]
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
  - name: log-sidecar
    image: busybox
    command: ["/bin/sh", "-c", "tail -f /var/log/app.log"]
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
  volumes:
  - name: log-volume
    emptyDir: {}
```

ตรวจสอบผลลัพธ์จาก Container เสริม:

```bash
kubectl logs sidecar-pattern -c log-sidecar
```

### 3. Ambassador Pattern: Proxy to External Service

Ambassador Pattern เป็นรูปแบบที่มี Container ทำหน้าที่เป็นตัวแทนในการเชื่อมต่อกับบริการภายนอก ในตัวอย่างนี้ เราจะจำลองการใช้ Ambassador Container เป็น proxy ไปยังบริการภายนอก:

```bash
kubectl apply -f ambassador-pattern.yaml
```

**ambassador-pattern.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ambassador-pattern
  namespace: pod-patterns
spec:
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh", "-c", "while true; do echo \"Sending request to: localhost:9000\"; wget -q -O- http://localhost:9000; sleep 5; done"]
  - name: ambassador
    image: nginx
    ports:
    - containerPort: 9000
    volumeMounts:
    - name: nginx-conf
      mountPath: /etc/nginx/conf.d
  volumes:
  - name: nginx-conf
    configMap:
      name: nginx-ambassador-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-ambassador-config
  namespace: pod-patterns
data:
  default.conf: |
    server {
      listen 9000;
      location / {
        return 200 'Response from mock external service\n';
      }
    }
```

ตรวจสอบผลลัพธ์จาก Container หลัก:

```bash
kubectl logs ambassador-pattern -c app
```

### 4. Adapter Pattern: Log Format Transformation

Adapter Pattern เป็นรูปแบบที่มี Container ทำหน้าที่แปลงรูปแบบข้อมูลให้เข้ากับระบบอื่น ในตัวอย่างนี้ เราจะสร้าง Pod ที่มี Container หนึ่งสร้างไฟล์ log และอีก Container ทำหน้าที่แปลงรูปแบบ log:

```bash
kubectl apply -f adapter-pattern.yaml
```

**adapter-pattern.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: adapter-pattern
  namespace: pod-patterns
spec:
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh", "-c", "while true; do echo \"$(date): INFO Application message\" >> /var/log/app.log; echo \"$(date): ERROR Application error\" >> /var/log/app.log; sleep 5; done"]
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
  - name: log-adapter
    image: busybox
    command: ["/bin/sh", "-c", "while true; do grep ERROR /var/log/app.log | awk '{$1=\"ERROR:\"; print}' > /var/transformed/error.log; sleep 5; done"]
    volumeMounts:
    - name: log-volume
      mountPath: /var/log
    - name: transformed-logs
      mountPath: /var/transformed
  volumes:
  - name: log-volume
    emptyDir: {}
  - name: transformed-logs
    emptyDir: {}
```

ตรวจสอบผลลัพธ์จาก Container เสริม:

```bash
kubectl exec -it adapter-pattern -c log-adapter -- cat /var/transformed/error.log
```

### 5. Init Container Pattern

Init Container เป็น Container ที่ทำงานและเสร็จสิ้นก่อนที่ Container หลักจะเริ่มทำงาน เหมาะสำหรับการเตรียมสภาพแวดล้อมหรือเงื่อนไขก่อนเริ่มแอปพลิเคชัน:

```bash
kubectl apply -f init-container.yaml
```

**init-container.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-container-demo
  namespace: pod-patterns
spec:
  initContainers:
  - name: init-db
    image: busybox
    command: ['/bin/sh', '-c', 'echo "Initializing database..."; sleep 10; echo "CREATE TABLE users (id INT, name VARCHAR(255));" > /init-data/init.sql; echo "Database initialized"']
    volumeMounts:
    - name: init-data
      mountPath: /init-data
  containers:
  - name: app
    image: busybox
    command: ['/bin/sh', '-c', 'echo "Application starting..."; if [ -f /init-data/init.sql ]; then echo "Found initialization script:"; cat /init-data/init.sql; else echo "No initialization script found"; fi; sleep 3600']
    volumeMounts:
    - name: init-data
      mountPath: /init-data
  volumes:
  - name: init-data
    emptyDir: {}
```

ตรวจสอบผลลัพธ์จาก Pod:

```bash
kubectl logs init-container-demo -c init-db
kubectl logs init-container-demo -c app
```

### 6. Practical Example: Web Application with Monitoring Sidecar

ตัวอย่างการใช้งานจริง: ระบบ Web Application พร้อม sidecar สำหรับเก็บข้อมูล metrics:

```bash
kubectl apply -f practical-example.yaml
```

**practical-example.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: pod-patterns
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web
        image: nginx:1.19
        ports:
        - containerPort: 80
        volumeMounts:
        - name: nginx-logs
          mountPath: /var/log/nginx
        - name: nginx-conf
          mountPath: /etc/nginx/conf.d
      - name: metrics-exporter
        image: busybox
        command: ["/bin/sh", "-c", "while true; do count=$(grep -c 'GET' /var/log/nginx/access.log 2>/dev/null || echo 0); echo \"requests_total $count\" > /metrics/requests.prom; sleep 15; done"]
        volumeMounts:
        - name: nginx-logs
          mountPath: /var/log/nginx
        - name: metrics
          mountPath: /metrics
      volumes:
      - name: nginx-logs
        emptyDir: {}
      - name: metrics
        emptyDir: {}
      - name: nginx-conf
        configMap:
          name: nginx-conf
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-conf
  namespace: pod-patterns
data:
  default.conf: |
    server {
      listen 80;
      location / {
        root /usr/share/nginx/html;
        index index.html;
      }
      location /metrics {
        alias /metrics;
      }
    }
---
apiVersion: v1
kind: Service
metadata:
  name: web-app
  namespace: pod-patterns
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
```

ตรวจสอบการทำงาน:

```bash
kubectl port-forward service/web-app 8080:80
# เปิดเบราว์เซอร์ไปที่ http://localhost:8080 และ http://localhost:8080/metrics/requests.prom
```

## แนวทางปฏิบัติที่ดีในการออกแบบ Multi-Container Pods

1. **ใช้เฉพาะเมื่อ Containers มีความเกี่ยวข้องกันอย่างแน่นแฟ้น**
   - Containers มีวงจรชีวิตเดียวกัน (เริ่มและหยุดพร้อมกัน)
   - ต้องแชร์ทรัพยากร เช่น network หรือ volumes

2. **แต่ละ Container ควรมีหน้าที่ชัดเจน**
   - Container หลักทำหน้าที่หลักของแอปพลิเคชัน
   - Container เสริมควรมีงานเฉพาะที่ไม่ทับซ้อนกัน

3. **การแชร์ข้อมูลระหว่าง Container**
   - ใช้ volumes แชร์ข้อมูลเมื่อต้องการแชร์ไฟล์
   - ใช้ localhost (127.0.0.1) สำหรับการสื่อสารภายใน Pod

4. **คำนึงถึงการใช้ทรัพยากร**
   - ระบุ resource requests และ limits สำหรับทุก container
   - หลีกเลี่ยงการใช้ images ที่มีขนาดใหญ่เกินความจำเป็น

## ข้อดีและข้อเสียของแต่ละรูปแบบ

### Sidecar Pattern
**ข้อดี:**
- เพิ่มความสามารถให้กับแอปพลิเคชันโดยไม่ต้องแก้ไขโค้ดหลัก
- แยกความรับผิดชอบระหว่างแอปพลิเคชันหลักและฟังก์ชันเสริม

**ข้อเสีย:**
- เพิ่มการใช้ทรัพยากรในระบบ
- การจัดการ logs และ debugging อาจซับซ้อนขึ้น

### Ambassador Pattern
**ข้อดี:**
- ทำให้แอปพลิเคชันไม่ต้องรับผิดชอบในการจัดการการเชื่อมต่อกับบริการภายนอก
- รองรับการเปลี่ยนแปลงของบริการภายนอกโดยไม่ต้องแก้ไขแอปพลิเคชันหลัก

**ข้อเสีย:**
- เพิ่มความซับซ้อนและ latency ในการเรียกใช้บริการ
- ต้องจัดการ configuration ของ ambassador container เพิ่มเติม

### Adapter Pattern
**ข้อดี:**
- มาตรฐานการเชื่อมต่อและรูปแบบข้อมูลที่สอดคล้องกัน
- แอปพลิเคชันหลักไม่ต้องรับผิดชอบในการแปลงรูปแบบข้อมูล

**ข้อเสีย:**
- เพิ่มความซับซ้อน
- อาจมีการซ้ำซ้อนของข้อมูลและการใช้ทรัพยากร

## การใช้ Shell Script สำหรับการจัดการทรัพยากร

เพื่อความสะดวกในการติดตั้งและทดสอบ workshop นี้ เราได้เตรียม shell script สำหรับการจัดการทรัพยากรทั้งหมด:

### 1. การติดตั้งทรัพยากรทั้งหมด (deploy.sh)

Script นี้จะสร้าง namespace และทรัพยากรทั้งหมดที่จำเป็นสำหรับ workshop นี้:

```bash
chmod +x deploy.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./deploy.sh
```

เมื่อรัน script นี้แล้ว จะมีการดำเนินการดังนี้:
- สร้าง namespace `pod-patterns`
- ตั้งค่า context ให้ใช้งาน namespace `pod-patterns`
- สร้าง Pods และ resources ต่างๆ ตามตัวอย่าง
- แสดงสถานะของทรัพยากรที่สร้าง

### 2. การทดสอบทรัพยากร (test.sh)

Script นี้จะทดสอบการทำงานของตัวอย่างต่างๆ:

```bash
chmod +x test.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./test.sh
```

การทดสอบประกอบด้วย:
- ตรวจสอบผลลัพธ์จาก Sidecar Container
- ตรวจสอบการทำงานของ Ambassador Container
- ตรวจสอบการแปลงข้อมูลของ Adapter Container
- ตรวจสอบการทำงานของ Init Container
- ทดสอบการทำงานของตัวอย่างที่ใช้งานจริง

### 3. การลบทรัพยากรทั้งหมด (cleanup.sh)

เมื่อต้องการลบทรัพยากรทั้งหมดที่สร้างขึ้นในบทเรียนนี้:

```bash
chmod +x cleanup.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./cleanup.sh
```

Script นี้จะดำเนินการ:
- ลบ Pods ทั้งหมด
- ลบ Services และ ConfigMaps
- ลบ Deployments
- ลบ namespace `pod-patterns`
- ตั้งค่า context กลับไปที่ namespace `default`

## ตัวอย่างการนำไปประยุกต์ใช้ในสถานการณ์จริง

1. **Logging and Monitoring**:
   - Main Container: Web server หรือ Application server
   - Sidecar Container: Log collector, Metrics exporter (เช่น Prometheus exporter)

2. **Service Mesh**:
   - Main Container: แอปพลิเคชันหลัก
   - Sidecar Container: Proxy (เช่น Envoy, Linkerd) สำหรับ service mesh

3. **Database Proxy**:
   - Main Container: แอปพลิเคชันที่เชื่อมต่อกับฐานข้อมูล
   - Ambassador Container: Database proxy (เช่น PgBouncer สำหรับ PostgreSQL)

4. **Legacy System Integration**:
   - Main Container: แอปพลิเคชันหลัก
   - Adapter Container: แปลงรูปแบบข้อมูลระหว่างแอปพลิเคชันกับระบบ legacy

5. **Content Synchronization**:
   - Main Container: Web server
   - Sidecar Container: ทำหน้าที่ sync content จากแหล่งภายนอก (เช่น Git repository)

## สรุป

ในเวิร์คช็อปนี้ เราได้เรียนรู้:

1. รูปแบบการออกแบบ Multi-Container Pod ที่สำคัญ: Sidecar, Ambassador, Adapter และ Init Container
2. วิธีการใช้ emptyDir volume ในการแชร์ข้อมูลระหว่าง containers
3. การใช้ localhost ในการสื่อสารระหว่าง containers ภายใน pod
4. แนวทางปฏิบัติที่ดีในการออกแบบ multi-container pods
5. ตัวอย่างการประยุกต์ใช้ในสถานการณ์จริง

การเลือกใช้รูปแบบที่เหมาะสมสำหรับการออกแบบ Multi-Container Pods จะช่วยให้แอปพลิเคชันมีความยืดหยุ่น แยกความรับผิดชอบ และเพิ่มความสามารถได้โดยไม่ต้องแก้ไขโค้ดหลัก
