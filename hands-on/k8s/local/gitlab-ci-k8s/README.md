# GitLab CI สำหรับ Continuous Deployment บน Kubernetes

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | การใช้ GitLab CI/CD สำหรับ Pipeline กับ Kubernetes |
| **วัตถุประสงค์** | เรียนรู้การสร้างและใช้งาน GitLab CI/CD เพื่อ build, test และ deploy แอปพลิเคชันไปยัง Kubernetes |
| **ระดับความยาก** | ง่าย |

ในเวิร์คช็อปนี้ เราจะเรียนรู้วิธีการใช้ GitLab CI/CD เพื่อสร้าง pipeline สำหรับการ deploy แอปพลิเคชันไปยัง Kubernetes cluster โดยอัตโนมัติเมื่อมีการ push code ไปยัง repository

## สิ่งที่จะได้เรียนรู้

- พื้นฐานของ GitLab CI/CD และโครงสร้างของไฟล์ `.gitlab-ci.yml`
- การสร้าง pipeline สำหรับ build และ test แอปพลิเคชัน
- การสร้าง Docker image และ push ไปยัง GitLab Container Registry
- การ deploy แอปพลิเคชันไปยัง Kubernetes ด้วย GitLab CI/CD
- การใช้ GitLab Kubernetes Agent สำหรับ deployment
- การใช้ GitLab Variables และ Secrets เพื่อเก็บข้อมูลสำคัญ
- การทำ continuous deployment ไปยัง environment ต่างๆ

## ความเข้าใจเกี่ยวกับ GitLab CI/CD

GitLab CI/CD เป็นระบบ Continuous Integration และ Deployment ที่มาพร้อมกับ GitLab ทำให้คุณสามารถสร้าง pipeline เพื่อทำงานอัตโนมัติต่างๆ ได้ โดยมีองค์ประกอบสำคัญ ดังนี้:

1. **Pipeline**: ชุดของ stages และ jobs ที่ทำงานตามลำดับ
2. **Stages**: กลุ่มของ jobs ที่ทำงานในลำดับเดียวกัน
3. **Jobs**: งานที่ต้องทำใน pipeline
4. **Runners**: เซิร์ฟเวอร์ที่ทำหน้าที่รัน jobs
5. **Variables**: ตัวแปรที่เก็บค่าสำหรับใช้ใน pipeline

## ขั้นตอนการทำงาน

### 1. สร้างโครงสร้าง GitLab Repository

จัดเตรียมโครงสร้างไฟล์ใน repository ดังนี้:

```
my-k8s-app/
├── .gitlab-ci.yml
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

### 2. สร้างไฟล์ `.gitlab-ci.yml` สำหรับ CI/CD

สร้างไฟล์ `.gitlab-ci.yml` สำหรับ pipeline:

```yaml
stages:
  - build
  - test
  - deploy

variables:
  IMAGE_NAME: $CI_REGISTRY_IMAGE/$CI_COMMIT_REF_SLUG
  IMAGE_TAG: $CI_COMMIT_SHA

build:
  stage: build
  image: node:16-alpine
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/

test:
  stage: test
  image: node:16-alpine
  script:
    - npm ci
    - npm test

build-docker:
  stage: build
  image: docker:20.10.16
  services:
    - docker:20.10.16-dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build -t $IMAGE_NAME:$IMAGE_TAG .
    - docker push $IMAGE_NAME:$IMAGE_TAG
  rules:
    - if: $CI_COMMIT_BRANCH == "main"

deploy-dev:
  stage: deploy
  image: 
    name: bitnami/kubectl:latest
    entrypoint: ['']
  script:
    - echo "Deploying to development environment"
    - sed -i "s|image:.*|image: $IMAGE_NAME:$IMAGE_TAG|" kubernetes/deployment.yaml
    - kubectl apply -f kubernetes/deployment.yaml
    - kubectl apply -f kubernetes/service.yaml
    - kubectl rollout status deployment/my-k8s-app -n default
  environment:
    name: development
  variables:
    KUBECONFIG: $KUBE_CONFIG_DEV
  rules:
    - if: $CI_COMMIT_BRANCH == "develop"

