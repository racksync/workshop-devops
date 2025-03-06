# Docker Hub CI/CD Workshop

This repository demonstrates how to set up CI/CD pipelines to automatically build and push Docker images to Docker Hub using different CI/CD platforms.

## Project Structure

- `app/app.py`: A simple Python Flask application that serves a single page
- `requirements.txt`: Python dependencies
- `Dockerfile`: Instructions to build the Docker image
- `.github/workflows/docker-build-push.yml`: GitHub Actions workflow
- `.gitlab-ci.yml`: GitLab CI configuration
- `bitbucket-pipelines.yml`: Bitbucket Pipelines configuration

## Local Development

### Prerequisites
- Docker installed on your machine
- Python 3.9 or higher (for local development without Docker)

### Running locally with Python

```bash
pip install -r requirements.txt
python app/app.py
```

Then visit `http://localhost:5000` in your browser.

### Running locally with Docker

```bash
docker build -t docker-hub-workshop .
docker run -p 5000:5000 docker-hub-workshop
```

Then visit `http://localhost:5000` in your browser.

## CI/CD Pipeline Setup

### Required Secrets

For all CI/CD platforms, you'll need to set up the following secrets:

- `DOCKER_HUB_USERNAME`: Your Docker Hub username
- `DOCKER_HUB_PASSWORD` or `DOCKER_HUB_ACCESS_TOKEN`: Your Docker Hub password or access token

### GitHub Actions

The pipeline in `.github/workflows/docker-build-push.yml` will:
1. Build the Docker image
2. Push it to Docker Hub when changes are pushed to the main branch

### GitLab CI

The pipeline in `.gitlab-ci.yml` will:
1. Build the Docker image
2. Push it to Docker Hub when changes are pushed to the main branch

### Bitbucket Pipelines

The pipeline in `bitbucket-pipelines.yml` will:
1. Build the Docker image
2. Push it to Docker Hub when changes are pushed to the main branch

## Security Best Practices

- Always use access tokens instead of passwords for Docker Hub authentication
- Regularly rotate your access tokens
- Use specific image tags instead of `latest` in production environments
- Consider implementing vulnerability scanning in your CI/CD pipeline

## คำอธิบายภาษาไทย: การตั้งค่า CI/CD เพื่อส่ง Docker Image ไปยัง Docker Hub

### การใช้งาน GitHub Actions

GitHub Actions เป็นเครื่องมือ CI/CD ที่ติดตั้งมากับ GitHub โดยไม่มีค่าใช้จ่ายเพิ่มเติมสำหรับ repository สาธารณะ การทำงานมีดังนี้:

1. ไฟล์ `.github/workflows/docker-build-push.yml` จะถูกเรียกใช้งานเมื่อมีการ push หรือ pull request ไปยัง branch main
2. เมื่อทริกเกอร์ทำงาน ระบบจะ:
   - ดาวน์โหลดโค้ดจาก repository
   - ล็อกอินเข้า Docker Hub ด้วย credentials ที่เก็บไว้ใน GitHub Secrets
   - สร้าง Docker image ด้วย Docker Buildx
   - ถ้าเป็นการ push (ไม่ใช่ pull request) จะส่ง image ไปยัง Docker Hub

วิธีตั้งค่า:
- ไปที่ repository settings > Secrets and variables > Actions
- สร้าง secrets สองตัวคือ `DOCKER_HUB_USERNAME` และ `DOCKER_HUB_ACCESS_TOKEN`

### การใช้งาน GitLab CI

GitLab CI เป็นระบบ CI/CD ที่มาพร้อมกับ GitLab การทำงานมีดังนี้:

1. ไฟล์ `.gitlab-ci.yml` จะควบคุมขั้นตอนการทำงานทั้งหมด
2. เมื่อมีการ push ไปยัง branch main:
   - ระบบจะสร้าง runner เพื่อทำงานตาม pipeline
   - ล็อกอินเข้า Docker Hub
   - สร้าง Docker image และส่งไปยัง Docker Hub

วิธีตั้งค่า:
- ไปที่ Settings > CI/CD > Variables
- สร้าง variables สองตัวคือ `DOCKER_HUB_USERNAME` และ `DOCKER_HUB_PASSWORD`

### การใช้งาน Bitbucket Pipelines

Bitbucket Pipelines เป็นระบบ CI/CD แบบคลาวด์ที่มาพร้อมกับ Bitbucket การทำงานมีดังนี้:

1. ไฟล์ `bitbucket-pipelines.yml` จะควบคุมขั้นตอนการทำงาน
2. เมื่อมีการ push ไปยัง branch main:
   - ระบบจะเริ่ม pipeline อัตโนมัติ
   - ล็อกอินเข้า Docker Hub
   - สร้าง Docker image และส่งไปยัง Docker Hub

วิธีตั้งค่า:
- ไปที่ Repository settings > Pipelines > Repository variables
- สร้าง variables สองตัวคือ `DOCKER_HUB_USERNAME` และ `DOCKER_HUB_PASSWORD`

### ข้อควรระวังด้านความปลอดภัย

- ใช้ Access Token แทนการใช้รหัสผ่านโดยตรง
- หมั่นเปลี่ยน Access Token เป็นประจำ
- หลีกเลี่ยงการใช้ tag `latest` ในสภาพแวดล้อมการผลิต
- พิจารณาเพิ่มการสแกนช่องโหว่ความปลอดภัยใน pipeline

## License

MIT
