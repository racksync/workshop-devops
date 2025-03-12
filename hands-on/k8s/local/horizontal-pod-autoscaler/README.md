# Kubernetes Horizontal Pod Autoscaler Workshop

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | การใช้งาน Horizontal Pod Autoscaler (HPA) สำหรับการปรับขนาดอัตโนมัติใน Kubernetes |
| **วัตถุประสงค์** | เรียนรู้การตั้งค่าและใช้งาน HPA เพื่อปรับขนาดแอปพลิเคชันโดยอัตโนมัติตามการใช้ทรัพยากร |
| **ระดับความยาก** | ปานกลาง |

ในเวิร์คช็อปนี้ เราจะเรียนรู้เกี่ยวกับ Horizontal Pod Autoscaler (HPA) ใน Kubernetes ซึ่งช่วยให้สามารถปรับขนาดของแอปพลิเคชันโดยอัตโนมัติตามการใช้ทรัพยากรที่กำหนด เช่น CPU หรือ Memory ทำให้ระบบสามารถรองรับโหลดที่เพิ่มขึ้นหรือลดลงได้อย่างมีประสิทธิภาพ

## สิ่งที่จะได้เรียนรู้

- ความเข้าใจพื้นฐานเกี่ยวกับ Horizontal Pod Autoscaler (HPA)
- การตั้งค่า HPA สำหรับ Deployment ด้วยตัวชี้วัดมาตรฐาน (CPU, Memory)
- การทดสอบการปรับขนาดอัตโนมัติด้วยการจำลองโหลด
- การใช้งาน Custom Metrics และ External Metrics สำหรับ HPA
- การกำหนดค่า stabilization window และพารามิเตอร์ขั้นสูง
- การสังเกตและวิเคราะห์พฤติกรรมการปรับขนาดอัตโนมัติ

## ก่อนเริ่มต้น

สำหรับเวิร์คช็อปนี้ คุณจะต้องมี:

- Kubernetes cluster (เช่น Minikube, Docker Desktop, Kind หรือ GKE/EKS/AKS)
- Metrics Server ติดตั้งในคลัสเตอร์ (จำเป็นสำหรับ HPA ที่ใช้ CPU/Memory metrics)
- kubectl ที่ตั้งค่าให้เชื่อมต่อกับคลัสเตอร์ของคุณ
- hey หรือ Apache Bench (ab) สำหรับการจำลองโหลด (ติดตั้งตามความสะดวก)

## ขั้นตอนการทำงาน

### 1. สร้าง Namespace

สร้าง Namespace เพื่อแยกทรัพยากรที่ใช้ในบทเรียนนี้:

```bash
kubectl create namespace hpa-demo
kubectl config set-context --current --namespace=hpa-demo
```

### 2. ตรวจสอบว่า Metrics Server ทำงานอยู่

```bash
kubectl get deployment metrics-server -n kube-system
```

หากยังไม่มี Metrics Server คุณสามารถติดตั้งได้ดังนี้:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

รอประมาณ 1-2 นาทีเพื่อให้ Metrics Server เริ่มทำงาน

### 3. สร้าง Deployment สำหรับตัวอย่างแอปพลิเคชัน

```bash
kubectl apply -f app-deployment.yaml
```

**app-deployment.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: php-apache
spec:
  selector:
    matchLabels:
      run: php-apache
  replicas: 1
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: php-apache
        image: k8s.gcr.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
---
apiVersion: v1
kind: Service
metadata:
  name: php-apache
spec:
  ports:
  - port: 80
  selector:
    run: php-apache
```

### 4. สร้าง Horizontal Pod Autoscaler

```bash
kubectl apply -f cpu-hpa.yaml
```

**cpu-hpa.yaml**:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: php-apache
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
```

### 5. ตรวจสอบสถานะของ HPA

```bash
kubectl get hpa php-apache
```

### 6. จำลองโหลดเพื่อทดสอบการทำงานของ HPA

```bash
# รันใน terminal แยก
kubectl run -i --tty load-generator --rm --image=busybox:1.28 --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://php-apache; done"
```

### 7. ตรวจสอบการทำงานของ HPA

```bash
# ดู HPA ทุก 5 วินาที
watch -n5 kubectl get hpa
```

```bash
# ดู Deployment และ Pods
watch -n5 "kubectl get deployment php-apache && kubectl get pods"
```

### 8. สร้าง HPA ที่ใช้ Memory เป็นตัวชี้วัด

```bash
kubectl apply -f memory-hpa.yaml
```

