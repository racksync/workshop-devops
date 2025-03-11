# Kubernetes พื้นฐาน - การสร้าง Pod แบบง่าย

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
