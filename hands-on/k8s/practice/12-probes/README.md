# Kubernetes Health Probes Workshop

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | การใช้ Health Probes (Liveness, Readiness และ Startup) ใน Kubernetes |
| **วัตถุประสงค์** | เรียนรู้การตั้งค่า และใช้งาน Health Probes เพื่อเพิ่มความเสถียรและความพร้อมใช้งานของแอปพลิเคชัน |
| **ระดับความยาก** | ปานกลาง |

ในเวิร์คช็อปนี้ เราจะเรียนรู้เกี่ยวกับ Health Probes ใน Kubernetes ซึ่งช่วยให้ระบบสามารถตรวจสอบและจัดการสถานะของแอปพลิเคชันได้อย่างอัตโนมัติ ทำให้แอปพลิเคชันมีความเสถียรและพร้อมใช้งานมากขึ้น

## สิ่งที่จะได้เรียนรู้

- เข้าใจความแตกต่างระหว่าง Liveness, Readiness และ Startup Probes
- การกำหนดค่า Health Probes แบบต่างๆ (HTTP, TCP, Exec)
- การทดสอบและสังเกตพฤติกรรมของ Pod เมื่อ Probe ล้มเหลว
- แนวปฏิบัติที่ดีในการตั้งค่า Health Probes
- การแก้ไขปัญหาที่เกิดขึ้นบ่อยกับ Health Probes

## ขั้นตอนการทำงาน

### 1. สร้าง Namespace

สร้าง Namespace เพื่อแยกทรัพยากรที่ใช้ในบทเรียนนี้:

```bash
kubectl create namespace probes-demo
kubectl config set-context --current --namespace=probes-demo
```

### 2. สร้าง Pod ด้วย Liveness Probe

Liveness Probe ใช้ตรวจสอบว่าแอปพลิเคชันยังทำงานอยู่หรือไม่ หากล้มเหลว Kubernetes จะรีสตาร์ท container:

```bash
kubectl apply -f liveness-http-probe.yaml
```

**liveness-http-probe.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness-http
  namespace: probes-demo
spec:
  containers:
  - name: app
    image: k8s.gcr.io/liveness
    ports:
    - containerPort: 8080
    livenessProbe:
      httpGet:
        path: /healthz
        port: 8080
      initialDelaySeconds: 3
      periodSeconds: 3
```

### 3. สร้าง Pod ด้วย Readiness Probe

Readiness Probe ใช้ตรวจสอบว่าแอปพลิเคชันพร้อมรับ traffic หรือไม่:

```bash
kubectl apply -f readiness-http-probe.yaml
```

**readiness-http-probe.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: readiness-http
  namespace: probes-demo
spec:
  containers:
  - name: app
    image: nginx
    ports:
    - containerPort: 80
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
```

### 4. สร้าง Pod ด้วย Startup Probe

Startup Probe ช่วยในกรณีแอปพลิเคชันเริ่มต้นช้า โดยจะป้องกันไม่ให้ Liveness Probe ทำงานจนกว่าแอปพลิเคชันจะพร้อม:

```bash
kubectl apply -f startup-probe.yaml
```

**startup-probe.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: startup-probe
  namespace: probes-demo
spec:
  containers:
  - name: app
    image: nginx
    ports:
    - containerPort: 80
    startupProbe:
      httpGet:
        path: /
        port: 80
      failureThreshold: 30
      periodSeconds: 10
    livenessProbe:
      httpGet:
        path: /
        port: 80
      periodSeconds: 10
```

### 5. สร้าง Pod ด้วย Exec Probe

นอกจาก HTTP ยังสามารถใช้การรันคำสั่งเพื่อตรวจสอบสถานะได้:

```bash
kubectl apply -f exec-probe.yaml
```

**exec-probe.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: exec-probe
  namespace: probes-demo
spec:
  containers:
  - name: app
    image: busybox
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy; sleep 30; rm -f /tmp/healthy; sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5
```

### 6. สร้าง Pod ด้วย TCP Socket Probe

สามารถตรวจสอบการเชื่อมต่อ TCP ได้:

```bash
kubectl apply -f tcp-probe.yaml
```

**tcp-probe.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: tcp-probe
  namespace: probes-demo
