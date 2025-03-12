# Kubernetes พื้นฐาน - การสร้าง Pod แบบง่าย

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | Kubernetes พื้นฐาน - การสร้าง Pod, Service และ Ingress |
| **วัตถุประสงค์** | เรียนรู้หลักการพื้นฐานและการสร้าง resources หลักใน Kubernetes |
| **ระดับความยาก** | ง่าย |



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

## 2. การสร้าง Pod

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

บันทึกเป็นไฟล์ `nginx-ingress.yaml` และใช้คำสั่ง:

```bash
kubectl apply -f nginx-ingress.yaml
```

ตรวจสอบ Ingress:

```bash
kubectl get ingress -n basic-demo
```

**หมายเหตุ:** หากต้องการทดสอบบน localhost คุณอาจต้องแก้ไขไฟล์ hosts:
- สำหรับ Linux/macOS: `/etc/hosts`
- สำหรับ Windows: `C:\Windows\System32\drivers\etc\hosts`

เพิ่มบรรทัดนี้:
```
127.0.0.1 nginx.k8s.local
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

## สรุป

ในบทเรียนนี้เราได้เรียนรู้การสร้างทรัพยากรพื้นฐานใน Kubernetes ได้แก่:
1. Namespace - สำหรับแบ่งกลุ่มทรัพยากร
2. Pod - หน่วยการทำงานที่รัน container
3. Service - สำหรับเข้าถึง Pod
4. Ingress - สำหรับกำหนดการเข้าถึงจากภายนอก

นี่เป็นพื้นฐานสำหรับการสร้างแอปพลิเคชันบน Kubernetes ต่อไป
