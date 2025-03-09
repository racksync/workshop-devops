# Debian Linux Tutorial

## สารบัญ

- [Debian Linux Tutorial](#debian-linux-tutorial)
  - [สารบัญ](#สารบัญ)
  - [1. เริ่มต้น](#1-เริ่มต้น)
    - [1.1 ภาพรวม](#11-ภาพรวม)
    - [1.2 วิธีการติดตั้ง Debian](#12-วิธีการติดตั้ง-debian)
  - [2. คำสั่งพื้นฐานและการใช้งาน Terminal](#2-คำสั่งพื้นฐานและการใช้งาน-terminal)
    - [2.1 Terminal คืออะไร?](#21-terminal-คืออะไร)
    - [2.2 คำสั่งพื้นฐาน](#22-คำสั่งพื้นฐาน)
    - [2.3 แบบฝึก](#23-แบบฝึก)
  - [3. โครงสร้างไฟล์ใน Debian](#3-โครงสร้างไฟล์ใน-debian)
    - [3.1 โครงสร้างไดเรกทอรีหลักใน Linux](#31-โครงสร้างไดเรกทอรีหลักใน-linux)
    - [3.2 แผนผังโครงสร้างไฟล์](#32-แผนผังโครงสร้างไฟล์)
    - [3.3 คำสั่งสำรวจโครงสร้างไฟล์](#33-คำสั่งสำรวจโครงสร้างไฟล์)
    - [3.4 แบบฝึก](#34-แบบฝึก)
  - [4. การใช้คำสั่ง man และเอกสารช่วยเหลือ](#4-การใช้คำสั่ง-man-และเอกสารช่วยเหลือ)
    - [4.1 Man Page คืออะไร?](#41-man-page-คืออะไร)
    - [4.2 วิธีใช้งาน man](#42-วิธีใช้งาน-man)
    - [4.3 ส่วนประกอบของ man page](#43-ส่วนประกอบของ-man-page)
    - [4.4 ตัวอย่างคำสั่งเพิ่มเติม](#44-ตัวอย่างคำสั่งเพิ่มเติม)
    - [4.5 แบบฝึก](#45-แบบฝึก)
  - [5. การจัดการแพ็คเกจใน Debian](#5-การจัดการแพ็คเกจใน-debian)
    - [5.1 คำสั่งพื้นฐานของ APT (Advanced Package Tool)](#51-คำสั่งพื้นฐานของ-apt-advanced-package-tool)
    - [5.2 แบบฝึก](#52-แบบฝึก)
  - [6. การจัดการผู้ใช้และกลุ่ม](#6-การจัดการผู้ใช้และกลุ่ม)
    - [6.1 การจัดการผู้ใช้](#61-การจัดการผู้ใช้)
    - [6.2 การจัดการกลุ่ม](#62-การจัดการกลุ่ม)
    - [6.3 แบบฝึก](#63-แบบฝึก)
  - [7. พื้นฐานเครือข่ายและการบริหารระบบ](#7-พื้นฐานเครือข่ายและการบริหารระบบ)
    - [7.1 คำสั่งเครือข่ายพื้นฐาน](#71-คำสั่งเครือข่ายพื้นฐาน)
    - [7.2 ไฟล์การตั้งค่าเครือข่าย](#72-ไฟล์การตั้งค่าเครือข่าย)
    - [7.3 แบบฝึก](#73-แบบฝึก)
  - [8. Shell Scripting](#8-shell-scripting)
    - [8.1 Shell Scripting คืออะไร?](#81-shell-scripting-คืออะไร)
    - [8.2 ตัวอย่างสคริปต์ง่าย ๆ](#82-ตัวอย่างสคริปต์ง่าย-ๆ)
    - [8.3 คำสั่งเพิ่มเติมใน Shell Scripting](#83-คำสั่งเพิ่มเติมใน-shell-scripting)
    - [8.4 แบบฝึก](#84-แบบฝึก)
  - [9. เครื่องมือเพิ่มเติมสำหรับ DevOps](#9-เครื่องมือเพิ่มเติมสำหรับ-devops)
    - [9.1 Git](#91-git)
    - [9.2 เครื่องมือ Automation อื่น ๆ](#92-เครื่องมือ-automation-อื่น-ๆ)
    - [9.3 ขั้นตอนถัดไป](#93-ขั้นตอนถัดไป)
  - [10. การจัดการสิทธิ์ไฟล์และการบริหารโปรเซส](#10-การจัดการสิทธิ์ไฟล์และการบริหารโปรเซส)
    - [10.1 การจัดการสิทธิ์ไฟล์ (File Permissions)](#101-การจัดการสิทธิ์ไฟล์-file-permissions)
    - [10.2 การบริหารโปรเซส (Process Management)](#102-การบริหารโปรเซส-process-management)
  - [11. หัวข้อเพิ่มเติม](#11-หัวข้อเพิ่มเติม)
    - [11.1 Lm-sensors](#111-lm-sensors)
    - [11.2 Compress](#112-compress)
    - [11.3 W](#113-w)
    - [11.4 Relative Path vs Absolute Path](#114-relative-path-vs-absolute-path)
    - [11.5 wget](#115-wget)
    - [11.6 Df](#116-df)
    - [11.7 Last](#117-last)
    - [11.8 Dmesg](#118-dmesg)
    - [11.9 Find](#119-find)
    - [11.10 Which](#1110-which)
  - [12. ระบบไฟล์ขั้นสูง](#12-ระบบไฟล์ขั้นสูง)
    - [12.1 ประเภทของระบบไฟล์ใน Linux](#121-ประเภทของระบบไฟล์ใน-linux)
    - [12.2 LVM (Logical Volume Management)](#122-lvm-logical-volume-management)
    - [12.3 RAID (Redundant Array of Independent Disks)](#123-raid-redundant-array-of-independent-disks)
    - [12.4 การจัดการ Mount Points และ fstab](#124-การจัดการ-mount-points-และ-fstab)
    - [12.5 การใช้ inodes และ block](#125-การใช้-inodes-และ-block)
  - [13. การจัดการผู้ใช้ขั้นสูง](#13-การจัดการผู้ใช้ขั้นสูง)
    - [13.1 PAM (Pluggable Authentication Modules)](#131-pam-pluggable-authentication-modules)
    - [13.2 การจัดการสิทธิ์ขั้นสูง](#132-การจัดการสิทธิ์ขั้นสูง)
      - [ACL (Access Control Lists)](#acl-access-control-lists)
      - [Sudo และ Sudoers](#sudo-และ-sudoers)
    - [13.3 Resource Limits](#133-resource-limits)
    - [13.4 User Quotas](#134-user-quotas)
  - [14. ความปลอดภัยระบบ Linux](#14-ความปลอดภัยระบบ-linux)
    - [14.1 การรักษาความปลอดภัยระดับพื้นฐาน](#141-การรักษาความปลอดภัยระดับพื้นฐาน)
    - [14.2 ไฟร์วอลล์ด้วย UFW (Uncomplicated Firewall)](#142-ไฟร์วอลล์ด้วย-ufw-uncomplicated-firewall)
    - [14.3 Fail2ban สำหรับป้องกันการโจมตี Brute Force](#143-fail2ban-สำหรับป้องกันการโจมตี-brute-force)
    - [14.4 SELinux/AppArmor](#144-selinuxapparmor)
      - [AppArmor (มาตรฐานใน Debian/Ubuntu)](#apparmor-มาตรฐานใน-debianubuntu)
      - [SELinux (มาตรฐานใน Fedora/CentOS/RHEL)](#selinux-มาตรฐานใน-fedoracentosrhel)
    - [14.5 Auditd สำหรับการตรวจสอบระบบ](#145-auditd-สำหรับการตรวจสอบระบบ)
    - [14.6 การเข้ารหัสและ GPG](#146-การเข้ารหัสและ-gpg)
    - [14.7 การสแกนช่องโหว่ด้วย Lynis](#147-การสแกนช่องโหว่ด้วย-lynis)
  - [15. Systemd และการจัดการบริการ](#15-systemd-และการจัดการบริการ)
    - [15.1 พื้นฐาน Systemd](#151-พื้นฐาน-systemd)
    - [15.2 การสร้าง Systemd Service เอง](#152-การสร้าง-systemd-service-เอง)
    - [15.3 การจัดการ Systemd Timers (ทางเลือกทดแทน Cron)](#153-การจัดการ-systemd-timers-ทางเลือกทดแทน-cron)
    - [15.4 Systemd Journal](#154-systemd-journal)
  - [16. Linux Performance Monitoring](#16-linux-performance-monitoring)
    - [16.1 เครื่องมือติดตามประสิทธิภาพ](#161-เครื่องมือติดตามประสิทธิภาพ)
    - [16.2 การใช้งาน Atop และ Iotop](#162-การใช้งาน-atop-และ-iotop)
    - [16.3 การเก็บข้อมูลประสิทธิภาพด้วย SAR](#163-การเก็บข้อมูลประสิทธิภาพด้วย-sar)
    - [16.4 การวิเคราะห์ Network Traffic](#164-การวิเคราะห์-network-traffic)
    - [16.5 การวิเคราะห์ระบบด้วย strace และ ltrace](#165-การวิเคราะห์ระบบด้วย-strace-และ-ltrace)
  - [17. การทำ Linux Automation](#17-การทำ-linux-automation)
    - [17.1 Crontab ขั้นสูง](#171-crontab-ขั้นสูง)
    - [17.2 การใช้ Ansible สำหรับ Configuration Management](#172-การใช้-ansible-สำหรับ-configuration-management)
    - [17.3 การใช้ Shell Script กับ Expect](#173-การใช้-shell-script-กับ-expect)
    - [17.4 ใช้ AWK สำหรับประมวลผลข้อความขั้นสูง](#174-ใช้-awk-สำหรับประมวลผลข้อความขั้นสูง)
    - [17.5 การจัดการงาน (Jobs) ขั้นสูง](#175-การจัดการงาน-jobs-ขั้นสูง)
  - [18. การสำรองข้อมูลและการกู้คืน](#18-การสำรองข้อมูลและการกู้คืน)
    - [18.1 การใช้ rsync สำหรับการสำรองข้อมูล](#181-การใช้-rsync-สำหรับการสำรองข้อมูล)
    - [18.2 การสำรองข้อมูลด้วย Duplicity](#182-การสำรองข้อมูลด้วย-duplicity)
    - [18.3 การสำรองและกู้คืนด้วย dd](#183-การสำรองและกู้คืนด้วย-dd)

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

## 12. ระบบไฟล์ขั้นสูง

### 12.1 ประเภทของระบบไฟล์ใน Linux

Linux รองรับระบบไฟล์หลายประเภท แต่ละประเภทมีข้อดีและข้อเสียต่างกัน:

- **ext4**: ระบบไฟล์มาตรฐานของ Linux ที่มีประสิทธิภาพสูงและเสถียร
- **XFS**: เหมาะสำหรับไฟล์ขนาดใหญ่และระบบที่มีการเขียนข้อมูลมาก
- **Btrfs**: ระบบไฟล์รุ่นใหม่ที่มีคุณสมบัติ copy-on-write และ snapshots
- **ZFS**: ระบบไฟล์ขั้นสูงที่มี data integrity สูงและรองรับการทำ RAID
- **F2FS**: ออกแบบมาเพื่ออุปกรณ์ flash storage

```sh
# ตรวจสอบระบบไฟล์ของพาร์ติชัน
sudo df -T

# สร้างระบบไฟล์บน USB drive
sudo mkfs.ext4 /dev/sdX1
```

### 12.2 LVM (Logical Volume Management)

LVM ช่วยให้การจัดการพื้นที่ดิสก์มีความยืดหยุ่นมากขึ้น:

```sh
# ติดตั้ง LVM
sudo apt install lvm2

# สร้าง Physical Volume
sudo pvcreate /dev/sdb

# สร้าง Volume Group
sudo vgcreate vg_data /dev/sdb

# สร้าง Logical Volume
sudo lvcreate -n lv_apps -L 20G vg_data

# สร้างระบบไฟล์บน Logical Volume
sudo mkfs.ext4 /dev/vg_data/lv_apps

# Mount Logical Volume
sudo mount /dev/vg_data/lv_apps /mnt/apps
```

### 12.3 RAID (Redundant Array of Independent Disks)

การทำ RAID ช่วยเพิ่มประสิทธิภาพและความน่าเชื่อถือของระบบ:

```sh
# ติดตั้ง mdadm
sudo apt install mdadm

# สร้าง RAID 1 (Mirror)
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1

# ตรวจสอบสถานะ RAID
cat /proc/mdstat
sudo mdadm --detail /dev/md0
```

### 12.4 การจัดการ Mount Points และ fstab

การจัดการจุดเชื่อมต่อ (mount points) แบบถาวรด้วยการแก้ไขไฟล์ `/etc/fstab`:

```sh
# เพิ่มบรรทัดใน /etc/fstab สำหรับ mount อัตโนมัติเมื่อเริ่มระบบ
/dev/vg_data/lv_apps  /mnt/apps  ext4  defaults  0  2

# สำหรับ NFS
server:/share  /mnt/nfs  nfs  defaults  0  0

# สำหรับ SMB/CIFS
//server/share  /mnt/smb  cifs  credentials=/etc/samba/credentials,uid=1000,gid=1000  0  0

# ตรวจสอบ fstab หาข้อผิดพลาด
sudo findmnt --verify
```

### 12.5 การใช้ inodes และ block

```sh
# ตรวจสอบการใช้งาน inodes
df -i

# หาโฟลเดอร์ที่มีไฟล์จำนวนมาก (ใช้ inodes เยอะ)
find / -xdev -type f | cut -d "/" -f 2 | sort | uniq -c | sort -n
```

## 13. การจัดการผู้ใช้ขั้นสูง

### 13.1 PAM (Pluggable Authentication Modules)

PAM เป็นระบบรับรองตัวตนแบบโมดูลาร์ใน Linux:

```sh
# ไฟล์ตั้งค่า PAM
ls -la /etc/pam.d/

# ตัวอย่างการตั้งค่าให้ผู้ใช้ต้องมีรหัสผ่านที่ซับซ้อน
sudo apt install libpam-pwquality
sudo nano /etc/pam.d/common-password
# เพิ่มพารามิเตอร์: retry=3 minlen=12 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1
```

### 13.2 การจัดการสิทธิ์ขั้นสูง

#### ACL (Access Control Lists)

ACL ช่วยให้กำหนดสิทธิ์ได้ละเอียดมากกว่า chmod ปกติ:

```sh
# ติดตั้ง ACL
sudo apt install acl

# กำหนดสิทธิ์ให้ผู้ใช้เฉพาะ
setfacl -m u:username:rwx file.txt

# กำหนดสิทธิ์ให้กลุ่ม
setfacl -m g:groupname:rw file.txt

# แสดงการตั้งค่า ACL
getfacl file.txt

# นำ ACL ออก
setfacl -x u:username file.txt
```

#### Sudo และ Sudoers

การตั้งค่าขั้นสูงของ sudo:

```sh
# แก้ไขไฟล์ sudoers (แนะนำให้ใช้ visudo เสมอ)
sudo visudo

# ตัวอย่างการกำหนดสิทธิ์เฉพาะคำสั่ง
username ALL=(ALL) /usr/bin/apt, /bin/systemctl restart apache2

# กำหนดให้ไม่ต้องใส่รหัสผ่านเมื่อใช้ sudo
username ALL=(ALL) NOPASSWD: ALL
```

### 13.3 Resource Limits

จำกัดทรัพยากรที่ผู้ใช้สามารถใช้งานได้:

```sh
# แก้ไขไฟล์ limits.conf
sudo nano /etc/security/limits.conf

# ตัวอย่าง - จำกัดจำนวนไฟล์ที่เปิดได้
username hard nofile 4096
username soft nofile 1024

# จำกัด CPU และ RAM ที่ใช้ได้
username hard as 1000000
username hard cpu 50
```

### 13.4 User Quotas

จำกัดพื้นที่ดิสก์ที่ผู้ใช้สามารถใช้ได้:

```sh
# ติดตั้ง quota
sudo apt install quota

# แก้ไข /etc/fstab เพิ่ม usrquota,grpquota
/dev/sda1 / ext4 defaults,usrquota,grpquota 0 1

# Remount หรือรีบูท
sudo mount -o remount /

# เปิดใช้งาน quota
sudo quotacheck -cugm /
sudo quotaon -v /

# กำหนด quota
sudo edquota -u username
sudo edquota -g groupname

# ตรวจสอบ quota ที่ใช้งาน
sudo quota -vs username
```

## 14. ความปลอดภัยระบบ Linux

### 14.1 การรักษาความปลอดภัยระดับพื้นฐาน

```sh
# อัปเดตระบบสม่ำเสมอ
sudo apt update && sudo apt upgrade

# ตรวจสอบพอร์ตที่เปิดรับการเชื่อมต่อ
sudo ss -tuln

# ปิดบริการที่ไม่จำเป็น
sudo systemctl disable SERVICE_NAME
sudo systemctl stop SERVICE_NAME
```

### 14.2 ไฟร์วอลล์ด้วย UFW (Uncomplicated Firewall)

```sh
# ติดตั้ง UFW
sudo apt install ufw

# กำหนดกฎเบื้องต้น - ปฏิเสธการเชื่อมต่อขาเข้าทั้งหมด
sudo ufw default deny incoming
sudo ufw default allow outgoing

# อนุญาตบริการเฉพาะ
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow from 192.168.1.0/24 to any port 22

# เปิดใช้งาน UFW
sudo ufw enable

# ตรวจสอบสถานะและกฎ
sudo ufw status verbose
```

### 14.3 Fail2ban สำหรับป้องกันการโจมตี Brute Force

```sh
# ติดตั้ง Fail2ban
sudo apt install fail2ban

# สร้างไฟล์ตั้งค่าเอง
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local

# ตัวอย่างการตั้งค่า - แบนหลังจากล็อกอินผิด 5 ครั้ง เป็นเวลา 1 ชั่วโมง
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
bantime = 3600

# รีสตาร์ท Fail2ban
sudo systemctl restart fail2ban

# ตรวจสอบสถานะ
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

### 14.4 SELinux/AppArmor

#### AppArmor (มาตรฐานใน Debian/Ubuntu)

```sh
# ตรวจสอบสถานะ
aa-status

# ดูโปรไฟล์ทั้งหมด
ls /etc/apparmor.d/

# สร้างโปรไฟล์ใหม่
sudo aa-genprof /path/to/program

# เปิด/ปิดโปรไฟล์
sudo aa-enforce /etc/apparmor.d/profile_name
sudo aa-complain /etc/apparmor.d/profile_name
sudo aa-disable /etc/apparmor.d/profile_name
```

#### SELinux (มาตรฐานใน Fedora/CentOS/RHEL)

```sh
# ติดตั้ง SELinux บน Debian
sudo apt install selinux-basics selinux-policy-default

# เรียกใช้ selinux-activate และรีบูท
sudo selinux-activate
sudo reboot

# ตรวจสอบสถานะ
sestatus
```

### 14.5 Auditd สำหรับการตรวจสอบระบบ

```sh
# ติดตั้ง auditd
sudo apt install auditd

# ตั้งค่ากฎการตรวจสอบ
sudo nano /etc/audit/rules.d/audit.rules

# เพิ่มกฎติดตามการเข้าถึงไฟล์สำคัญ
-w /etc/passwd -p wa -k user_modification
-w /etc/shadow -p wa -k user_modification
-w /etc/sudoers -p wa -k sudo_modification

# รีสตาร์ท auditd
sudo systemctl restart auditd

# ค้นหาข้อมูล audit
sudo ausearch -k user_modification
```

### 14.6 การเข้ารหัสและ GPG

```sh
# สร้างคู่กุญแจ GPG
gpg --full-generate-key

# เข้ารหัสไฟล์
gpg --encrypt --recipient user@example.com file.txt

# ถอดรหัสไฟล์
gpg --decrypt file.txt.gpg > file.txt

# เซ็นไฟล์ดิจิทัล
gpg --sign document.txt

# ตรวจสอบลายเซ็น
gpg --verify document.txt.gpg
```

### 14.7 การสแกนช่องโหว่ด้วย Lynis

```sh
# ติดตั้ง Lynis
sudo apt install lynis

# ทำการสแกนระบบ
sudo lynis audit system

# ดูรายงานล่าสุด
cat /var/log/lynis.log
```

## 15. Systemd และการจัดการบริการ

### 15.1 พื้นฐาน Systemd

Systemd เป็นระบบ init และจัดการบริการหลักของ Linux สมัยใหม่:

```sh
# ตรวจสอบสถานะบริการ
systemctl status SERVICE_NAME

# เปิด/ปิดบริการ
sudo systemctl start SERVICE_NAME
sudo systemctl stop SERVICE_NAME

# ตั้งค่าให้ทำงานเมื่อเริ่มระบบ
sudo systemctl enable SERVICE_NAME
sudo systemctl disable SERVICE_NAME

# รีสตาร์ทบริการ
sudo systemctl restart SERVICE_NAME

# โหลดการตั้งค่าใหม่โดยไม่หยุดบริการ
sudo systemctl reload SERVICE_NAME
```

### 15.2 การสร้าง Systemd Service เอง

```sh
# สร้างไฟล์บริการใหม่
sudo nano /etc/systemd/system/myapp.service

# ตัวอย่างไฟล์ service
[Unit]
Description=My Custom Application
After=network.target

[Service]
Type=simple
User=myuser
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/python3 /opt/myapp/app.py
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target

# โหลดไฟล์บริการใหม่
sudo systemctl daemon-reload
sudo systemctl enable myapp
sudo systemctl start myapp
```

### 15.3 การจัดการ Systemd Timers (ทางเลือกทดแทน Cron)

```sh
# สร้างไฟล์ timer
sudo nano /etc/systemd/system/backup.timer

# ตัวอย่างไฟล์ timer
[Unit]
Description=Daily backup timer

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target

# สร้างไฟล์ service ที่ทำงานเมื่อ timer ทำงาน
sudo nano /etc/systemd/system/backup.service

[Unit]
Description=Daily backup service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/backup-script.sh

# เปิดใช้งาน timer
sudo systemctl daemon-reload
sudo systemctl enable backup.timer
sudo systemctl start backup.timer

# ดูรายการ timers ทั้งหมด
systemctl list-timers
```

### 15.4 Systemd Journal

```sh
# ดูข้อความ log ล่าสุด
journalctl -e

# ดูข้อความ log ของบริการเฉพาะ
journalctl -u SERVICE_NAME

# กรองตามช่วงเวลา
journalctl --since "2023-01-01" --until "2023-01-02"

# ติดตาม log แบบเรียลไทม์
journalctl -f

# ดูข้อความ log ของการบูทครั้งล่าสุด
journalctl -b
```

## 16. Linux Performance Monitoring

### 16.1 เครื่องมือติดตามประสิทธิภาพ

```sh
# สถิติ CPU, Memory, Process
top
htop  # (ต้องติดตั้งเพิ่ม: sudo apt install htop)

# สถานะการใช้ Memory
free -h

# การใช้งานดิสก์
df -h
du -sh /path/to/directory

# สถิติระบบ
vmstat 1
```

### 16.2 การใช้งาน Atop และ Iotop

```sh
# ติดตั้ง Atop และ Iotop
sudo apt install atop iotop

# ใช้งาน Atop
atop

# ดูกิจกรรม I/O ของระบบ
sudo iotop
```

### 16.3 การเก็บข้อมูลประสิทธิภาพด้วย SAR

```sh
# ติดตั้ง SAR
sudo apt install sysstat

# เปิดใช้งานการเก็บข้อมูล
sudo nano /etc/default/sysstat
ENABLED="true"

# รีสตาร์ทบริการ
sudo systemctl restart sysstat

# ดูรายงานประสิทธิภาพ CPU
sar -u

# ดูรายงานการใช้งาน Memory
sar -r

# ดูรายงานการใช้งานดิสก์
sar -b
```

### 16.4 การวิเคราะห์ Network Traffic

```sh
# ติดตั้ง nethogs และ iftop
sudo apt install nethogs iftop

# ดูแบนด์วิดท์ที่ใช้โดยแต่ละโปรเซส
sudo nethogs

# ดูการใช้งานเครือข่ายแบบเรียลไทม์
sudo iftop
```

### 16.5 การวิเคราะห์ระบบด้วย strace และ ltrace

```sh
# ติดตั้ง strace และ ltrace
sudo apt install strace ltrace

# ติดตาม system calls ของโปรเซส
sudo strace -p PID

# ติดตาม library calls ของโปรเซส
sudo ltrace -p PID
```

## 17. การทำ Linux Automation

### 17.1 Crontab ขั้นสูง

```sh
# แก้ไข crontab
crontab -e

# รูปแบบ crontab: m h dom mon dow command
# ตัวอย่าง - รันทุกวันจันทร์เวลา 8:00
0 8 * * 1 /path/to/script.sh

# รองรับช่วงเวลาและตัวคั่น
*/5 9-17 * * 1-5 /path/to/workday_script.sh  # ทุก 5 นาทีในเวลาทำงานวันจันทร์-ศุกร์
```

### 17.2 การใช้ Ansible สำหรับ Configuration Management

```sh
# ติดตั้ง Ansible
sudo apt install ansible

# สร้างไฟล์ inventory
sudo nano /etc/ansible/hosts
[webservers]
web1.example.com
web2.example.com

# ทดสอบการเชื่อมต่อ
ansible webservers -m ping

# รันคำสั่งบนเซิร์ฟเวอร์ทั้งหมด
ansible webservers -a "df -h"

# สร้างและรัน playbook
sudo nano webserver.yml
---
- hosts: webservers
  tasks:
    - name: Install Nginx
      apt:
        name: nginx
        state: latest

# รัน playbook
ansible-playbook webserver.yml
```

### 17.3 การใช้ Shell Script กับ Expect

Expect ช่วยให้ทำงานอัตโนมัติกับโปรแกรมที่ต้องการการโต้ตอบ:

```sh
# ติดตั้ง Expect
sudo apt install expect

# ตัวอย่าง script expect
#!/usr/bin/expect

spawn ssh user@example.com
expect "password:"
send "your-password\r"
expect "$ "
send "ls -la\r"
expect "$ "
send "exit\r"
expect eof
```

### 17.4 ใช้ AWK สำหรับประมวลผลข้อความขั้นสูง

```sh
# ดึงคอลัมน์เฉพาะจากไฟล์
awk '{print $1, $3}' file.txt

# คำนวณค่าเฉลี่ย
cat values.txt | awk '{sum+=$1} END {print sum/NR}'

# นับจำนวนการเกิดของแต่ละคำ
cat file.txt | awk '{for(i=1;i<=NF;i++) words[$i]++} END {for(w in words) print w, words[w]}'

# แทนที่ข้อความในไฟล์
awk '{gsub(/old/, "new"); print}' file.txt > newfile.txt
```

### 17.5 การจัดการงาน (Jobs) ขั้นสูง

```sh
# รันงานในพื้นหลัง
command &

# แสดงรายการงานที่กำลังทำงาน
jobs

# นำงานกลับมาทำงานในพื้นหน้า
fg %job_number

# ส่งงานไปทำงานในพื้นหลัง
bg %job_number

# รันคำสั่งอย่างต่อเนื่องแม้จะออกจาก terminal (nohup)
nohup command > output.log &

# จำกัดทรัพยากรสำหรับคำสั่ง
nice -n 19 command  # น้อยที่สุด
sudo nice -n -20 command  # มากที่สุด
```

## 18. การสำรองข้อมูลและการกู้คืน

### 18.1 การใช้ rsync สำหรับการสำรองข้อมูล

```sh
# ทำสำเนาไฟล์และโฟลเดอร์
rsync -a source/ destination/

# รวมการบีบอัด
rsync -az source/ destination/

# แสดงความคืบหน้า
rsync -azP source/ destination/

# สำรองข้อมูลไปยัง remote server
rsync -azP source/ user@remote_host:/path/to/destination/

# แบบเก็บประวัติ
rsync -azP --link-dest=/path/to/prev_backup source/ /path/to/new_backup/
```

### 18.2 การสำรองข้อมูลด้วย Duplicity

```sh
# ติดตั้ง Duplicity
sudo apt install duplicity

# สำรองข้อมูลไปยัง FTP server
duplicity /home/user/data ftp://user:pass@ftp.example.com/backup

# สำรองข้อมูลแบบเข้ารหัส
duplicity --encrypt-key key_id /home/user/data rsync://user@backup.example.com/backup

# กู้คืนข้อมูลทั้งหมด
duplicity restore rsync://user@backup.example.com/backup /home/user/restored_data
```

### 18.3 การสำรองและกู้คืนด้วย dd

```sh
# สำรองพาร์ติชันทั้งหมด
sudo dd if=/dev/sda1 of=/path/to/sda1.img bs=4M status=progress

# กู้คืนพาร์ติชัน
sudo dd if=/path/to/sda1.img of=/dev/sda1 bs=4M status=progress

# สำรอง MBR
sudo dd if=/dev/sda of=mbr.img bs=512 count=1
```
