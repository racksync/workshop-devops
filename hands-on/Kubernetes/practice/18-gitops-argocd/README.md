# GitOps Continuous Deployment Pipeline with ArgoCD

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | การสร้าง GitOps Continuous Deployment Pipeline ด้วย ArgoCD บน Kubernetes |
| **วัตถุประสงค์** | เรียนรู้การออกแบบและสร้างระบบ GitOps CD Pipeline โดยใช้ ArgoCD เพื่อจัดการการ deploy แอปพลิเคชันบน Kubernetes แบบอัตโนมัติ |
| **ระดับความยาก** | ยากมาก |

ในเวิร์คช็อปนี้ เราจะเรียนรู้เกี่ยวกับแนวคิด GitOps และการสร้างระบบ Continuous Deployment Pipeline บน Kubernetes โดยใช้ ArgoCD เพื่อจัดการการ deploy แอปพลิเคชันแบบอัตโนมัติ ซึ่งเป็นวิธีการที่ทำให้การส่งมอบซอฟต์แวร์มีความรวดเร็ว ปลอดภัย และสามารถย้อนกลับได้ง่าย

## สิ่งที่จะได้เรียนรู้

- หลักการของ GitOps และความสำคัญในระบบ Kubernetes
- การตั้งค่าและติดตั้ง ArgoCD บน Kubernetes Cluster
- การออกแบบและสร้าง Repository Structure สำหรับ GitOps
- การจัดการ Environments ต่างๆ (Development, Staging, Production) ด้วย Kustomize
- การใช้ Helm Chart ร่วมกับ ArgoCD
- การทำ Progressive Delivery ด้วย Argo Rollouts
- การสร้างระบบ Continuous Integration ที่ทำงานร่วมกับ GitOps
- การตั้งค่า Webhooks และระบบ Automation
- การทำ Policy Enforcement และ Security ในกระบวนการ GitOps
- การออกแบบและจัดการ Multi-cluster GitOps Deployment
- การทำ Observability และ Monitoring สำหรับ GitOps Pipeline

## สถาปัตยกรรมของระบบ

ระบบ GitOps CD Pipeline ที่เราจะสร้างประกอบด้วยองค์ประกอบหลัก ดังนี้:

1. **Source Code Repository**: เก็บ application source code
2. **Configuration Repository**: เก็บ Kubernetes manifests และการตั้งค่าของแอปพลิเคชัน
3. **CI Pipeline**: ทำหน้าที่สร้าง container images และอัปเดต configuration repository
4. **ArgoCD**: ตรวจสอบและ sync สถานะของคลัสเตอร์ให้ตรงกับ configuration repository
5. **Kubernetes Clusters**: สภาพแวดล้อมที่รันแอปพลิเคชัน
6. **Monitoring & Alerting**: ระบบติดตามและแจ้งเตือนสำหรับ deployment process

## ขั้นตอนการทำงาน

### 1. การตั้งค่า Kubernetes Cluster

เริ่มจากการตั้งค่า Kubernetes Cluster สำหรับการทดลอง:

```bash
# สร้าง namespace สำหรับ ArgoCD
kubectl create namespace argocd
kubectl config set-context --current --namespace=argocd
```

### 2. การติดตั้ง ArgoCD

ติดตั้ง ArgoCD ลงบน Kubernetes cluster:

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

รอจนกว่า ArgoCD pods จะพร้อม:

```bash
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=300s
```

### 3. การตั้งค่า Port Forward เพื่อเข้าถึง ArgoCD UI

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

หลังจากรันคำสั่งนี้ คุณสามารถเข้าถึง ArgoCD UI ได้ที่ `https://localhost:8080`

### 4. การรับ Admin Password

```bash
# สำหรับ ArgoCD v1.8 ขึ้นไป
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

# สำหรับ ArgoCD เวอร์ชันเก่ากว่า
kubectl -n argocd get pods -l app.kubernetes.io/name=argocd-server -o jsonpath='{.items[0].metadata.name}'
```

### 5. การสร้างโครงสร้าง Git Repository สำหรับ GitOps

สร้างโครงสร้างไฟล์สำหรับ GitOps repository:

```
gitops-config/
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
├── overlays/
│   ├── dev/
│   │   └── kustomization.yaml
│   ├── staging/
│   │   └── kustomization.yaml
│   └── prod/
│       └── kustomization.yaml
├── apps/
│   ├── app1/
│   │   └── ...
│   └── app2/
│       └── ...
└── clusters/
    ├── cluster1/
    │   └── ...
    └── cluster2/
        └── ...
```

