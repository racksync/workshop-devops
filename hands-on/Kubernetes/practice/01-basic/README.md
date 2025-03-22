<img src="https://logos-world.net/wp-content/uploads/2023/06/Kubernetes-Logo.png" alt="Kubernetes Logo" height="450px">

# Kubernetes พื้นฐาน - การสร้าง Pod แบบง่าย

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | Kubernetes พื้นฐาน - การสร้าง Pod, Service และ Ingress |
| **วัตถุประสงค์** | เรียนรู้หลักการพื้นฐานและการสร้าง resources หลักใน Kubernetes |
| **ระดับความยาก** | ง่าย |

## การเตรียมสภาพแวดล้อมสำหรับ Kubernetes

### 1. Docker Desktop for Windows
1. ดาวน์โหลดและติดตั้ง Docker Desktop จาก https://www.docker.com/products/docker-desktop

2. สำหรับ Windows: ตั้งค่า WSL2 Integration
   - ติดตั้ง WSL2 โดยเปิด PowerShell แบบ Administrator และรันคำสั่ง:
     ```powershell
     wsl --install
     ```
   - เปิด Docker Desktop ไปที่ Settings > Resources > WSL Integration
   - เปิดใช้งาน "Enable integration with my default WSL distro"
   - เลือกเปิดใช้งาน Linux distributions ที่ต้องการใช้งานกับ Docker
   - กด "Apply & Restart"

3. เปิดใช้งาน Kubernetes:
   - ไปที่ Settings > Kubernetes
   - เลือก "Enable Kubernetes"
   - คลิก "Apply & Restart"

4. ตรวจสอบการติดตั้ง:
```bash
kubectl version
kubectl cluster-info
```

### 2. Orbstack for Mac
1. ติดตั้ง Orbstack จาก https://orbstack.dev
2. Kubernetes จะถูกเปิดใช้งานโดยอัตโนมัติ
3. รันคำสั่งเพื่อตั้งค่า kubectl context:
```bash
orb k8s use
```

### 3. Minikube for Linux
1. ติดตั้ง Minikube:
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

2. เริ่มใช้งาน Minikube:
```bash
minikube start --driver=docker
# หรือใช้ driver อื่นๆ เช่น
# minikube start --driver=kvm2
# minikube start --driver=virtualbox
```

3. ตรวจสอบสถานะ:
```bash
minikube status
kubectl get nodes
```

### 4. DigitalOcean Kubernetes (DOKS)

#### การติดตั้ง doctl
doctl คือ Command Line Interface (CLI) สำหรับจัดการทรัพยากรบน DigitalOcean

##### macOS
ติดตั้งด้วย Homebrew:
```bash
brew install doctl
```


##### Windows


ติดตั้งแบบ Manual:
   เข้าชมหน้า Releases ของโปรเจค GitHub doctl และค้นหาไฟล์ที่เหมาะสมสำหรับระบบปฏิบัติการและสถาปัตยกรรมของคุณ ดาวน์โหลดไฟล์จากเบราว์เซอร์หรือคัดลอก URL และดาวน์โหลดโดยใช้ PowerShell

   ตัวอย่างเช่น เพื่อดาวน์โหลดเวอร์ชันล่าสุดของ doctl ให้รันคำสั่ง:
   ```powershell
   Invoke-WebRequest https://github.com/digitalocean/doctl/releases/download/v1.123.0/doctl-1.123.0-windows-amd64.zip -OutFile ~\doctl-1.123.0-windows-amd64.zip
   ```

   จากนั้น แตกไฟล์ binary โดยรันคำสั่ง:
   ```powershell
   Expand-Archive -Path ~\doctl-1.123.0-windows-amd64.zip
   ```

   สุดท้าย ในเทอร์มินัล PowerShell ที่เปิดด้วย Run as Administrator ให้ย้ายไฟล์ doctl binary ไปยังไดเรกทอรีเฉพาะและเพิ่มเข้าไปใน path ของระบบโดยรันคำสั่ง:
   ```powershell
   New-Item -ItemType Directory $env:ProgramFiles\doctl\
   Move-Item -Path ~\doctl-1.123.0-windows-amd64\doctl.exe -Destination $env:ProgramFiles\doctl\
   [Environment]::SetEnvironmentVariable(
       "Path", 
       [Environment]::GetEnvironmentVariable("Path",
       [EnvironmentVariableTarget]::Machine) + ";$env:ProgramFiles\doctl\",
       [EnvironmentVariableTarget]::Machine)
   $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine")
   ```

