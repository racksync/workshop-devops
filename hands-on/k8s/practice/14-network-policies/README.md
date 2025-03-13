# Kubernetes Network Policies Workshop

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | การควบคุมการสื่อสารระหว่าง Pods ด้วย Network Policies |
| **วัตถุประสงค์** | เรียนรู้การรักษาความปลอดภัยเครือข่ายใน Kubernetes โดยการกำหนดกฎการเชื่อมต่อระหว่าง Pods |
| **ระดับความยาก** | ปานกลาง |

ในเวิร์คช็อปนี้ เราจะเรียนรู้เกี่ยวกับ Network Policies ใน Kubernetes ซึ่งช่วยให้เราสามารถควบคุมการรับส่งข้อมูลระหว่าง Pods ได้อย่างละเอียด ทำให้เพิ่มความปลอดภัยให้กับแอปพลิเคชันด้วยการจำกัดการติดต่อสื่อสารเฉพาะส่วนที่จำเป็นเท่านั้น

## สิ่งที่จะได้เรียนรู้

- หลักการพื้นฐานของ Network Policies ใน Kubernetes
- การสร้างกฎควบคุมการสื่อสารแบบขาเข้า (Ingress) และขาออก (Egress)
- การกำหนดกฎโดยใช้ Labels และ Namespaces
- การกำหนดกฎโดยใช้ IP blocks
- การทดสอบและตรวจสอบประสิทธิภาพของ Network Policies
- แนวทางปฏิบัติที่ดีในการรักษาความปลอดภัยเครือข่ายใน Kubernetes

## ความเข้าใจเกี่ยวกับ Network Policies

Network Policy เป็นทรัพยากรใน Kubernetes ที่ช่วยให้เราสามารถควบคุมการรับส่งข้อมูลระหว่าง Pods ได้ โดยมีแนวคิดสำคัญดังนี้:

1. โดยค่าเริ่มต้น Pods ใน Kubernetes จะสามารถสื่อสารกันได้ทั้งหมด (Allow all)
2. Network Policies จะทำงานแบบ "deny by default" เมื่อนำมาใช้ หมายความว่าการเชื่อมต่อทั้งหมดจะถูกปิดกั้นยกเว้นที่อนุญาตไว้ในกฎ
3. Network Policies ใช้ Pod selectors, Namespace selectors และ IP blocks ในการกำหนดกฎ
4. สามารถควบคุมได้ทั้งการสื่อสารขาเข้า (Ingress) และขาออก (Egress)

## ข้อกำหนดเบื้องต้น

**หมายเหตุสำคัญ:** Network Policies จะทำงานได้ก็ต่อเมื่อ Kubernetes cluster ของคุณใช้ Network Plugin ที่รองรับ Network Policies เท่านั้น เช่น:
- Calico
- Cilium
- Kube-router
- Romana
- Weave Net
- Antrea

โดยตัวอย่างเช่น Minikube สามารถเปิดใช้งาน Network Policies ได้ด้วยคำสั่ง:
```bash
minikube start --network-plugin=cni --enable-default-cni
```

## ขั้นตอนการทำงาน

### 1. สร้าง Namespace

สร้าง Namespace เพื่อแยกทรัพยากรที่ใช้ในบทเรียนนี้:

```bash
kubectl create namespace netpol-demo
kubectl config set-context --current --namespace=netpol-demo
```

### 2. สร้างแอปพลิเคชันตัวอย่าง

เราจะสร้างแอปพลิเคชันตัวอย่างที่ประกอบด้วยส่วนต่างๆ ดังนี้:
- Frontend: เว็บแอปพลิเคชัน
- Backend API: บริการ API
- Database: ฐานข้อมูล
- Monitoring: ระบบตรวจสอบ

```bash
kubectl apply -f app-deployment.yaml
```

