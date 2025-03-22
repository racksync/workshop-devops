# Kubernetes Jobs และ CronJobs Workshop

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | การใช้งาน Jobs และ CronJobs ใน Kubernetes |
| **วัตถุประสงค์** | เรียนรู้การสร้างและจัดการ batch jobs และ scheduled tasks ใน Kubernetes |
| **ระดับความยาก** | ปานกลาง |

ในบทเรียนนี้ เราจะเรียนรู้เกี่ยวกับ Jobs และ CronJobs ใน Kubernetes สำหรับการประมวลผลแบบ batch และการจัดการงานที่ทำงานตามกำหนดเวลา

## สิ่งที่จะได้เรียนรู้

- การสร้างและจัดการ Jobs ใน Kubernetes
- การสร้าง CronJobs สำหรับงานที่ทำงานตามกำหนดเวลา
- การติดตาม (monitor) สถานะของ Jobs และ CronJobs
- การจัดการ completions และ parallelism ใน Jobs
- การกำหนดเงื่อนไขการทำงานซ้ำและการจัดการความล้มเหลว

## ขั้นตอนการทำงาน

### 1. สร้าง Namespace

สร้าง Namespace เพื่อแยกทรัพยากรที่ใช้ในบทเรียนนี้:

```bash
kubectl create namespace jobs-demo
kubectl config set-context --current --namespace=jobs-demo
```

### 2. สร้าง Job แบบพื้นฐาน

Job จะสร้าง Pod ที่ทำงานจนเสร็จแล้วหยุด ไม่ใช่ทำงานตลอดเวลาเหมือน Deployment

```bash
kubectl apply -f basic-job.yaml
```

**basic-job.yaml**:
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: hello-world-job
spec:
  template:
    spec:
      containers:
      - name: hello
        image: busybox
        command: ["sh", "-c", "echo 'Hello from Kubernetes job!' && sleep 30"]
      restartPolicy: Never
  backoffLimit: 4
```

### 3. สร้าง Job พร้อมกำหนด Completions และ Parallelism

Job นี้จะทำงานหลายครั้ง และสามารถทำงานพร้อมกันได้หลาย Pod:

```bash
kubectl apply -f parallel-job.yaml
```

**parallel-job.yaml**:
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: parallel-job
spec:
  completions: 5     # ต้องทำงานให้สำเร็จ 5 ครั้ง
  parallelism: 2     # อนุญาตให้ทำงานพร้อมกัน 2 Pod
  template:
    spec:
      containers:
      - name: worker
        image: busybox
        command: ["sh", "-c", "echo 'Working on task!' && sleep $(( $RANDOM % 20 + 10 ))"]
      restartPolicy: Never
  backoffLimit: 4
```

### 4. สร้าง CronJob

CronJob จะสร้าง Job ตามกำหนดเวลาที่ระบุ:

```bash
kubectl apply -f basic-cronjob.yaml
```

**basic-cronjob.yaml**:
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: hello-cronjob
spec:
  schedule: "*/5 * * * *"  # ทุกๆ 5 นาที
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            command: ["sh", "-c", "echo 'Hello from scheduled job!' && date"]
          restartPolicy: OnFailure
```

### 5. สร้าง CronJob พร้อมตัวเลือกขั้นสูง

```bash
kubectl apply -f advanced-cronjob.yaml
```

**advanced-cronjob.yaml**:
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: advanced-cronjob
spec:
  schedule: "*/10 * * * *"  # ทุกๆ 10 นาที
  startingDeadlineSeconds: 180  # หากเริ่มช้าเกิน 3 นาที ให้ข้าม
  concurrencyPolicy: Forbid     # ห้ามทำงานซ้อนกัน
  successfulJobsHistoryLimit: 3 # เก็บประวัติงานสำเร็จไว้ 3 ชุด
  failedJobsHistoryLimit: 1     # เก็บประวัติงานล้มเหลวไว้ 1 ชุด
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: advanced-worker
            image: busybox
            command: ["sh", "-c", "echo 'Running advanced job' && date && sleep 30"]
          restartPolicy: OnFailure
```

### 6. ตรวจสอบการทำงานของ Jobs

```bash
# ดู Jobs ทั้งหมด
kubectl get jobs

# ดูรายละเอียดของ Job
kubectl describe job hello-world-job

# ดู Pods ที่ถูกสร้างโดย Job
kubectl get pods --selector=job-name=hello-world-job

# ดู logs ของ Pod
kubectl logs -l job-name=hello-world-job
```

### 7. ตรวจสอบการทำงานของ CronJobs

```bash
# ดู CronJobs ทั้งหมด
kubectl get cronjobs

# ดูรายละเอียดของ CronJob
kubectl describe cronjob hello-cronjob

# ดู Jobs ที่ถูกสร้างโดย CronJob
kubectl get jobs --selector=job-name=hello-cronjob
```

### 8. สร้าง Job ที่มีการจัดการความล้มเหลว

```bash
kubectl apply -f failure-handling-job.yaml
```

