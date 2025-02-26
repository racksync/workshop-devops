# Debian Linux Exercise

## 1. เริ่มต้น

### 1.1 ภาพรวม

เปรียบเทียบกับ Windows:
- Windows: ส่วนใหญ่ใช้ Control Panel หรือ Settings ในการปรับแต่ง
- Linux: ใช้การแก้ไขไฟล์การตั้งค่าภายใน /etc

### 1.2 วิธีการติดตั้ง Debian

- Virtual Machine (VM): ใช้ VirtualBox, VMware หรือ Hyper-V เพื่อทดลองใช้งาน Linux โดยไม่กระทบระบบ Windows
- Dual Boot: ติดตั้ง Debian คู่กับ Windows
- Live USB: รัน Debian จาก USB โดยไม่ต้องติดตั้งลงฮาร์ดดิสก์
- WSL2 (Windows Subsystem for Linux 2): สำหรับผู้ใช้ Windows 10/11 สามารถติดตั้ง Debian ผ่าน WSL2 ได้ทันที

ตัวอย่างการติดตั้งผ่าน WSL2:
```sh
wsl --install -d Debian
```

หลังการติดตั้ง ให้เปิด Windows Terminal แล้วเลือก Debian เพื่อเข้าใช้งาน

## 2. คำสั่งพื้นฐานและการใช้งาน Terminal

### 2.1 Terminal คืออะไร?

Terminal คือโปรแกรมที่ให้ผู้ใช้พิมพ์คำสั่งเพื่อควบคุมและบริหารระบบ Linux (คล้าย Command Prompt หรือ PowerShell ใน Windows)

### 2.2 คำสั่งพื้นฐาน

- `pwd`: แสดงไดเรกทอรีปัจจุบัน
- `ls`: แสดงรายชื่อไฟล์และโฟลเดอร์
- `cd`: เปลี่ยนไดเรกทอรี
- `mkdir`: สร้างโฟลเดอร์ใหม่
- `touch`: สร้างไฟล์ว่าง
- `cp`, `mv`, `rm`: คัดลอก, ย้าย, ลบ ไฟล์หรือโฟลเดอร์

ตัวอย่างการใช้งาน:
```sh
pwd
ls -alF
cd /home/username/Documents
mkdir learn-debian
touch learn-debian/example.txt
cp source.txt destination.txt
mv file.txt newfile.txt
rm file.txt
rm -r foldername  # ลบโฟลเดอร์พร้อมไฟล์ภายใน
```

### 2.3 แบบฝึก

- เปิด Terminal ไปยังโฟลเดอร์ Home (`cd ~`)
- สร้างโฟลเดอร์ชื่อ `learn-debian`
- ภายในโฟลเดอร์ สร้างไฟล์ชื่อ `example.txt`
- ใช้ `ls -l` เพื่อตรวจสอบ

## 3. โครงสร้างไฟล์ใน Debian

### 3.1 โครงสร้างไดเรกทอรีหลักใน Linux

Linux ใช้โครงสร้างไฟล์แบบลำดับชั้น โดยมี Root Directory เป็น `/` แตกต่างจาก Windows ที่แบ่งเป็นไดรฟ์ `C:`, `D:` เป็นต้น

### 3.2 แผนผังโครงสร้างไฟล์

```
/
├── bin     # คำสั่งพื้นฐานของผู้ใช้ทั่วไป
├── boot    # ไฟล์สำหรับบูทระบบ เช่น kernel, boot loader
├── dev     # ไฟล์อุปกรณ์
├── etc     # ไฟล์ตั้งค่าระบบ
├── home    # โฟลเดอร์ของผู้ใช้ (user home directories)
├── lib     # ไลบรารีที่จำเป็น
├── media   # จุด mount สำหรับอุปกรณ์ (USB/CD-ROM)
├── mnt     # จุด mount ชั่วคราว
├── opt     # โปรแกรม/แอปพลิเคชันเพิ่มเติม
├── proc    # ไฟล์ระบบแบบเวอร์ชวล (process info)
├── root    # โฟลเดอร์ home ของ root user
├── run     # ไฟล์ runtime (PID, sock)
├── sbin    # คำสั่งระบบ/ผู้ดูแลระบบ
├── sys     # ไฟล์ระบบแบบเวอร์ชวล (hardware info)
├── tmp     # ไฟล์ชั่วคราว
├── usr     # ไฟล์/โปรแกรมที่ใช้ร่วมกัน
└── var     # ไฟล์ที่มีการเปลี่ยนแปลงบ่อย (log, cache)
```