##### Linux
1. ติดตั้งด้วย Snap (Ubuntu และ distributions ที่รองรับ):
```bash
sudo snap install doctl
```

2. ติดตั้งแบบ Manual:
```bash
# ดาวน์โหลดไฟล์ล่าสุด (แทนที่ X.XX.X ด้วยเวอร์ชันล่าสุด)
cd ~/Downloads
wget https://github.com/digitalocean/doctl/releases/download/v1.123.0/doctl-1.123.0-linux-amd64.tar.gz

# แตกไฟล์
tar xf ~/doctl-1.123.0-linux-amd64.tar.gz

# ย้ายไฟล์ doctl ไปยัง /usr/local/bin เพื่อให้รันได้ทุกที่
sudo mv ~/doctl /usr/local/bin
```


##### ตรวจสอบการติดตั้ง
หลังจากติดตั้ง doctl แล้ว ทดสอบการทำงานด้วยคำสั่ง:
```bash
doctl version
```

##### การตั้งค่าสิทธิ์การใช้งาน (Authentication)
```bash
# สร้าง Personal access token ที่ https://cloud.digitalocean.com/account/api/tokens
# และใช้คำสั่งนี้เพื่อบันทึกลงในเครื่อง
doctl auth init --context default
# ระบบจะขอ API Token เพื่อบันทึก
```

สามารถใช้หลาย context สำหรับหลาย tokens:
```bash
# สร้าง context ใหม่
doctl auth init --context `prod-cluster`

# สลับไปใช้ context ที่ต้องการ
doctl auth switch --context `prod-cluster`

# ดู context ทั้งหมด
doctl auth list
```

#### การสร้าง Kubernetes Cluster
1. สร้าง Cluster:
```bash
doctl kubernetes cluster create k8s-workshop \
  --region sgp1 \
  --size s-2vcpu-4gb \
  --count 3 \
  --version latest
```

2. ตั้งค่า kubectl context:
```bash
doctl kubernetes cluster kubeconfig save k8s-workshop
```

3. ตรวจสอบ Node:
```bash
kubectl get nodes
```

4. การลบ Cluster เมื่อเลิกใช้งาน:
```bash
doctl kubernetes cluster delete k8s-workshop
```

บทเรียนนี้จะสอนการสร้าง resources พื้นฐานใน Kubernetes ตั้งแต่การสร้าง Namespace, Pod, Service และ Ingress โดยจะใช้ NGINX เป็นตัวอย่าง

## ขั้นตอนการทำงาน

เราจะทำตามลำดับขั้นตอนดังนี้:
1. สร้าง Namespace เพื่อแยกทรัพยากรของเรา
2. สร้าง Pod ที่รัน NGINX
3. สร้าง Service เพื่อเปิด port ให้เข้าถึง NGINX
4. สร้าง Ingress เพื่อกำหนด routing จากภายนอก

## 1. การสร้าง Namespace

Namespace ใช้สำหรับการแบ่งกลุ่มและแยกทรัพยากรใน Kubernetes ทำให้สามารถจัดการทรัพยากรได้เป็นสัดส่วน

```bash
# สร้าง Namespace ชื่อ basic-demo
kubectl create namespace basic-demo
```

หรือสร้างโดยใช้ไฟล์ YAML:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: basic-demo
```

บันทึกเป็นไฟล์ `namespace.yaml` และใช้คำสั่ง:

```bash
kubectl apply -f namespace.yaml
```

ตรวจสอบว่า Namespace ถูกสร้างแล้ว:

```bash
kubectl get namespaces
```

## 2. การสร้าง ConfigMap

ConfigMap ใช้สำหรับเก็บค่า configuration ต่างๆ ที่ใช้ใน Pod เช่น ไฟล์ configuration หรือค่าตัวแปร environment

สร้าง ConfigMap สำหรับเก็บไฟล์ index.html ของ NGINX:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nginx-index-html-configmap
  namespace: basic-demo
data:
  index.html: |
    <!DOCTYPE html>
    <html>
    <head>
      <title>Welcome to NGINX on Kubernetes</title>
      <style>
        body {
          width: 35em;
          margin: 0 auto;
          font-family: Tahoma, Verdana, Arial, sans-serif;
        }
      </style>
    </head>
    <body>
      <h1>Welcome to NGINX on Kubernetes!</h1>
      <p>If you see this page, your Kubernetes NGINX deployment with Ingress is working correctly.</p>
      
      <h2>Environment Information:</h2>
      <ul>
        <li>Pod Name: NGINX Demo Pod</li>
        <li>Namespace: basic-demo</li>
        <li>Accessed via Ingress: nginx.k8s.local</li>
      </ul>
      
      <p><em>Thank you for using the DevOps Workshop tutorial.</em></p>
    </body>
    </html>
```

