# เวิร์คช็อป Kubernetes Dashboard

| รายละเอียด | คำอธิบาย |
|--------|------------|
| **ชื่อเวิร์คช็อป** | การเริ่มต้นใช้งาน Kubernetes Dashboard |
| **วัตถุประสงค์** | เรียนรู้วิธีการติดตั้ง เข้าถึง และใช้งาน Kubernetes Dashboard สำหรับการแสดงผลและจัดการคลัสเตอร์ |
| **ระดับความยาก** | เริ่มต้น |

## บทนำ

Kubernetes Dashboard คือส่วนติดต่อผู้ใช้แบบเว็บสำหรับคลัสเตอร์ Kubernetes ช่วยให้ผู้ใช้สามารถจัดการและแก้ไขปัญหาแอปพลิเคชันที่ทำงานในคลัสเตอร์ รวมถึงจัดการคลัสเตอร์เองได้ ในเวิร์คช็อปนี้ คุณจะได้เรียนรู้:

1. วิธีติดตั้ง Kubernetes Dashboard
2. การสร้างบัญชีผู้ใช้สำหรับการเข้าถึงแดชบอร์ด
3. การกำหนดค่าการเข้าถึงแดชบอร์ดอย่างปลอดภัย
4. การสำรวจคุณลักษณะหลักของแดชบอร์ด
5. การใช้แดชบอร์ดสำหรับงานปฏิบัติการทั่วไป

## ข้อกำหนดเบื้องต้น

- มีคลัสเตอร์ Kubernetes ที่ทำงานอยู่ (Minikube, Docker Desktop หรือผู้ให้บริการคลาวด์)
- มีเครื่องมือ `kubectl` ที่กำหนดค่าให้สื่อสารกับคลัสเตอร์ของคุณ
- มีความเข้าใจพื้นฐานเกี่ยวกับแนวคิด Kubernetes (Pods, Deployments, Services)

## ขั้นตอนที่ 1: ติดตั้ง Kubernetes Dashboard

