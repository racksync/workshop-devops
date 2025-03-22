# Rust CI/CD Workshop with GitHub Actions

Workshop นี้จะแสดงวิธีการตั้งค่า CI/CD pipeline สำหรับโปรเจคภาษา Rust โดยใช้ GitHub Actions

## สารบัญ

- [Rust CI/CD Workshop with GitHub Actions](#rust-cicd-workshop-with-github-actions)
  - [สารบัญ](#สารบัญ)
  - [ข้อกำหนดเบื้องต้น](#ข้อกำหนดเบื้องต้น)
  - [โครงสร้างโปรเจค](#โครงสร้างโปรเจค)
  - [การตั้งค่า CI Pipeline](#การตั้งค่า-ci-pipeline)
    - [1. การทดสอบอัตโนมัติ (Automated Testing)](#1-การทดสอบอัตโนมัติ-automated-testing)
    - [2. การตรวจสอบโค้ด (Code Linting)](#2-การตรวจสอบโค้ด-code-linting)
  - [การตั้งค่า CD Pipeline](#การตั้งค่า-cd-pipeline)
    - [การสร้างและเผยแพร่เวอร์ชันใหม่ (Build and Release)](#การสร้างและเผยแพร่เวอร์ชันใหม่-build-and-release)
  - [วิธีใช้งาน](#วิธีใช้งาน)
  - [บทสรุป](#บทสรุป)

## ข้อกำหนดเบื้องต้น

- [Rust](https://www.rust-lang.org/tools/install) (1.56.0 หรือสูงกว่า)
- [Git](https://git-scm.com/downloads)
- บัญชี [GitHub](https://github.com/)
- ความรู้พื้นฐานเกี่ยวกับ Rust และคำสั่ง Git

## โครงสร้างโปรเจค

โปรเจคนี้เป็นแอปพลิเคชัน Rust อย่างง่ายที่มีการตั้งค่า CI/CD pipeline ด้วย GitHub Actions:

```
rust-cicd-workshop/
├── .github/
│   └── workflows/
│       ├── ci.yml        # CI workflow สำหรับการทดสอบและตรวจสอบโค้ด
│       └── release.yml   # CD workflow สำหรับการสร้างและเผยแพร่เวอร์ชันใหม่
├── src/
│   └── main.rs           # โค้ดหลักของแอปพลิเคชัน
├── tests/
│   └── integration_test.rs  # การทดสอบแบบ Integration
├── Cargo.toml            # ไฟล์คอนฟิกของโปรเจค Rust
└── README.md             # เอกสารประกอบโปรเจค
```

## การตั้งค่า CI Pipeline

### 1. การทดสอบอัตโนมัติ (Automated Testing)

ไฟล์ `.github/workflows/ci.yml` กำหนดค่า pipeline สำหรับ Continuous Integration ดังนี้:

- **Trigger**: ทุกครั้งที่มีการ push หรือสร้าง Pull Request ไปยัง branch `main`
- **การดำเนินการ**:
  - ติดตั้ง Rust toolchain
  - ดาวน์โหลดและแคชไฟล์ dependencies
  - ตรวจสอบการจัดรูปแบบโค้ด (format) ด้วย `rustfmt`
  - วิเคราะห์โค้ดด้วย `clippy`
  - รันการทดสอบด้วย `cargo test`

GitHub Actions จะรันงานนี้โดยอัตโนมัติเมื่อมีการ push โค้ดหรือสร้าง Pull Request และจะรายงานผลลัพธ์กลับไปยัง GitHub

### 2. การตรวจสอบโค้ด (Code Linting)

Workshop นี้ใช้ Clippy ซึ่งเป็นเครื่องมือวิเคราะห์โค้ดของ Rust เพื่อตรวจหาปัญหาทั่วไป, ข้อผิดพลาด, และโอกาสในการปรับปรุงโค้ด 

CI pipeline จะตรวจสอบว่าโค้ดผ่านการตรวจสอบของ Clippy โดยไม่มี warning หรือ error

## การตั้งค่า CD Pipeline

### การสร้างและเผยแพร่เวอร์ชันใหม่ (Build and Release)

ไฟล์ `.github/workflows/release.yml` กำหนดค่า pipeline สำหรับ Continuous Deployment ดังนี้:

- **Trigger**: เมื่อมีการสร้าง tag ใหม่ด้วยรูปแบบ `v*` (เช่น v1.0.0)
- **การดำเนินการ**:
  - สร้างไบนารีสำหรับหลายแพลตฟอร์ม (Linux, macOS, Windows)
  - สร้าง GitHub Release โดยอัตโนมัติ
  - อัปโหลดไบนารีเป็น artifacts ของ Release

## วิธีใช้งาน

1. **Clone โปรเจค**:
   ```
   git clone https://github.com/yourusername/rust-cicd-workshop.git
   cd rust-cicd-workshop
   ```

2. **พัฒนาและทดสอบในเครื่องของคุณ**:
   ```
   cargo build
   cargo test
   ```

3. **Push การเปลี่ยนแปลงไปยัง GitHub**:
   ```
   git add .
   git commit -m "เพิ่มฟีเจอร์ใหม่"
   git push origin main
   ```

   GitHub Actions จะรัน CI pipeline โดยอัตโนมัติ

4. **สร้าง Release**:
   ```
   git tag v1.0.0
   git push origin v1.0.0
   ```

   GitHub Actions จะรัน CD pipeline และสร้าง release โดยอัตโนมัติ

## บทสรุป

การตั้งค่า CI/CD pipeline ด้วย GitHub Actions ช่วยให้สามารถทดสอบและเผยแพร่โปรเจค Rust ได้โดยอัตโนมัติ ทุกครั้งที่มีการ push โค้ดหรือสร้าง tag ใหม่ ลดขั้นตอนที่ต้องทำด้วยมือและเพิ่มความมั่นใจในคุณภาพของโค้ด
