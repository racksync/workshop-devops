# เวิร์คชอป Kubernetes แบบลงมือปฏิบัติ

คลังเก็บนี้มีตัวอย่างและแบบฝึกหัดสำหรับการเรียนรู้พื้นฐานของ Kubernetes โดยครอบคลุมทั้งการพัฒนาแบบโลคอลด้วย Docker Desktop และการ Deployไปยัง DigitalOcean Kubernetes

## สารบัญ

- [เวิร์คชอป Kubernetes แบบลงมือปฏิบัติ](#เวิร์คชอป-kubernetes-แบบลงมือปฏิบัติ)
  - [สารบัญ](#สารบัญ)
  - [1. Kubernetes แบบโลคอลด้วย Docker Desktop](#1-kubernetes-แบบโลคอลด้วย-docker-desktop)
    - [1.1 สิ่งที่ต้องมีก่อน](#11-สิ่งที่ต้องมีก่อน)
    - [1.2 การตั้งค่าคลัสเตอร์โลคอล](#12-การตั้งค่าคลัสเตอร์โลคอล)
    - [1.3 การ Deploy Nginx](#13-การ-deploy-nginx)
    - [1.4 การตั้งค่า Ingress หรือ Port Forwarding](#14-การตั้งค่า-ingress-หรือ-port-forwarding)
      - [1.4.1 ทางเลือกที่ 1: Port Forwarding](#141-ทางเลือกที่-1-port-forwarding)
      - [1.4.2 ทางเลือกที่ 2: Ingress](#142-ทางเลือกที่-2-ingress)
  - [2. การ Deployไปยัง DigitalOcean Kubernetes](#2-การ-deployไปยัง-digitalocean-kubernetes)
    - [2.1 สิ่งที่ต้องมีก่อน](#21-สิ่งที่ต้องมีก่อน)
    - [2.2 การสร้างและการพุช Docker images](#22-การสร้างและการพุช-docker-images)
    - [2.3 การ Deployไปยัง DigitalOcean Kubernetes](#23-การ-deployไปยัง-digitalocean-kubernetes)

## 1. Kubernetes แบบโลคอลด้วย Docker Desktop

### 1.1 สิ่งที่ต้องมีก่อน

- มี Docker Desktop ติดตั้งบน Windows
- มีการเปิดใช้งาน Kubernetes ในการตั้งค่าของ Docker Desktop

### 1.2 การตั้งค่าคลัสเตอร์โลคอล

1. เปิด Docker Desktop และไปที่การตั้งค่า
2. นำทางไปที่แท็บ Kubernetes
3. เลือก "Enable Kubernetes" และคลิก Apply & Restart
4. รอให้คลัสเตอร์ Kubernetes พร้อมใช้งาน

ตรวจสอบว่าคลัสเตอร์ของคุณทำงานอยู่:

```bash
kubectl get nodes
```

### 1.3 การ Deploy Nginx

วิธีการ Deploy Nginx ไปยังคลัสเตอร์โลคอลของคุณ:

```bash
kubectl apply -f local-cluster/nginx-deployment.yaml
kubectl apply -f local-cluster/nginx-service.yaml
```

ตรวจสอบการ Deploy:

```bash
kubectl get pods
kubectl get deployments
kubectl get services
```

### 1.4 การตั้งค่า Ingress หรือ Port Forwarding

#### 1.4.1 ทางเลือกที่ 1: Port Forwarding

วิธีการเข้าถึงแอปพลิเคชันของคุณอย่างรวดเร็ว:

```bash
kubectl port-forward service/nginx-service 8080:80
```

ตอนนี้สามารถเข้าถึง Nginx ได้ที่: http://localhost:8080

#### 1.4.2 ทางเลือกที่ 2: Ingress

1. เปิดใช้งาน Nginx Ingress Controller:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
```

2.  Deployทรัพยากร ingress:

```bash
kubectl apply -f local-cluster/nginx-ingress.yaml
```

3. อัปเดตไฟล์ hosts ของคุณ (C:\Windows\System32\drivers\etc\hosts):
```
127.0.0.1 nginx.local
```

4. เข้าถึงบริการ Nginx ของคุณที่: http://nginx.local

## 2. การ Deployไปยัง DigitalOcean Kubernetes

### 2.1 สิ่งที่ต้องมีก่อน

- บัญชี DigitalOcean
- มีการติดตั้งและตรวจสอบความถูกต้องของ CLI `doctl` 
- มีการสร้างคลัสเตอร์ Kubernetes บน DigitalOcean
- มีการตั้งค่า DigitalOcean Container Registry

### 2.2 การสร้างและการพุช Docker images

1. สร้างแอปพลิเคชัน Node.js อย่างง่ายในไดเรกทอรี `do-registry`
2. สร้าง Docker image:

```bash
docker build -t <your-registry>/sample-app:latest ./do-registry
```

3. พุชไปยัง DigitalOcean Container Registry:

```bash
# ตรวจสอบความถูกต้องกับ registry
doctl registry login

# แท็ก image ด้วย registry ของคุณ
docker tag <your-registry>/sample-app:latest registry.digitalocean.com/<your-registry>/sample-app:latest

# พุช image
docker push registry.digitalocean.com/<your-registry>/sample-app:latest
```

### 2.3 การ Deployไปยัง DigitalOcean Kubernetes

1. เชื่อมต่อกับคลัสเตอร์ DigitalOcean Kubernetes ของคุณ:

```bash
doctl kubernetes cluster kubeconfig save <cluster-id>
```

2.  Deployแอปพลิเคชันของคุณ:

```bash
kubectl apply -f do-registry/deployment.yaml
```

3. ตรวจสอบสถานะการ Deploy:

```bash
kubectl get pods
kubectl get deployments
kubectl get services
```

สำหรับคำแนะนำโดยละเอียดเพิ่มเติม โปรดดูที่ [เอกสารของ DigitalOcean](https://docs.digitalocean.com/products/kubernetes/getting-started/deploy-image-to-cluster/)