### 3.3 คำสั่งสำรวจโครงสร้างไฟล์

```sh
ls -l /
ls -la /etc
find / -name "ssh_config" 2>/dev/null
```

ติดตั้ง tree (ถ้ายังไม่มี):
```sh
sudo apt install tree
```

ใช้ `tree -L 2 /` เพื่อดูโครงสร้างไฟล์แบบต้นไม้

### 3.4 แบบฝึก

ใช้ `tree` ดูโครงสร้างใน `/` หรือ `/etc` แล้วสังเกตการจัดเรียง
```sh
tree /etc
```

## 4. การใช้คำสั่ง man และเอกสารช่วยเหลือ

### 4.1 Man Page คืออะไร?

Man Page (Manual Page) คือเอกสารออนไลน์ของ Linux ที่อธิบายวิธีใช้งานของคำสั่งต่าง ๆ

### 4.2 วิธีใช้งาน man

```sh
man ls
```

ใช้ปุ่มลูกศรหรือ Page Up/Down เพื่อเลื่อนดู
กด `/` ตามด้วยคำที่ต้องการค้นหา
กด `q` เพื่อออก

### 4.3 ส่วนประกอบของ man page

- NAME: ชื่อคำสั่งและคำอธิบายสั้น
- SYNOPSIS: รูปแบบการเรียกใช้งาน
- DESCRIPTION: คำอธิบายรายละเอียด
- OPTIONS: ตัวเลือกหรือ flag ที่ใช้กับคำสั่ง
- EXAMPLES: ตัวอย่างการใช้งาน

### 4.4 ตัวอย่างคำสั่งเพิ่มเติม

```sh
man -k network  # ค้นหาคำสั่งที่เกี่ยวกับ network
man -f ls       # แสดงข้อมูลสั้น ๆ ของ ls
```

### 4.5 แบบฝึก

เปิด `man grep`
กด `/option` เพื่อค้นหาเรื่องของ option ใน man page

## 5. การจัดการแพ็คเกจใน Debian

### 5.1 คำสั่งพื้นฐานของ APT (Advanced Package Tool)

```sh
sudo apt update
sudo apt upgrade
sudo apt install <ชื่อแพ็คเกจ>
sudo apt remove <ชื่อแพ็คเกจ>
apt search <คำค้นหา>
```

### 5.2 แบบฝึก

```sh
sudo apt update
sudo apt install nano
nano --version
```

## 6. การจัดการผู้ใช้และกลุ่ม

### 6.1 การจัดการผู้ใช้

สร้างผู้ใช้ใหม่:
```sh
sudo adduser <ชื่อผู้ใช้>
```

เปลี่ยนรหัสผ่าน:
```sh
sudo passwd <ชื่อผู้ใช้>
```

เพิ่มผู้ใช้เข้าในกลุ่ม:
```sh
sudo usermod -aG <ชื่อกลุ่ม> <ชื่อผู้ใช้>
```

### 6.2 การจัดการกลุ่ม

สร้างกลุ่มใหม่:
```sh
sudo groupadd <ชื่อกลุ่ม>
```

เพิ่มผู้ใช้เข้าในกลุ่ม:
```sh
sudo usermod -aG <ชื่อกลุ่ม> <ชื่อผู้ใช้>
```

### 6.3 แบบฝึก

ใช้ `id <ชื่อผู้ใช้>` เพื่อตรวจสอบว่าผู้ใช้อยู่ในกลุ่มใด

## 7. พื้นฐานเครือข่ายและการบริหารระบบ

### 7.1 คำสั่งเครือข่ายพื้นฐาน

- `ip addr show`: แสดงที่อยู่ IP
- `ping google.com`: ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต
- `netstat -tuln` หรือ `ss -tuln`: ดูพอร์ตที่เปิดรับการเชื่อมต่อ

### 7.2 ไฟล์การตั้งค่าเครือข่าย

- `/etc/hosts`: แมปชื่อโฮสต์กับ IP
- `/etc/resolv.conf`: ตั้งค่า DNS Server

### 7.3 แบบฝึก

ใช้ `ip addr show` ตรวจสอบ IP
แก้ไข `/etc/hosts` เพิ่ม `127.0.0.1 mylocal.dev` แล้วลอง `ping mylocal.dev`

## 8. Shell Scripting

### 8.1 Shell Scripting คืออะไร?

Shell Scripting คือการเขียนโปรแกรม (สคริปต์) เพื่อสั่งงานซ้ำ ๆ และอัตโนมัติบน Shell