เราจะเริ่มต้นด้วยการติดตั้ง Kubernetes Dashboard อย่างเป็นทางการโดยใช้ไฟล์กำหนดการติดตั้งที่แนะนำ:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
```

คำสั่งนี้จะสร้างทรัพยากรต่อไปนี้:
- เนมสเปซ `kubernetes-dashboard`
- การกำหนดการติดตั้ง สร้างเซอร์วิส และองค์ประกอบอื่น ๆ ที่จำเป็น
- บทบาท RBAC และการผูกบทบาทสำหรับการทำงานอย่างปลอดภัย

ตรวจสอบว่า pod ของแดชบอร์ดกำลังทำงาน:

```bash
kubectl get pods -n kubernetes-dashboard
```

## ขั้นตอนที่ 2: สร้างบัญชีผู้ใช้สำหรับแดชบอร์ด

ในการเข้าถึงแดชบอร์ด เราจำเป็นต้องสร้างบัญชีผู้ใช้ที่มีสิทธิ์ที่เหมาะสม:

```bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
```

> **หมายเหตุ:** สำหรับสภาพแวดล้อมการผลิต ควรพิจารณาการสร้างบทบาทที่จำกัดยิ่งขึ้นโดยให้สิทธิ์เฉพาะที่จำเป็นสำหรับผู้ใช้ของคุณ

## ขั้นตอนที่ 3: เข้าถึงแดชบอร์ด

### สร้างโทเค็นการเข้าถึง

```bash
kubectl -n kubernetes-dashboard create token admin-user
```

บันทึกโทเค็นนี้เนื่องจากคุณจะต้องใช้มันเพื่อเข้าสู่ระบบแดชบอร์ด

### เข้าถึงผ่าน kubectl proxy

เริ่มต้น Kubernetes API server proxy:

```bash
kubectl proxy
```

ตอนนี้คุณสามารถเข้าถึงแดชบอร์ดได้ที่:
[http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

ใช้โทเค็นที่คุณสร้างไว้ก่อนหน้านี้เพื่อเข้าสู่ระบบ

### วิธีการเข้าถึงทางเลือก: Port Forward

คุณยังสามารถใช้การส่งต่อพอร์ตเพื่อเข้าถึงแดชบอร์ด:

```bash
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443
```

จากนั้นเข้าถึงแดชบอร์ดได้ที่: https://localhost:8443

> **หมายเหตุ:** เบราว์เซอร์ของคุณอาจแจ้งเตือนเกี่ยวกับใบรับรองที่ไม่ถูกต้อง ซึ่งเป็นเรื่องปกติเนื่องจากแดชบอร์ดใช้ใบรับรองที่ลงนามด้วยตนเอง

## ขั้นตอนที่ 4: สำรวจแดชบอร์ด

เมื่อเข้าสู่ระบบแล้ว ให้ใช้เวลาสำรวจส่วนต่างๆ ของแดชบอร์ด:

1. **ภาพรวม**: แสดงสถานะของคลัสเตอร์และเวิร์กโหลดของคุณ
2. **Workloads**: จัดการ deployments, pods, replica sets และอื่นๆ
3. **Discovery and Load Balancing**: สำรวจ services, ingresses และอื่นๆ
4. **Configuration**: ดูและแก้ไข ConfigMaps และ secrets
5. **Storage**: ตรวจสอบ persistent volumes และ claims
6. **Settings**: กำหนดค่าการตั้งค่าแดชบอร์ด

## ขั้นตอนที่ 5: ติดตั้งแอปพลิเคชันตัวอย่างผ่านแดชบอร์ด

มาสร้าง NGINX deployment อย่างง่ายโดยใช้แดชบอร์ด:

1. คลิกปุ่ม "+" ที่มุมขวาบน
2. เลือก "Create from form"
3. กรอกฟอร์มด้วย:
   - App name: `nginx-demo`
   - Container image: `nginx:latest`
   - Number of pods: `2`
   - Service: External, Port: `80`, Target port: `80`
4. คลิก "Deploy"

หรือคุณสามารถวาง YAML ต่อไปนี้:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-demo
  labels:
    app: nginx-demo
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx-demo
  template:
    metadata:
      labels:
        app: nginx-demo
    spec:
      containers:
      - name: nginx
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-demo
spec:
  selector:
    app: nginx-demo
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

## ขั้นตอนที่ 6: สำรวจคุณลักษณะของแดชบอร์ด

### การแสดงภาพทรัพยากร

1. ไปที่ส่วน "Workloads"
2. เลือก `nginx-demo` deployment ของคุณ
3. สำรวจการแสดงผลของ pods, replica sets และทรัพยากรที่เกี่ยวข้อง

### การเข้าถึงบันทึกและเทอร์มินัลแบบเรียลไทม์

1. ค้นหา pod NGINX หนึ่งในของคุณ
2. คลิกเพื่อดูรายละเอียด
3. คลิก "Logs" เพื่อดูบันทึกของคอนเทนเนอร์แบบเรียลไทม์
4. คลิก "Exec" เพื่อเข้าถึงเทอร์มินัลภายในคอนเทนเนอร์

### การแก้ไขทรัพยากร

1. ไปที่รายละเอียด deployment
2. คลิก "Edit" เพื่อแก้ไข YAML
3. เพิ่มจำนวน replicas เป็น 3
4. คลิก "Update"
5. ดูการสร้าง pod ใหม่

## ขั้นตอนที่ 7: แนวทางปฏิบัติด้านความปลอดภัยของแดชบอร์ด

1. **หลีกเลี่ยงการใช้บทบาท `cluster-admin`** สำหรับผู้ใช้ทั่วไป - สร้างบทบาทเฉพาะที่มีสิทธิ์น้อยที่สุด
2. **ใช้การพิสูจน์ตัวตน** - ไม่ควรเปิดเผยแดชบอร์ดโดยไม่มีการพิสูจน์ตัวตนที่เหมาะสม
3. **พิจารณานโยบายเครือข่าย** เพื่อจำกัดการเข้าถึงบริการแดชบอร์ด
4. **ตรวจสอบเป็นประจำ** ว่าใครมีสิทธิ์เข้าถึงแดชบอร์ดของคุณ
5. **อัปเดตแดชบอร์ด** ให้เป็นเวอร์ชันล่าสุดอยู่เสมอ

## ขั้นตอนที่ 8: การทำความสะอาด

เมื่อคุณเสร็จสิ้น คุณสามารถลบแดชบอร์ดและบัญชีผู้ใช้:

```bash
kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
kubectl delete serviceaccount admin-user -n kubernetes-dashboard
kubectl delete clusterrolebinding admin-user
```

## ทรัพยากรเพิ่มเติม

- [Kubernetes Dashboard GitHub Repository](https://github.com/kubernetes/dashboard)
- [Official Dashboard Documentation](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/)
- [Dashboard Access Control Documentation](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/README.md)

## แบบฝึกหัด

1. สร้างบัญชีผู้ใช้แบบจำกัดที่สามารถดูทรัพยากรได้เฉพาะในเนมสเปซที่กำหนด
2. ติดตั้งแอปพลิเคชันแบบหลายคอนเทนเนอร์อย่างง่ายโดยใช้แดชบอร์ด
3. ใช้แดชบอร์ดเพื่อปรับขนาด deployment ขึ้นและลง
4. ดูเมตริกการใช้ทรัพยากรในแดชบอร์ด
5. สร้าง ingress เฉพาะสำหรับแดชบอร์ดพร้อม TLS ที่เหมาะสมสำหรับการเข้าถึงอย่างปลอดภัยนอกเหนือจาก kubectl proxy

## สคริปต์เพื่อช่วยในการทำเวิร์คช็อป

เวิร์คช็อปนี้มีสคริปต์สนับสนุนเพื่อช่วยให้คุณสามารถติดตั้ง, ทดสอบ และทำความสะอาดทรัพยากรได้อย่างง่ายดาย:

### deploy.sh - สคริปต์สำหรับติดตั้งทรัพยากรทั้งหมด

สคริปต์นี้จะติดตั้ง Kubernetes Dashboard, สร้างบัญชีผู้ใช้, และติดตั้งแอปพลิเคชันตัวอย่าง:

```bash
#!/bin/bash

