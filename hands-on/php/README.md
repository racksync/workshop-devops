# DevOps Workshop: Modern PHP Application with CI/CD

![RACKSYNC CO., LTD.](https://github.com/racksync/devops-workshop/raw/main/assets/racksync-logo.png)

## Overview

This workshop by RACKSYNC CO., LTD. provides a practical hands-on experience with DevOps practices using a modern PHP application. Participants will learn how to containerize a PHP application and implement continuous integration and deployment (CI/CD) pipelines across multiple platforms.

## Application Features

- Modern responsive design using Bootstrap 5
- Multi-page application with component-based architecture
- Simple routing system
- Clean code organization
- Cross-platform CI/CD implementation (GitHub Actions, GitLab CI, and Bitbucket Pipelines)

## Prerequisites

- Docker and Docker Compose
- Git
- Basic understanding of PHP
- Account on at least one of: GitHub, GitLab, or Bitbucket
- A CI/CD runner/agent (self-hosted or cloud-based)

## Quick Start Guide

### 1. Clone the Repository

```bash
git clone https://github.com/racksync/devops-workshop.git
cd devops-workshop/hands-on/php
```

### 2. Build and Run Locally

```bash
docker build -t php-app:local .
docker run -d -p 8080:80 --name php-local php-app:local
```

Visit http://localhost:8080 in your browser to see the application running.

## Project Structure

```
/hands-on/php/
├── src/                        # Application source code
│   ├── assets/                 # Static assets
│   │   ├── css/                # CSS files
│   │   └── js/                 # JavaScript files
│   ├── includes/               # Reusable PHP components
│   │   ├── header.php          # Page header with navigation
│   │   └── footer.php          # Page footer
│   ├── pages/                  # Page-specific content
│   │   ├── home.php            # Homepage content
│   │   ├── about.php           # About page content
│   │   └── services.php        # Services page content
│   ├── index.php               # Main application entry point with routing
│   └── landing.html            # Simple landing page
├── .github/                    # GitHub Actions configuration
│   └── workflows/              
│       ├── main.yml            # Production deployment workflow
│       └── dev.yml             # Development deployment workflow
├── deploy-scripts/             # Deployment scripts for Bitbucket Pipelines
│   ├── deploy-dev.sh           # Script to deploy to dev environment
│   └── deploy-prod.sh          # Script to deploy to production environment
├── .gitlab-ci.yml              # GitLab CI configuration
├── bitbucket-pipelines.yml     # Bitbucket Pipelines configuration
├── Dockerfile                  # Docker configuration
└── README.md                   # This documentation
```

## CI/CD Implementation

This workshop includes CI/CD configurations for three popular platforms. Choose the one that best suits your needs or experiment with all three.

### GitHub Actions

Located in `.github/workflows/`:

- **dev.yml**: Triggered on pushes to the `dev` branch
  - Builds and deploys to development environment (port 8082)
  - Automatic deployment

- **main.yml**: Triggered on pushes to the `main` branch
  - Builds and deploys to production environment (port 8081)
  - Automatic deployment

### GitLab CI

Located in `.gitlab-ci.yml`:

- **Development Pipeline**: Triggered on pushes to the `dev` branch
  - Builds and tests the application
  - Automatic deployment to development environment (port 8082)

- **Production Pipeline**: Triggered on pushes to the `main` branch
  - Builds and tests the application
  - Manual deployment to production environment (port 8081)

### Bitbucket Pipelines

Located in `bitbucket-pipelines.yml`:

- **Development Pipeline**: Triggered on pushes to the `dev` branch
  - Builds and tests the application
  - Deploys to development environment using SSH (port 8082)

- **Production Pipeline**: Triggered on pushes to the `main` branch
  - Builds and tests the application
  - Manual deployment to production environment using SSH (port 8081)
  - Requires approval before deployment

## Workshop Exercises

### Exercise 1: Local Development

1. Clone the repository
2. Build and run the Docker container locally
3. Make changes to the application:
   - Add a new image to the homepage
   - Change text on the about page
   - Add a new service to the services page
4. Test your changes locally

### Exercise 2: GitHub Actions CI/CD

1. Fork the repository to your GitHub account
2. Set up a self-hosted GitHub Actions runner
   ```bash
   # Download runner script (replace with appropriate script for your OS)
   curl -o actions-runner-linux-x64-2.300.2.tar.gz -L https://github.com/actions/runner/releases/download/v2.300.2/actions-runner-linux-x64-2.300.2.tar.gz
   tar xzf ./actions-runner-linux-x64-2.300.2.tar.gz
   
   # Configure runner
   ./config.sh --url https://github.com/[YOUR_USERNAME]/devops-workshop --token [YOUR_TOKEN]
   
   # Install as a service
   sudo ./svc.sh install
   sudo ./svc.sh start
   ```
3. Push changes to the `dev` branch and observe the pipeline
4. Merge to `main` when satisfied with your changes

### Exercise 3: GitLab CI/CD

1. Import the project into GitLab
2. Set up a GitLab runner
   ```bash
   # Download and install GitLab Runner
   curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
   sudo apt-get install gitlab-runner
   
   # Register the runner
   sudo gitlab-runner register
   # Enter your GitLab instance URL
   # Enter the registration token
   # Enter a description for the runner
   # Enter tags for the runner (e.g., "docker", "shell")
   # Choose an executor (e.g., "shell")
   
   # Start the runner
   sudo gitlab-runner start
   ```
3. Push changes to the `dev` branch and observe the pipeline
4. Create a merge request to `main` when ready

### Exercise 4: Bitbucket Pipelines CI/CD

1. Import the project into Bitbucket
2. Enable Bitbucket Pipelines for your repository
3. Set up required environment variables:
   - `SSH_USER`: SSH user for deployment
   - `DEV_SERVER`: Hostname/IP of development server
   - `PROD_SERVER`: Hostname/IP of production server
4. Set up SSH keys for deployment
5. Push changes to the `dev` branch and observe the pipeline
6. Create a pull request to `main` when ready

### Exercise 5: Feature Branch Workflow

1. Choose a CI/CD platform from the above options
2. Create a new feature branch from `dev`
   ```bash
   git checkout dev
   git pull
   git checkout -b feature/new-feature
   ```
3. Implement a new feature (e.g., contact page, gallery, etc.)
4. Test locally using Docker
5. Push your branch and create a pull/merge request to `dev`
6. Observe CI/CD pipeline testing your changes
7. After approval and merge to `dev`, verify deployment to development environment
8. Create a pull/merge request from `dev` to `main` for production deployment

## Best Practices

- **Version Control**:
  - Use feature branches for development
  - Write meaningful commit messages
  - Review code before merging

- **Docker**:
  - Keep images small and efficient
  - Use specific version tags for base images
  - Implement multi-stage builds for complex applications

- **CI/CD**:
  - Test before pushing
  - Implement proper testing in pipelines
  - Use separate environments for development and production
  - Implement deployment approval for production

## Troubleshooting

### Common Issues

- **Docker Permission Issues**
  ```bash
  # Add your user to the docker group
  sudo usermod -aG docker $USER
  newgrp docker
  ```

- **Port Conflicts**
  ```bash
  # Check if ports are already in use
  sudo lsof -i :8080
  sudo lsof -i :8081
  sudo lsof -i :8082
  
  # Change port mapping if needed
  docker run -p 8090:80 --name php-local php-app:local
  ```

- **CI/CD Runner Connection Issues**
  - Verify network connectivity between runners and repositories
  - Check runner logs for detailed error messages
  - Ensure proper permissions for deployment

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitLab CI Documentation](https://docs.gitlab.com/ee/ci/)
- [Bitbucket Pipelines Documentation](https://support.atlassian.com/bitbucket-cloud/docs/bitbucket-pipelines-configuration-reference/)
- [PHP Best Practices](https://phptherightway.com/)

## About RACKSYNC

RACKSYNC CO., LTD. is a leading provider of DevOps solutions and training in Thailand. We specialize in helping organizations implement modern infrastructure practices to improve their development workflows and operational efficiency.

For more information, visit our [GitHub repository](https://github.com/racksync/devops-workshop) or contact our team for personalized training and consultation.

## License

This workshop material is provided by RACKSYNC CO., LTD. and is licensed under the MIT License.

## คู่มือเริ่มต้นอย่างรวดเร็ว (Quick Start Guide)

### 1. โคลนโปรเจค (Clone Repository)

```bash
git clone https://github.com/racksync/devops-workshop.git
cd devops-workshop/hands-on/php
```

### 2. สร้างและรันโปรเจคในเครื่องท้องถิ่น (Build and Run Locally)

```bash
docker build -t php-app:local .
docker run -d -p 8080:80 --name php-local php-app:local
```

เข้าชมที่ http://localhost:8080 ในเบราว์เซอร์ของคุณเพื่อดูแอปพลิเคชันที่กำลังทำงาน

## โครงสร้างโปรเจค (Project Structure)

```
/hands-on/php/
├── src/                        # โค้ดต้นฉบับของแอปพลิเคชัน
│   ├── assets/                 # ไฟล์สถิต
│   │   ├── css/                # ไฟล์ CSS
│   │   └── js/                 # ไฟล์ JavaScript
│   ├── includes/               # ส่วนประกอบ PHP ที่ใช้ซ้ำได้
│   │   ├── header.php          # ส่วนหัวของหน้าเว็บพร้อมเมนูนำทาง
│   │   └── footer.php          # ส่วนท้ายของหน้าเว็บ
│   ├── pages/                  # เนื้อหาเฉพาะหน้า
│   │   ├── home.php            # เนื้อหาหน้าแรก
│   │   ├── about.php           # เนื้อหาหน้าเกี่ยวกับ
│   │   └── services.php        # เนื้อหาหน้าบริการ
│   ├── index.php               # จุดเข้าหลักของแอปพลิเคชันพร้อมระบบเส้นทาง
│   └── landing.html            # หน้า Landing แบบเรียบง่าย
├── .github/                    # การกำหนดค่า GitHub Actions
│   └── workflows/              
│       ├── main.yml            # ขั้นตอนการ Deploy สำหรับโปรดักชัน
│       └── dev.yml             # ขั้นตอนการ Deploy สำหรับการพัฒนา
├── deploy-scripts/             # สคริปต์การ Deploy สำหรับ Bitbucket Pipelines
│   ├── deploy-dev.sh           # สคริปต์สำหรับ Deploy ไปยังสภาพแวดล้อมการพัฒนา
│   └── deploy-prod.sh          # สคริปต์สำหรับ Deploy ไปยังสภาพแวดล้อมการผลิต
├── .gitlab-ci.yml              # การกำหนดค่า GitLab CI
├── bitbucket-pipelines.yml     # การกำหนดค่า Bitbucket Pipelines
├── Dockerfile                  # การกำหนดค่า Docker
└── README.md                   # เอกสารนี้
```

## การดำเนินการ CI/CD

เวิร์กช็อปนี้รวมการกำหนดค่า CI/CD สำหรับแพลตฟอร์มยอดนิยม 3 แพลตฟอร์ม คุณสามารถเลือกแพลตฟอร์มที่เหมาะกับความต้องการของคุณหรือทดลองใช้ทั้งสามก็ได้

### GitHub Actions

อยู่ที่ `.github/workflows/`:

- **dev.yml**: ทริกเกอร์เมื่อมีการ push ไปยังสาขา `dev`
  - สร้างและ Deploy ไปยังสภาพแวดล้อมการพัฒนา (พอร์ต 8082)
  - ทำการ Deploy อัตโนมัติ

- **main.yml**: ทริกเกอร์เมื่อมีการ push ไปยังสาขา `main`
  - สร้างและ Deploy ไปยังสภาพแวดล้อมการผลิต (พอร์ต 8081)
  - ทำการ Deploy อัตโนมัติ

### GitLab CI

อยู่ที่ `.gitlab-ci.yml`:

- **Development Pipeline**: ทริกเกอร์เมื่อมีการ push ไปยังสาขา `dev`
  - สร้างและทดสอบแอปพลิเคชัน
  - ทำการ Deploy อัตโนมัติไปยังสภาพแวดล้อมการพัฒนา (พอร์ต 8082)

- **Production Pipeline**: ทริกเกอร์เมื่อมีการ push ไปยังสาขา `main`
  - สร้างและทดสอบแอปพลิเคชัน
  - ทำการ Deploy ด้วยตนเองไปยังสภาพแวดล้อมการผลิต (พอร์ต 8081)

### Bitbucket Pipelines

อยู่ที่ `bitbucket-pipelines.yml`:

- **Development Pipeline**: ทริกเกอร์เมื่อมีการ push ไปยังสาขา `dev`
  - สร้างและทดสอบแอปพลิเคชัน
  - Deploy ไปยังสภาพแวดล้อมการพัฒนาโดยใช้ SSH (พอร์ต 8082)

- **Production Pipeline**: ทริกเกอร์เมื่อมีการ push ไปยังสาขา `main`
  - สร้างและทดสอบแอปพลิเคชัน
  - ทำการ Deploy ด้วยตนเองไปยังสภาพแวดล้อมการผลิตโดยใช้ SSH (พอร์ต 8081)
  - ต้องการการอนุมัติก่อน Deploy

## แบบฝึกหัดเวิร์กช็อป

### แบบฝึกหัดที่ 1: การพัฒนาในเครื่องท้องถิ่น

1. โคลนโปรเจค
2. สร้างและรันคอนเทนเนอร์ Docker ในเครื่องท้องถิ่น
3. ทำการเปลี่ยนแปลงกับแอปพลิเคชัน:
   - เพิ่มรูปภาพใหม่ในหน้าแรก
   - เปลี่ยนข้อความบนหน้าเกี่ยวกับ
   - เพิ่มบริการใหม่ในหน้าบริการ
4. ทดสอบการเปลี่ยนแปลงของคุณในเครื่องท้องถิ่น

### แบบฝึกหัดที่ 2: GitHub Actions CI/CD

1. Fork โปรเจคไปยังบัญชี GitHub ของคุณ
2. ตั้งค่า GitHub Actions runner แบบ self-hosted
   ```bash
   # ดาวน์โหลดสคริปต์ runner (แทนที่ด้วยสคริปต์ที่เหมาะสมสำหรับ OS ของคุณ)
   curl -o actions-runner-linux-x64-2.300.2.tar.gz -L https://github.com/actions/runner/releases/download/v2.300.2/actions-runner-linux-x64-2.300.2.tar.gz
   tar xzf ./actions-runner-linux-x64-2.300.2.tar.gz
   
   # กำหนดค่า runner
   ./config.sh --url https://github.com/[YOUR_USERNAME]/devops-workshop --token [YOUR_TOKEN]
   
   # ติดตั้งเป็นบริการ
   sudo ./svc.sh install
   sudo ./svc.sh start
   ```
3. Push การเปลี่ยนแปลงไปยังสาขา `dev` และสังเกตไปป์ไลน์
4. Merge ไปยัง `main` เมื่อพึงพอใจกับการเปลี่ยนแปลงของคุณ

### แบบฝึกหัดที่ 3: GitLab CI/CD

1. นำเข้าโปรเจคเข้าสู่ GitLab
2. ตั้งค่า GitLab runner
   ```bash
   # ดาวน์โหลดและติดตั้ง GitLab Runner
   curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
   sudo apt-get install gitlab-runner
   
   # ลงทะเบียน runner
   sudo gitlab-runner register
   # ป้อน URL ของอินสแตนซ์ GitLab ของคุณ
   # ป้อนโทเค็นลงทะเบียน
   # ป้อนคำอธิบายสำหรับ runner
   # ป้อนแท็กสำหรับ runner (เช่น "docker", "shell")
   # เลือกตัวประมวลผล (เช่น "shell")
   
   # เริ่ม runner
   sudo gitlab-runner start
   ```
3. Push การเปลี่ยนแปลงไปยังสาขา `dev` และสังเกตไปป์ไลน์
4. สร้าง Merge Request ไปยัง `main` เมื่อพร้อม

### แบบฝึกหัดที่ 4: Bitbucket Pipelines CI/CD

1. นำเข้าโปรเจคเข้าสู่ Bitbucket
2. เปิดใช้งาน Bitbucket Pipelines สำหรับโปรเจคของคุณ
3. ตั้งค่าตัวแปรสภาพแวดล้อมที่จำเป็น:
   - `SSH_USER`: ผู้ใช้ SSH สำหรับการ Deploy
   - `DEV_SERVER`: ชื่อโฮสต์/IP ของเซิร์ฟเวอร์พัฒนา
   - `PROD_SERVER`: ชื่อโฮสต์/IP ของเซิร์ฟเวอร์โปรดักชัน
4. ตั้งค่าคีย์ SSH สำหรับการ Deploy
5. Push การเปลี่ยนแปลงไปยังสาขา `dev` และสังเกตไปป์ไลน์
6. สร้าง Pull Request ไปยัง `main` เมื่อพร้อม

### แบบฝึกหัดที่ 5: ขั้นตอนการทำงานด้วยสาขา Feature

1. เลือกแพลตฟอร์ม CI/CD จากตัวเลือกข้างต้น
2. สร้างสาขา feature ใหม่จาก `dev`
   ```bash
   git checkout dev
   git pull
   git checkout -b feature/new-feature
   ```
3. ดำเนินการฟีเจอร์ใหม่ (เช่น หน้าติดต่อ, แกลเลอรี, ฯลฯ)
4. ทดสอบในเครื่องท้องถิ่นโดยใช้ Docker
5. Push สาขาของคุณและสร้าง Pull/Merge Request ไปยัง `dev`
6. สังเกตไปป์ไลน์ CI/CD ที่ทดสอบการเปลี่ยนแปลงของคุณ
7. หลังจากได้รับการอนุมัติและ Merge ไปยัง `dev` ตรวจสอบการ Deploy ไปยังสภาพแวดล้อมการพัฒนา
8. สร้าง Pull/Merge Request จาก `dev` ไปยัง `main` สำหรับการ Deploy การผลิต

## แนวปฏิบัติที่ดีที่สุด (Best Practices)

- **การควบคุมเวอร์ชัน**:
  - ใช้สาขา feature สำหรับการพัฒนา
  - เขียนข้อความ Commit ที่มีความหมาย
  - ตรวจสอบโค้ดก่อน Merge

- **Docker**:
  - ทำให้อิมเมจมีขนาดเล็กและมีประสิทธิภาพ
  - ใช้แท็กเวอร์ชันเฉพาะสำหรับอิมเมจพื้นฐาน
  - ใช้การสร้างแบบหลายขั้นตอนสำหรับแอปพลิเคชันที่ซับซ้อน

- **CI/CD**:
  - ทดสอบก่อน Push
  - ใช้การทดสอบที่เหมาะสมในไปป์ไลน์
  - ใช้สภาพแวดล้อมแยกสำหรับการพัฒนาและการผลิต
  - ใช้การอนุมัติการ Deploy สำหรับการผลิต

## การแก้ไขปัญหา (Troubleshooting)

### ปัญหาทั่วไป

- **ปัญหาสิทธิ์การใช้งาน Docker**
  ```bash
  # เพิ่มผู้ใช้ของคุณในกลุ่ม docker
  sudo usermod -aG docker $USER
  newgrp docker
  ```

- **การขัดแย้งของพอร์ต**
  ```bash
  # ตรวจสอบว่ามีการใช้พอร์ตอยู่แล้วหรือไม่
  sudo lsof -i :8080
  sudo lsof -i :8081
  sudo lsof -i :8082
  
  # เปลี่ยนการ map พอร์ตหากจำเป็น
  docker run -p 8090:80 --name php-local php-app:local
  ```

- **ปัญหาการเชื่อมต่อ CI/CD Runner**
  - ตรวจสอบการเชื่อมต่อเครือข่ายระหว่าง runner และโปรเจค
  - ตรวจสอบบันทึก runner สำหรับข้อความข้อผิดพลาดโดยละเอียด
  - ตรวจสอบสิทธิ์ที่เหมาะสมสำหรับการ Deploy

## ทรัพยากรเพิ่มเติม

- [เอกสาร Docker](https://docs.docker.com/)
- [เอกสาร GitHub Actions](https://docs.github.com/en/actions)
- [เอกสาร GitLab CI](https://docs.gitlab.com/ee/ci/)
- [เอกสาร Bitbucket Pipelines](https://support.atlassian.com/bitbucket-cloud/docs/bitbucket-pipelines-configuration-reference/)
- [แนวปฏิบัติที่ดีที่สุดของ PHP](https://phptherightway.com/)

## เกี่ยวกับ RACKSYNC

RACKSYNC CO., LTD. เป็นผู้ให้บริการชั้นนำด้านโซลูชัน DevOps และการฝึกอบรมในประเทศไทย เราเชี่ยวชาญในการช่วยให้องค์กรใช้แนวทางปฏิบัติโครงสร้างพื้นฐานสมัยใหม่เพื่อปรับปรุงกระบวนการพัฒนาและประสิทธิภาพการดำเนินงาน

สำหรับข้อมูลเพิ่มเติม เยี่ยมชม [GitHub repository](https://github.com/racksync/devops-workshop) ของเราหรือติดต่อทีมของเราเพื่อรับการฝึกอบรมและคำปรึกษาเฉพาะบุคคล

## ลิขสิทธิ์

เนื้อหาเวิร์กช็อปนี้จัดทำโดย RACKSYNC CO., LTD. และได้รับอนุญาตภายใต้สัญญาอนุญาต MIT