deploy-prod:
  stage: deploy
  image: 
    name: bitnami/kubectl:latest
    entrypoint: ['']
  script:
    - echo "Deploying to production environment"
    - sed -i "s|image:.*|image: $IMAGE_NAME:$IMAGE_TAG|" kubernetes/deployment.yaml
    - kubectl apply -f kubernetes/deployment.yaml
    - kubectl apply -f kubernetes/service.yaml
    - kubectl rollout status deployment/my-k8s-app -n default
  environment:
    name: production
  variables:
    KUBECONFIG: $KUBE_CONFIG_PROD
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
  when: manual
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
        image: $IMAGE_NAME:$IMAGE_TAG
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

### 4. เพิ่ม GitLab CI/CD Variables

ใน GitLab repository เลือก Settings > CI/CD > Variables และเพิ่ม variables ต่อไปนี้:

1. `KUBE_CONFIG_DEV`: ไฟล์ kubeconfig สำหรับ development environment (ตั้งเป็น Protected และ Masked)
2. `KUBE_CONFIG_PROD`: ไฟล์ kubeconfig สำหรับ production environment (ตั้งเป็น Protected และ Masked)

### 5. ตั้งค่า GitLab Kubernetes Agent (ทางเลือก)

สำหรับความปลอดภัยที่สูงขึ้น คุณสามารถใช้ GitLab Kubernetes Agent แทนการใช้ kubeconfig ได้:

1. สร้างไฟล์ `.gitlab/agents/my-agent/config.yaml`:

```yaml
ci_access:
  projects:
    - id: <your-project-path>
```

2. ลงทะเบียน Agent ใน GitLab:
   - ไปที่ Infrastructure > Kubernetes clusters
   - เลือก "Connect a cluster" และเลือก "GitLab Agent"
   - เลือก Agent "my-agent"

3. ติดตั้ง Agent ใน Kubernetes cluster:
   - ทำตามคำแนะนำในหน้า Agent configuration

### 6. ทำการ Push ไปยัง Repository

หลังจาก push code ไปยัง repository pipeline จะทำงานอัตโนมัติตามที่กำหนดไว้ใน `.gitlab-ci.yml`

## การใช้ Shell Script สำหรับการจัดการทรัพยากร

เพื่อความสะดวกในการติดตั้งและทดสอบ workshop นี้ เราได้เตรียม shell script สำหรับการจัดการทรัพยากรทั้งหมด:

### 1. การติดตั้งทรัพยากรทั้งหมด (deploy.sh)

Script นี้จะสร้าง namespace และทรัพยากรทั้งหมดที่จำเป็นสำหรับ workshop นี้:

```bash
chmod +x deploy.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./deploy.sh
```

เมื่อรัน script นี้แล้ว จะมีการดำเนินการดังนี้:
- สร้าง namespace `gitlab-demo`
- ตั้งค่า context ให้ใช้งาน namespace `gitlab-demo`
- สร้างโครงสร้างไฟล์ตัวอย่างสำหรับโปรเจ็ค
- สร้าง Kubernetes manifests พื้นฐาน
- สร้าง Dockerfile และไฟล์แอปพลิเคชันตัวอย่าง

### 2. การทดสอบทรัพยากร (test.sh)

Script นี้จะทดสอบการทำงานของทรัพยากรต่างๆ ที่สร้างขึ้น:

```bash
chmod +x test.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./test.sh
```

การทดสอบประกอบด้วย:
- การ build docker image แบบ local
- การทดสอบการทำงานของแอปพลิเคชัน
- การทดสอบการ apply Kubernetes manifests (โดยไม่ได้ deploy จริง)

### 3. การลบทรัพยากรทั้งหมด (cleanup.sh)

เมื่อต้องการลบทรัพยากรทั้งหมดที่สร้างขึ้นในบทเรียนนี้:

```bash
chmod +x cleanup.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./cleanup.sh
```