บันทึกเป็นไฟล์ `nginx-configmap.yaml` และใช้คำสั่ง:

```bash
kubectl apply -f nginx-configmap.yaml
```

ตรวจสอบว่า ConfigMap ถูกสร้างแล้ว:

```bash
kubectl get configmaps -n basic-demo
kubectl describe configmap nginx-index-html-configmap -n basic-demo
```

## 3. การสร้าง Pod

Pod คือหน่วยการทำงานที่เล็กที่สุดใน Kubernetes ซึ่งสามารถมีได้หนึ่งหรือหลาย Container

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  namespace: basic-demo
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```

บันทึกเป็นไฟล์ `nginx-pod.yaml` และใช้คำสั่ง:

```bash
kubectl apply -f nginx-pod.yaml
```

ตรวจสอบสถานะของ Pod:

```bash
kubectl get pods -n basic-demo
```

ดูรายละเอียดเพิ่มเติม:

```bash
kubectl describe pod nginx-pod -n basic-demo
```

ทดสอบการเข้าถึง NGINX โดยตรงจาก Pod (port-forward):

```bash
kubectl port-forward pod/nginx-pod 8080:80 -n basic-demo
```

จากนั้นเปิดเบราว์เซอร์ไปที่ `http://localhost:8080` คุณจะเห็นหน้าต้อนรับของ NGINX

## 3. การสร้าง Service

Service ช่วยให้สามารถเข้าถึง Pod ได้อย่างถาวร แม้ว่า Pod จะถูกสร้างใหม่หรือตำแหน่งเปลี่ยนไป

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: basic-demo
spec:
  selector:
    app: nginx  # ต้องตรงกับ label ของ Pod
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP  # ประเภทเป็น ClusterIP ซึ่งเข้าถึงได้เฉพาะภายใน cluster
```

แต่เพื่อให้ Service ทำงานได้ เราต้องเพิ่ม label ให้กับ Pod ก่อน ให้แก้ไขไฟล์ `nginx-pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
  namespace: basic-demo
  labels:
    app: nginx  # เพิ่ม label
spec:
  containers:
  - name: nginx
    image: nginx:latest
    ports:
    - containerPort: 80
```

บันทึกเป็นไฟล์ `nginx-service.yaml` และใช้คำสั่ง:

```bash
kubectl apply -f nginx-pod.yaml  # อัพเดท Pod ที่มี label
kubectl apply -f nginx-service.yaml
```

ตรวจสอบ Service:

```bash
kubectl get services -n basic-demo
```

ทดสอบการเข้าถึง Service:

```bash
kubectl port-forward service/nginx-service 8080:80 -n basic-demo
```

## 4. การสร้าง Ingress

Ingress ช่วยให้สามารถเข้าถึง Service จากภายนอก cluster ได้ และยังสามารถกำหนด routing rules ได้

**หมายเหตุ:** ต้องมี Ingress Controller (เช่น NGINX Ingress Controller) ติดตั้งในคลัสเตอร์ก่อน

### การติดตั้ง NGINX Ingress Controller

ก่อนที่จะใช้งาน Ingress resource ได้ จำเป็นต้องติดตั้ง Ingress Controller ก่อน โดย NGINX Ingress Controller เป็นตัวเลือกที่นิยมใช้งานกันมาก ทำหน้าที่เป็นตัวกลางในการจัดการ traffic และ routing rules ที่กำหนดไว้ใน Ingress resources

#### ขั้นตอนการติดตั้ง NGINX Ingress Controller

1. **ตรวจสอบว่ามี Ingress Controller ติดตั้งแล้วหรือไม่**:
   ```bash
   kubectl get pods -n ingress-nginx
   ```
   
   หากยังไม่มีการติดตั้ง ไม่ต้องกังวล เราจะติดตั้งในขั้นตอนถัดไป

2. **ใช้ Manifest จาก GitHub Repository ทางการ**:
   ```bash
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
   ```
   
   คำสั่งนี้จะ:
   - สร้าง Namespace `ingress-nginx` สำหรับ Ingress Controller
   - ติดตั้ง Custom Resource Definitions (CRDs) ที่จำเป็น
   - ติดตั้ง RBAC resources (ServiceAccount, ClusterRole, RoleBinding)
   - สร้าง Deployment สำหรับ Controller
   - สร้าง Service สำหรับเข้าถึง Controller

3. **รอให้ Ingress Controller ทำงาน**:
   ```bash
   kubectl wait --namespace ingress-nginx \
     --for=condition=ready pod \
     --selector=app.kubernetes.io/component=controller \
     --timeout=120s
   ```

4. **ตรวจสอบว่า Ingress Controller ทำงานหรือไม่**:
   ```bash
   kubectl get pods -n ingress-nginx
   ```
   
   ควรจะเห็น Pod ที่มีชื่อเริ่มต้นด้วย `ingress-nginx-controller` และมีสถานะเป็น `Running`

5. **ตรวจสอบ Service ที่สร้างขึ้น**:
   ```bash
   kubectl get svc -n ingress-nginx
   ```
   
   จะเห็น Service ชื่อ `ingress-nginx-controller` มี Type เป็น `LoadBalancer` หรือ `NodePort` ขึ้นอยู่กับ environment ที่ใช้

#### การติดตั้งบน Environment เฉพาะ

- **สำหรับ Minikube**:
  ```bash
  minikube addons enable ingress
  ```

- **สำหรับ Docker Desktop**:
  ใช้คำสั่งเดียวกับที่แนะนำข้างต้น แต่อาจต้องรอสักครู่เพื่อให้ LoadBalancer ได้รับ External IP

- **สำหรับ Kind (Kubernetes in Docker)**:
  ```bash
  kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
  ```

#### การทดสอบว่า Ingress Controller ทำงานถูกต้อง

สร้างไฟล์ `test-ingress.yaml` มีเนื้อหาดังนี้:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /test
        pathType: Prefix
        backend:
          service:
            name: kubernetes
            port:
              number: 443
```