# Deploy the Kubernetes Dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Wait for dashboard to be ready
kubectl wait --for=condition=ready pod -l k8s-app=kubernetes-dashboard -n kubernetes-dashboard --timeout=120s

# Create admin user
kubectl apply -f admin-user.yaml

# Create test namespace and restricted user
kubectl apply -f restricted-user.yaml

# Deploy sample application
kubectl apply -f nginx-demo.yaml
kubectl wait --for=condition=ready pod -l app=nginx-demo -n dashboard-demo --timeout=60s
```

วิธีการใช้งาน:
```bash
chmod +x deploy.sh
./deploy.sh
```

### test.sh - สคริปต์สำหรับทดสอบการติดตั้ง

สคริปต์นี้จะตรวจสอบว่าทรัพยากรทั้งหมดได้ถูกสร้างและทำงานอย่างถูกต้อง:

```bash
#!/bin/bash

# Testing dashboard deployment
if kubectl get deployment kubernetes-dashboard -n kubernetes-dashboard &> /dev/null; then
  echo "Dashboard deployment found"
else
  echo "Dashboard deployment not found. Please run ./deploy.sh first"
  exit 1
fi

# Check if pods are running
RUNNING_PODS=$(kubectl get pods -n kubernetes-dashboard -l k8s-app=kubernetes-dashboard -o jsonpath='{.items[*].status.phase}' 2>/dev/null)
if [ "$RUNNING_PODS" == "Running" ]; then
  echo "Dashboard pods are running"
else
  echo "Dashboard pods are not running. Current status: $RUNNING_PODS"
fi

