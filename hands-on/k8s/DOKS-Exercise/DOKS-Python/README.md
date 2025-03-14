# การติดตั้ง Python Application บน Kubernetes ด้วย Okteto

## สิ่งที่จำเป็นต้องมี
- บัญชี DigitalOcean
- kubectl ติดตั้งในเครื่อง
- Docker Desktop
- Okteto CLI
- Python 3.x
- Git

## ขั้นตอนการติดตั้ง

### 1. สร้าง Python Application
เริ่มต้นด้วยการสร้าง Flask application อย่างง่าย:

```python
from flask import Flask
app = Flask(__name__)

@app.route('/')
def hello():
    return "สวัสดี Kubernetes!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

### 2. สร้าง Dockerfile
```dockerfile
FROM python:3.8-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

### 3. การตั้งค่า Kubernetes
สร้างไฟล์ `k8s.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: python-app
  template:
    metadata:
      labels:
        app: python-app
    spec:
      containers:
      - name: python-app
        image: python-app
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: python-app
spec:
  selector:
    app: python-app
  ports:
  - port: 8080
    targetPort: 8080
  type: LoadBalancer
```

### 4. การตั้งค่า Okteto
สร้างไฟล์ `okteto.yaml`:

```yaml
name: python-app
image: python:3.8
command: ["bash"]
volumes:
  - /root/.cache/pip
sync:
  - .:/app
forward:
  - 8080:8080
```

## วิธีการใช้งาน

1. สร้าง Kubernetes cluster บน DigitalOcean
```bash
doctl kubernetes cluster create my-cluster
```

2. เชื่อมต่อกับ cluster
```bash
doctl kubernetes cluster kubeconfig save my-cluster
```

3. Deploy application
```bash
kubectl apply -f k8s.yaml
```

4. เริ่มการพัฒนาด้วย Okteto
```bash
okteto up
```

## การพัฒนาแบบ Live Development

เมื่อใช้ Okteto คุณสามารถแก้ไขโค้ดได้แบบ real-time โดยการเปลี่ยนแปลงจะถูก sync ไปยัง container โดยอัตโนมัติ

## การลบ Resources

เมื่อต้องการลบ resources ทั้งหมด:
```bash
kubectl delete -f k8s.yaml
doctl kubernetes cluster delete my-cluster
```

## การแก้ไขปัญหาเบื้องต้น

1. ตรวจสอบ pod status:
```bash
kubectl get pods
```

2. ดู logs:
```bash
kubectl logs <pod-name>
```

3. เข้าถึง container:
```bash
kubectl exec -it <pod-name> -- /bin/bash
```
