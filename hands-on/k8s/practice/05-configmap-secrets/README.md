# Kubernetes ConfigMap และ Secret

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | การจัดการ Configuration และ Secrets ใน Kubernetes |
| **วัตถุประสงค์** | เรียนรู้การเก็บและใช้งานค่า configuration และข้อมูลที่เป็นความลับในแอปพลิเคชัน |
| **ระดับความยาก** | ปานกลาง |

ในบทเรียนนี้ เราจะเรียนรู้เกี่ยวกับ ConfigMap และ Secret ใน Kubernetes สำหรับการจัดการ configuration และข้อมูลที่เป็นความลับในแอปพลิเคชัน

## สิ่งที่จะได้เรียนรู้

- การสร้างและใช้งาน ConfigMap สำหรับเก็บค่า configuration
- การสร้างและใช้งาน Secret สำหรับเก็บข้อมูลที่เป็นความลับ
- การนำ ConfigMap และ Secret มาใช้ใน Pod
- การอัปเดต ConfigMap และดูผลกระทบต่อแอปพลิเคชัน

## ขั้นตอนการทำงาน

### 1. สร้าง Namespace

สร้าง Namespace เพื่อแยกทรัพยากรที่ใช้ในบทเรียนนี้:

```bash
kubectl create namespace config-demo
kubectl config set-context --current --namespace=config-demo
```

### 2. สร้าง ConfigMap

ConfigMap ใช้เก็บข้อมูล configuration ที่ไม่ใช่ความลับ เช่น ค่า parameter หรือไฟล์ configuration

#### 2.1 สร้าง ConfigMap แบบง่าย

```bash
kubectl apply -f simple-configmap.yaml
```

**simple-configmap.yaml**:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  app.properties: |
    app.name=MyApp
    app.version=1.0.0
    app.environment=development
  database.properties: |
    db.host=my-db-service
    db.port=3306
    db.name=mydb
  message: "สวัสดี Kubernetes ConfigMap"
```

#### 2.2 สร้าง ConfigMap จากไฟล์

สร้างไฟล์ config.json:

```bash
echo '{
  "apiEndpoint": "https://api.example.com",
  "enableFeatureA": true,
  "maxConnections": 100
}' > config.json
```

สร้าง ConfigMap จากไฟล์:

```bash
kubectl create configmap json-config --from-file=config.json
```

### 3. สร้าง Secret

Secret ใช้เก็บข้อมูลที่เป็นความลับ เช่น รหัสผ่าน, token, หรือใบรับรอง

#### 3.1 สร้าง Secret แบบ generic

```bash
kubectl apply -f app-secret.yaml
```

**app-secret.yaml**:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  db.user: YWRtaW4=      # "admin" ในรูปแบบ base64
  db.password: UGAkJHcwcmQ=  # "P@$$w0rd" ในรูปแบบ base64
```

#### 3.2 สร้าง Secret จากคำสั่ง

```bash
kubectl create secret generic api-keys \
  --from-literal=api-key=2f5a14d7e9c83b4 \
  --from-literal=api-secret=c87d4pq39fjwlc2890f
```

### 4. ใช้ ConfigMap และ Secret ใน Pod

สร้าง Pod ที่ใช้ ConfigMap และ Secret:

```bash
kubectl apply -f app-pod.yaml
```

**app-pod.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: config-demo-pod
spec:
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh", "-c", "while true; do echo Environment: $APP_ENV, Message: $APP_MESSAGE, DB User: $DB_USER; sleep 10; done"]
    env:
    - name: APP_ENV
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: app.properties
    - name: APP_MESSAGE
      valueFrom:
        configMapKeyRef:
          name: app-config
          key: message
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: db.user
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
    - name: secret-volume
      mountPath: /etc/secret
      readOnly: true
  volumes:
  - name: config-volume
    configMap:
      name: app-config
  - name: secret-volume
    secret:
      secretName: app-secret
```

### 5. ตรวจสอบการทำงาน

ตรวจสอบค่าใน ConfigMap และ Secret:

```bash
# ดูข้อมูล ConfigMap
kubectl describe configmap app-config

# ดูข้อมูล Secret (จะแสดงเป็น base64)
kubectl describe secret app-secret

# ดูผลลัพธ์จาก Pod
kubectl logs config-demo-pod
```

### 6. อัปเดต ConfigMap

อัปเดต ConfigMap และดูผลกระทบ:

```bash
# แก้ไข ConfigMap
kubectl edit configmap app-config

# หรือสร้างไฟล์ update-configmap.yaml และใช้ kubectl apply
kubectl apply -f update-configmap.yaml
```

**update-configmap.yaml**:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  app.properties: |
    app.name=MyApp
    app.version=1.0.1
    app.environment=staging
  database.properties: |
    db.host=my-db-service
    db.port=3306
    db.name=mydb
  message: "สวัสดี Kubernetes ConfigMap (updated)"
```

### 7. สร้าง ConfigMap และ Secret แบบเข้ารหัส

สร้าง Secret แบบ TLS ด้วยใบรับรองที่สร้างขึ้นเอง:

```bash
# สร้าง self-signed certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=example.com"

# สร้าง Secret ประเภท TLS
kubectl create secret tls tls-secret --cert=tls.crt --key=tls.key
```

## การใช้ Shell Script สำหรับการจัดการทรัพยากร

เพื่อความสะดวกในการติดตั้งและทดสอบ workshop นี้ เราได้เตรียม shell script สำหรับการจัดการทรัพยากรทั้งหมด:

### 1. การติดตั้งทรัพยากรทั้งหมด (deploy.sh)

Script นี้จะสร้าง namespace และทรัพยากรทั้งหมดที่จำเป็นสำหรับ workshop นี้:

```bash
chmod +x deploy.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./deploy.sh
```

เมื่อรัน script นี้แล้ว จะมีการดำเนินการดังนี้:
- สร้าง namespace `config-demo`
- ตั้งค่า context ให้ใช้งาน namespace `config-demo`
- สร้าง ConfigMap จากไฟล์และคำสั่ง
- สร้าง Secret จากไฟล์และคำสั่ง
- สร้าง Pod สำหรับการทดสอบ
- สร้างตัวอย่างการใช้งานจริง

### 2. การทดสอบทรัพยากร (test.sh)

Script นี้จะทดสอบการทำงานของทรัพยากรต่างๆ ที่สร้างขึ้น:

```bash
chmod +x test.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./test.sh
```

การทดสอบประกอบด้วย:
- ตรวจสอบว่า ConfigMap และ Secret ถูกสร้างขึ้นอย่างถูกต้อง
- ตรวจสอบว่า Pod ทดสอบทำงานได้อย่างถูกต้อง
- ทดสอบการอัปเดต ConfigMap และดูผลกระทบ
- ตรวจสอบการทำงานของตัวอย่างการใช้งานจริง

### 3. การลบทรัพยากรทั้งหมด (cleanup.sh)

เมื่อต้องการลบทรัพยากรทั้งหมดที่สร้างขึ้นในบทเรียนนี้:

```bash
chmod +x cleanup.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./cleanup.sh
```

Script นี้จะดำเนินการ:
- ลบ Pod ทดสอบและ Deployment
- ลบ ConfigMap และ Secret ทั้งหมด
- ลบ namespace `config-demo`
- ตั้งค่า context กลับไปที่ namespace `default`

## ความแตกต่างระหว่าง ConfigMap และ Secret

| คุณสมบัติ | ConfigMap | Secret |
|----------|----------|--------|
| จุดประสงค์ | เก็บข้อมูล configuration ที่ไม่เป็นความลับ | เก็บข้อมูลที่เป็นความลับ เช่น password |
| การเข้ารหัส | ไม่มีการเข้ารหัสโดยอัตโนมัติ | ข้อมูลถูกเข้ารหัสเป็น base64 และมีกลไกป้องกันเพิ่มเติม |
| ขนาด | สามารถเก็บข้อมูลได้มากกว่า | มีขีดจำกัดขนาด 1MB |
| การดูข้อมูล | ดูได้โดยตรงด้วย kubectl | ถูกซ่อนในคำสั่ง kubectl describe |

## วิธีการใช้ ConfigMap และ Secret

1. **Environment Variables**: นำค่าไปใช้เป็นตัวแปรสภาพแวดล้อม
2. **Volume Mounts**: นำข้อมูลไปเป็นไฟล์ในระบบไฟล์ของ container
3. **Command Arguments**: ใช้ค่าเป็นพารามิเตอร์ในการเรียกคำสั่ง

## ข้อควรระวัง

1. **Secret ไม่ปลอดภัย 100%**: Secret ใน Kubernetes แบบพื้นฐานจะถูกเก็บใน etcd โดยไม่มีการเข้ารหัส ควรพิจารณาใช้ระบบเสริม เช่น Vault
2. **การอัปเดต ConfigMap**: การอัปเดต ConfigMap ไม่ได้ทำให้ Pod รีสตาร์ทอัตโนมัติ ต้องใช้เทคนิคเพิ่มเติม เช่น Deployment
3. **การใช้งานเป็น Volume**: เมื่อใช้เป็น Volume อาจต้องรอให้ข้อมูลอัปเดตในระบบไฟล์ของ Pod (ใช้เวลาหลายวินาที/นาที)

## การนำไปใช้งานจริง

การใช้งาน ConfigMap และ Secret ในสถานการณ์จริงมีหลากหลายรูปแบบ ต่อไปนี้เป็นตัวอย่างการนำไปประยุกต์ใช้:

### 1. การจัดการค่าคอนฟิกสำหรับแอปพลิเคชันในสภาพแวดล้อมต่างๆ

ใช้ ConfigMap เพื่อเก็บค่าคอนฟิกที่แตกต่างกันสำหรับแต่ละสภาพแวดล้อม (development, staging, production) โดยไม่ต้องสร้าง container image ใหม่:

```yaml
# dev-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: dev
data:
  app.properties: |
    log.level=DEBUG
    feature.experimental=true
    cache.timeToLiveSeconds=60
    
# prod-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: production
data:
  app.properties: |
    log.level=WARN
    feature.experimental=false
    cache.timeToLiveSeconds=3600
```