### 6. การสร้าง Application Manifests ด้วย Kustomize

**base/deployment.yaml**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
spec:
  replicas: 1
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
        image: nginx:1.19
        ports:
        - containerPort: 80
```

**base/service.yaml**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: sample-app
spec:
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: sample-app
```

**base/kustomization.yaml**:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
```

**overlays/dev/kustomization.yaml**:
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- ../../base
namePrefix: dev-
namespace: development
patchesStrategicMerge:
- deployment-patch.yaml
```

### 7. การกำหนดค่า ArgoCD Application

สร้างไฟล์ application manifest สำหรับ ArgoCD:

**argocd-app.yaml**:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: sample-app-dev
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/yourusername/gitops-config.git
    targetRevision: HEAD
    path: overlays/dev
  destination:
    server: https://kubernetes.default.svc
    namespace: development
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
```

นำ application manifest ไปใช้:

```bash
kubectl apply -f argocd-app.yaml
```

### 8. การตั้งค่า Progressive Delivery ด้วย Argo Rollouts

ติดตั้ง Argo Rollouts:

```bash
kubectl create namespace argo-rollouts
kubectl apply -n argo-rollouts -f https://github.com/argoproj/argo-rollouts/releases/latest/download/install.yaml
```

สร้าง Rollout manifest:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Rollout
metadata:
  name: sample-app
spec:
  replicas: 3
  strategy:
    canary:
      steps:
      - setWeight: 20
      - pause: {duration: 1m}
      - setWeight: 40
      - pause: {duration: 1m}
      - setWeight: 60
      - pause: {duration: 1m}
      - setWeight: 80
      - pause: {duration: 1m}
  revisionHistoryLimit: 2
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
        image: nginx:1.19
        ports:
        - containerPort: 80
```

### 9. การตั้งค่า CI Pipeline ที่ทำงานร่วมกับ GitOps

สร้าง GitHub Actions workflow สำหรับการ build และ update configuration:

**.github/workflows/ci.yaml**:
```yaml
name: Build and Update Config
on:
  push:
    branches: [ main ]
    paths:
    - 'src/**'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Build and Push Docker Image
      uses: docker/build-push-action@v2
      with:
        context: ./src
        push: true
        tags: yourusername/sample-app:${{ github.sha }}
    
    - name: Checkout config repo
      uses: actions/checkout@v2
      with:
        repository: yourusername/gitops-config
        token: ${{ secrets.GH_PAT }}
        path: gitops-config
    
    - name: Update Image Tag
      run: |
        cd gitops-config
        kustomize edit set image yourusername/sample-app=yourusername/sample-app:${{ github.sha }}
        git commit -am "Update image tag to ${{ github.sha }}"
        git push
```

### 10. การตั้งค่า Multi-Cluster Deployment

สร้างโครงสร้างสำหรับ multi-cluster:

**clusters/cluster1/apps.yaml**:
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: apps-cluster1
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/yourusername/gitops-config.git
    targetRevision: HEAD
    path: clusters/cluster1
  destination:
    server: https://kubernetes.cluster1.example.com
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## การใช้ Shell Script สำหรับการจัดการทรัพยากร

เพื่อความสะดวกในการติดตั้งและทดสอบ workshop นี้ เราได้เตรียม shell script สำหรับการจัดการทรัพยากรทั้งหมด:

### 1. การติดตั้งทรัพยากรทั้งหมด (deploy.sh)

Script นี้จะติดตั้งองค์ประกอบทั้งหมดของระบบ GitOps:

```bash
chmod +x deploy.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./deploy.sh
```

เมื่อรัน script นี้แล้ว จะมีการดำเนินการดังนี้:
- สร้าง namespace `argocd`
- ติดตั้ง ArgoCD และองค์ประกอบที่เกี่ยวข้อง
- สร้าง namespace สำหรับแอปพลิเคชันตัวอย่าง
- สร้าง secret สำหรับการเชื่อมต่อกับ git repository
- กำหนดค่า ArgoCD application เพื่อ deploy ตัวอย่างแอปพลิเคชัน
- ติดตั้ง Argo Rollouts (ถ้าเลือก)

### 2. การทดสอบทรัพยากร (test.sh)

Script นี้จะทดสอบการทำงานของระบบ GitOps:

```bash
chmod +x test.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./test.sh
```

การทดสอบประกอบด้วย:
- ตรวจสอบการทำงานของ ArgoCD
- ทดสอบการ sync แอปพลิเคชัน
- จำลองการเปลี่ยนแปลงใน git repository และดูผลลัพธ์
- ทดสอบการ rollback
- ทดสอบคุณสมบัติ progressive delivery (ถ้ามี)