Script นี้จะดำเนินการ:
- ลบ docker images ที่สร้างขึ้นระหว่างการทดสอบ
- ลบ namespace `gitlab-demo`
- ตั้งค่า context กลับไปที่ namespace `default`

## แนวทางปฏิบัติที่ดีสำหรับ GitLab CI/CD

1. **ใช้ Stages อย่างเหมาะสม**: แบ่ง pipeline ออกเป็น stages ที่มีความหมาย (build, test, security scan, deploy)
2. **ใช้ Cache**: เพิ่มความเร็วในการทำงานโดยใช้ cache สำหรับไฟล์ dependencies
3. **ทำ Pipeline เป็นแบบ fail-fast**: จัดให้ jobs ที่ใช้เวลาน้อยและมีโอกาสล้มเหลวสูงทำงานก่อน
4. **ใช้ Environment Variables**: เก็บค่าที่ใช้ซ้ำใน variables
5. **ใช้ Dependencies ให้ถูกต้อง**: กำหนด artifacts และ dependencies ให้เหมาะสม
6. **ตั้งค่า Timeout**: กำหนดเวลาทำงานสูงสุดเพื่อป้องกันการทำงานค้าง
7. **แบ่ง Jobs ที่ใหญ่ออกเป็นส่วนเล็กๆ**: ทำให้ทำงานขนานได้และแก้ไขปัญหาได้ง่าย

## การประยุกต์ใช้ในสถานการณ์จริง

### 1. การทดสอบในหลาย Environment พร้อมกัน

```yaml
test:matrix:
  stage: test
  parallel:
    matrix:
      - NODE_VERSION: ['14', '16', '18']
        MONGODB_VERSION: ['4.4', '5.0']
  image: node:$NODE_VERSION-alpine
  services:
    - name: mongo:$MONGODB_VERSION
      alias: mongodb
  script:
    - npm ci
    - npm test
```

### 2. การทำ Review Apps

```yaml
deploy:review:
  stage: deploy
  script:
    - echo "Deploying to review app"
    - sed -i "s|image:.*|image: $IMAGE_NAME:$IMAGE_TAG|" kubernetes/deployment.yaml
    - kubectl apply -f kubernetes/deployment.yaml -n review-$CI_COMMIT_REF_SLUG
  environment:
    name: review/$CI_COMMIT_REF_SLUG
    url: https://$CI_COMMIT_REF_SLUG.review.example.com
    on_stop: stop:review
  rules:
    - if: $CI_MERGE_REQUEST_ID
```

### 3. การทำ Rolling Deployment

```yaml
deploy:production:rolling:
  stage: deploy
  script:
    - echo "Performing rolling deployment"
    - kubectl set image deployment/my-k8s-app my-k8s-app=$IMAGE_NAME:$IMAGE_TAG
    - kubectl rollout status deployment/my-k8s-app -n production
  environment:
    name: production
    url: https://example.com
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
  when: manual
```

## สรุป

ในเวิร์คช็อปนี้ เราได้เรียนรู้:

1. วิธีการสร้าง GitLab CI/CD pipeline สำหรับ Kubernetes
2. การ build และ push Docker image ไปยัง GitLab Container Registry
3. การ deploy แอปพลิเคชันไปยัง Kubernetes cluster
4. การใช้ GitLab Kubernetes Agent และ Variables
5. แนวทางปฏิบัติที่ดีและเทคนิคการทำ CI/CD กับ Kubernetes

GitLab CI/CD เป็นเครื่องมือที่ทรงพลังสำหรับการทำ Continuous Integration และ Deployment โดยมีข้อดีคือรวมอยู่ในระบบ GitLab ทำให้ไม่จำเป็นต้องใช้บริการภายนอก และมีความสามารถในการทำงานร่วมกับ Kubernetes ได้อย่างมีประสิทธิภาพ ช่วยให้ทีมพัฒนาสามารถส่งมอบซอฟต์แวร์ได้อย่างรวดเร็วและมีคุณภาพ