**memory-hpa.yaml**:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: memory-demo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: memory-demo
  minReplicas: 1
  maxReplicas: 5
  metrics:
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 60
```

### 9. สร้าง HPA แบบ Multi-Metric

```bash
kubectl apply -f multi-metric-hpa.yaml
```

**multi-metric-hpa.yaml**:
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: multi-metric-demo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 50
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 60
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
      - type: Percent
        value: 100
        periodSeconds: 60
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
      - type: Percent
        value: 10
        periodSeconds: 60
```

### 10. การใช้งาน Custom Metrics API (ต้องติดตั้งเพิ่มเติม)

หากต้องการใช้ Custom Metrics เช่น จำนวน request ต่อวินาที ต้องติดตั้ง:
- Prometheus
- Prometheus Adapter

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: custom-metric-demo
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  minReplicas: 1
  maxReplicas: 10
  metrics:
  - type: Pods
    pods:
      metric:
        name: http_requests_per_second
      target:
        type: AverageValue
        averageValue: 10
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
- สร้าง namespace `hpa-demo`
- ตั้งค่า context ให้ใช้งาน namespace `hpa-demo`
- ตรวจสอบและติดตั้ง Metrics Server หากจำเป็น
- สร้าง Deployment สำหรับตัวอย่างแอปพลิเคชัน
- สร้าง HPA ต่างๆ สำหรับการทดสอบ

### 2. การทดสอบทรัพยากร (test.sh)

Script นี้จะทดสอบการทำงานของ HPA:

```bash
chmod +x test.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./test.sh
```

การทดสอบประกอบด้วย:
- จำลองโหลดสำหรับแอปพลิเคชัน
- ตรวจสอบการทำงานของ HPA และการปรับขนาดอัตโนมัติ
- แสดงกราฟการใช้งาน CPU และจำนวน Pod

### 3. การลบทรัพยากรทั้งหมด (cleanup.sh)

เมื่อต้องการลบทรัพยากรทั้งหมดที่สร้างขึ้นในบทเรียนนี้:

```bash
chmod +x cleanup.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./cleanup.sh
```

Script นี้จะดำเนินการ:
- ลบ load generator pod
- ลบ HPAs ทั้งหมด
- ลบ Deployments และ Services
- ลบ namespace `hpa-demo`
- ตั้งค่า context กลับไปที่ namespace `default`

## การแก้ไขปัญหาที่พบบ่อย

1. **HPA ไม่ทำงาน**
   - ตรวจสอบว่า Metrics Server ทำงานอยู่
   - ตรวจสอบว่ามีการกำหนด resource requests สำหรับ containers

   ```bash
   kubectl describe hpa php-apache
   ```

2. **ไม่เห็นข้อมูล metrics**
   - ตรวจสอบว่า Metrics Server สามารถเข้าถึง Pod ได้

   ```bash
   kubectl top pods
   ```

3. **การปรับขนาดช้าเกินไป**
   - ปรับค่า `stabilizationWindowSeconds` ให้เหมาะสม
   - ตรวจสอบนโยบายการปรับขนาด (scaling policies)

## ข้อแนะนำเพิ่มเติม

- ตั้งค่า resource requests ที่แม่นยำเพื่อให้ HPA ทำงานได้อย่างมีประสิทธิภาพ
- ใช้ `stabilizationWindowSeconds` เพื่อป้องกันการปรับขนาดที่ไม่จำเป็นเมื่อมีการเปลี่ยนแปลงระยะสั้น
- พิจารณาใช้ metrics หลายตัวสำหรับการปรับขนาดที่ซับซ้อน
- ทดสอบ HPA ในสภาพแวดล้อมที่เหมือนกับการใช้งานจริงก่อนนำไปใช้ในการผลิตจริง

## สรุป

ในเวิร์คช็อปนี้ เราได้เรียนรู้:

1. หลักการทำงานของ Horizontal Pod Autoscaler (HPA)
2. การตั้งค่า HPA ด้วย CPU และ Memory metrics
3. การกำหนดค่าขั้นสูงเช่น stabilization window และ scaling policies
4. การใช้งาน Custom Metrics สำหรับการปรับขนาดตามตัวชี้วัดที่ซับซ้อนขึ้น
5. แนวทางการแก้ไขปัญหาที่พบบ่อย

การใช้ HPA อย่างเหมาะสมช่วยให้ระบบของคุณสามารถรองรับโหลดที่เปลี่ยนแปลงได้อย่างมีประสิทธิภาพ ช่วยประหยัดทรัพยากรในช่วงที่มีการใช้งานน้อย และรองรับการใช้งานสูงโดยอัตโนมัติ