### 3. การลบทรัพยากรทั้งหมด (cleanup.sh)

เมื่อต้องการลบทรัพยากรทั้งหมดที่สร้างขึ้นในบทเรียนนี้:

```bash
chmod +x cleanup.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./cleanup.sh
```

Script นี้จะดำเนินการ:
- ลบ application ทั้งหมดที่สร้างขึ้นใน ArgoCD
- ลบ namespace สำหรับแอปพลิเคชัน
- ลบ ArgoCD และองค์ประกอบที่เกี่ยวข้อง
- ลบ namespace `argocd`
- ตั้งค่า context กลับไปที่ namespace `default`

## แนวทางปฏิบัติที่ดีในการทำ GitOps

1. **Infrastructure as Code (IaC)** - เก็บการตั้งค่าทั้งหมดเป็น code ใน git repository
2. **Declarative Definitions** - กำหนดสถานะที่ต้องการของระบบ ไม่ใช่ขั้นตอนการทำงาน
3. **Single Source of Truth** - git repository เป็นแหล่งข้อมูลเดียวที่เชื่อถือได้
4. **การแยก Responsibility** - แยกการพัฒนา การสร้าง image และการ deploy ออกจากกัน
5. **Automation** - ทำให้ทุกขั้นตอนเป็นอัตโนมัติมากที่สุด
6. **ตรวจสอบและ verify ได้** - ทุกการเปลี่ยนแปลงมี audit trail และสามารถตรวจสอบได้
7. **Immutable Infrastructure** - ไม่แก้ไขระบบที่ใช้งานอยู่โดยตรง แต่สร้างใหม่แทน

## ความท้าทายและวิธีแก้ไขปัญหา

1. **Secrets Management**
   - ใช้ sealed-secrets, Vault, หรือ SOPS ในการจัดการ secrets
   - ไม่เก็บ credentials ที่ไม่ได้เข้ารหัสใน git

2. **การจัดการ Rollbacks**
   - ทดสอบการ rollback เป็นส่วนหนึ่งของ CI/CD pipeline
   - ใช้ history และ versioning ใน git อย่างเหมาะสม

3. **การจัดการ Drift**
   - ตั้งค่า ArgoCD ให้ตรวจสอบและแก้ไข drift ด้วย selfHeal
   - ตั้งค่าระบบแจ้งเตือนเมื่อเกิด drift

4. **การกำหนดสิทธิ์และความปลอดภัย**
   - ใช้ RBAC ทั้งใน git repository และ ArgoCD
   - แยกสิทธิ์ในการ deploy ระหว่างสภาพแวดล้อมต่างๆ

## การประยุกต์ใช้ในสถานการณ์จริง

1. **Multi-environment Management**
   - ใช้ directory structure ที่ชัดเจนสำหรับแต่ละ environment
   - ใช้ Kustomize หรือ Helm เพื่อจัดการความแตกต่างระหว่าง environments

2. **Blue-Green Deployments**
   - ใช้ ArgoCD Sync Waves และ Hooks เพื่อควบคุมลำดับการ deploy
   - เตรียม rollback plan สำหรับกรณีที่มีปัญหา

3. **การทำ Monitoring และ Observability**
   - ติดตั้งระบบ monitoring ด้วย GitOps เช่นเดียวกัน
   - สร้าง dashboards เพื่อติดตามการ deploy และสถานะของแอปพลิเคชัน

## สรุป

ในเวิร์คช็อปนี้ เราได้เรียนรู้การสร้าง GitOps Continuous Deployment Pipeline ด้วย ArgoCD บน Kubernetes ซึ่งประกอบด้วย:

1. การติดตั้งและตั้งค่า ArgoCD
2. การออกแบบโครงสร้าง repository ที่เหมาะสมสำหรับ GitOps
3. การจัดการ applications ใน multiple environments
4. การทำ progressive delivery ด้วย Argo Rollouts
5. การบูรณาการ CI pipeline กับ GitOps workflow
6. การจัดการ multiple clusters
7. แนวทางปฏิบัติที่ดีและการแก้ไขปัญหาที่อาจพบ

การนำ GitOps มาใช้จะช่วยให้การส่งมอบซอฟต์แวร์มีความรวดเร็ว เชื่อถือได้ และสามารถตรวจสอบได้มากขึ้น ทำให้การบริหารจัดการ infrastructure และแอปพลิเคชันบน Kubernetes มีประสิทธิภาพสูงขึ้น
