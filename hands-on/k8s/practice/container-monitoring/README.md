# Kubernetes Container Monitoring Workshop

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | การติดตั้งและใช้งานระบบ Monitoring สำหรับ Containers บน Kubernetes |
| **วัตถุประสงค์** | เรียนรู้การติดตั้งและกำหนดค่าเครื่องมือ Monitoring พร้อมทั้งการเก็บ Metrics และการสร้าง Dashboards สำหรับ Containers บน Kubernetes |
| **ระดับความยาก** | ปานกลาง |

ในเวิร์คช็อปนี้ เราจะเรียนรู้เกี่ยวกับการติดตั้งและใช้งานระบบ Monitoring สำหรับ Containers บน Kubernetes โดยใช้ Prometheus และ Grafana ซึ่งเป็นเครื่องมือยอดนิยมในการเฝ้าติดตามและวิเคราะห์ประสิทธิภาพของแอปพลิเคชันและโครงสร้างพื้นฐานใน Kubernetes

## สิ่งที่จะได้เรียนรู้

- หลักการพื้นฐานของการ Monitoring ใน Kubernetes
- การติดตั้ง Prometheus Stack (Prometheus, Alertmanager, Node Exporter)
- การติดตั้งและกำหนดค่า Grafana สำหรับการสร้าง Visualization
- การกำหนดค่า ServiceMonitor สำหรับการเก็บ Metrics จาก Pods
- การสร้าง Custom Metrics สำหรับแอปพลิเคชัน
- การตั้งค่า Alerts และการแจ้งเตือนผ่านช่องทางต่างๆ
- การสร้าง Dashboards ที่มีประโยชน์สำหรับการติดตาม Containers
- การใช้ Prometheus Operator เพื่อจัดการระบบ Monitoring ใน Kubernetes

## ขั้นตอนการทำงาน

### 1. สร้าง Namespace

สร้าง Namespace เพื่อแยกทรัพยากรที่ใช้ในการ monitoring:

```bash
kubectl create namespace monitoring
kubectl config set-context --current --namespace=monitoring
```

### 2. ติดตั้ง Prometheus Operator ด้วย Helm

Prometheus Operator ช่วยให้การจัดการ Prometheus และ Alertmanager เป็นเรื่องง่าย:

```bash
# เพิ่ม Helm Repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# ติดตั้ง Prometheus Operator Stack
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.adminPassword=admin123 \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

### 3. ตรวจสอบการติดตั้ง

```bash
# ตรวจสอบ pods ใน namespace monitoring
kubectl get pods -n monitoring

# ตรวจสอบ services ที่ถูกสร้าง
kubectl get svc -n monitoring
```

### 4. เข้าถึง Grafana Dashboard

สร้าง port-forward เพื่อเข้าถึง Grafana:

```bash
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
```

เปิดเบราว์เซอร์ไปที่ `http://localhost:3000` แล้วล็อกอินด้วย:
- Username: admin
- Password: admin123

### 5. สร้างแอปพลิเคชันตัวอย่างพร้อม Metrics Endpoint

เราจะสร้างแอปพลิเคชันที่เปิด metrics endpoint เพื่อให้ Prometheus สามารถเก็บข้อมูลได้:

```bash
kubectl apply -f sample-app-with-metrics.yaml
```

**sample-app-with-metrics.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
  namespace: monitoring
  labels:
    app: sample-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
      - name: sample-app
        image: nginx
        ports:
        - containerPort: 80
        resources:
          requests:
            memory: "64Mi"
            cpu: "100m"
          limits:
            memory: "128Mi"
            cpu: "200m"
---
apiVersion: v1
kind: Service
metadata:
  name: sample-app
  namespace: monitoring
  labels:
    app: sample-app
spec:
  selector:
    app: sample-app
  ports:
  - port: 80
    targetPort: 80
```

### 6. กำหนดค่า ServiceMonitor

```bash
kubectl apply -f service-monitor.yaml
```

**service-monitor.yaml**:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: sample-app
  namespace: monitoring
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app: sample-app
  endpoints:
  - port: web
    path: /metrics
    interval: 15s
```

### 7. สร้าง PrometheusRule สำหรับ Alert

```bash
kubectl apply -f prometheus-rule.yaml
```

**prometheus-rule.yaml**:
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: sample-app-alerts
  namespace: monitoring
  labels:
    release: prometheus
spec:
  groups:
  - name: sample-app.rules
    rules:
    - alert: SampleAppHighCPU
      expr: avg(rate(container_cpu_usage_seconds_total{pod=~"sample-app-.*"}[5m])) * 100 > 80
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "Sample App high CPU usage"
        description: "Sample App has been using high CPU for more than 5 minutes."
```

### 8. ตั้งค่า Alertmanager

```bash
kubectl apply -f alertmanager-config.yaml
```

**alertmanager-config.yaml**:
```yaml
apiVersion: monitoring.coreos.com/v1alpha1
kind: AlertmanagerConfig
metadata:
  name: sample-alertmanager-config
  namespace: monitoring
  labels:
    release: prometheus