ใช้คำสั่งเพื่อสร้าง Ingress:
```bash
kubectl apply -f test-ingress.yaml
```

ตรวจสอบสถานะ:
```bash
kubectl get ingress
```

หลังจากนั้นให้ทำการติดตั้ง Ingress resource ตามต้องการ:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  namespace: basic-demo
spec:
  rules:
  - host: nginx.k8s.local  # เปลี่ยนเป็นโดเมนของคุณ หรือใช้เป็น localhost
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
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
- สร้าง namespace `basic-demo`
- ตั้งค่า context ให้ใช้งาน namespace `basic-demo`
- สร้าง Pod ตัวอย่างทั้งหมด (nginx-pod, multi-container-pod)
- สร้าง Service สำหรับเข้าถึง Pod
- สร้าง ConfigMap และ Secret ที่จำเป็นสำหรับตัวอย่าง

### 2. การทดสอบทรัพยากร (test.sh)

Script นี้จะทดสอบการทำงานของทรัพยากรต่างๆ ที่สร้างขึ้น:

```bash
chmod +x test.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./test.sh
```

การทดสอบประกอบด้วย:
- ตรวจสอบว่า Pod ทำงานปกติ
- ทดสอบการเข้าถึง Pod ผ่าน Service
- ตรวจสอบ logs ของ container ใน Pod
- ทดสอบการรัน command ภายใน container

### 3. การลบทรัพยากรทั้งหมด (cleanup.sh)

เมื่อต้องการลบทรัพยากรทั้งหมดที่สร้างขึ้นในบทเรียนนี้:

```bash
chmod +x cleanup.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./cleanup.sh
```

Script นี้จะดำเนินการ:
- ลบ Pod ทั้งหมดที่สร้างในบทเรียน
- ลบ Service ทั้งหมด
- ลบ ConfigMap และ Secret ที่สร้างขึ้น
- ลบ namespace `basic-demo`
- ตั้งค่า context กลับไปที่ namespace `default`

## การลบทรัพยากรทั้งหมด

เมื่อเสร็จสิ้นการทดสอบ คุณสามารถลบทรัพยากรทั้งหมดได้ด้วยคำสั่ง:

```bash
kubectl delete namespace basic-demo
```

การลบ namespace จะลบทรัพยากรทั้งหมดที่อยู่ภายใน namespace นั้นโดยอัตโนมัติ

## การแก้ไขปัญหา Ingress ที่แสดงข้อความ 404 Not Found

