# GitHub Actions สำหรับ Continuous Deployment บน Kubernetes

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | การใช้ GitHub Actions สำหรับ CI/CD Pipeline กับ Kubernetes |
| **วัตถุประสงค์** | เรียนรู้การสร้างและใช้งาน GitHub Actions เพื่อ build, test และ deploy แอปพลิเคชันไปยัง Kubernetes |
| **ระดับความยาก** | ง่าย |

ในเวิร์คช็อปนี้ เราจะเรียนรู้วิธีการใช้ GitHub Actions เพื่อสร้าง CI/CD pipeline สำหรับการ deploy แอปพลิเคชันไปยัง Kubernetes cluster โดยอัตโนมัติเมื่อมีการ push code ไปยัง repository

## สิ่งที่จะได้เรียนรู้

- พื้นฐานของ GitHub Actions และโครงสร้างของ workflow
- การสร้าง workflow สำหรับ build และ test แอปพลิเคชัน
- การสร้าง Docker image และ push ไปยัง Container Registry
- การ deploy แอปพลิเคชันไปยัง Kubernetes ด้วย GitHub Actions
- การจัดการ Kubernetes manifests ใน repository
- การใช้ GitHub Secrets เพื่อเก็บข้อมูลสำคัญ
- การทำ continuous deployment ไปยัง environment ต่างๆ

## ความเข้าใจเกี่ยวกับ GitHub Actions

GitHub Actions เป็น CI/CD platform ที่ติดตั้งมาพร้อมกับ GitHub ทำให้คุณสามารถสร้าง workflows เพื่อทำงานอัตโนมัติต่างๆ ได้ โดยมีองค์ประกอบสำคัญ ดังนี้:

1. **Workflow**: ชุดคำสั่งที่ประกอบด้วย jobs หนึ่งหรือหลาย jobs
2. **Jobs**: ชุดของ steps ที่ทำงานบน runner เดียวกัน
3. **Steps**: งานย่อยที่สามารถรันคำสั่งหรือใช้ action ได้
4. **Actions**: ชุดคำสั่งที่นำมาใช้ซ้ำได้
5. **Runner**: เซิร์ฟเวอร์ที่ทำหน้าที่รัน workflow

## ขั้นตอนการทำงาน

### 1. สร้างโครงสร้าง GitHub Repository

จัดเตรียมโครงสร้างไฟล์ใน repository ดังนี้:

```
my-k8s-app/
├── .github/
│   └── workflows/
│       └── ci-cd.yaml
├── kubernetes/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
├── src/
│   └── app.js
├── Dockerfile
├── package.json
└── README.md
```

### 2. สร้าง Workflow สำหรับ CI/CD

สร้างไฟล์ `.github/workflows/ci-cd.yaml` สำหรับ workflow:

```yaml
name: CI/CD Pipeline for Kubernetes

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  IMAGE_NAME: my-k8s-app
  IMAGE_TAG: ${{ github.sha }}

jobs:
  build-and-test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '16'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Run tests
      run: npm test
      
    - name: Build and push Docker image
      uses: docker/build-push-action@v2
      with:
        context: .
        push: ${{ github.event_name != 'pull_request' }}
        tags: ${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}
        
  deploy:
    needs: build-and-test
    if: github.event_name != 'pull_request'
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Update Kubernetes manifests
      run: |
        cd kubernetes
        kustomize edit set image ${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}=${{ secrets.DOCKER_USERNAME }}/${{ env.IMAGE_NAME }}:${{ env.IMAGE_TAG }}
        
    - name: Set up kubeconfig
      uses: azure/k8s-set-context@v1
      with:
        method: kubeconfig
        kubeconfig: ${{ secrets.KUBE_CONFIG }}
        
    - name: Deploy to Kubernetes
      run: |
        kubectl apply -k kubernetes/
        kubectl rollout status deployment/my-k8s-app
```

### 3. สร้างไฟล์ Kubernetes Manifests

สร้างไฟล์ `kubernetes/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-k8s-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-k8s-app
  template:
    metadata:
      labels:
        app: my-k8s-app
    spec:
      containers:
      - name: my-k8s-app
        image: username/my-k8s-app:latest
        ports:
        - containerPort: 3000
```

สร้างไฟล์ `kubernetes/service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-k8s-app
spec:
  selector:
    app: my-k8s-app
  ports:
  - port: 80
    targetPort: 3000
  type: ClusterIP
```

