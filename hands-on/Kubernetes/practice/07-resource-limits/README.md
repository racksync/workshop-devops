# Kubernetes Resource Limits Workshop

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | การจัดการทรัพยากรใน Kubernetes ด้วย Resource Requests และ Limits |
| **วัตถุประสงค์** | เรียนรู้การจัดสรรและควบคุมการใช้ทรัพยากร CPU และ Memory ของ containers ใน Kubernetes |
| **ระดับความยาก** | ง่าย |

ในเวิร์คช็อปนี้ เราจะเรียนรู้เกี่ยวกับการจัดการทรัพยากรใน Kubernetes โดยใช้ Resource Requests และ Limits เพื่อควบคุมการใช้งาน CPU และ Memory ของแอปพลิเคชัน

## สิ่งที่จะได้เรียนรู้

- ความเข้าใจพื้นฐานเกี่ยวกับการจัดการทรัพยากรใน Kubernetes
- การกำหนด Resource Requests เพื่อจองทรัพยากรขั้นต่ำ
- การกำหนด Resource Limits เพื่อจำกัดการใช้ทรัพยากรสูงสุด
- การตรวจสอบการใช้ทรัพยากรของ Pod
- การทดสอบพฤติกรรมเมื่อใช้ทรัพยากรเกินกำหนด
- การใช้ LimitRange และ ResourceQuota เพื่อควบคุมการใช้ทรัพยากรในระดับ namespace

## ขั้นตอนการทำงาน

### 1. สร้าง Namespace

สร้าง Namespace เพื่อแยกทรัพยากรที่ใช้ในบทเรียนนี้:

```bash
kubectl create namespace resource-demo
kubectl config set-context --current --namespace=resource-demo
```

### 2. สร้าง Pod ที่มีการกำหนด Requests และ Limits

Resource Requests คือปริมาณทรัพยากรขั้นต่ำที่ Pod ต้องการ ส่วน Limits คือขีดจำกัดสูงสุดที่ Pod สามารถใช้ได้

```bash
kubectl apply -f simple-pod.yaml
```

**simple-pod.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: simple-pod
  namespace: resource-demo
spec:
  containers:
  - name: nginx
    image: nginx:latest
    resources:
      requests:
        memory: "64Mi"
        cpu: "100m"
      limits:
        memory: "128Mi"
        cpu: "200m"
    ports:
    - containerPort: 80
```

### 3. สร้าง Pod ที่ใช้ทรัพยากรมาก

เราจะสร้าง Pod ที่จงใจใช้ทรัพยากรมาก เพื่อดูพฤติกรรมเมื่อใช้ทรัพยากรเกินกำหนด:

```bash
kubectl apply -f resource-hungry-pod.yaml
```

**resource-hungry-pod.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: memory-hungry-pod
  namespace: resource-demo
spec:
  containers:
  - name: memory-stress
    image: polinux/stress
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "150M", "--vm-hang", "1"]
    resources:
      requests:
        memory: "100Mi"
        cpu: "100m"
      limits:
        memory: "150Mi"
        cpu: "200m"
```

### 4. สร้าง Deployment พร้อมกำหนดทรัพยากร

ในการใช้งานจริง เราจะกำหนด Resource Requests และ Limits ใน Deployment เพื่อให้ Pod ทั้งหมดมีการจัดการทรัพยากรที่ถูกต้อง:

```bash
kubectl apply -f resource-deployment.yaml
```

**resource-deployment.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: resource-deployment
  namespace: resource-demo
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      containers:
      - name: web
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
```

### 5. สร้าง LimitRange

LimitRange ช่วยให้เราสามารถกำหนดค่า default Requests และ Limits สำหรับ namespace ได้:

```bash
kubectl apply -f limit-range.yaml
```

**limit-range.yaml**:
```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
  namespace: resource-demo
spec:
  limits:
  - default:
      memory: "256Mi"
      cpu: "500m"
    defaultRequest:
      memory: "128Mi"
      cpu: "250m"
    type: Container
```

### 6. สร้าง ResourceQuota

ResourceQuota ช่วยให้เราสามารถจำกัดการใช้ทรัพยากรรวมในระดับ namespace ได้:

```bash
kubectl apply -f resource-quota.yaml
```

**resource-quota.yaml**:
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: namespace-quota
  namespace: resource-demo
spec:
  hard:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
    pods: "10"
```

### 7. ตรวจสอบข้อมูลการใช้ทรัพยากร

ตรวจสอบข้อมูลทรัพยากรของ Pod:

```bash
# ตรวจสอบรายละเอียด Pod
kubectl describe pod simple-pod

# ดูการใช้ทรัพยากรในปัจจุบัน
kubectl top pod

# ตรวจสอบ ResourceQuota
kubectl describe resourcequota namespace-quota
```

### 8. ทดสอบการทำงานเมื่อใช้ทรัพยากรเกินกำหนด

```bash
# สร้าง Pod ที่ใช้ memory มากเกินไป
kubectl apply -f exceed-limits-pod.yaml
```

**exceed-limits-pod.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: exceed-memory-pod
  namespace: resource-demo
spec:
  containers:
  - name: memory-hog
    image: polinux/stress
    command: ["stress"]
    args: ["--vm", "1", "--vm-bytes", "300M", "--vm-hang", "1"]
    resources:
      limits:
        memory: "200Mi"
        cpu: "300m"
      requests:
        memory: "100Mi"
        cpu: "150m"
```

ดูผลลัพธ์:
```bash
kubectl get pod exceed-memory-pod --watch
```

คุณจะเห็นว่า Pod ถูก kill และกลับมาเริ่มใหม่เมื่อใช้ memory เกินกำหนด (OOMKilled)

## ความสำคัญของ Requests และ Limits

1. **Resource Requests**:
   - ใช้สำหรับการจัดสรร (scheduling) Pod ไปยัง Node ที่มีทรัพยากรเพียงพอ
   - เป็นค่าขั้นต่ำที่ Pod ต้องการ
   - ช่วยให้ Kubernetes จัดสรรทรัพยากรได้อย่างเหมาะสม

2. **Resource Limits**:
   - กำหนดปริมาณทรัพยากรสูงสุดที่ Pod สามารถใช้ได้
   - ช่วยป้องกันไม่ให้ Pod ใดใช้ทรัพยากรมากเกินไปจนกระทบ Pod อื่น
   - กรณี CPU: จำกัดการใช้งาน CPU สูงสุด
   - กรณี Memory: หาก Pod ใช้ memory เกินกำหนด จะถูก kill (OOMKilled)

## หน่วยวัดทรัพยากร

### CPU
- 1 CPU unit = 1 vCPU / Core
- 100m = 0.1 CPU (100 milli-CPU)

### Memory
- Mi = Mebibyte (1 Mi = 1,048,576 bytes)
- Gi = Gibibyte (1 Gi = 1,073,741,824 bytes)
- M = Megabyte (1 M = 1,000,000 bytes)
- G = Gigabyte (1 G = 1,000,000,000 bytes)

## พฤติกรรมเมื่อไม่กำหนด Requests และ Limits

1. **ไม่กำหนด Requests**: 
   - Pod อาจถูกจัดสรรไปยัง Node ที่ไม่มีทรัพยากรเพียงพอ
   - ในกรณีที่มี LimitRange ในระดับ namespace จะใช้ค่า defaultRequest

2. **ไม่กำหนด Limits**:
   - Pod สามารถใช้ทรัพยากรได้ไม่จำกัดจนกระทบ Pod อื่นๆ
   - ในกรณีที่มี LimitRange ในระดับ namespace จะใช้ค่า default

## แนวทางการตั้งค่า Requests และ Limits

1. **สำหรับแอปพลิเคชันทั่วไป**:
   - Requests: ตั้งเป็น ~80% ของการใช้งานปกติ
   - Limits: ตั้งเป็น ~120-150% ของการใช้งานปกติ

2. **สำหรับ Production**:
   - ควรมีการทดสอบและวัดประสิทธิภาพเพื่อหาค่าที่เหมาะสม
   - ใช้เครื่องมือ monitoring เช่น Prometheus ร่วมกับ Grafana
   - พิจารณาใช้ Vertical Pod Autoscaler เพื่อปรับค่าอัตโนมัติ

3. **ข้อพิจารณาเพิ่มเติม**:
   - CPU เป็น "compressible resource" (จำกัดการใช้งานได้)
   - Memory เป็น "incompressible resource" (ไม่สามารถคืนให้ระบบได้หลังจากใช้แล้ว)

## การใช้ Shell Script สำหรับการจัดการทรัพยากร

เพื่อความสะดวกในการติดตั้งและทดสอบ workshop นี้ เราได้เตรียม shell script สำหรับการจัดการทรัพยากรทั้งหมด:

### 1. การติดตั้งทรัพยากรทั้งหมด (deploy.sh)

Script นี้จะสร้าง namespace และทรัพยากรทั้งหมดที่จำเป็นสำหรับ workshop นี้:

```bash
chmod +x deploy.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./deploy.sh
```

เมื่อรัน script นี้แล้ว จะมีการดำเนินการดังนี้:
- สร้าง namespace `resource-demo`
- ตั้งค่า context ให้ใช้งาน namespace `resource-demo`
- สร้าง Pod และ Deployment ตัวอย่างทั้งหมดพร้อม resource settings
- สร้าง LimitRange และ ResourceQuota

### 2. การทดสอบทรัพยากร (test.sh)

Script นี้จะทดสอบการทำงานของทรัพยากรต่างๆ ที่สร้างขึ้น:

```bash
chmod +x test.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./test.sh
```

การทดสอบประกอบด้วย:
- ตรวจสอบว่า Pod ทำงานปกติ
- ตรวจสอบการใช้ทรัพยากรของแต่ละ Pod
- ทดสอบการสร้าง Pod ที่ใช้ทรัพยากรเกินกว่า Limits
- ทดสอบการสร้าง Pod เมื่อใช้ทรัพยากรรวมเกินกว่า ResourceQuota

### 3. การลบทรัพยากรทั้งหมด (cleanup.sh)

เมื่อต้องการลบทรัพยากรทั้งหมดที่สร้างขึ้นในบทเรียนนี้:

```bash
chmod +x cleanup.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./cleanup.sh
```

Script นี้จะดำเนินการ:
- ลบ Pod ทั้งหมดที่สร้างในบทเรียน
- ลบ Deployment ทั้งหมด
- ลบ LimitRange และ ResourceQuota
- ลบ namespace `resource-demo`
- ตั้งค่า context กลับไปที่ namespace `default`

## ข้อควรระวังในการตั้งค่า Requests และ Limits

1. **ตั้ง Requests มากเกินไป**:
   - Node ไม่สามารถรองรับ Pod ได้มากเพียงพอ (แม้มีทรัพยากรเหลือ)
   - ทำให้เกิด under-utilization ของ cluster

2. **ตั้ง Requests น้อยเกินไป**:
   - อาจเกิด overcommitment บน Node
   - เมื่อ Pod ใช้ทรัพยากรมากกว่าที่ Request จะทำให้เกิดการแย่งทรัพยากร

3. **ตั้ง Limits น้อยเกินไป**:
   - Pod อาจถูก kill บ่อยครั้งเมื่อต้องการใช้ทรัพยากรมากขึ้นชั่วคราว

4. **ตั้ง Limits มากเกินไป**:
   - สูญเสียประโยชน์ของการควบคุม resource usage
   - อาจทำให้เกิด resource starvation บน Node

5. **ความไม่สมดุลระหว่าง Requests และ Limits**:
   - ตั้ง Limits สูงมากกว่า Requests มากเกินไป: อาจทำให้เกิด resource starvation
   - ตั้ง Limits เท่ากับ Requests: อาจทำให้ใช้ทรัพยากรไม่เต็มประสิทธิภาพ

## ตัวอย่างการประยุกต์ใช้ในสถานการณ์จริง

1. **แอปพลิเคชันที่ใช้ทรัพยากรคงที่** (เช่น API server):
   ```yaml
   resources:
     requests:
       cpu: "500m"
       memory: "512Mi"
     limits:
       cpu: "1000m"
       memory: "1Gi"
   ```

2. **แอปพลิเคชันที่มีการใช้ทรัพยากรแบบ burst** (เช่น batch processing):
   ```yaml
   resources:
     requests:
       cpu: "250m"
       memory: "256Mi"
     limits:
       cpu: "1500m"
       memory: "1.5Gi"
   ```

3. **แอปพลิเคชันที่มีความสำคัญสูง** (critical applications):
   ```yaml
   resources:
     requests:
       cpu: "1000m"
       memory: "1Gi"
     limits:
       cpu: "1500m"
       memory: "1.5Gi"
   ```

## สรุป

ในเวิร์คช็อปนี้ เราได้เรียนรู้:

1. วิธีการกำหนด Resource Requests และ Limits ใน Kubernetes
2. ความแตกต่างและความสำคัญของ Requests และ Limits
3. การใช้ LimitRange และ ResourceQuota ในการควบคุมการใช้ทรัพยากรในระดับ namespace
4. พฤติกรรมของ Pod เมื่อใช้ทรัพยากรเกินกำหนด
5. แนวทางการตั้งค่า Requests และ Limits ที่เหมาะสม

การจัดการทรัพยากรอย่างเหมาะสมเป็นส่วนสำคัญในการบริหาร Kubernetes cluster ให้มีประสิทธิภาพ ช่วยให้แอปพลิเคชันทำงานได้อย่างราบรื่น และป้องกันปัญหาที่เกิดจากการใช้ทรัพยากรมากเกินไป