### 2. แอปพลิเคชันที่เชื่อมต่อกับฐานข้อมูล

ใช้ ConfigMap เก็บ endpoint และค่าการตั้งค่าการเชื่อมต่อฐานข้อมูล และใช้ Secret เก็บข้อมูลรหัสผ่าน:

```yaml
# db-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-config
data:
  host: "mysql.database.svc.cluster.local"
  port: "3306"
  dbname: "myapp"
  connection-pool-size: "10"
  timeout-seconds: "30"
  
# db-credentials.yaml
apiVersion: v1
kind: Secret
metadata:
  name: db-credentials
type: Opaque
stringData:  # ใช้ stringData เพื่อไม่ต้อง encode base64 เอง
  username: "db_user"
  password: "complex-password-here"
```

### 3. การเก็บใบรับรอง TLS/SSL สำหรับ Ingress

การใช้ Secret เพื่อเก็บ SSL certificate สำหรับ Ingress controller:

```yaml
# ขั้นตอนที่ 1: สร้าง Secret เก็บ certificate
apiVersion: v1
kind: Secret
metadata:
  name: tls-secret
  namespace: ingress-system
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded-cert>
  tls.key: <base64-encoded-key>

# ขั้นตอนที่ 2: ใช้ Secret กับ Ingress
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: secure-app
spec:
  tls:
  - hosts:
    - secure.example.com
    secretName: tls-secret
  rules:
  - host: secure.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80
```

### 4. การตั้งค่า Web Server

การใช้ ConfigMap เพื่อจัดการไฟล์คอนฟิกของ NGINX:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-config
data:
  nginx.conf: |
    server {
      listen 80;
      server_name example.com;
      
      location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
      }
      
      location /api {
        proxy_pass http://backend-service:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
      }
    }
    
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  template:
    spec:
      containers:
      - name: nginx
        image: nginx:1.21
        volumeMounts:
        - name: config-volume
          mountPath: /etc/nginx/conf.d/default.conf
          subPath: nginx.conf
      volumes:
      - name: config-volume
        configMap:
          name: nginx-config
```

### 5. ระบบ API Keys สำหรับบริการภายนอก

ใช้ Secret เพื่อเก็บ API keys ที่ใช้เชื่อมต่อกับบริการภายนอกต่างๆ:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: external-services-keys
type: Opaque
stringData:
  aws-access-key: "AKIAXXXXXXXXXXXXXXXXX"
  aws-secret-key: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  sendgrid-api-key: "SG.XXXXXXXXXXXXXXXXXXXXXXXX"
  slack-webhook: "https://hooks.slack.com/services/TXXXXXXXXX/BXXXXXXXXX/XXXXXXXXXXXXXXXXXXXXXXXX"
```

### 6. ตัวอย่างการทำ Blue-Green Deployment โดยใช้ ConfigMap

การใช้ ConfigMap เพื่อสลับระหว่าง blue และ green deployment โดยการอัปเดตค่าใน ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-router
data:
  # เปลี่ยนค่านี้ระหว่าง "blue" และ "green" เพื่อสลับ traffic
  ACTIVE_DEPLOYMENT: "blue"
  BLUE_SERVICE: "app-service-blue:8080"
  GREEN_SERVICE: "app-service-green:8080"
```

### 7. การทำ Feature Flags

การใช้ ConfigMap ทำ feature flags ที่สามารถเปิด-ปิด feature ได้โดยไม่ต้องทำการ deploy ใหม่:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: feature-flags
data:
  ENABLE_NEW_UI: "true"
  ENABLE_BETA_FEATURES: "false"
  ENABLE_ANALYTICS: "true"
  MAINTENANCE_MODE: "false"
```

การเลือกใช้ ConfigMap หรือ Secret ให้เหมาะสมกับแต่ละกรณี และการออกแบบให้แอปพลิเคชันของคุณรองรับการอัปเดตค่าการตั้งค่าแบบ dynamic จะช่วยเพิ่มความยืดหยุ่นและความสามารถในการบริหารจัดการระบบอย่างมาก

## สรุป

ConfigMap และ Secret เป็นทรัพยากรสำคัญใน Kubernetes สำหรับการจัดการ configuration และข้อมูลที่เป็นความลับ:

1. **ConfigMap** เหมาะสำหรับข้อมูลทั่วไปที่ไม่ต้องการการปกป้องพิเศษ
2. **Secret** เหมาะสำหรับข้อมูลที่เป็นความลับ แม้จะไม่ได้ปลอดภัย 100% แต่ก็มีกลไกป้องกันพื้นฐาน
3. การแยกข้อมูล configuration ออกจากโค้ดทำให้การจัดการแอปพลิเคชันมีความยืดหยุ่นมากขึ้น
4. สามารถอัปเดต configuration ได้โดยไม่ต้องสร้าง container image ใหม่

สำหรับระบบที่ต้องการความปลอดภัยสูง ควรพิจารณาใช้ solution อื่นเพิ่มเติม เช่น HashiCorp Vault, AWS Secrets Manager หรือ Azure Key Vault
