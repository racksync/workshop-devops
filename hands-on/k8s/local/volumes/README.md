# Kubernetes Volumes Workshop

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | การใช้งาน Volumes และ PersistentVolumes ใน Kubernetes |
| **วัตถุประสงค์** | เรียนรู้การจัดการและเก็บข้อมูลอย่างถาวรใน Kubernetes โดยใช้ Volumes |
| **ระดับความยาก** | ง่าย |

ในเวิร์คช็อปนี้ เราจะเรียนรู้เกี่ยวกับการจัดการพื้นที่เก็บข้อมูลใน Kubernetes โดยใช้ Volumes ประเภทต่างๆ รวมถึงการใช้งาน PersistentVolumes สำหรับการเก็บข้อมูลอย่างถาวร

## สิ่งที่จะได้เรียนรู้

- การใช้งาน Volume พื้นฐาน (emptyDir)
- การใช้งาน hostPath Volume
- การสร้างและใช้งาน PersistentVolume (PV) และ PersistentVolumeClaim (PVC)
- การจัดการข้อมูลในแอปพลิเคชันที่ต้องการเก็บข้อมูลอย่างถาวร
- การใช้ ConfigMap และ Secret เป็น Volume

## ขั้นตอนการทำงาน

### 1. สร้าง Namespace

สร้าง Namespace เพื่อแยกทรัพยากรที่ใช้ในบทเรียนนี้:

```bash
kubectl create namespace volume-demo
kubectl config set-context --current --namespace=volume-demo
```

### 2. สร้าง Pod ด้วย emptyDir Volume

emptyDir เป็น Volume ชั่วคราวที่ถูกสร้างเมื่อ Pod เริ่มทำงานและจะถูกลบเมื่อ Pod ถูกลบ เหมาะสำหรับการแชร์ข้อมูลระหว่าง containers ใน Pod เดียวกัน

```bash
kubectl apply -f emptydir-pod.yaml
```

**emptydir-pod.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: emptydir-pod
  namespace: volume-demo