spec:
  containers:
  - name: app
    image: nginx
    ports:
    - containerPort: 80
    livenessProbe:
      tcpSocket:
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
    readinessProbe:
      tcpSocket:
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 10
```

### 7. สร้าง Deployment ที่ใช้หลาย Probe

ในการใช้งานจริง เราจะใช้ Deployment และกำหนดค่า Probes ทั้งหมดอย่างเหมาะสม:

```bash
kubectl apply -f deployment-with-probes.yaml
```

**deployment-with-probes.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-with-probes
  namespace: probes-demo
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
        image: nginx
        ports:
        - containerPort: 80
        startupProbe:
          httpGet:
            path: /
            port: 80
          failureThreshold: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /
            port: 80
          initialDelaySeconds: 15
          periodSeconds: 20
```

### 8. ตรวจสอบสถานะของ Probes

```bash
# ดูสถานะ Pod ที่มี Probes
kubectl get pods

# ดูรายละเอียด Pod และ Events ที่เกี่ยวข้อง
kubectl describe pod liveness-http

# ดู logs ของ container
kubectl logs liveness-http
```

### 9. จำลองการล้มเหลวของ Probe

```bash
# สร้าง Pod ที่จะล้มเหลวหลังจากเวลาผ่านไประยะหนึ่ง
kubectl apply -f failing-probe.yaml
```

**failing-probe.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: failing-probe
  namespace: probes-demo