### 8.2 ตัวอย่างสคริปต์ง่าย ๆ

```sh
#!/bin/bash
echo "สวัสดี, $(whoami)! ยินดีต้อนรับสู่ Debian Linux."
```

### 8.3 คำสั่งเพิ่มเติมใน Shell Scripting

อ่านค่าจากผู้ใช้:
```sh
read -p "กรุณาใส่ชื่อของคุณ: " username
echo "สวัสดี, $username!"
```

ลูป for:
```sh
for i in {1..5}; do
    echo "เลขที่: $i"
done
```

if-else:
```sh
if [ -f "example.txt" ]; then
    echo "ไฟล์ example.txt มีอยู่แล้ว"
else
    echo "ไม่พบไฟล์ example.txt"
fi
```

### 8.4 แบบฝึก

- สร้างไฟล์ชื่อ `greet.sh` แล้วใส่สคริปต์
- เปลี่ยนโหมดให้ไฟล์รันได้ด้วย `chmod +x greet.sh`
- รันไฟล์ด้วยคำสั่ง `./greet.sh`

## 9. เครื่องมือเพิ่มเติมสำหรับ DevOps

### 9.1 Git

```sh
git clone <repository_url>
git add .
git commit -m "ข้อความ commit"
git push origin main
```

### 9.2 เครื่องมือ Automation อื่น ๆ

- Jenkins
- Ansible

### 9.3 ขั้นตอนถัดไป

- ติดตั้ง Git (`sudo apt install git`)
- สร้างหรือ clone repository และทดลอง commit

## 10. การจัดการสิทธิ์ไฟล์และการบริหารโปรเซส

### 10.1 การจัดการสิทธิ์ไฟล์ (File Permissions)

- `chmod`: ปรับระดับสิทธิ์ (r, w, x) สำหรับ owner, group, others
  ```sh
  chmod 755 script.sh
  chmod u+x file.txt
  ```

- `chown`: เปลี่ยนเจ้าของไฟล์/โฟลเดอร์
  ```sh
  sudo chown user:group file.txt
  ```

- `chgrp`: เปลี่ยนกลุ่มของไฟล์/โฟลเดอร์
  ```sh
  sudo chgrp developers file.txt
  ```

### 10.2 การบริหารโปรเซส (Process Management)

- `ps`: แสดงรายการโปรเซสที่กำลังทำงาน (`ps aux`)
- `top`/`htop`: ดูการใช้งาน CPU/Memory แบบเรียลไทม์
- `kill`: หยุดโปรเซส
  ```sh
  kill <PID>
  ```

## 11. หัวข้อเพิ่มเติม

### 11.1 Lm-sensors

ใช้ตรวจสอบอุณหภูมิ ความเร็วพัดลม และแรงดันไฟฟ้าของฮาร์ดแวร์
```sh
sudo apt install lm-sensors
sudo sensors-detect
sensors
```

### 11.2 Compress

คำสั่งบีบอัดและแตกไฟล์

- tar:
  ```sh
  tar -czvf archive.tar.gz folder/
  tar -xzvf archive.tar.gz
  ```

- gzip / gunzip:
  ```sh
  gzip file.txt
  gunzip file.txt.gz
  ```

- zip / unzip:
  ```sh
  apt install zip unzip
  zip -r compress_file.zip original_file.txt
  unzip compress_file.zip
  ```

### 11.3 W

คำสั่ง `w` แสดงผู้ใช้ที่ล็อกอินอยู่และกิจกรรมล่าสุด
```sh
w
```

### 11.4 Relative Path vs Absolute Path

- Absolute Path: ระบุจาก `/` เช่น `/home/user/docs`
- Relative Path: ระบุจากตำแหน่งปัจจุบัน เช่น `./docs` หรือ `../docs`

### 11.5 wget

เครื่องมือสำหรับดาวน์โหลด
```sh
wget https://www.domain.com/file.zip
```

### 11.6 Df

แสดงพื้นที่ใช้งานในดิสก์
```sh
df -h
```

### 11.7 Last

แสดงประวัติการล็อกอินของผู้ใช้
```sh
last
```

### 11.8 Dmesg

แสดงข้อความ kernel log ใช้ตรวจสอบปัญหาเกี่ยวกับฮาร์ดแวร์หรือ driver
```sh
dmesg | less
```

### 11.9 Find

ค้นหาไฟล์หรือโฟลเดอร์ในระบบ
```sh
find / -name "*.log"
```

### 11.10 Which

หาตำแหน่งของคำสั่งในระบบ
```sh
which python3
```
