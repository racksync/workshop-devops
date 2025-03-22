# CI/CD Workshop with Bitbucket Pipelines

## 📑 สารบัญ

- [1. Overview of Bitbucket Pipelines](#-1-overview-of-bitbucket-pipelines)
- [2. Getting Started with Bitbucket Pipelines](#-2-getting-started-with-bitbucket-pipelines)
- [3. Core Concepts in Bitbucket Pipelines](#-3-core-concepts-in-bitbucket-pipelines)
- [4. Variables, Secrets & Permissions](#-4-variables-secrets--permissions)
- [5. Caching & Artifacts in Bitbucket Pipelines](#-5-caching--artifacts-in-bitbucket-pipelines)
- [6. Debugging & Troubleshooting](#-6-debugging--troubleshooting)
- [7. Optimizing Pipelines](#-7-optimizing-pipelines)
- [8. Basic CI/CD Pipeline Examples](#-8-basic-cicd-pipeline-examples)
- [9. Deployment Pipeline Examples](#-9-deployment-pipeline-examples)
- [10. Advanced Bitbucket Pipeline Features](#-10-advanced-bitbucket-pipeline-features)
- [11. Real-World Pipeline Examples](#-11-real-world-pipeline-examples)
- [12. Bitbucket vs. Other CI/CD Platforms](#-12-bitbucket-vs-other-cicd-platforms)

## 🔹 1. Overview of Bitbucket Pipelines

Bitbucket Pipelines เป็นระบบ CI/CD ในตัวของ Bitbucket ที่ทำงานบน cloud ทำให้ไม่ต้องตั้งค่าเซิร์ฟเวอร์เอง รันอยู่บน Docker containers และกำหนดค่าผ่านไฟล์ `bitbucket-pipelines.yml` ที่อยู่ในโปรเจคของคุณ

### 1.1 จุดเด่นของ Bitbucket Pipelines

- **แบบ Cloud-based**: ไม่จำเป็นต้องตั้งค่าหรือดูแลเซิร์ฟเวอร์เอง
- **Docker-based**: รันงานทั้งหมดใน Docker containers ทำให้มีความสามารถในการย้ายข้ามแพลตฟอร์ม
- **ผสานรวมกับ Bitbucket**: เชื่อมต่อกับฟีเจอร์อื่น ๆ ของ Bitbucket เช่น Deployments และ Pull Requests
- **Pipeline as Code**: กำหนดค่า Pipelines ในไฟล์ YAML ทำให้ version control และติดตามการเปลี่ยนแปลงได้ง่าย
- **สนับสนุนหลายภาษา**: รองรับทั้ง Node.js, Python, Java, .NET, PHP, Ruby และอื่น ๆ

## 🔹 2. Getting Started with Bitbucket Pipelines

### 2.1 เริ่มต้นใช้งาน Bitbucket Pipelines ใน 5 นาที

1. **เปิดใช้งาน Bitbucket Pipelines**:
   - ไปที่ repository ของคุณใน Bitbucket
   - คลิกที่ "Pipelines" ในเมนูด้านซ้าย
   - คลิก "Enable Pipelines"

2. **สร้างไฟล์ `bitbucket-pipelines.yml` ในโปรเจค**:
   - Bitbucket จะแนะนำ templates ให้เลือกตามภาษาของโปรเจค
   - หรือสร้างไฟล์เองและ commit เข้า repository

3. **ตัวอย่างไฟล์ `bitbucket-pipelines.yml` เบื้องต้น**:

```yaml
image: node:16

pipelines:
  default:
    - step:
        name: Build and Test
        caches:
          - node
        script:
          - npm install
          - npm run test
```

4. **Commit และ Push ไฟล์**:
   - Bitbucket จะเริ่ม pipeline โดยอัตโนมัติ
   - คุณสามารถติดตามความคืบหน้าของ pipeline ได้ในแท็บ "Pipelines"

## 🔹 3. Core Concepts in Bitbucket Pipelines

### 3.1 โครงสร้างของไฟล์ bitbucket-pipelines.yml

โครงสร้างพื้นฐานของไฟล์ `bitbucket-pipelines.yml` มีดังนี้:

```yaml
image: node:16  # Base Docker image

definitions:
  caches:
    npm: ~/.npm  # กำหนด cache สำหรับใช้ในหลาย step
  
  services:
    postgres:  # กำหนด service containers
      image: postgres:13
      variables:
        POSTGRES_USER: 'test'
        POSTGRES_PASSWORD: 'test'

pipelines:
  default:  # รันเมื่อมีการ push ไปยัง branch ที่ไม่ได้กำหนดเฉพาะ
    - step:
        name: Build and Test
        caches:
          - npm
        services:
          - postgres
        script:
          - npm install
          - npm test
          
  branches:  # รันเมื่อมีการ push ไปยัง branch ที่ระบุ
    master:
      - step:
          name: Build
          script:
            - npm install
            - npm run build
      - step:
          name: Deploy to Production
          deployment: production
          script:
            - echo "Deploying to production..."
            - npm run deploy:prod
            
  pull-requests:  # รันเมื่อมีการสร้าง/อัปเดต pull request
    '**':
      - step:
          script:
            - npm install
            - npm test
            
  custom:  # กำหนด pipelines แบบกำหนดเองสำหรับรันด้วย trigger ต่างๆ
    deployment-to-staging:
      - step:
          name: Deploy to staging
          deployment: staging
          script:
            - npm run deploy:staging
            
  tags:  # รันเมื่อมีการเพิ่ม tag
    '*':
      - step:
          script:
            - echo "Building release..."
```

### 3.2 องค์ประกอบหลักของ Pipeline

#### 1. Images
กำหนด Docker image ที่จะใช้รัน pipeline:

```yaml
image: node:16  # Global image

pipelines:
  default:
    - step:
        image: python:3.10  # Override global image for this step
        script:
          - python --version
```

#### 2. Steps
ขั้นตอนที่ทำงานตามลำดับในแต่ละ pipeline:

```yaml
pipelines:
  default:
    - step:
        name: First step
        script:
          - echo "Running first step"
    - step:
        name: Second step
        script:
          - echo "Running after first step completes"
```

#### 3. Services
Docker containers เพิ่มเติมที่ทำงานพร้อมกับ step เพื่อให้บริการเสริม:

```yaml
pipelines:
  default:
    - step:
        services:
          - docker
          - postgres
        script:
          - echo "Connected to PostgreSQL at postgres:5432"

definitions:
  services:
    postgres:
      image: postgres:13
      variables:
        POSTGRES_USER: 'test'
        POSTGRES_PASSWORD: 'test'
        POSTGRES_DB: 'test'
    docker:
      memory: 2048  # จัดสรร memory 2GB สำหรับ service นี้
```

#### 4. Parallel Steps
การทำงานพร้อมกันของหลาย step:

```yaml
pipelines:
  default:
    - parallel:
        - step:
            name: Tests
            script:
              - npm test
        - step:
            name: Linting
            script:
              - npm run lint
```

#### 5. Conditions
เงื่อนไขสำหรับการทำงานของ step:

```yaml
pipelines:
  default:
    - step:
        script:
          - echo "This step always runs"
    - step:
        trigger: manual  # ต้อง trigger ด้วยตนเอง
        script:
          - echo "This step runs only when manually triggered"
```

### 3.3 Environments และ Deployments

กำหนด environments สำหรับ deployment ใน step:

```yaml
pipelines:
  branches:
    master:
      - step:
          name: Deploy to Production
          deployment: production  # ระบุชื่อ environment
          trigger: manual  # ต้อง trigger ด้วยตนเอง
          script:
            - npm run deploy:prod
```

สามารถตั้งค่า environments ได้ที่ Repository settings > Deployments > Environments

## 🔹 4. Variables, Secrets & Permissions

### 4.1 Repository Variables และ Secured Variables

การกำหนดตัวแปรทำได้สองแบบ:

1. **ใน Repository settings**:
   - ไปที่ Repository settings > Pipelines > Repository variables
   - เพิ่มตัวแปรพร้อมค่าและเลือกว่าเป็น "Secured" หรือไม่

2. **ในไฟล์ `bitbucket-pipelines.yml`**:
   ```yaml
   pipelines:
     default:
       - step:
           name: Using Variables
           script:
             - echo "Non-sensitive variable: $PUBLIC_VAR"
             - echo "Using secured variable: $SECRET_VAR" # จะไม่แสดงค่าจริงในล็อก
   ```

### 4.2 Workspace และ Project Variables

- **Workspace variables**: ใช้ร่วมกันระหว่าง repositories ใน workspace เดียวกัน
- **Project variables**: ใช้ร่วมกันระหว่าง repositories ในโปรเจคเดียวกัน

```yaml
pipelines:
  default:
    - step:
        script:
          - echo "Using workspace variable: $WORKSPACE_VARIABLE"
          - echo "Using project variable: $PROJECT_VARIABLE"
```

ตั้งค่าได้ที่:
- Workspace settings > Pipelines > Workspace variables
- Project settings > Pipelines > Project variables

### 4.3 การใช้ OAuth Credentials

Bitbucket Pipelines มีระบบ OAuth built-in สำหรับบริการสำคัญ:

```yaml
pipelines:
  default:
    - step:
        # เชื่อมต่อกับ AWS โดยใช้ OAuth
        oidc: true
        script:
          - pipe: atlassian/aws-sam-deploy:1.1.0
            variables:
              AWS_REGION: 'ap-southeast-1'
              STACK_NAME: 'my-app-stack'
```

### 4.4 SSH Keys

การใช้ SSH Keys ใน pipelines:

1. **เพิ่ม SSH Key ใน Repository settings**:
   - ไปที่ Repository settings > Pipelines > SSH keys
   - เพิ่ม SSH Key หรือใช้ key pair ที่สร้างโดย Bitbucket

2. **ใช้ SSH Key ใน pipeline**:
   ```yaml
   pipelines:
     default:
       - step:
           name: Deploy with SSH
           script:
             - pipe: atlassian/ssh-run:0.4.0
               variables:
                 SSH_USER: 'ec2-user'
                 SERVER: 'ec2-instance-ip'
                 SSH_KEY: $SSH_PRIVATE_KEY  # Secured variable จาก repository settings
                 COMMAND: 'cd /app && ./deploy.sh'
   ```

## 🔹 5. Caching & Artifacts in Bitbucket Pipelines

### 5.1 การใช้ Caches

Caching ช่วยเก็บข้อมูลระหว่าง pipeline runs เพื่อทำให้เร็วขึ้น:

```yaml
definitions:
  caches:
    npm: ~/.npm
    yarn: ~/.cache/yarn
    custom: path/to/custom/cache

pipelines:
  default:
    - step:
        name: Build with caching
        caches:
          - npm
          - yarn
          - custom
        script:
          - npm install
          - npm run build
```

Built-in caches ที่มีให้ใช้:
- `node`
- `composer`
- `pip`
- `maven`
- `gradle`
- `yarn`
- `sbt`
- `bundler`

### 5.2 การใช้ Artifacts

Artifacts ช่วยส่งผ่านไฟล์ระหว่าง steps:

```yaml
pipelines:
  default:
    - step:
        name: Build
        script:
          - npm install
          - npm run build
        artifacts:
          - dist/**  # ส่ง folder dist ไปยัง step ถัดไป
    - step:
        name: Deploy
        script:
          - ls -la dist/  # ไฟล์จาก step ก่อนหน้า
          - npm run deploy
```

## 🔹 6. Debugging & Troubleshooting

### 6.1 การดู Logs

1. **เข้าถึง logs**:
   - ไปที่ Pipelines ในเมนูด้านซ้าย
   - เลือก pipeline run ที่ต้องการดู
   - คลิกที่ step เพื่อดูรายละเอียด logs

2. **การดู logs ที่ละเอียดขึ้น**:
   ```yaml
   pipelines:
     default:
       - step:
           script:
             - set -x  # แสดงคำสั่งที่รันทั้งหมด
             - env     # แสดงตัวแปรสภาพแวดล้อมทั้งหมด
             - your-command
   ```

### 6.2 การดีบั๊ก Pipeline

1. **เพิ่ม Debug Information**:
   ```yaml
   pipelines:
     default:
       - step:
           script:
             - echo "Working directory: $(pwd)"
             - echo "Contents: $(ls -la)"
             - echo "Environment: $(env)"
             - echo "Memory: $(free -h)"
             - echo "Disk space: $(df -h)"
   ```

2. **SSH into Pipeline**:
   
   ใช้ฟีเจอร์ "SSH session" เพื่อเข้าสู่ container ขณะที่ pipeline กำลังรัน:
   
   - เปิดใช้งาน "SSH on pipeline fail" ใน Repository settings > Pipelines > Settings
   - เมื่อ pipeline ล้มเหลว Bitbucket จะให้คำสั่ง SSH สำหรับเชื่อมต่อ
   - SSH session มีอายุ 15 นาที สามารถตรวจสอบสภาพแวดล้อมและรันคำสั่งเพื่อดีบั๊กได้

## 🔹 7. Optimizing Pipelines

### 7.1 การใช้ Parallel Steps

รัน steps พร้อมกันเพื่อเร็วขึ้น:

```yaml
pipelines:
  default:
    - parallel:
        - step:
            name: Unit Tests
            script:
              - npm run test:unit
        - step:
            name: Integration Tests
            script:
              - npm run test:integration
        - step:
            name: Linting
            script:
              - npm run lint
```

### 7.2 Pipeline Optimization Tips

1. **ใช้ Specific Docker Images**:
   ```yaml
   # แทนที่จะใช้
   image: node:latest
   
   # ใช้ specific tag
   image: node:16.14.0-alpine
   ```

2. **Optimize Caching Strategy**:
   ```yaml
   definitions:
     caches:
       npm: ~/.npm
   
   pipelines:
     default:
       - step:
           caches:
             - npm
           script:
             - npm ci  # ใช้ npm ci แทน npm install เพื่อให้เร็วขึ้น
   ```

3. **เลือกใช้เฉพาะ Services ที่จำเป็น**:
   ```yaml
   pipelines:
     default:
       - step:
           services:
             - postgres  # เปิดใช้เฉพาะ services ที่จำเป็น
           script:
             - npm test
   ```

4. **Skip Pipelines เมื่อไม่จำเป็น**:
   ```yaml
   pipelines:
     default:
       - step:
           script:
             - echo "Checking if build is necessary..."
             - if [ "$(git diff --name-only HEAD~1 | grep -c '\.js$')" -eq 0]; then exit 0; fi
             - npm run build
   ```

## 🔹 8. Basic CI/CD Pipeline Examples

### 8.1 Node.js Pipeline

```yaml
image: node:16

pipelines:
  default:
    - step:
        name: Build and Test
        caches:
          - node
        script:
          - npm ci
          - npm run lint
          - npm test
          - npm run build
        artifacts:
          - dist/**
          
  branches:
    master:
      - step:
          name: Build
          caches:
            - node
          script:
            - npm ci
            - npm run build
          artifacts:
            - dist/**
      - step:
          name: Deploy to Production
          deployment: production
          trigger: manual
          script:
            - pipe: atlassian/aws-s3-deploy:0.5.0
              variables:
                AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION
                AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
                AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
                S3_BUCKET: $PROD_S3_BUCKET
                LOCAL_PATH: 'dist'
```

### 8.2 Python Django Pipeline

```yaml
image: python:3.10

pipelines:
  default:
    - step:
        name: Test
        caches:
          - pip
        services:
          - postgres
        script:
          - pip install -r requirements.txt
          - python manage.py test
  
  branches:
    master:
      - step:
          name: Test
          caches:
            - pip
          services:
            - postgres
          script:
            - pip install -r requirements.txt
            - python manage.py test
      - step:
          name: Deploy to Heroku
          deployment: production
          script:
            - pipe: atlassian/heroku-deploy:2.0.0
              variables:
                HEROKU_API_KEY: $HEROKU_API_KEY
                HEROKU_APP_NAME: $HEROKU_APP_NAME
                ZIP_FILE: "app.tar.gz"

definitions:
  services:
    postgres:
      image: postgres:13
      variables:
        POSTGRES_DB: 'test_db'
        POSTGRES_USER: 'postgres'
        POSTGRES_PASSWORD: 'postgres'
```

### 8.3 React Application Pipeline

```yaml
image: node:16

pipelines:
  pull-requests:
    '**':
      - step:
          name: Build and Test PR
          caches:
            - node
          script:
            - npm ci
            - npm run lint
            - npm test
            - npm run build
  
  branches:
    develop:
      - step:
          name: Build and Test
          caches:
            - node
          script:
            - npm ci
            - npm test
            - npm run build
          artifacts:
            - build/**
      - step:
          name: Deploy to Staging
          deployment: staging
          script:
            - pipe: atlassian/firebase-deploy:0.5.0
              variables:
                FIREBASE_TOKEN: $FIREBASE_TOKEN
                PROJECT_ID: $FIREBASE_PROJECT_ID
                MESSAGE: "Deployed to staging from Bitbucket Pipelines"
                EXTRA_ARGS: '--only hosting:staging'
    
    master:
      - step:
          name: Build for Production
          caches:
            - node
          script:
            - npm ci
            - npm run lint
            - npm test
            - npm run build:production
          artifacts:
            - build/**
      - step:
          name: Deploy to Production
          deployment: production
          trigger: manual
          script:
            - pipe: atlassian/firebase-deploy:0.5.0
              variables:
                FIREBASE_TOKEN: $FIREBASE_TOKEN
                PROJECT_ID: $FIREBASE_PROJECT_ID
                MESSAGE: "Deployed to production from Bitbucket Pipelines"
                EXTRA_ARGS: '--only hosting:production'
```

## 🔹 9. Deployment Pipeline Examples

### 9.1 Docker Build & Push Pipeline

```yaml
image: atlassian/default-image:3

pipelines:
  branches:
    master:
      - step:
          name: Build and Test
          script:
            - npm ci
            - npm test
            - npm run build
      - step:
          name: Build and Push Docker Image
          services:
            - docker
          script:
            # Build Docker image
            - export IMAGE_NAME=$DOCKER_HUB_USERNAME/app:${BITBUCKET_COMMIT:0:7}
            - docker build -t $IMAGE_NAME .
            # Push to Docker Hub
            - echo $DOCKER_HUB_PASSWORD | docker login --username $DOCKER_HUB_USERNAME --password-stdin
            - docker push $IMAGE_NAME
            # Tag as latest
            - docker tag $IMAGE_NAME $DOCKER_HUB_USERNAME/app:latest
            - docker push $DOCKER_HUB_USERNAME/app:latest

definitions:
  services:
    docker:
      memory: 2048
```

### 9.2 AWS Elastic Beanstalk Deployment

```yaml
image: node:16

pipelines:
  branches:
    master:
      - step:
          name: Build
          caches:
            - node
          script:
            - npm ci
            - npm run build
          artifacts:
            - dist/**
            - package.json
            - package-lock.json
            - Procfile
            - .ebextensions/**
      - step:
          name: Deploy to AWS Elastic Beanstalk
          deployment: production
          script:
            - pipe: atlassian/aws-elasticbeanstalk-deploy:0.6.0
              variables:
                AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
                AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
                AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION
                APPLICATION_NAME: $APPLICATION_NAME
                ENVIRONMENT_NAME: $ENVIRONMENT_NAME
                STACK_NAME: '64bit Amazon Linux 2 v5.4.9 running Node.js 16'
                VERSION_LABEL: 'app-prod-${BITBUCKET_BUILD_NUMBER}'
                WAIT: 'true'
```

### 9.3 Multi-Environment Deployment

```yaml
image: node:16

pipelines:
  branches:
    develop:
      - step:
          name: Build for Staging
          caches:
            - node
          script:
            - npm ci
            - npm run build:staging
          artifacts:
            - build/**
      - step:
          name: Deploy to Staging
          deployment: staging
          script:
            - pipe: atlassian/aws-s3-deploy:0.5.0
              variables:
                AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
                AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
                AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION
                S3_BUCKET: $STAGING_S3_BUCKET
                LOCAL_PATH: 'build'

    master:
      - step:
          name: Build for Production
          caches:
            - node
          script:
            - npm ci
            - npm run build:production
          artifacts:
            - build/**
      - step:
          name: Deploy to UAT
          deployment: uat
          trigger: manual
          script:
            - pipe: atlassian/aws-s3-deploy:0.5.0
              variables:
                AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
                AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
                AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION
                S3_BUCKET: $UAT_S3_BUCKET
                LOCAL_PATH: 'build'
      - step:
          name: Deploy to Production
          deployment: production
          trigger: manual
          script:
            - pipe: atlassian/aws-s3-deploy:0.5.0
              variables:
                AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
                AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
                AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION
                S3_BUCKET: $PRODUCTION_S3_BUCKET
                LOCAL_PATH: 'build'
            - pipe: atlassian/aws-cloudfront-invalidate:0.6.0
              variables:
                AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
                AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
                AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION
                DISTRIBUTION_ID: $CLOUDFRONT_DISTRIBUTION_ID
```

## 🔹 10. Advanced Bitbucket Pipeline Features

### 10.1 การใช้ Custom Pipes

Pipes คือ reusable scripts ที่ทำงานเฉพาะอย่าง คล้าย Actions ใน GitHub:

```yaml
pipelines:
  default:
    - step:
        script:
          # ใช้ pipe สำหรับการ deploy ไปยัง Kubernetes
          - pipe: atlassian/kubectl-run:1.1.0
            variables:
              KUBE_CONFIG: $KUBE_CONFIG
              KUBECTL_COMMAND: 'apply'
              RESOURCE_PATH: 'k8s/'
              
          # ใช้ pipe สำหรับการส่งแจ้งเตือนไปยัง Slack
          - pipe: atlassian/slack-notify:0.3.0
            variables:
              WEBHOOK_URL: $SLACK_WEBHOOK
              MESSAGE: 'Deployment completed successfully'
```

### 10.2 Scheduled Pipelines

การตั้งค่าให้ pipeline รันตามกำหนดเวลา:

1. **เพิ่ม Scheduled Pipeline**:
   - ไปที่ Repository settings > Pipelines > Schedules
   - คลิก "Add Schedule"
   - กำหนดเวลาเป็น cron expression (เช่น `0 2 * * *` สำหรับทุกวันเวลา 2 AM)
   - เลือก branch ที่จะรัน

2. **กำหนด Custom Pipeline ในไฟล์ configuration**:
   ```yaml
   pipelines:
     custom:
       nightly-build:
         - step:
             name: Nightly Database Backup
             script:
               - echo "Running scheduled backup..."
               - export DATE=$(date +%Y-%m-%d)
               - ./backup-script.sh
   ```

3. **เลือก Custom Pipeline นี้ในการตั้ง Schedule**

### 10.3 การใช้ Docker in Docker

สำหรับการสร้าง Docker images ใน pipelines:

```yaml
pipelines:
  default:
    - step:
        name: Build Docker Image
        services:
          - docker
        script:
          - docker build -t my-app:${BITBUCKET_COMMIT:0:7} .
          - docker run my-app:${BITBUCKET_COMMIT:0:7} npm test

definitions:
  services:
    docker:
      memory: 2048  # จัดสรร memory 2GB
```

### 10.4 การใช้ Include Files

แบ่ง pipeline configuration เป็นหลายไฟล์และรวมกัน:

```yaml
pipelines:
  default:
    - step:
        script:
          - echo "Default pipeline"
  include:
    - deployment.yml    # Include จากไฟล์ในโปรเจค
    - path: frontend-ci.yml
      project: team/frontend-config
      ref: master       # Include จาก repository อื่น
```

## 🔹 11. Real-World Pipeline Examples

### 11.1 Monorepo Pipeline

การจัดการ pipeline สำหรับ monorepo ที่มีหลาย projects:

```yaml
image: alpine:3.15

pipelines:
  pull-requests:
    '**':
      - step:
          name: Check Changes
          script:
            - apk add --no-cache git bash
            - bash ./scripts/check_changes.sh > changes.txt
            - cat changes.txt
          artifacts:
            - changes.txt
      - parallel:
          - step:
              name: Frontend Tests
              trigger: manual
              condition:
                file: changes.txt
                pattern: '^frontend$'
              image: node:16
              caches:
                - node
              script:
                - cd frontend
                - npm ci
                - npm test
          - step:
              name: Backend Tests
              trigger: manual
              condition:
                file: changes.txt
                pattern: '^backend$'
              image: python:3.10
```

### 11.2 Microservices Pipeline

```yaml
definitions:
  services:
    redis:
      image: redis:6
    mongodb:
      image: mongo:4
      variables:
        MONGO_INITDB_ROOT_USERNAME: 'root'
        MONGO_INITDB_ROOT_PASSWORD: 'example'

pipelines:
  default:
    - parallel:
        - step:
            name: Auth Service
            services:
              - redis
            script:
              - cd auth-service
              - npm ci
              - npm test
              - docker build -t auth-service .
            artifacts:
              - auth-service/dist/**
        - step:
            name: User Service
            services:
              - mongodb
            script:
              - cd user-service
              - npm ci
              - npm test
              - docker build -t user-service .
            artifacts:
              - user-service/dist/**
    - step:
        name: Integration Tests
        script:
          - docker-compose -f docker-compose.test.yml up -d
          - ./run-integration-tests.sh
          - docker-compose -f docker-compose.test.yml down
```

### 11.3 Progressive Delivery Pipeline

```yaml
definitions:
  steps:
    - step: &build-step
        name: Build
        script:
          - npm ci
          - npm run build
        artifacts:
          - dist/**

pipelines:
  branches:
    develop:
      - step: *build-step
      - step:
          name: Deploy to Dev
          deployment: development
          script:
            - pipe: atlassian/aws-elasticbeanstalk-deploy:1.0.0
              variables:
                AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
                AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
                AWS_DEFAULT_REGION: 'ap-southeast-1'
                APPLICATION_NAME: 'my-app'
                ENVIRONMENT_NAME: 'my-app-dev'

    master:
      - step: *build-step
      - step:
          name: Deploy to Staging (10%)
          deployment: staging
          script:
            - pipe: atlassian/aws-cloudformation-deploy:1.0.0
              variables:
                AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID
                AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY
                AWS_DEFAULT_REGION: 'ap-southeast-1'
                STACK_NAME: 'canary-deployment'
                TEMPLATE_FILE: 'canary.yml'
                CAPABILITIES: 'CAPABILITY_IAM'
                PARAMETER_OVERRIDES: >
                  TargetGroupWeight=10
                  NewTargetGroupWeight=90

      - step:
          name: Validate Canary Deployment
          script:
            - ./monitor-canary.sh
          artifacts:
            - metrics/**

      - step:
          name: Deploy to Production (100%)
          deployment: production
          trigger: manual
          script:
            - pipe: atlassian/aws-cloudformation-deploy:1.0.0
              variables:
                STACK_NAME: 'canary-deployment'
                TEMPLATE_FILE: 'canary.yml'
                PARAMETER_OVERRIDES: >
                  TargetGroupWeight=100
                  NewTargetGroupWeight=0
```

### 11.4 E2E Testing Pipeline with Multiple Browsers

```yaml
image: cypress/included:12.3.0

definitions:
  services:
    selenium-hub:
      image: selenium/hub:4.8
    chrome:
      image: selenium/node-chrome:4.8
    firefox:
      image: selenium/node-firefox:4.8

pipelines:
  default:
    - parallel:
        - step:
            name: E2E Tests - Chrome
            services:
              - selenium-hub
              - chrome
            script:
              - npm ci
              - npm run test:e2e:chrome
            artifacts:
              - cypress/videos/**
              - cypress/screenshots/**
        - step:
            name: E2E Tests - Firefox
            services:
              - selenium-hub
              - firefox
            script:
              - npm ci
              - npm run test:e2e:firefox
            artifacts:
              - cypress/videos/**
              - cypress/screenshots/**
```

## 🔹 12. Bitbucket vs. Other CI/CD Platforms

### 12.1 Comparison Table

| Feature | Bitbucket Pipelines | GitHub Actions | GitLab CI/CD | Jenkins |
|---------|-------------------|----------------|--------------|----------|
| **Hosting** | Cloud-only | Cloud & Self-hosted | Cloud & Self-hosted | Self-hosted |
| **Configuration** | YAML | YAML | YAML | Jenkinsfile (Groovy) |
| **Container Support** | Yes (Docker-based) | Yes | Yes | Yes (with plugins) |
| **Marketplace** | Limited | Large | Limited | Extensive plugins |
| **Free Tier** | 50 mins/month | 2000 mins/month | 400 mins/month | Self-hosted only |
| **Integration** | Strong with Jira/Confluence | Strong with GitHub ecosystem | Complete DevOps platform | Generic, plugin-based |

### 12.2 Advantages of Bitbucket Pipelines

1. **Simplified Setup**
   - ไม่ต้องตั้งค่าเซิร์ฟเวอร์
   - ติดตั้งและเริ่มใช้งานได้ทันที

2. **Atlassian Integration**
   - ทำงานร่วมกับ Jira และ Confluence ได้ดี
   - เชื่อมต่อกับ Trello และ Statuspage

3. **Docker-First Approach**
   - ใช้ Docker เป็นพื้นฐาน
   - มี cache และ service containers ในตัว

4. **Cost-Effective**
   - ราคาถูกกว่าเมื่อใช้งานในทีมขนาดเล็ก
   - รวมอยู่ในแพ็คเกจ Bitbucket

### 12.3 Limitations

1. **Cloud-Only**
   - ไม่สามารถติดตั้งบน premises ได้
   - ต้องพึ่งพาอินเทอร์เน็ต

2. **Limited Marketplace**
   - มี pipes น้อยกว่า GitHub Actions
   - ต้องเขียน custom scripts มากขึ้น

3. **Resource Limits**
   - จำกัด build minutes ในแพ็คเกจฟรี
   - จำกัด parallel steps