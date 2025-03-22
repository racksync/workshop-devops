# Kubernetes Load Balancing Workshop

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | การทำ Load Balancing บน Kubernetes |
| **วัตถุประสงค์** | เรียนรู้รูปแบบและเทคนิคการทำ Load Balancing แอปพลิเคชันบน Kubernetes |
| **ระดับความยาก** | ปานกลาง |

ในเวิร์คช็อปนี้ เราจะเรียนรู้เกี่ยวกับการทำ Load Balancing บน Kubernetes โดยใช้เทคนิคและรูปแบบต่างๆ เพื่อกระจายโหลดของ traffic ไปยัง Pod ต่างๆ อย่างมีประสิทธิภาพ ซึ่งเป็นหนึ่งในพื้นฐานสำคัญของการสร้างระบบที่มีความพร้อมใช้งานสูง (High Availability) และรองรับผู้ใช้จำนวนมากได้

## สิ่งที่จะได้เรียนรู้

- การใช้งาน Service ประเภทต่างๆ (ClusterIP, NodePort, LoadBalancer)
- การกำหนด Traffic Policy และ External Traffic Policy ใน Service 
- การใช้งาน Ingress Controller เพื่อทำ Load Balancing สำหรับ HTTP/HTTPS
- การทำ Round-robin, Session affinity และรูปแบบการกระจาย traffic อื่นๆ
- การทำ Canary Deployment ด้วย Load Balancing
- การทำ A/B Testing บน Kubernetes โดยใช้ traffic splitting
- การใช้ ExternalName Service สำหรับ Load Balancing ไปยังบริการภายนอก
- การปรับแต่ง Load Balancing ให้เหมาะกับความต้องการของแอปพลิเคชัน

## ขั้นตอนการทำงาน

### 1. สร้าง Namespace

สร้าง Namespace เพื่อแยกทรัพยากรที่ใช้ในบทเรียนนี้:

```bash
kubectl create namespace lb-demo
kubectl config set-context --current --namespace=lb-demo
```

### 2. สร้าง Deployment หลายตัวเพื่อทดสอบ Load Balancing

สร้าง Deployment จำนวน 3 ตัวที่มีแอปพลิเคชันเหมือนกันแต่คนละเวอร์ชัน:

```bash
kubectl apply -f deployments.yaml
```

**deployments.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-v1
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
      version: v1
  template:
    metadata:
      labels:
        app: web
        version: v1
    spec:
      containers:
      - name: web
        image: nginx:1.19
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config
          mountPath: /usr/share/nginx/html
      volumes:
      - name: config
        configMap:
          name: web-v1-config
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-v2
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
      version: v2
  template:
    metadata:
      labels:
        app: web
        version: v2
    spec:
      containers:
      - name: web
        image: nginx:1.19
        ports:
        - containerPort: 80
        volumeMounts:
        - name: config
          mountPath: /usr/share/nginx/html
      volumes:
      - name: config
        configMap:
          name: web-v2-config
```

### 3. สร้าง ConfigMap สำหรับไฟล์ HTML ที่แสดงเวอร์ชันต่างๆ

```bash
kubectl apply -f configmaps.yaml
```

**configmaps.yaml**:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-v1-config
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
      <title>Version 1</title>
      <style>
        body { background-color: #f0f8ff; font-family: Arial, sans-serif; text-align: center; padding-top: 50px; }
        h1 { color: #0066cc; }
      </style>
    </head>
    <body>
      <h1>Version 1</h1>
      <p>This is version 1 of the application</p>
      <p>Pod: ${HOSTNAME}</p>
    </body>
    </html>
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-v2-config
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
      <title>Version 2</title>
      <style>
        body { background-color: #e6ffe6; font-family: Arial, sans-serif; text-align: center; padding-top: 50px; }
        h1 { color: #009933; }
      </style>
    </head>
    <body>
      <h1>Version 2</h1>
      <p>This is version 2 of the application</p>
      <p>Pod: ${HOSTNAME}</p>
    </body>
    </html>
```

### 4. การทำ Load Balancing พื้นฐานด้วย Service

#### 4.1 Load Balancing แบบพื้นฐานด้วย ClusterIP Service

```bash
kubectl apply -f service-clusterip.yaml
```

**service-clusterip.yaml**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service-all
spec:
  selector:
    app: web  # จะเลือกทั้ง v1 และ v2
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
```

#### 4.2 Load Balancing โดยแยกเวอร์ชัน

```bash
kubectl apply -f service-version-specific.yaml
```

**service-version-specific.yaml**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service-v1
spec:
  selector:
    app: web
    version: v1
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  name: web-service-v2
spec:
  selector:
    app: web
    version: v2
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
```