spec:
  containers:
  - name: writer
    image: busybox
    command: ["/bin/sh", "-c", "while true; do echo $(date) >> /data/output.txt; sleep 5; done"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  - name: reader
    image: busybox
    command: ["/bin/sh", "-c", "tail -f /data/output.txt"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  volumes:
  - name: shared-data
    emptyDir: {}
```

ดูผลลัพธ์จาก container reader:

```bash
kubectl logs emptydir-pod -c reader
```

### 3. สร้าง Pod ด้วย hostPath Volume

hostPath ใช้พื้นที่เก็บข้อมูลจาก Node ที่ Pod ทำงานอยู่ ข้อมูลจะยังคงอยู่แม้ Pod จะถูกลบ แต่จะหายไปถ้า Pod ถูกย้ายไปทำงานบน Node อื่น

```bash
kubectl apply -f hostpath-pod.yaml
```

**hostpath-pod.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hostpath-pod
  namespace: volume-demo
spec:
  containers:
  - name: container
    image: nginx
    volumeMounts:
    - name: html-volume
      mountPath: /usr/share/nginx/html
  volumes:
  - name: html-volume
    hostPath:
      path: /tmp/html-data
      type: DirectoryOrCreate
```

### 4. สร้าง PersistentVolume และ PersistentVolumeClaim

PersistentVolume (PV) คือทรัพยากรเก็บข้อมูลที่ถูกจัดสรรโดยผู้ดูแลระบบ ส่วน PersistentVolumeClaim (PVC) คือคำขอใช้ทรัพยากรจากผู้ใช้

```bash
kubectl apply -f persistent-volume.yaml
kubectl apply -f persistent-volume-claim.yaml
```

**persistent-volume.yaml**:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: example-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: /tmp/pv-data
```

**persistent-volume-claim.yaml**:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: example-pvc
  namespace: volume-demo
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 500Mi
```

### 5. สร้าง Pod ที่ใช้ PersistentVolumeClaim

```bash
kubectl apply -f pvc-pod.yaml
```

**pvc-pod.yaml**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pvc-pod
  namespace: volume-demo
spec:
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh", "-c", "while true; do echo $(date) >> /mnt/data/output.txt; sleep 5; done"]
    volumeMounts:
    - name: persistent-storage
      mountPath: /mnt/data
  volumes:
  - name: persistent-storage
    persistentVolumeClaim:
      claimName: example-pvc
```

### 6. สร้าง ConfigMap และ Secret สำหรับใช้เป็น Volume

```bash
kubectl apply -f config-volume.yaml
kubectl apply -f secret-volume.yaml
```

**config-volume.yaml**:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: example-config
  namespace: volume-demo
data:
  config.properties: |
    app.name=Example App
    app.version=1.0
    log.level=INFO
---
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod
  namespace: volume-demo
spec:
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh", "-c", "cat /etc/config/config.properties; sleep 3600"]
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: example-config
```

**secret-volume.yaml**:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: example-secret
  namespace: volume-demo
type: Opaque
stringData:
  username: admin
  password: mysecretpassword
---
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
  namespace: volume-demo
spec:
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh", "-c", "cat /etc/secrets/username /etc/secrets/password; sleep 3600"]
    volumeMounts:
    - name: secret-volume
      mountPath: /etc/secrets
      readOnly: true
  volumes:
  - name: secret-volume
    secret:
      secretName: example-secret
```

### 7. ทดสอบ StorageClass (เฉพาะในคลัสเตอร์ที่รองรับ)

StorageClass ช่วยให้สามารถจัดหาพื้นที่จัดเก็บข้อมูลแบบไดนามิก (dynamic provisioning) ได้โดยไม่ต้องสร้าง PV ก่อน

```bash
kubectl apply -f storage-class-example.yaml
```

**storage-class-example.yaml**:
```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: standard
provisioner: k8s.io/minikube-hostpath  # เปลี่ยนตาม provisioner ที่คลัสเตอร์ของคุณรองรับ
reclaimPolicy: Delete
volumeBindingMode: Immediate
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: dynamic-pvc
  namespace: volume-demo
spec:
  storageClassName: standard
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
  name: dynamic-pvc-pod
  namespace: volume-demo
spec:
  containers:
  - name: app
    image: nginx
    volumeMounts:
    - name: dynamic-storage
      mountPath: /usr/share/nginx/html
  volumes:
  - name: dynamic-storage
    persistentVolumeClaim:
      claimName: dynamic-pvc
```

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

## ความแตกต่างของ Volume ประเภทต่างๆ

| ประเภท | การคงอยู่ของข้อมูล | ใช้เมื่อ |
|--------|--------------|---------|
| emptyDir | ชั่วคราว (หายเมื่อ Pod ถูกลบ) | ต้องการแชร์ข้อมูลระหว่าง containers ในโปรเซส |
| hostPath | คงอยู่บน Node (หายเมื่อ Node หาย) | ต้องการเข้าถึงไฟล์ระบบของโฮสต์ |
| PersistentVolume | ถาวร (แม้ Pod จะถูกลบ) | ต้องการเก็บข้อมูลแบบถาวร เช่น ฐานข้อมูล |
| ConfigMap/Secret as Volume | ถูกจัดการโดย Kubernetes | ต้องการไฟล์คอนฟิกหรือข้อมูลลับในรูปแบบไฟล์ |

## ประโยชน์ของการใช้ PersistentVolumes

1. **ความคงทนของข้อมูล** - ข้อมูลยังคงอยู่แม้ Pod จะถูกลบหรือสร้างใหม่
2. **แยกการจัดสรรและการใช้ทรัพยากร** - ผู้ดูแลระบบจัดสรร PV และผู้ใช้สร้าง PVC
3. **รองรับหลายโครงสร้างพื้นฐาน** - รองรับการจัดเก็บข้อมูลหลายรูปแบบ เช่น NFS, cloud storage, local disk
4. **การจัดสรรแบบไดนามิก** - สามารถจัดสรรพื้นที่จัดเก็บข้อมูลแบบอัตโนมัติเมื่อมีการสร้าง PVC

## สรุป

ในเวิร์คช็อปนี้ เราได้เรียนรู้:

1. การใช้งาน Volume ประเภทต่างๆ ใน Kubernetes
2. การสร้างและใช้งาน PersistentVolume และ PersistentVolumeClaim
3. การใช้ ConfigMap และ Secret เป็น Volume
4. ข้อควรพิจารณาในการเลือกใช้ Volume แต่ละประเภท

การเลือกใช้ Volume ที่เหมาะสมเป็นส่วนสำคัญในการออกแบบแอปพลิเคชันบน Kubernetes เพื่อให้สามารถจัดการข้อมูลได้อย่างมีประสิทธิภาพและเหมาะสมกับความต้องการ