**app-deployment.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:1.19
        ports:
        - containerPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: nginx:1.19
        ports:
        - containerPort: 8080
        command: ["/bin/sh", "-c", "echo 'Backend API running on port 8080' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
    spec:
      containers:
      - name: mysql
        image: mysql:5.7
        ports:
        - containerPort: 3306
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: password
        - name: MYSQL_DATABASE
          value: testdb
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: monitoring
  template:
    metadata:
      labels:
        app: monitoring
    spec:
      containers:
      - name: monitoring
        image: prom/prometheus:v2.30.0
        ports:
        - containerPort: 9090
```

สร้าง Services สำหรับแต่ละ component:

```bash
kubectl apply -f app-services.yaml
```

**app-services.yaml**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: frontend-svc
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: backend-svc
spec:
  selector:
    app: backend
  ports:
  - port: 8080
    targetPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: database-svc
spec:
  selector:
    app: database
  ports:
  - port: 3306
    targetPort: 3306
---
apiVersion: v1
kind: Service
metadata:
  name: monitoring-svc
spec:
  selector:
    app: monitoring
  ports:
  - port: 9090
    targetPort: 9090
```

### 3. สร้าง Pod สำหรับทดสอบการเชื่อมต่อ

```bash
kubectl apply -f test-pod.yaml
```

**test-pod.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: network-test
  labels:
    role: test
spec:
  containers:
  - name: network-test
    image: nicolaka/netshoot
    command: ["sleep", "infinity"]
```

### 4. การสร้าง Network Policy แบบ Default Deny

เริ่มต้นด้วยการสร้าง Network Policy ที่ปิดกั้นการเชื่อมต่อทั้งหมด:

```bash
kubectl apply -f default-deny.yaml
```

**default-deny.yaml**:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}  # เลือกทุก Pod
  policyTypes:
  - Ingress
  - Egress
```

### 5. สร้าง Ingress Network Policy

อนุญาตให้ frontend สามารถเข้าถึงได้จากภายนอก:

```bash
kubectl apply -f frontend-policy.yaml
```

**frontend-policy.yaml**:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-ingress
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  ingress:
  - {}  # อนุญาตการเข้าถึงจากแหล่งใดก็ได้
```

### 6. สร้าง Frontend to Backend Network Policy

อนุญาตเฉพาะ frontend ที่จะเชื่อมต่อไปยัง backend:

```bash
kubectl apply -f frontend-to-backend.yaml
```

**frontend-to-backend.yaml**:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: frontend-to-backend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

### 7. สร้าง Backend to Database Network Policy

อนุญาตเฉพาะ backend ที่จะเชื่อมต่อไปยัง database:

```bash
kubectl apply -f backend-to-database.yaml
```

**backend-to-database.yaml**:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: backend-to-database
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: backend
    ports:
    - protocol: TCP
      port: 3306
```

### 8. สร้าง Monitoring Network Policy

อนุญาตให้ monitoring สามารถเข้าถึง pods ทั้งหมดบนพอร์ตที่กำหนด:

```bash
kubectl apply -f monitoring-policy.yaml
```

**monitoring-policy.yaml**:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-monitoring
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: monitoring
    ports:
    - protocol: TCP
      port: 80
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-monitoring-backend
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: monitoring
    ports:
    - protocol: TCP
      port: 8080
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-monitoring-database
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: monitoring
    ports:
    - protocol: TCP
      port: 3306
```

### 9. สร้าง DNS Network Policy สำหรับ Egress

อนุญาตให้ทุก Pod สามารถใช้งาน DNS ได้:

```bash
kubectl apply -f allow-dns.yaml
```

**allow-dns.yaml**:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns-access
spec:
  podSelector:
    matchLabels: {}
  policyTypes:
  - Egress
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: kube-system
    ports:
    - protocol: UDP
      port: 53
    - protocol: TCP
      port: 53
```

### 10. ทดสอบ Network Policies

ทดสอบการเชื่อมต่อระหว่าง Pods:

```bash
# เข้าไปใน test pod
kubectl exec -it network-test -- bash

# ทดสอบการเชื่อมต่อไปยัง frontend (ควรจะไม่สามารถเข้าถึงได้)
curl frontend-svc

# ทดสอบการเชื่อมต่อไปยัง backend (ควรจะไม่สามารถเข้าถึงได้)
curl backend-svc:8080

# ทดสอบการเชื่อมต่อไปยัง database (ควรจะไม่สามารถเข้าถึงได้)
nc -zvw 1 database-svc 3306
```

จากนั้นทดสอบจาก frontend pod ไปยัง backend (ควรเชื่อมต่อได้):

```bash
kubectl exec -it $(kubectl get pod -l app=frontend -o jsonpath='{.items[0].metadata.name}') -- curl backend-svc:8080
```

ทดสอบจาก backend pod ไปยัง database (ควรเชื่อมต่อได้):

```bash
kubectl exec -it $(kubectl get pod -l app=backend -o jsonpath='{.items[0].metadata.name}') -- nc -zvw 1 database-svc 3306
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
- สร้าง namespace `netpol-demo`
- ตั้งค่า context ให้ใช้งาน namespace `netpol-demo`
- สร้าง Deployment สำหรับแอปพลิเคชันตัวอย่าง (frontend, backend, database, monitoring)
- สร้าง Services สำหรับแต่ละ component
- สร้าง Test Pod สำหรับทดสอบการเชื่อมต่อ

### 2. การทดสอบทรัพยากร (test.sh)

Script นี้จะทดสอบการทำงานของ Network Policies:

```bash
chmod +x test.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./test.sh
```

การทดสอบประกอบด้วย:
- ตรวจสอบว่า Pods ทั้งหมดทำงานเป็นปกติ
- ทดสอบการเชื่อมต่อระหว่าง Pods ที่ควรจะเชื่อมต่อได้
- ทดสอบการเชื่อมต่อระหว่าง Pods ที่ควรจะเชื่อมต่อไม่ได้
- แสดงผลลัพธ์การทดสอบในรูปแบบตาราง

### 3. การลบทรัพยากรทั้งหมด (cleanup.sh)

เมื่อต้องการลบทรัพยากรทั้งหมดที่สร้างขึ้นในบทเรียนนี้:

```bash
chmod +x cleanup.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./cleanup.sh
```

Script นี้จะดำเนินการ:
- ลบ Network Policies ทั้งหมด
- ลบ Deployments และ Services ทั้งหมด
- ลบ namespace `netpol-demo`
- ตั้งค่า context กลับไปที่ namespace `default`

## Network Policy แบบขั้นสูง

### 1. Network Policy โดยใช้ IP Blocks

ตัวอย่างการอนุญาตการเข้าถึงจากเครือข่าย IP ที่กำหนด:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-external-ip
spec:
  podSelector:
    matchLabels:
      app: frontend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - ipBlock:
        cidr: 192.168.1.0/24
        except:
        - 192.168.1.1/32
```

### 2. Network Policy ข้ามต่าง Namespaces

ตัวอย่างการอนุญาตให้ Pods จาก namespace อื่นเข้าถึงได้:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-from-other-namespace
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          purpose: monitoring
      podSelector:
        matchLabels:
          app: prometheus
```

### 3. Network Policy สำหรับการเข้าถึงบริการภายนอก

ตัวอย่างการอนุญาตให้ Pods เข้าถึงบริการภายนอก (Egress):

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-external-egress
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - ipBlock:
        cidr: 0.0.0.0/0
        except:
        - 10.0.0.0/8
        - 172.16.0.0/12
        - 192.168.0.0/16
    ports:
    - protocol: TCP
      port: 443
```

## แนวทางปฏิบัติที่ดีสำหรับ Network Policies

1. **เริ่มต้นด้วยการปิดกั้นทั้งหมด**: ใช้ default-deny policy แล้วค่อยๆ อนุญาตเฉพาะการเชื่อมต่อที่จำเป็น
2. **แยกแยะตาม namespaces**: ใช้ namespaces สำหรับแยก environments หรือทีมที่แตกต่างกัน
3. **ใช้ labels อย่างสม่ำเสมอ**: กำหนดระบบการตั้งชื่อ labels ที่ชัดเจนสำหรับการอ้างอิงใน NetworkPolicies
4. **อย่าลืม DNS**: ต้องแน่ใจว่าอนุญาตการเชื่อมต่อ DNS สำหรับทุก Pod
5. **ทดสอบอย่างละเอียด**: มีการทดสอบการเชื่อมต่อในทุกรูปแบบทั้งที่ควรทำงานได้และไม่ควรทำงานได้
6. **ติดตามและปรับปรุง**: คอยติดตามปัญหาที่อาจเกิดขึ้นและปรับปรุง policies อย่างสม่ำเสมอ

## ข้อจำกัดของ Network Policies

1. Network Policies ทำงานที่ Layer 3/4 (IP/port) ไม่ใช่ Layer 7 (application layer)
2. ไม่สามารถกำหนดกฎตาม HTTP methods หรือ paths ได้
3. ต้องใช้ CNI plugin ที่รองรับ Network Policies
4. ไม่มีการแจ้งเตือนหรือบันทึกเมื่อมีการปฏิเสธการเชื่อมต่อ (ต้องใช้เครื่องมือเพิ่มเติม)

## สรุป

ในเวิร์คช็อปนี้ เราได้เรียนรู้:

1. หลักการพื้นฐานของ Network Policies ใน Kubernetes
2. การสร้างและใช้งาน Network Policies แบบต่างๆ
3. การควบคุมการสื่อสารระหว่าง Pods ทั้งแบบ ingress และ egress
4. การทดสอบประสิทธิภาพของ Network Policies
5. แนวทางปฏิบัติที่ดีในการใช้งาน Network Policies

การใช้งาน Network Policies อย่างเหมาะสมจะช่วยเพิ่มความปลอดภัยให้กับแอปพลิเคชันใน Kubernetes ด้วยการจำกัดการสื่อสารเฉพาะส่วนที่จำเป็นเท่านั้น ซึ่งเป็นไปตามหลักการ "principle of least privilege" อันเป็นแนวทางสำคัญในการรักษาความปลอดภัยของระบบ
