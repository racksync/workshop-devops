# CI/CD Workshop with GitLab CI/CD

## 📑 สารบัญ

- [1. Overview of GitLab CI/CD](#-1-overview-of-gitlab-cicd)
- [2. Getting Started with GitLab CI/CD](#-2-getting-started-with-gitlab-cicd)
- [3. Core Concepts in GitLab CI/CD](#-3-core-concepts-in-gitlab-cicd)
- [4. GitLab Registry and Packages](#-4-gitlab-registry-and-packages)
- [5. Variables, Secrets & Permissions](#-5-variables-secrets--permissions)
- [6. Debugging & Monitoring GitLab Pipelines](#-6-debugging--monitoring-gitlab-pipelines)
- [7. Optimizing GitLab CI/CD Workflows](#-7-optimizing-gitlab-cicd-workflows)
- [8. Basic CI/CD Pipelines](#-8-basic-cicd-pipelines)
- [9. Deployment Pipelines](#-9-deployment-pipelines)
- [10. Advanced Use Cases](#-10-advanced-use-cases)
- [11. ตัวอย่าง Pipeline จากโปรเจค Workshop](#-11-ตัวอย่าง-pipeline-จากโปรเจค-workshop)
- [12. ความแตกต่างระหว่าง GitLab CI/CD กับ Platform อื่น](#-12-ความแตกต่างระหว่าง-gitlab-cicd-กับ-platform-อื่น)

## 🔹 1. Overview of GitLab CI/CD

### จุดเด่นของ GitLab CI/CD

GitLab CI/CD เป็นระบบ Continuous Integration และ Continuous Deployment ที่รวมอยู่ในแพลตฟอร์ม GitLab ซึ่งมีจุดเด่นหลายประการ:

1. **ระบบแบบครบวงจร**: GitLab นำเสนอระบบแบบบูรณาการเต็มรูปแบบสำหรับการจัดการโค้ด (Git repositories), CI/CD และการติดตามปัญหา (Issue tracking) ทั้งหมดอยู่ในที่เดียว
2. **Pipeline as Code**: กำหนด pipeline ในไฟล์ `.gitlab-ci.yml` ที่อยู่ในโค้ดของคุณ ทำให้ version control และติดตามการเปลี่ยนแปลงง่าย
3. **Auto DevOps**: มีฟีเจอร์ Auto DevOps ที่ช่วยให้เริ่มต้นการใช้งาน CI/CD ได้อย่างรวดเร็วโดยไม่ต้องตั้งค่ามาก
4. **Container Registry ในตัว**: สามารถสร้างและจัดเก็บ Docker images ได้ในระบบเดียวกัน
5. **GitLab Runner**: สามารถติดตั้ง runners บนเครื่องของคุณเองเพื่อทำ self-hosted CI/CD ได้ง่าย
6. **สนับสนุน Multi-project Pipelines**: ช่วยให้สามารถสร้าง workflows ที่ซับซ้อนข้ามโปรเจคได้

### เปรียบเทียบกับ CI/CD Platforms อื่นๆ อย่างย่อ

| Platform | จุดเด่น | ข้อเสีย |
|----------|--------|---------|
| **GitLab CI/CD** | - All-in-one platform<br>- Built-in container registry<br>- DevOps lifecycle tools | - UI ซับซ้อน<br>- Self-hosted อาจยุ่งยาก |
| **GitHub Actions** | - ใช้งานง่าย<br>- รวมกับ GitHub<br>- Marketplace ใหญ่ | - เป็นแพลตฟอร์มที่ค่อนข้างใหม่กว่า มีประวัติการใช้งานในตลาดน้อยกว่า |
| **Jenkins** | - Customizable<br>- Plugin ecosystem ใหญ่มาก | - ต้องการ maintenance สูง<br>- Setup ยาก |
| **CircleCI** | - ใช้งานง่าย<br>- Orbs (reusable configurations) | - ราคาอาจแพงสำหรับทีมขนาดใหญ่ |
| **Travis CI** | - Setup ง่าย<br>- เหมาะกับ open source | - จำกัดความสามารถในการ customize |

## 🔹 2. Getting Started with GitLab CI/CD

### เริ่มต้นใช้งาน GitLab CI/CD ใน 5 นาที

1. **สร้างไฟล์ `.gitlab-ci.yml` ในโปรเจคของคุณ**
2. **Commit และ push ไฟล์**
3. **ไปที่ CI/CD > Pipelines ใน GitLab เพื่อดูผลลัพธ์**

ตัวอย่างไฟล์ `.gitlab-ci.yml` สำหรับเริ่มต้น:

```yaml
stages:
  - build
  - test

build-job:
  stage: build
  script:
    - echo "Building project..."
    - echo "Build complete."

test-job:
  stage: test
  script:
    - echo "Running tests..."
    - echo "Test complete."
```

### การตั้งค่า GitLab Runner สำหรับ Self-Hosted

หากต้องการใช้ runner ของตัวเอง (ซึ่งมีประโยชน์สำหรับการเข้าถึงทรัพยากรภายใน):

1. **ติดตั้ง GitLab Runner บนเซิร์ฟเวอร์**:
   ```bash
   curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
   sudo apt-get install gitlab-runner
   ```

2. **ลงทะเบียน Runner**:
   ```bash
   sudo gitlab-runner register
   ```
   คุณต้องกรอกข้อมูลต่อไปนี้:
   - GitLab URL (เช่น https://gitlab.com/)
   - Registration token (หาได้จาก Settings > CI/CD > Runners)
   - Description และ tags
   - Executor type (เช่น docker, shell)

3. **เปิดใช้งาน Runner**:
   ```bash
   sudo gitlab-runner start
   ```

### การติดตั้ง GitLab Runner บน Linux ทั่วไป (Binary)

หากระบบไม่สนับสนุนการติดตั้งผ่าน package manager คุณสามารถติดตั้งจาก binary ได้โดยตรง:

1. **ดาวน์โหลด binary**:
   ```bash
   sudo curl -L --output /usr/local/bin/gitlab-runner https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64
   ```

2. **กำหนดสิทธิ์การทำงาน**:
   ```bash
   sudo chmod +x /usr/local/bin/gitlab-runner
   ```

3. **สร้างผู้ใช้สำหรับ GitLab Runner**:
   ```bash
   sudo useradd --comment 'GitLab Runner' --create-home gitlab-runner --shell /bin/bash
   ```

4. **ติดตั้งและเริ่มใช้งานเป็น service**:
   ```bash
   sudo gitlab-runner install --user=gitlab-runner --working-directory=/home/gitlab-runner
   sudo gitlab-runner start
   ```

5. **ลงทะเบียน Runner**:
   ```bash
   sudo gitlab-runner register
   ```

### การตั้งค่า GitLab Runner บน macOS (Apple Silicon/ARM)

1. **ติดตั้ง GitLab Runner ด้วย Homebrew**:
   ```bash
   brew install gitlab-runner
   ```

2. **ติดตั้งเป็น service**:
   ```bash
   brew services start gitlab-runner
   ```

3. **ลงทะเบียน Runner**:
   ```bash
   gitlab-runner register
   ```
   คุณต้องกรอกข้อมูลต่อไปนี้:
   - GitLab URL (เช่น https://gitlab.com/)
   - Registration token (หาได้จาก Settings > CI/CD > Runners)
   - Description (เช่น "Mac M4 Runner")
   - Tags (เช่น "macos,arm64")
   - Executor type (แนะนำให้ใช้ "shell" สำหรับ macOS)

4. **ตรวจสอบสถานะ**:
   ```bash
   gitlab-runner status
   ```

5. **หากใช้ Docker executor บน M1/M2**:
   
   เนื่องจาก Apple Silicon อาจมีความท้าทายเรื่อง compatibility กับ Docker images บางตัว คุณควรเพิ่มการตั้งค่าเหล่านี้ใน `/etc/gitlab-runner/config.toml`:
   
   ```toml
   [[runners]]
     // ...existing config...
     executor = "docker"
     [runners.docker]
       platform = "linux/amd64"  # บังคับให้ใช้ platform x86_64
       image = "alpine:latest"
   ```
   
   คำสั่งนี้จะทำให้ Docker บน M1/M2 รัน image ในโหมด emulation สำหรับ x86_64 ซึ่งรองรับ image ส่วนใหญ่ได้ดีขึ้น แต่อาจจะช้ากว่าการรัน native ARM images

6. **รีสตาร์ท service หลังจากปรับแก้ config**:
   ```bash
   brew services restart gitlab-runner
   ```

## 🔹 3. Core Concepts in GitLab CI/CD

### โครงสร้างของไฟล์ .gitlab-ci.yml

```yaml
# ระบุขั้นตอนของ pipeline
stages:
  - build
  - test
  - deploy

# ตัวแปรที่ใช้ในทุก job
variables:
  GLOBAL_VAR: "value"

# job: build
build:
  stage: build   # ระบุว่า job นี้อยู่ใน stage build
  image: node:16 # Docker image ที่ใช้รัน
  script:        # คำสั่งที่จะรัน
    - npm ci
    - npm run build
  artifacts:     # ไฟล์ที่ต้องการเก็บไว้ใช้ใน job อื่นต่อไป
    paths:
      - dist/
  cache:         # เก็บ cache ของ dependencies
    paths:
      - node_modules/
  only:          # รัน job นี้เฉพาะเมื่อ
    - main       # - push ไปยัง branch main
  tags:          # เลือก runner ที่มี tag เหล่านี้
    - docker
```

### การใช้ Predefined Variables

GitLab CI/CD มีตัวแปรที่กำหนดไว้ล่วงหน้ามากมาย เช่น:

- `CI_COMMIT_SHA`: commit SHA ปัจจุบัน
- `CI_COMMIT_REF_NAME`: ชื่อ branch หรือ tag
- `CI_PROJECT_NAME`: ชื่อโปรเจค
- `CI_REGISTRY_IMAGE`: URL สำหรับ container registry ของโปรเจค

ตัวอย่างการใช้งาน:

```yaml
build:
  script:
    - echo "Building $CI_PROJECT_NAME on branch $CI_COMMIT_REF_NAME"
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG .
```

### Environment และ Deployment

GitLab ช่วยให้คุณสามารถกำหนด environment ต่างๆ สำหรับการ deploy ได้:

```yaml
deploy_staging:
  stage: deploy
  script:
    - deploy-script.sh --server=staging
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop

deploy_production:
  stage: deploy
  script:
    - deploy-script.sh --server=production
  environment:
    name: production
    url: https://example.com
  when: manual  # ต้องคลิกปุ่มเพื่อเริ่มทำงาน
  only:
    - main
```

ไปที่ Deployments > Environments เพื่อดูประวัติการ deploy และสถานะของแต่ละ environment

## 🔹 4. GitLab Registry and Packages

### Container Registry

GitLab มี container registry ในตัวสำหรับจัดเก็บและจัดการ Docker images ของคุณ:

```yaml
build_image:
  image: docker:20.10
  services:
    - docker:20.10-dind
  variables:
    DOCKER_TLS_CERTDIR: "/certs"
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG .
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
  only:
    - main
    - develop
```

เข้าถึงและจัดการ images ได้ที่ Packages & Registries > Container Registry

### Package Registry

ใช้ GitLab Package Registry สำหรับจัดเก็บแพ็คเกจต่างๆ เช่น npm, Maven, PyPI:

ตัวอย่าง job สำหรับเผยแพร่แพ็คเกจ npm:

```yaml
publish_npm:
  stage: deploy
  script:
    - echo "@${CI_PROJECT_ROOT_NAMESPACE}:registry=${CI_API_V4_URL}/projects/${CI_PROJECT_ID}/packages/npm/" > .npmrc
    - echo "//${CI_SERVER_HOST}/api/v4/projects/${CI_PROJECT_ID}/packages/npm/:_authToken=${CI_JOB_TOKEN}" >> .npmrc
    - npm publish
  only:
    - tags
```

### GitLab Pages

GitLab Pages ช่วยให้คุณสามารถโฮสต์เว็บไซต์สถิตได้:

```yaml
pages:
  stage: deploy
  script:
    - npm ci
    - npm run build
    - cp -r dist/* public/
  artifacts:
    paths:
      - public
  only:
    - main
```

เว็บไซต์จะถูกเผยแพร่ที่ `https://<username>.gitlab.io/<project-name>/`

## 🔹 5. Variables, Secrets & Permissions

### Project Variables และ Group Variables

1. ไปที่ Settings > CI/CD > Variables
2. คลิก "Add Variable"
3. กรอกข้อมูล Key และ Value
4. ตัวเลือกเพิ่มเติม:
   - **Protected**: ใช้ได้เฉพาะใน protected branches/tags
   - **Masked**: ซ่อนค่าในล็อก
   - **Expand variable reference**: แทนที่ตัวแปรอื่นใน value

```yaml
deploy:
  script:
    - echo "Deploying with API key $API_KEY" # API_KEY ถูกเพิ่มเป็น masked variable
    - curl -H "Authorization: Bearer $API_KEY" https://api.example.com
```

### File Variables

คุณสามารถเพิ่มไฟล์เป็นตัวแปรได้ (เช่น SSH private keys, certificates):

```yaml
deploy:
  script:
    - mkdir -p ~/.ssh
    - echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
    - chmod 600 ~/.ssh/id_rsa
    - ssh user@server "deploy-command"
```

### CI/CD Access Tokens

GitLab สร้าง CI_JOB_TOKEN โดยอัตโนมัติสำหรับการเข้าถึง GitLab API:

```yaml
api_call:
  script:
    - 'curl --header "JOB-TOKEN: $CI_JOB_TOKEN" "https://gitlab.com/api/v4/projects/$CI_PROJECT_ID/packages/generic/my_package/1.0.0/file.txt" --upload-file path/to/file.txt'
```

## 🔹 6. Debugging & Monitoring GitLab Pipelines

### การดู Logs และ Debug Pipeline

1. ไปที่ CI/CD > Pipelines
2. คลิกที่ ID ของ pipeline
3. คลิกที่ job เพื่อดู logs แบบละเอียด
4. ใช้ปุ่ม "Raw" เพื่อดู logs แบบไม่มีการจัดรูปแบบ

เทคนิคเพิ่มเติม:
- ใช้ debug mode: `set -x` ใน bash script
- เพิ่มข้อมูลสภาพแวดล้อม: `env` หรือ `printenv`
- ใช้ `CI_DEBUG_TRACE: "true"` สำหรับ trace คำสั่งทั้งหมด

```yaml
job_name:
  variables:
    CI_DEBUG_TRACE: "true"
  script:
    - set -x
    - env
    - your-command
```

### Live Tracing และ Interactive Debugging

สำหรับผู้ใช้ GitLab Premium/Ultimate:

```yaml
job_with_debug:
  script:
    - echo "Job with debug capabilities"
  variables:
    FAILURE_OPTION: "true"  # ทำให้ job นี้เข้าโหมด debug เมื่อล้มเหลว
```

หลังจาก job เริ่มทำงาน คุณสามารถคลิกที่ปุ่ม "Debug" เพื่อเปิด terminal แบบ interactive

### ตรวจสอบประสิทธิภาพของ Pipeline

1. ไปที่ CI/CD > Pipelines
2. ดู duration ของแต่ละ job
3. ใช้เมนู "CI/CD Analytics" เพื่อวิเคราะห์แนวโน้มระยะยาว

## 🔹 7. Optimizing GitLab CI/CD Workflows

### Dependencies และ Needs

ปกติ job ใน stage เดียวกันจะรันพร้อมกัน และต้องรอให้ stage ก่อนหน้าเสร็จก่อน แต่คุณสามารถกำหนดความสัมพันธ์แบบเฉพาะเจาะจงได้:

```yaml
build_a:
  stage: build
  script: echo "Building A..."

build_b:
  stage: build
  script: echo "Building B..."

test_a:
  stage: test
  needs: [build_a]  # รอเฉพาะ build_a (ไม่ต้องรอ build_b)
  script: echo "Testing A..."

test_b:
  stage: test
  needs: [build_b]  # รอเฉพาะ build_b
  script: echo "Testing B..."
```

### การใช้ Cache อย่างมีประสิทธิภาพ

```yaml
# Global cache configuration
cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - node_modules/
    - .npm/

# Job-specific cache configuration
job_name:
  cache:
    key: ${CI_JOB_NAME}-${CI_COMMIT_REF_SLUG}
    paths:
      - binaries/
    policy: pull-push  # pull ก่อน, push หลังจาก job เสร็จ
```

### Parallel และ Matrix Jobs

ทำงานเร็วขึ้นด้วยการรัน jobs แบบขนาน:

```yaml
test:
  stage: test
  parallel: 5  # รัน job นี้พร้อมกัน 5 instances
  script:
    - npm test -- --split=${CI_NODE_INDEX} --total=${CI_NODE_TOTAL}
```

สร้าง matrix ของ job ด้วย `parallel:matrix`:

```yaml
test:
  stage: test
  parallel:
    matrix:
      - BROWSER: [firefox, chrome, safari]
        RESOLUTION: [1080p, 4k]
  script:
    - npm test -- --browser=$BROWSER --resolution=$RESOLUTION
```

### Child Pipelines

คุณสามารถสร้าง pipelines ย่อยและรันได้จาก main pipeline:

```yaml
trigger_child_pipeline:
  stage: build
  trigger:
    include:
      - local: 'child-pipeline.yml'
    strategy: depend  # รอให้ child pipeline เสร็จก่อนไปยัง job ถัดไป
  only:
    - main
```

## 🔹 8. Basic CI/CD Pipelines

### ตัวอย่าง: Node.js Application

```yaml
image: node:16

stages:
  - install
  - lint
  - test
  - build

variables:
  NPM_CONFIG_CACHE: "$CI_PROJECT_DIR/.npm"

cache:
  key:
    files:
      - package-lock.json
  paths:
    - .npm/
    - node_modules/

install:
  stage: install
  script:
    - npm ci

lint:
  stage: lint
  script:
    - npm run lint
  needs:
    - install

unit_test:
  stage: test
  script:
    - npm run test:unit
  needs:
    - install
  coverage: /All\sfiles.*?\s+(\d+.\d+)/

e2e_test:
  stage: test
  script:
    - npm run test:e2e
  needs:
    - install
  artifacts:
    when: on_failure
    paths:
      - cypress/screenshots/

build:
  stage: build
  script:
    - npm run build
  needs:
    - lint
    - unit_test
  artifacts:
    paths:
      - dist/
```

### ตัวอย่าง: PHP Laravel Application

```yaml
image: php:8.1

stages:
  - prepare
  - test
  - build
  - deploy

variables:
  COMPOSER_CACHE_DIR: "$CI_PROJECT_DIR/.composer-cache"

cache:
  key: ${CI_COMMIT_REF_SLUG}
  paths:
    - vendor/
    - .composer-cache/

prepare:
  stage: prepare
  script:
    - apt-get update && apt-get install -y git zip unzip libpng-dev
    - curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    - composer install --prefer-dist --no-ansi --no-interaction --no-progress

lint:
  stage: test
  script:
    - vendor/bin/phpcs app
  needs:
    - prepare

test:
  stage: test
  services:
    - mysql:8.0
  variables:
    MYSQL_DATABASE: testing
    MYSQL_ROOT_PASSWORD: password
    DB_HOST: mysql
    DB_DATABASE: testing
    DB_USERNAME: root
    DB_PASSWORD: password
  script:
    - cp .env.example .env
    - php artisan key:generate
    - php artisan migrate --seed
    - vendor/bin/phpunit --coverage-text
  needs:
    - prepare

build:
  stage: build
  script:
    - npm ci
    - npm run production
  artifacts:
    paths:
      - public/css
      - public/js
  needs:
    - test
    - lint
```

## 🔹 9. Deployment Pipelines

### ตัวอย่าง: Deploy to EC2 via SSH

```yaml
stages:
  - build
  - test
  - deploy

build:
  stage: build
  script:
    - npm ci
    - npm run build
  artifacts:
    paths:
      - dist/

test:
  stage: test
  script:
    - npm test

deploy_staging:
  stage: deploy
  script:
    - apt-get update -q && apt-get install -y openssh-client rsync
    - mkdir -p ~/.ssh
    - echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_rsa
    - chmod 600 ~/.ssh/id_rsa
    - echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config
    - rsync -avz --delete dist/ $SSH_USER@$STAGING_SERVER:/var/www/html/
  environment:
    name: staging
    url: https://staging.example.com
  only:
    - develop
```

### ตัวอย่าง: Deploy to Kubernetes

```yaml
stages:
  - build
  - test
  - deploy

variables:
  DOCKER_HOST: tcp://docker:2376
  DOCKER_TLS_CERTDIR: "/certs"
  DOCKER_TLS_VERIFY: 1
  DOCKER_CERT_PATH: "$DOCKER_TLS_CERTDIR/client"

build:
  image: docker:20.10
  services:
    - docker:20.10-dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG .
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG

deploy_to_k8s:
  image: bitnami/kubectl:latest
  script:
    - kubectl config set-cluster k8s --server="$KUBE_URL" --certificate-authority="$KUBE_CA_PEM_FILE"
    - kubectl config set-credentials gitlab --token="$KUBE_TOKEN"
    - kubectl config set-context default --cluster=k8s --user=gitlab
    - kubectl config use-context default
    - sed -i "s|__CI_REGISTRY_IMAGE__|${CI_REGISTRY_IMAGE}|g" kubernetes/deployment.yaml
    - sed -i "s|__CI_COMMIT_REF_SLUG__|${CI_COMMIT_REF_SLUG}|g" kubernetes/deployment.yaml
    - kubectl apply -f kubernetes/deployment.yaml
  environment:
    name: production
    url: https://example.com
  only:
    - main
```

### ตัวอย่าง: Progressive Delivery ด้วย Canary

```yaml
stages:
  - build
  - test
  - deploy
  - canary
  - production

deploy_canary:
  stage: canary
  script:
    - kubectl set image deployment/app app=$CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
    - kubectl scale deployment app-canary --replicas=1
  environment:
    name: production:canary
    url: https://canary.example.com
  when: manual
  only:
    - main

monitor_canary:
  stage: canary
  script:
    - sleep 60
    - canary-checker --url https://canary.example.com
  when: on_success
  needs:
    - deploy_canary

deploy_production:
  stage: production
  script:
    - kubectl set image deployment/app app=$CI_REGISTRY_IMAGE:$CI_COMMIT_REF_SLUG
    - kubectl scale deployment app-canary --replicas=0
  environment:
    name: production
    url: https://example.com
  when: manual
  needs:
    - monitor_canary
  only:
    - main
```

## 🔹 10. Advanced Use Cases

### Multi-project Pipelines

สร้าง pipeline ที่ทำงานข้ามโปรเจค:

```yaml
# ใน project A
trigger_project_b:
  stage: deploy
  trigger:
    project: group/project-b
    branch: main
    strategy: depend  # รอให้ downstream pipeline เสร็จก่อนถือว่า job นี้สำเร็จ
```

### Dynamic Child Pipelines

```yaml
generate_dotnet_pipelines:
  stage: prepare
  script:
    - echo "stages: [build, test]" > dotnet-pipeline.yml
    - echo "build_job: { stage: build, script: dotnet build }" >> dotnet-pipeline.yml
    - echo "test_job: { stage: test, script: dotnet test }" >> dotnet-pipeline.yml
  artifacts:
    paths:
      - dotnet-pipeline.yml

trigger_dotnet_pipeline:
  stage: build
  trigger:
    include:
      - artifact: dotnet-pipeline.yml
        job: generate_dotnet_pipelines
    strategy: depend
```

### CI/CD สำหรับ Mono Repository

```yaml
.changes:rules:
  rules:
    - changes:
        paths:
          - ${PROJECT_DIR}/**/*

include:
  - local: 'frontend/.gitlab-ci.yml'
    rules:
      - !reference [.changes:rules, rules]
        variables:
          PROJECT_DIR: frontend
  
  - local: 'backend/.gitlab-ci.yml'
    rules:
      - !reference [.changes:rules, rules]
        variables:
          PROJECT_DIR: backend
          
  - local: 'common/.gitlab-ci.yml'
```

### GitLab CI Schedule กับ Cron Syntax

```yaml
scheduled_pipeline:
  script:
    - echo "This job runs on a schedule!"
  only:
    - schedules
```

ไปที่ CI/CD > Schedules เพื่อตั้งค่า cron schedule:
- นำเข้าข้อมูลทุกวันตอน 4 AM: `0 4 * * *`
- วันแรกของทุกเดือน: `0 0 1 * *`
- ทุกวันจันทร์ 9 AM: `0 9 * * 1`

## 🔹 11. ตัวอย่าง Pipeline จากโปรเจค Workshop

### ตัวอย่าง: Full Stack Web Application

ตัวอย่าง CI/CD สำหรับแอปพลิเคชันที่มี Node.js backend และ React frontend:

```yaml
stages:
  - prepare
  - build
  - test
  - deploy

variables:
  DOCKER_HOST: tcp://docker:2376
  DOCKER_TLS_CERTDIR: "/certs"
  DOCKER_TLS_VERIFY: 1
  DOCKER_CERT_PATH: "$DOCKER_TLS_CERTDIR/client"

.node_modules_cache:
  cache: &node_modules_cache
    key: ${CI_COMMIT_REF_SLUG}
    paths:
      - node_modules/
      - backend/node_modules/
      - frontend/node_modules/

prepare:
  image: node:16
  stage: prepare
  script:
    - npm ci
    - cd backend && npm ci && cd ..
    - cd frontend && npm ci && cd ..
  cache:
    <<: *node_modules_cache

backend:test:
  image: node:16
  stage: test
  script:
    - cd backend
    - npm test
  needs:
    - prepare

frontend:test:
  image: node:16
  stage: test
  script:
    - cd frontend
    - npm test
  needs:
    - prepare

backend:build:
  image: docker:20.10
  services:
    - docker:20.10-dind
  stage: build
  script:
    - cd backend
    - docker build -t $CI_REGISTRY_IMAGE/backend:$CI_COMMIT_REF_SLUG .
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker push $CI_REGISTRY_IMAGE/backend:$CI_COMMIT_REF_SLUG
  needs:
    - backend:test
  only:
    - main
    - develop

frontend:build:
  image: docker:20.10
  services:
    - docker:20.10-dind
  stage: build
  script:
    - cd frontend
    - docker build -t $CI_REGISTRY_IMAGE/frontend:$CI_COMMIT_REF_SLUG .
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker push $CI_REGISTRY_IMAGE/frontend:$CI_COMMIT_REF_SLUG
  needs:
    - frontend:test
  only:
    - main
    - develop