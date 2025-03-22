# แอปพลิเคชัน Django พื้นฐาน

นี่เป็นแอปพลิเคชัน Django อย่างง่ายพร้อมการกำหนดค่า Docker สำหรับการพัฒนาและการติดตั้ง สร้างโดย RACKSYNC CO., LTD. สำหรับการสาธิตเวิร์กช็อป DevOps

## คุณสมบัติของแอปพลิเคชัน

- แอปพลิเคชันเว็บ Django พื้นฐาน
- การกำหนดค่าตัวแปรสภาพแวดล้อม
- การสร้างคอนเทนเนอร์ด้วย Docker
- การรวม CI/CD
- การจัดการข้อมูลลับอย่างปลอดภัย

## ตัวแปรสภาพแวดล้อม

เพื่อความปลอดภัย แอปพลิเคชันนี้ใช้ตัวแปรสภาพแวดล้อมสำหรับการกำหนดค่า:

- `DJANGO_SECRET_KEY`: คีย์ลับที่ใช้สำหรับการเข้ารหัสลายเซ็น
- `DJANGO_DEBUG`: ตั้งค่าเป็น "True" สำหรับการพัฒนา, "False" สำหรับการใช้งานจริง

### การจัดการข้อมูลลับ

- **การพัฒนาในเครื่อง**: สำหรับการพัฒนาในเครื่อง ข้อมูลลับจะถูกโหลดจากไฟล์ `.env`
- **ไปป์ไลน์ CI/CD**: ในไปป์ไลน์ CI/CD, `DJANGO_SECRET_KEY` จะถูกให้ผ่านระบบจัดการข้อมูลลับของไปป์ไลน์

> **หมายเหตุ**: แอปพลิเคชันจะสร้างคีย์สุ่มหากไม่มีคีย์ที่ให้มา แต่วิธีนี้เหมาะสำหรับการพัฒนาเท่านั้นเนื่องจากจะทำให้เซสชันไม่สามารถใช้งานได้ระหว่างรีสตาร์ท

## การรันในเครื่องด้วยสภาพแวดล้อมเสมือน (Virtual Environment)

### สิ่งที่ต้องมีก่อน

- Python 3.12+ ติดตั้งในระบบของคุณ
- Git

### การตั้งค่าและการรัน

1. โคลนที่เก็บ
   ```bash
   git clone <repository-url>
   cd <repository-directory>/hands-on/django
   ```

2. สร้างสภาพแวดล้อมเสมือน
   ```bash
   # บน macOS/Linux
   python -m venv venv
   
   # บน Windows
   python -m venv venv
   ```

3. เปิดใช้งานสภาพแวดล้อมเสมือน
   ```bash
   # บน macOS/Linux
   source venv/bin/activate
   
   # บน Windows
   venv\Scripts\activate
   ```

4. ติดตั้งแพ็คเกจที่จำเป็น
   ```bash
   pip install -r requirements.txt
   ```

5. ทำการ migrations
   ```bash
   python manage.py migrate
   ```

6. เริ่มเซิร์ฟเวอร์สำหรับการพัฒนา
   ```bash
   python manage.py runserver
   ```

7. เปิดเบราว์เซอร์และไปที่ http://127.0.0.1:8000/

8. เพื่อปิดใช้งานสภาพแวดล้อมเสมือนเมื่อเสร็จสิ้น
   ```bash
   deactivate
   ```

## การรันด้วย Docker

1. คัดลอก `.env.example` เป็น `.env` และกำหนดค่าตามต้องการ (สำหรับการพัฒนาในเครื่องเท่านั้น)
2. สร้างอิมเมจ Docker:
   ```bash
   docker build -t django-basic .
   ```
3. รันคอนเทนเนอร์:
   ```bash
   # สำหรับการพัฒนาในเครื่องด้วยไฟล์ .env
   docker run -p 8000:8000 --env-file .env django-basic
   
   # ทางเลือก: ให้ข้อมูลลับโดยตรง
   docker run -p 8000:8000 -e DJANGO_SECRET_KEY="your-secret-key" -e DJANGO_DEBUG="True" django-basic
   ```

## โครงสร้างโปรเจกต์

```
django/
├── app/                # โค้ดแอปพลิเคชันหลัก
│   ├── templates/      # แม่แบบ HTML
│   ├── models.py       # โมเดลฐานข้อมูล
│   ├── views.py        # วิวและคอนโทรลเลอร์
│   ├── urls.py         # การกำหนดเส้นทาง URL
│   └── apps.py         # การกำหนดค่าแอป
├── django_project/     # การตั้งค่าโปรเจกต์
├── registration/       # แอปการลงทะเบียน
├── .env.example        # ตัวอย่างตัวแปรสภาพแวดล้อม
├── Dockerfile          # การกำหนดค่า Docker
├── manage.py           # ยูทิลิตี้บรรทัดคำสั่ง Django
├── requirements.txt    # ขึ้นอยู่กับ Python
└── README.md           # เอกสารโปรเจกต์
```

## การกำหนดค่าไปป์ไลน์ CI/CD

ในไปป์ไลน์ CI/CD ข้อมูลลับจะถูกฉีดเป็นตัวแปรสภาพแวดล้อม:

1. เพิ่ม `DJANGO_SECRET_KEY` เป็นข้อมูลลับในแพลตฟอร์มไปป์ไลน์ของคุณ
2. กำหนดค่างานการติดตั้งของคุณเพื่อส่งผ่านข้อมูลลับนี้ไปยังคอนเทนเนอร์

ตัวอย่างการทำงานของ GitHub Actions:
```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build and deploy
        env:
          DJANGO_SECRET_KEY: ${{ secrets.DJANGO_SECRET_KEY }}
        run: |
          docker build -t django-basic .
          # คำสั่งการติดตั้งที่นี่พร้อมข้อมูลลับที่ฉีด
```

## หมายเหตุด้านความปลอดภัย

- อย่าคอมมิตข้อมูลลับไปยังที่เก็บ
- ฉีด `DJANGO_SECRET_KEY` ผ่านตัวแปรสภาพแวดล้อมหรือการจัดการข้อมูลลับเสมอ
- ปิดโหมดดีบักในการใช้งานจริงโดยตั้งค่า `DJANGO_DEBUG=False`
- ทบทวนเอกสารความปลอดภัยของ Django: https://docs.djangoproject.com/en/stable/topics/security/

## เวิร์กโฟลว์ GitHub Actions

ที่เก็บนี้รวมถึงสองเวิร์กโฟลว์:

1. **main.yml**: รันการทดสอบและติดตั้งไปยังการใช้งานจริงเมื่อมีการพุชไปยัง main
2. **dev.yml**: รันการทดสอบและติดตั้งไปยังการพัฒนาเมื่อมีการพุชไปยัง dev

## ใบอนุญาต

© RACKSYNC CO., LTD. สงวนลิขสิทธิ์ทั้งหมด.