### 5. การทำ Load Balancing ด้วย Ingress

#### 5.1 สร้าง Ingress แบบพื้นฐาน

```bash
kubectl apply -f ingress-basic.yaml
```

**ingress-basic.yaml**:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress
spec:
  rules:
  - host: lb.k8s.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service-all
            port:
              number: 80
```

#### 5.2 สร้าง Ingress ที่แบ่ง Traffic ตาม Path

```bash
kubectl apply -f ingress-path-based.yaml
```

**ingress-path-based.yaml**:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress-path
spec:
  rules:
  - host: lb.k8s.local
    http:
      paths:
      - path: /v1
        pathType: Prefix
        backend:
          service:
            name: web-service-v1
            port:
              number: 80
      - path: /v2
        pathType: Prefix
        backend:
          service:
            name: web-service-v2
            port:
              number: 80
```

### 6. การทำ Traffic Splitting สำหรับ Canary Deployment

```bash
kubectl apply -f ingress-canary.yaml
```

**ingress-canary.yaml**:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web-ingress-canary
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "20"
spec:
  rules:
  - host: lb.k8s.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-service-v2
            port:
              number: 80
```

### 7. การใช้ Session Affinity

```bash
kubectl apply -f service-session-affinity.yaml
```

**service-session-affinity.yaml**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service-sticky
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 80
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 180
```

### 8. การใช้ ExternalName Service

```bash
kubectl apply -f service-externalname.yaml
```

**service-externalname.yaml**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-api
spec:
  type: ExternalName
  externalName: api.external-service.com
  ports:
  - port: 80
```

### 9. ทดสอบ Load Balancing ในรูปแบบต่างๆ

สำคัญ: ก่อนทำการทดสอบการใช้งาน Host `lb.k8s.local` คุณจำเป็นต้องเพิ่มรายการใน `/etc/hosts` ไฟล์เพื่อให้ระบบสามารถ resolve โดเมนนี้ไปที่ localhost ได้ โดยใช้คำสั่งต่อไปนี้ (ต้องใช้สิทธิ์ admin/sudo):

```bash
# เพิ่มรายการในไฟล์ /etc/hosts
sudo sh -c 'echo "127.0.0.1 lb.k8s.local" >> /etc/hosts'

# หรือเปิดไฟล์ด้วย editor เพื่อแก้ไขด้วยตนเอง
sudo nano /etc/hosts  # หรือใช้ editor อื่นๆ เช่น vi, vim
```

จากนั้นจึงทำการทดสอบได้ด้วยคำสั่งต่อไปนี้:

```bash
# ทดสอบ Service แบบพื้นฐาน
kubectl port-forward svc/web-service-all 8080:80

# ทดสอบ Service แยกเวอร์ชัน
kubectl port-forward svc/web-service-v1 8081:80
kubectl port-forward svc/web-service-v2 8082:80