หากคุณสามารถเข้าถึง NGINX ผ่าน port-forward (http://localhost:8080) ได้อย่างถูกต้อง แต่เมื่อเข้าผ่าน Ingress (http://nginx.k8s.local) กลับได้รับข้อความ 404 Not Found คุณสามารถทำตามขั้นตอนต่อไปนี้:

### 1. ตรวจสอบการติดตั้ง Ingress Controller

```bash
kubectl get pods -n ingress-nginx
```

ถ้าไม่พบ pods ที่เกี่ยวข้อง แสดงว่ายังไม่ได้ติดตั้ง Ingress Controller สามารถติดตั้งได้ดังนี้:

```bash
# สำหรับ Docker Desktop
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml

# สำหรับ Minikube
minikube addons enable ingress
```

### 2. ตรวจสอบการตั้งค่า Ingress Controller

Ingress Controller อาจต้องการการตั้งค่าเพิ่มเติม:

```bash
# ตรวจสอบ logs ของ Ingress Controller
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller

# ตรวจสอบรายละเอียดของ Ingress
kubectl describe ingress nginx-ingress -n basic-demo
```

### 3. รีสตาร์ท Pod

บางครั้งการรีสตาร์ท Pod อาจช่วยแก้ปัญหาได้:

```bash
kubectl delete pod nginx-pod -n basic-demo
kubectl apply -f nginx-pod.yaml
```

### 4. ตรวจสอบการตั้งค่า hosts file

ตรวจสอบว่าในไฟล์ hosts มีบรรทัดต่อไปนี้:

## สรุป

ในบทเรียนนี้เราได้เรียนรู้การสร้างทรัพยากรพื้นฐานใน Kubernetes ได้แก่:
1. Namespace - สำหรับแบ่งกลุ่มทรัพยากร
2. Pod - หน่วยการทำงานที่รัน container
3. Service - สำหรับเข้าถึง Pod
4. Ingress - สำหรับกำหนดการเข้าถึงจากภายนอก

นี่เป็นพื้นฐานสำหรับการสร้างแอปพลิเคชันบน Kubernetes ต่อไป

## สรุปประโยชน์ที่ได้รับ

| หัวข้อ | รายละเอียด |
|-------|-----------|
| **Namespace** | เรียนรู้การแยกทรัพยากรเป็นกลุ่มเพื่อการจัดการที่ดีขึ้น |
| **ConfigMap** | เข้าใจการใช้ ConfigMap เพื่อเก็บค่า configuration แยกจาก Pod |
| **Pod** | สามารถสร้างและจัดการ Pod ซึ่งเป็นหน่วยการทำงานพื้นฐานของ Kubernetes |
| **Service** | เรียนรู้การใช้ Service เพื่อเชื่อมต่อกับ Pod อย่างเสถียร |
| **Ingress** | เข้าใจการกำหนด routing rules เพื่อเข้าถึงแอพพลิเคชันจากภายนอก |

## ทักษะที่ได้ฝึกปฏิบัติ
1. การใช้งาน kubectl เพื่อจัดการทรัพยากรใน Kubernetes
2. การเขียนไฟล์ YAML เพื่อกำหนดคุณสมบัติของทรัพยากร
3. การตรวจสอบและแก้ไขปัญหาพื้นฐานใน Kubernetes
4. การใช้งาน Shell Script เพื่อการ Automation
5. การจัดการ configuration ด้วย ConfigMap

## แหล่งข้อมูลเพิ่มเติม
- [Kubernetes Official Documentation](https://kubernetes.io/docs/home/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
- [Kubernetes ConfigMap and Secrets](https://kubernetes.io/docs/concepts/configuration/configmap/)

### การติดตั้งและการใช้งาน
- [Docker Desktop Kubernetes](https://docs.docker.com/desktop/kubernetes/)
- [Orbstack Documentation](https://docs.orbstack.dev/)
- [Minikube Documentation](https://minikube.sigs.k8s.io/docs/)
- [DigitalOcean Kubernetes Documentation](https://docs.digitalocean.com/products/kubernetes/)
- [doctl Command Reference](https://docs.digitalocean.com/reference/doctl/)

### คู่มือการเรียนรู้
- [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way)
- [Kubernetes Learning Path](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [CNCF Kubernetes Training](https://www.cncf.io/certification/training/)

### เครื่องมือที่เป็นประโยชน์
- [k9s - Terminal UI for Kubernetes](https://k9scli.io/)
- [Lens - Kubernetes IDE](https://k8slens.dev/)
- [kubectx & kubens](https://github.com/ahmetb/kubectx)