สร้างไฟล์ `kubernetes/kustomization.yaml`:

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
- deployment.yaml
- service.yaml
```

### 4. เพิ่ม GitHub Secrets

ใน repository settings > Secrets > Actions สร้าง secrets ต่อไปนี้:

1. `DOCKER_USERNAME`: Username สำหรับ Docker Hub หรือ container registry อื่น
2. `DOCKER_PASSWORD`: Password หรือ token สำหรับ container registry
3. `KUBE_CONFIG`: ไฟล์ kubeconfig ในรูปแบบ base64

### 5. ทำการ Push ไปยัง main Branch

เมื่อทำการ push code ไปยัง main branch GitHub Actions จะทำงานอัตโนมัติตาม workflow ที่กำหนด

## การใช้ Shell Script สำหรับการเตรียมทรัพยากร

เพื่อความสะดวกในการเตรียมทรัพยากรสำหรับ workshop นี้ เราได้เตรียม shell script สำหรับการจัดการทรัพยากรทั้งหมด:

### 1. การเตรียมทรัพยากรทั้งหมด (setup.sh)

Script นี้จะเตรียมโครงสร้างไฟล์และทรัพยากรทั้งหมดที่จำเป็นสำหรับ workshop นี้:

```bash
chmod +x setup.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./setup.sh
```

เมื่อรัน script นี้แล้ว จะมีการดำเนินการดังนี้:
- สร้างโครงสร้างไฟล์ตัวอย่างสำหรับโปรเจ็ค
- สร้างตัวอย่าง workflow file สำหรับ GitHub Actions
- สร้าง Kubernetes manifests พื้นฐาน
- สร้าง Dockerfile และไฟล์แอปพลิเคชันตัวอย่าง

### 2. การทดสอบ workflow (test-local.sh)

Script นี้จะจำลองการทำงานของ workflow ในเครื่อง local:

```bash
chmod +x test-local.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./test-local.sh
```

การทดสอบประกอบด้วย:
- การ build docker image แบบ local
- การทดสอบการทำงานของแอปพลิเคชัน
- การทดสอบการ apply Kubernetes manifests (โดยไม่ได้ deploy จริง)

### 3. การเก็บทรัพยากรทั้งหมด (cleanup.sh)

เมื่อต้องการลบทรัพยากรทั้งหมดที่สร้างขึ้นในการทดสอบ:

```bash
chmod +x cleanup.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./cleanup.sh
```

Script นี้จะดำเนินการ:
- ลบ docker images ที่สร้างขึ้นระหว่างการทดสอบ
- ลบไฟล์ชั่วคราวต่างๆ

## แนวทางปฏิบัติที่ดีสำหรับ GitHub Actions CI/CD

1. **แบ่ง workflow ให้เหมาะสม**: แยก workflow สำหรับ dev, staging, และ production
2. **ใช้ Branch Protection Rules**: ป้องกัน main branch ด้วย required checks
3. **จัดการ Secrets อย่างปลอดภัย**: ไม่เก็บข้อมูลสำคัญใน repository
4. **เขียน Test ให้ครอบคลุม**: ทำ Unit test และ Integration test ก่อน deploy
5. **Reuse Actions**: ใช้ community actions ที่มีอยู่แล้วแทนการเขียนเอง
6. **ใช้ Matrix Build**: ทดสอบในหลาย environment พร้อมกัน
7. **Set Timeouts**: กำหนด timeout เพื่อป้องกัน workflow ค้าง

## การประยุกต์ใช้ในสถานการณ์จริง

### 1. Multi-Environment Deployment

แยก workflow สำหรับแต่ละ environment:

```yaml
name: Deploy to Development

on:
  push:
    branches: [ develop ]

jobs:
  deploy-dev:
    # รายละเอียดการ deploy ไปยัง dev environment
```

```yaml
name: Deploy to Production

on:
  push:
    branches: [ main ]

jobs:
  deploy-prod:
    # รายละเอียดการ deploy ไปยัง production environment
```

### 2. การทำ Canary Deployment

```yaml
jobs:
  deploy-canary:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy Canary
      run: |
        kubectl apply -f kubernetes/canary/
        
    - name: Verify Canary
      run: |
        # ทดสอบ canary deployment
        
    - name: Deploy Full Rollout
      if: success()
      run: |
        kubectl apply -f kubernetes/production/
```

### 3. การทำ Automated Rollback

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy
      id: deploy
      run: kubectl apply -f kubernetes/deployment.yaml
      
    - name: Verify Deployment
      id: verify
      run: |
        # ทดสอบ deployment
        
    - name: Rollback on Failure
      if: failure() && steps.deploy.outcome == 'success'
      run: |
        kubectl rollout undo deployment/my-k8s-app
```

## สรุป

ในเวิร์คช็อปนี้ เราได้เรียนรู้:

1. วิธีการสร้าง GitHub Actions workflow สำหรับ CI/CD
2. การ build และ push Docker image ไปยัง container registry
3. การอัพเดทและ deploy Kubernetes manifests
4. การใช้ GitHub Secrets เพื่อจัดการข้อมูลสำคัญ
5. แนวทางปฏิบัติที่ดีในการทำ CI/CD กับ Kubernetes

GitHub Actions เป็นเครื่องมือที่มีประสิทธิภาพและยืดหยุ่นสำหรับการทำ CI/CD โดยเฉพาะอย่างยิ่งสำหรับโปรเจ็คที่อยู่บน GitHub อีกทั้งยังสามารถใช้งานได้ฟรีสำหรับ public repositories และมีการใช้งานฟรีบางส่วนสำหรับ private repositories ทำให้เป็นตัวเลือกที่น่าสนใจสำหรับทีมขนาดเล็กถึงขนาดกลาง