spec:
  containers:
  - name: app
    image: nginx
    command:
    - /bin/sh
    - -c
    - "sleep 30; echo 'Simulating failure'; mv /usr/share/nginx/html/index.html /usr/share/nginx/html/index.html.backup; sleep 600"
    ports:
    - containerPort: 80
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 5
```

## ความแตกต่างระหว่าง Probes

| ประเภท | วัตถุประสงค์ | ผลเมื่อล้มเหลว | ใช้เมื่อ |
|--------|------------|---------------|--------|
| Liveness | ตรวจสอบว่าแอปพลิเคชันทำงานหรือไม่ | รีสตาร์ท container | แอปพลิเคชันอาจค้าง/ทำงานผิดพลาดและต้องรีสตาร์ท |
| Readiness | ตรวจสอบว่าแอปพลิเคชันพร้อมรับ traffic หรือไม่ | หยุดส่ง traffic ไปยัง Pod | แอปพลิเคชันอาจไม่พร้อมชั่วคราว เช่น โหลดข้อมูล |
| Startup | ตรวจสอบว่าแอปพลิเคชันเริ่มต้นเสร็จหรือไม่ | ยังไม่เริ่ม Liveness Probe | แอปพลิเคชันใช้เวลานานในการเริ่มต้น |

## วิธีการตรวจสอบ (Probes Handler Types)

1. **HTTP GET**: ส่ง HTTP request ไปยังเส้นทางที่กำหนด ถ้าได้รับ status code 2xx หรือ 3xx ถือว่าสำเร็จ
2. **TCP Socket**: พยายามสร้าง TCP connection ไปยัง port ที่กำหนด ถ้าเชื่อมต่อได้ถือว่าสำเร็จ
3. **Exec**: รันคำสั่งใน container ถ้า exit code เป็น 0 ถือว่าสำเร็จ

## พารามิเตอร์สำคัญในการตั้งค่า Probes

- **initialDelaySeconds**: เวลาที่รอก่อนเริ่มตรวจสอบ Probe หลังจาก container เริ่มต้น
- **periodSeconds**: ความถี่ในการตรวจสอบ
- **timeoutSeconds**: เวลาที่รอให้ Probe ตอบกลับ
- **successThreshold**: จำนวนครั้งที่ต้องผ่านติดต่อกันหลังจากล้มเหลว จึงจะถือว่าสำเร็จ
- **failureThreshold**: จำนวนครั้งที่ล้มเหลวติดต่อกันก่อนที่จะดำเนินการ (รีสตาร์ทหรือไม่ส่ง traffic)

## การใช้ Shell Script สำหรับการจัดการทรัพยากร

เพื่อความสะดวกในการติดตั้งและทดสอบ workshop นี้ เราได้เตรียม shell script สำหรับการจัดการทรัพยากรทั้งหมด:

### 1. การติดตั้งทรัพยากรทั้งหมด (deploy.sh)

Script นี้จะสร้าง namespace และทรัพยากรทั้งหมดที่จำเป็นสำหรับ workshop นี้:

```bash
chmod +x deploy.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./deploy.sh
```

เมื่อรัน script นี้แล้ว จะมีการดำเนินการดังนี้:
- สร้าง namespace `probes-demo`
- ตั้งค่า context ให้ใช้งาน namespace `probes-demo`
- สร้าง Pod ตัวอย่างทั้งหมดที่มี Probes แบบต่างๆ
- สร้าง Deployment ตัวอย่างที่มีการกำหนด Probes

### 2. การทดสอบทรัพยากร (test.sh)

Script นี้จะทดสอบการทำงานของทรัพยากรต่างๆ ที่สร้างขึ้น:

```bash
chmod +x test.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./test.sh
```

การทดสอบประกอบด้วย:
- ตรวจสอบว่า Pod ที่มี Probes ทำงานได้ปกติ
- จำลองการล้มเหลวของ Probe และสังเกตพฤติกรรม
- ตรวจสอบสถานะของ Pod และ Events ที่เกิดขึ้น

### 3. การลบทรัพยากรทั้งหมด (cleanup.sh)

เมื่อต้องการลบทรัพยากรทั้งหมดที่สร้างขึ้นในบทเรียนนี้:

```bash
chmod +x cleanup.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./cleanup.sh
```

Script นี้จะดำเนินการ:
- ลบ Pod และ Deployment ทั้งหมดที่สร้างขึ้น
- ลบ namespace `probes-demo`
- ตั้งค่า context กลับไปที่ namespace `default`

## แนวปฏิบัติที่ดีในการใช้ Health Probes

1. **ใช้ Probe ให้ตรงกับวัตถุประสงค์**:
   - Liveness: ตรวจสอบว่าแอปพลิเคชันทำงานถูกต้องหรือไม่
   - Readiness: ตรวจสอบว่าแอปพลิเคชันพร้อมรับ traffic หรือไม่
   - Startup: ใช้กับแอปพลิเคชันที่เริ่มต้นช้า

2. **เลือก endpoint ที่เหมาะสม**:
   - Liveness: ควรเป็นส่วนที่ตรวจสอบการทำงานพื้นฐาน (ไม่ควรตรวจสอบการเชื่อมต่อกับบริการภายนอก)
   - Readiness: ควรรวมการตรวจสอบการเชื่อมต่อกับบริการที่จำเป็น

3. **ตั้งค่า timeout อย่างเหมาะสม**:
   - timeout ไม่ควรนานเกินไป เพื่อให้ระบบตอบสนองต่อความล้มเหลวได้รวดเร็ว
   - แต่ก็ไม่ควรสั้นเกินไปจนทำให้เกิด false negatives

4. **กำหนด initialDelaySeconds ให้เหมาะสม**:
   - ควรให้เวลาเพียงพอสำหรับแอปพลิเคชันในการเริ่มต้น
   - หากไม่แน่ใจ ให้ใช้ Startup Probe

5. **ทำให้ Probe มีประสิทธิภาพและเบา**:
   - Probe ไม่ควรใช้ทรัพยากรมากเกินไป
   - หลีกเลี่ยงการเรียก API ภายนอกใน Liveness Probe

## ปัญหาที่พบบ่อยและวิธีแก้ไข

1. **Pod รีสตาร์ทต่อเนื่อง (CrashLoopBackOff)**:
   - ตรวจสอบ livenessProbe ว่าเหมาะสมหรือไม่
   - เพิ่ม initialDelaySeconds หรือใช้ startupProbe

2. **Pod ไม่รับ traffic แม้จะทำงานปกติ**:
   - ตรวจสอบว่า readinessProbe ล้มเหลวหรือไม่
   - ตรวจสอบ endpoint ที่ใช้ใน readinessProbe

3. **Probe timeout บ่อยเกินไป**:
   - เพิ่ม timeoutSeconds
   - ตรวจสอบว่า endpoint ที่ใช้ทำงานเร็วพอหรือไม่

## สรุป

ในเวิร์คช็อปนี้ เราได้เรียนรู้:

1. ความแตกต่างและวัตถุประสงค์ของ Liveness, Readiness และ Startup Probes
2. วิธีการกำหนดค่า Probes ประเภทต่างๆ (HTTP, TCP, Exec)
3. พารามิเตอร์สำคัญในการตั้งค่า Probes และผลกระทบ
4. แนวปฏิบัติที่ดีในการใช้ Health Probes
5. วิธีการแก้ไขปัญหาที่พบบ่อย

การใช้ Health Probes อย่างเหมาะสมช่วยเพิ่มความเสถียรและความพร้อมใช้งานของแอปพลิเคชันบน Kubernetes โดยอนุญาตให้ระบบจัดการกับความล้มเหลวได้อย่างอัตโนมัติ