**failure-handling-job.yaml**:
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: sometimes-fails
spec:
  template:
    spec:
      containers:
      - name: sometimes-fails
        image: busybox
        command: ["sh", "-c", "if [ $((RANDOM % 3)) -eq 0 ]; then echo 'Failed!'; exit 1; else echo 'Success!'; fi"]
      restartPolicy: OnFailure
  backoffLimit: 6  # จำนวนครั้งที่ยอมให้ล้มเหลวก่อนจะหยุดพยายาม
```

## การใช้งานจริง

Jobs และ CronJobs มีประโยชน์ในหลายกรณี:

1. **การประมวลผลข้อมูลแบบ Batch**:
   - การนำเข้าหรือส่งออกข้อมูลจำนวนมาก
   - การคำนวณรายงานประจำวันหรือประจำเดือน

2. **งานบำรุงรักษาระบบ**:
   - การสำรองข้อมูล (backup)
   - การล้างข้อมูลชั่วคราว (cleanup)
   - การตรวจสอบความสมบูรณ์ของข้อมูล

3. **การส่งอีเมลหรือแจ้งเตือนตามกำหนดเวลา**:
   - ส่งรายงานประจำวัน
   - แจ้งเตือนเหตุการณ์ที่กำหนด

4. **การอัพเดตข้อมูลแคช (Cache)**:
   - รีเฟรชข้อมูลแคชตามกำหนดเวลา

## การใช้ Shell Script สำหรับการจัดการทรัพยากร

เพื่อความสะดวกในการติดตั้งและทดสอบ workshop นี้ เราได้เตรียม shell script สำหรับการจัดการทรัพยากรทั้งหมด:

### 1. การติดตั้งทรัพยากรทั้งหมด (deploy.sh)

Script นี้จะสร้าง namespace และทรัพยากรทั้งหมดที่จำเป็นสำหรับ workshop นี้:

```bash
chmod +x deploy.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./deploy.sh
```

### 2. การทดสอบทรัพยากร (test.sh)

Script นี้จะทดสอบการทำงานของทรัพยากรต่างๆ ที่สร้างขึ้น:

```bash
chmod +x test.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./test.sh
```

### 3. การลบทรัพยากรทั้งหมด (cleanup.sh)

เมื่อต้องการลบทรัพยากรทั้งหมดที่สร้างขึ้นในบทเรียนนี้:

```bash
chmod +x cleanup.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./cleanup.sh
```

## เทคนิคเพิ่มเติม

1. **การกำหนดเงื่อนไขในการสร้าง Pod ใหม่** ใช้ `restartPolicy`:
   - `Never`: ไม่สร้าง Pod ใหม่แทนที่ Pod ที่ล้มเหลว
   - `OnFailure`: สร้าง Pod ใหม่เฉพาะเมื่อ Pod ล้มเหลว

2. **การจัดการความล้มเหลวซ้ำซ้อน** ใช้ `backoffLimit` เพื่อกำหนดจำนวนครั้งสูงสุดที่ Job จะพยายามทำงานใหม่เมื่อล้มเหลว

3. **การกำหนดระยะเวลาสูงสุดที่อนุญาตให้ Job ทำงาน** ใช้ `activeDeadlineSeconds`

4. **การจัดการความขัดแย้งใน CronJob** ใช้ `concurrencyPolicy`:
   - `Allow`: อนุญาตให้ Jobs ทำงานพร้อมกัน (ค่าเริ่มต้น)
   - `Forbid`: ไม่อนุญาตให้มี Job ใหม่ถ้ายังมี Job ก่อนหน้าทำงานอยู่
   - `Replace`: ยกเลิก Job ที่กำลังทำงานและสร้าง Job ใหม่แทน

## ความแตกต่างระหว่าง Jobs และ Deployments

| คุณสมบัติ | Jobs | Deployments |
|----------|------|-------------|
| จุดประสงค์ | ทำงานจนเสร็จแล้วหยุด | ทำงานตลอดเวลา ไม่มีจุดสิ้นสุด |
| การทำงานเมื่อ Pod หยุด | ขึ้นอยู่กับ completions | สร้าง Pod ใหม่ทันที |
| เหมาะสำหรับ | งานประมวลผลแบบ batch | บริการที่ต้องทำงานต่อเนื่อง |
| การจัดการเมื่อ Node ล้มเหลว | อาจต้องทำงานใหม่ | ย้าย Pod ไปยัง Node อื่น |
| Scaling | ปรับ parallelism | ปรับจำนวน replicas |

## สรุป

Jobs และ CronJobs เป็นทรัพยากรใน Kubernetes ที่เหมาะกับการประมวลผลแบบ batch และงานที่ต้องการทำงานตามกำหนดเวลา ในบทเรียนนี้เราได้เรียนรู้:

1. การสร้างและจัดการ Jobs พื้นฐาน
2. การกำหนด completions และ parallelism เพื่อควบคุมการทำงานแบบขนาน
3. การสร้าง CronJobs เพื่อทำงานตามกำหนดเวลา
4. การจัดการความล้มเหลวและการทำงานซ้ำ
5. การติดตามและตรวจสอบสถานะของ Jobs และ CronJobs

Jobs และ CronJobs เป็นเครื่องมือที่มีประสิทธิภาพสำหรับการจัดการงานประมวลผลแบบ batch ใน Kubernetes ช่วยให้สามารถทำงานที่มีจุดเริ่มต้นและสิ้นสุดได้อย่างมีประสิทธิภาพ