# Check service account
if kubectl get serviceaccount admin-user -n kubernetes-dashboard &> /dev/null; then
  echo "Admin user service account exists"
else
  echo "Admin user service account not found"
fi

# Try to generate token
TOKEN=$(kubectl -n kubernetes-dashboard create token admin-user 2>/dev/null)
if [ -n "$TOKEN" ]; then
  echo "Token generation successful"
  TOKEN_PREFIX="${TOKEN:0:15}"
  echo "Token preview: $TOKEN_PREFIX... (truncated for security)"
fi

# Test port-forward
kubectl port-forward -n kubernetes-dashboard service/kubernetes-dashboard 8443:443 &>/dev/null &
PORT_FORWARD_PID=$!
sleep 3
kill $PORT_FORWARD_PID &>/dev/null
```

วิธีการใช้งาน:
```bash
chmod +x test.sh
./test.sh
```

### cleanup.sh - สคริปต์สำหรับลบทรัพยากรทั้งหมด

สคริปต์นี้จะลบทรัพยากรทั้งหมดที่ได้สร้างขึ้นในระหว่างเวิร์คช็อป:

```bash
#!/bin/bash

# Delete any port-forward process that might be running
pkill -f "kubectl port-forward.*kubernetes-dashboard" || true

# Delete the sample application
kubectl delete -f nginx-demo.yaml --ignore-not-found

# Delete the restricted user resources
kubectl delete -f restricted-user.yaml --ignore-not-found

# Delete the admin user
kubectl delete -f admin-user.yaml --ignore-not-found

# Delete the dashboard itself
kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Delete any ingress if it was applied
kubectl delete -f dashboard-ingress.yaml --ignore-not-found &> /dev/null

# Clean up the namespace
kubectl delete namespace dashboard-demo --ignore-not-found
```

วิธีการใช้งาน:
```bash
chmod +x cleanup.sh
./cleanup.sh
```

### dashboard-access.sh - สคริปต์สำหรับเข้าถึงแดชบอร์ดอย่างง่าย

สคริปต์นี้เป็นตัวช่วยในการเข้าถึงแดชบอร์ดด้วยวิธีต่างๆ:

```bash
#!/bin/bash

# Check if dashboard is running
if ! kubectl get deployment kubernetes-dashboard -n kubernetes-dashboard &> /dev/null; then
  echo "Kubernetes Dashboard is not deployed. Please run ./deploy.sh first."
  exit 1
fi

echo "Kubernetes Dashboard Access Helper"

# Menu for access options
echo "Please select your preferred access method:"
echo "1. kubectl proxy (http access)"
echo "2. port-forward (https access)"
echo "3. ingress (if configured)"
echo "q. quit"

read -r choice

case $choice in
  1)
    # Generate token
    TOKEN=$(kubectl -n kubernetes-dashboard create token admin-user)
    
    echo "Access the dashboard at:"
    echo "http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
    
    echo "Use this token to log in:"
    echo "$TOKEN"
    
    # Start proxy
    kubectl proxy
    ;;
  
  2)
    # Similar options for port-forward and ingress
    # ...
esac
```

วิธีการใช้งาน:
```bash
chmod +x dashboard-access.sh
./dashboard-access.sh
```

## ขั้นตอนการทำงานที่แนะนำ

1. รันสคริปต์ `deploy.sh` เพื่อติดตั้งแดชบอร์ดและทรัพยากรที่จำเป็น
2. ใช้สคริปต์ `test.sh` เพื่อตรวจสอบว่าทุกอย่างทำงานถูกต้อง
3. ใช้สคริปต์ `dashboard-access.sh` เพื่อเข้าถึงแดชบอร์ด
4. ทดลองใช้คุณสมบัติต่างๆ ของแดชบอร์ดตามที่อธิบายในเวิร์คช็อป
5. เมื่อเสร็จสิ้น รันสคริปต์ `cleanup.sh` เพื่อลบทรัพยากรทั้งหมด

ขอให้สนุกกับการใช้งานแดชบอร์ด!
