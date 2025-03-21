# การใช้ ZAP Full Scan ด้วย GitHub Actions

ZAP Full Scan เป็นเครื่องมือสำหรับการทดสอบความปลอดภัยของเว็บแอปพลิเคชัน (Web Application Security Testing) โดยใช้ OWASP ZAP (Zed Attack Proxy) ซึ่งสามารถทำงานร่วมกับ GitHub Actions เพื่อทำการสแกนแบบอัตโนมัติ

## คุณประโยชน์

- ค้นหาช่องโหว่ด้านความปลอดภัยโดยอัตโนมัติ
- ตรวจจับปัญหาความปลอดภัยแบบ OWASP Top 10
- สร้างรายงานผลการทดสอบโดยละเอียด
- ทำงานร่วมกับ CI/CD pipeline ได้อย่างราบรื่น

## การตั้งค่า ZAP Full Scan ใน GitHub Actions

### ขั้นที่ 1: สร้างไฟล์ Workflow

สร้างไฟล์ `.github/workflows/zap-scan.yml` ในโปรเจคของคุณ ด้วยเนื้อหาดังนี้:

```yaml
name: ZAP Full Scan

on:
  schedule:
    # ทำการสแกนทุกวันจันทร์เวลา 6:00 น. ตาม UTC
    - cron: '0 6 * * 1'
  workflow_dispatch:
    # อนุญาตให้เรียกใช้ workflow ด้วยตนเอง

jobs:
  zap_scan:
    runs-on: ubuntu-latest
    name: สแกนความปลอดภัยด้วย ZAP
    steps:
      - name: Checkout
        uses: actions/checkout@v2
        
      - name: ZAP Scan
        uses: zaproxy/action-full-scan@v0.7.0
        with:
          target: 'https://www.example.com'
          # หากต้องการส่งรายงานไปยัง GitHub Issues
          # issue_title: รายงานการสแกนความปลอดภัย ZAP
          # token: ${{ secrets.GITHUB_TOKEN }}
          # rules_file_name: '.zap/rules.tsv'
```

### ขั้นที่ 2: ปรับแต่งการตั้งค่า

ปรับแต่งค่าพารามิเตอร์ตามต้องการ:

- `target`: URL ของเว็บไซต์ที่ต้องการสแกน
- `rules_file_name`: ไฟล์กฎที่ใช้กำหนดวิธีการรายงานปัญหา (ถ้ามี)
- `token`: ใช้ในกรณีที่ต้องการสร้าง GitHub Issues อัตโนมัติ
- `issue_title`: ชื่อของ Issue ที่จะถูกสร้าง

### ขั้นที่ 3: ตัวอย่างไฟล์ Rules (ทางเลือก)

หากต้องการกำหนดกฎการรายงาน สร้างไฟล์ `.zap/rules.tsv` ด้วยเนื้อหาดังนี้:

```
10016	IGNORE	(Modern Web Application)
10017	IGNORE	(Cross-Domain JavaScript Source File Inclusion)
```

## ตัวอย่างเพิ่มเติม: การตั้งค่าขั้นสูง

สำหรับการตั้งค่าที่ซับซ้อนขึ้น:

```yaml
name: ทดสอบความปลอดภัยแบบละเอียด

on:
  push:
    branches: [ main ]
  schedule:
    - cron: '0 0 * * 0'  # ทุกวันอาทิตย์เวลาเที่ยงคืน
  workflow_dispatch:

jobs:
  zap-full-scan:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      
      - name: เริ่มระบบทดสอบ
        run: |
          docker-compose up -d
          sleep 30  # รอให้ระบบพร้อมใช้งาน
      
      - name: ZAP Full Scan
        uses: zaproxy/action-full-scan@v0.7.0
        with:
          target: 'http://localhost:8080'
          cmd_options: '-a -j -T 60'
          allow_issue_writing: false
          fail_action: true
          rules_file_name: '.zap/rules.tsv'
          artifact_name: 'zap-scan-results'
```

## พารามิเตอร์ที่รองรับ

| พารามิเตอร์ | คำอธิบาย | ค่าเริ่มต้น |
|------------|---------|-----------|
| `target` | URL เป้าหมายที่จะทำการสแกน | (จำเป็นต้องระบุ) |
| `cmd_options` | ตัวเลือกคำสั่งเพิ่มเติมสำหรับ ZAP | - |
| `rules_file_name` | ชื่อไฟล์กฎสำหรับการแจ้งเตือน | - |
| `issue_title` | ชื่อของ Issue ที่จะสร้าง | "ZAP Full Scan Report" |
| `token` | GitHub token สำหรับการสร้าง Issues | ${{ github.token }} |
| `fail_action` | หยุดการทำงานหากพบปัญหาความปลอดภัย | false |
| `allow_issue_writing` | อนุญาตให้เขียน Issues | true |
| `artifact_name` | ชื่อของ artifact สำหรับบันทึกผลลัพธ์ | "zap-scan" |

## ผลการทำงาน

หลังจากการสแกนเสร็จสิ้น:

1. ผลลัพธ์จะถูกบันทึกเป็น GitHub Artifact
2. หากเลือกใช้งาน จะสร้าง GitHub Issue พร้อมรายละเอียดผลการสแกน
3. หากพบปัญหาและตั้งค่า `fail_action: true` การทำงานจะล้มเหลวโดยอัตโนมัติ

## เทคนิคเพิ่มเติม

1. **การสแกนหลังการ deploy:**
   - เพิ่ม workflow ให้ทำงานหลังจากการ deploy ไปยัง environment
   
2. **การสแกนเฉพาะส่วน:**
   - ใช้ context เช่น `-c 10` เพื่อจำกัดความลึกของการสแกน

3. **การสแกนที่ต้องการ Authentication:**
   ```yaml
   cmd_options: '-c "auth.loginurl=http://example.com/login" -c "auth.username=test" -c "auth.password=test"'
   ```

4. **การตรวจสอบผลลัพธ์แบบละเอียด:**
   - ใช้ ZAP API เพื่อนำผลลัพธ์ไปวิเคราะห์เพิ่มเติมโดยใช้สคริปต์

## อ้างอิง

- [ZAP Full Scan GitHub Action](https://github.com/marketplace/actions/zap-full-scan)
- [OWASP ZAP Documentation](https://www.zaproxy.org/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