# ทดสอบ Load Balancing ด้วย curl หลายครั้ง
for i in {1..10}; do curl -s -H "Host: lb.k8s.local" http://localhost:8080 | grep "Pod:"; done
```

### 10. การสังเกตความแตกต่างระหว่าง Pods

เมื่อทดสอบการ Load Balancing คุณจะสามารถสังเกตความแตกต่างระหว่าง Pods ที่ให้บริการได้ทั้งจากข้อความ, สี, และชื่อ Pod ที่แสดงผล:

#### ตัวอย่าง Output เมื่อเข้าถึง Version 1:
```
Version 1
This is version 1 of the application
Pod: web-v1-75b9bbd684-j7lqx
```

#### ตัวอย่าง Output เมื่อเข้าถึง Version 2:
```
Version 2
This is version 2 of the application
Pod: web-v2-6b8df56c47-xvt5p
```

เมื่อทดสอบด้วยการเรียกซ้ำ ๆ ไปยัง `web-service-all` คุณจะเห็นว่า Kubernetes จะสลับเส้นทางระหว่าง pods v1 และ v2 ตามกลไก load balancing:

```bash
# ตัวอย่างผลลัพธ์จากการทดสอบ 10 ครั้ง
Pod: web-v1-75b9bbd684-j7lqx  # v1 pod
Pod: web-v2-6b8df56c47-xvt5p  # v2 pod
Pod: web-v1-75b9bbd684-t3p4r  # v1 pod
Pod: web-v2-6b8df56c47-xvt5p  # v2 pod
Pod: web-v1-75b9bbd684-j7lqx  # v1 pod
Pod: web-v2-6b8df56c47-k8d9s  # v2 pod
Pod: web-v1-75b9bbd684-t3p4r  # v1 pod
Pod: web-v2-6b8df56c47-k8d9s  # v2 pod
Pod: web-v1-75b9bbd684-j7lqx  # v1 pod
Pod: web-v1-75b9bbd684-t3p4r  # v1 pod
```

ความแตกต่างทางสายตาที่คุณจะเห็นในเบราว์เซอร์:
- **Version 1**: พื้นหลังสีฟ้าอ่อน (#f0f8ff) และหัวข้อสีน้ำเงิน (#0066cc)
- **Version 2**: พื้นหลังสีเขียวอ่อน (#e6ffe6) และหัวข้อสีเขียว (#009933)

การเปลี่ยนแปลงสีพื้นหลังและสีข้อความนี้ทำให้คุณสามารถมองเห็นได้ทันทีว่ากำลังเชื่อมต่อกับ pod เวอร์ชันใดอยู่

เมื่อทดสอบ Canary Deployment โดยใช้ ingress-canary.yaml คุณจะสังเกตเห็นว่า traffic ประมาณ 20% จะถูกส่งไปยัง Version 2 (สีเขียว) และที่เหลือจะยังคงไปที่ Version 1 (สีฟ้า) ตามค่า `canary-weight: "20"` ที่กำหนดไว้

## การใช้ Shell Script สำหรับการจัดการทรัพยากร

เพื่อความสะดวกในการติดตั้งและทดสอบ workshop นี้ เราได้เตรียม shell script สำหรับการจัดการทรัพยากรทั้งหมด:

### 1. การติดตั้งทรัพยากรทั้งหมด (deploy.sh)

Script นี้จะสร้าง namespace และทรัพยากรทั้งหมดที่จำเป็นสำหรับ workshop นี้:

```bash
chmod +x deploy.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./deploy.sh
```

เมื่อรัน script นี้แล้ว จะมีการดำเนินการดังนี้:
- สร้าง namespace `lb-demo`
- ตั้งค่า context ให้ใช้งาน namespace `lb-demo`
- สร้าง ConfigMap สำหรับไฟล์ HTML ของแต่ละเวอร์ชัน
- สร้าง Deployment สำหรับแต่ละเวอร์ชันของแอปพลิเคชัน
- สร้าง Service แบบต่างๆ สำหรับการทำ Load Balancing
- สร้าง Ingress resources เพื่อการทำ routing และ traffic splitting

### 2. การทดสอบทรัพยากร (test.sh)

Script นี้จะทดสอบการทำงานของทรัพยากรต่างๆ ที่สร้างขึ้น:

```bash
chmod +x test.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./test.sh
```

การทดสอบประกอบด้วย:
- ตรวจสอบว่า Pods และ Services ทำงานได้ตามปกติ
- ทดสอบการเชื่อมต่อไปยัง Services แบบต่างๆ
- ทดสอบการกระจาย traffic ไปยัง Pods ต่างๆ
- ทดสอบ Session Affinity
- แสดงผลลัพธ์การทำ Canary Deployment

### 3. การลบทรัพยากรทั้งหมด (cleanup.sh)

เมื่อต้องการลบทรัพยากรทั้งหมดที่สร้างขึ้นในบทเรียนนี้:

```bash
chmod +x cleanup.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./cleanup.sh
```

Script นี้จะดำเนินการ:
- ลบ Ingress resources ทั้งหมด
- ลบ Services ทั้งหมด
- ลบ Deployments ทั้งหมด
- ลบ ConfigMaps ทั้งหมด
- ลบ namespace `lb-demo`
- ตั้งค่า context กลับไปที่ namespace `default`

## สรุป

ในเวิร์คช็อปนี้ เราได้เรียนรู้:

1. วิธีการทำ Load Balancing ด้วย Service ประเภทต่างๆ
2. การทำ Load Balancing สำหรับ HTTP traffic ด้วย Ingress
3. การจำกัดการกระจาย traffic ไปยัง Pods ที่เฉพาะเจาะจง
4. การทำ Canary Deployment โดยการแบ่งสัดส่วน traffic
5. การใช้ Session Affinity เพื่อให้ traffic จาก client เดียวกันไปยัง Pod เดียวกันเสมอ
6. การเชื่อมต่อกับบริการภายนอกด้วย ExternalName Service

การทำ Load Balancing ที่มีประสิทธิภาพเป็นส่วนสำคัญในการสร้างแอปพลิเคชันที่สามารถขยายขนาดและมีความพร้อมใช้งานสูง บน Kubernetes เราสามารถใช้ความสามารถของระบบในการกระจาย traffic และจัดการการทำงาน เพื่อให้สามารถรองรับผู้ใช้จำนวนมากได้อย่างมีประสิทธิภาพ