spec:
  route:
    receiver: 'slack'
    groupBy: ['alertname', 'namespace']
    groupWait: 30s
    groupInterval: 5m
    repeatInterval: 12h
  receivers:
  - name: 'slack'
    slackConfigs:
    - apiURL: 'https://hooks.slack.com/services/YOUR_SLACK_WEBHOOK'
      channel: '#monitoring-alerts'
      sendResolved: true
```

### 9. นำเข้า Grafana Dashboard

สร้าง Dashboard ใหม่ใน Grafana หรือนำเข้า Dashboard ที่มีอยู่แล้วจาก Grafana.com:

1. ไปที่ Grafana UI (http://localhost:3000)
2. เลือก "+" และ "Import"
3. ใส่ ID ของ Dashboard (เช่น 12740 สำหรับ Kubernetes Monitoring Dashboard)
4. เลือก Data Source เป็น Prometheus

## การใช้ Shell Script สำหรับการจัดการทรัพยากร

เพื่อความสะดวกในการติดตั้งและทดสอบ workshop นี้ เราได้เตรียม shell script สำหรับการจัดการทรัพยากรทั้งหมด:

### 1. การติดตั้งทรัพยากรทั้งหมด (deploy.sh)

Script นี้จะสร้าง namespace และทรัพยากรทั้งหมดที่จำเป็นสำหรับ workshop นี้:

```bash
chmod +x deploy.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./deploy.sh
```

เมื่อรัน script นี้แล้ว จะมีการดำเนินการดังนี้:
- สร้าง namespace `monitoring`
- ตั้งค่า context ให้ใช้งาน namespace `monitoring`
- ติดตั้ง Prometheus Operator Stack ด้วย Helm
- สร้างแอปพลิเคชันตัวอย่างพร้อม metrics
- กำหนดค่า ServiceMonitor และ PrometheusRules
- ตั้งค่า port-forward สำหรับการเข้าถึง Grafana และ Prometheus

### 2. การทดสอบทรัพยากร (test.sh)

Script นี้จะทดสอบการทำงานของระบบ monitoring:

```bash
chmod +x test.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./test.sh
```

การทดสอบประกอบด้วย:
- ตรวจสอบว่า Prometheus Operator ทำงานได้ปกติ
- ทดสอบการทำงานของ metrics collection
- ทดสอบการแสดงผลใน Grafana
- ทดสอบการสร้าง alert conditions

### 3. การลบทรัพยากรทั้งหมด (cleanup.sh)

เมื่อต้องการลบทรัพยากรทั้งหมดที่สร้างขึ้นในบทเรียนนี้:

```bash
chmod +x cleanup.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./cleanup.sh
```

Script นี้จะดำเนินการ:
- ถอนการติดตั้ง Prometheus Operator Stack
- ลบแอปพลิเคชันตัวอย่าง
- ลบ ServiceMonitors และ PrometheusRules ทั้งหมด
- ลบ namespace `monitoring`
- ตั้งค่า context กลับไปที่ namespace `default`

## Best Practices สำหรับ Container Monitoring

1. **เก็บ Metrics ที่สำคัญ**: 
   - CPU และ Memory Usage
   - Network I/O
   - Disk I/O
   - Request Rate และ Latency

2. **ตั้งค่า Alert ที่เหมาะสม**:
   - หลีกเลี่ยง Alert Fatigue
   - ตั้งค่า threshold ที่มีความหมายกับระบบของคุณ
   - ใช้การแจ้งเตือนแบบเป็นลำดับขั้น (severity levels)

3. **สร้าง Dashboard ที่มีประสิทธิภาพ**:
   - แสดงข้อมูลที่สำคัญที่สุดเป็นอันดับแรก
   - จัดกลุ่ม metrics ที่เกี่ยวข้องกันไว้ด้วยกัน
   - ใช้สีและการแสดงผลที่สื่อความหมายได้ชัดเจน

4. **การ Monitor แอปพลิเคชันเฉพาะ**:
   - ใช้ Prometheus client libraries ในการ instrument code
   - วัด business metrics ที่สำคัญ
   - สร้าง custom metrics ที่สะท้อนสุขภาพของแอปพลิเคชัน

## สรุป

ในเวิร์คช็อปนี้ เราได้เรียนรู้การติดตั้งและใช้งานระบบ Monitoring สำหรับ Containers บน Kubernetes โดยใช้ Prometheus และ Grafana ซึ่งเป็นเครื่องมือยอดนิยมในวงการ DevOps และ SRE

การมีระบบ monitoring ที่ดีช่วยให้:
1. ตรวจจับปัญหาได้ก่อนที่จะส่งผลกระทบต่อผู้ใช้
2. เข้าใจพฤติกรรมของระบบและแอปพลิเคชัน
3. วางแผนการขยายระบบและทรัพยากร
4. ระบุจุดที่มีปัญหาและแก้ไขได้อย่างรวดเร็ว

การนำความรู้นี้ไปประยุกต์ใช้จะช่วยให้การบริหารจัดการระบบ Kubernetes มีประสิทธิภาพและความน่าเชื่อถือมากขึ้น
