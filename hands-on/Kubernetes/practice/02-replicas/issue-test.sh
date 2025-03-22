#!/bin/bash

# Script for testing replica behavior in Kubernetes

# Define color variables
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function for displaying status messages
print_status() {
  echo -e "${YELLOW}$1${NC}"
}

# Function for displaying success messages
print_success() {
  echo -e "${GREEN}$1${NC}"
}

# Function for displaying error messages
print_error() {
  echo -e "${RED}$1${NC}"
}

# Function for displaying test messages
print_test() {
  echo -e "${BLUE}$1${NC}"
}

# Function for checking errors
check_error() {
  if [ $? -ne 0 ]; then
    print_error "$1"
    exit 1
  fi
}

# Function to wait for user input before continuing
pause() {
  read -p "กด Enter เพื่อดำเนินการต่อ..."
}

# Check if namespace exists
if ! kubectl get namespace replica-demo &> /dev/null; then
  print_error "Namespace 'replica-demo' ไม่พบ กรุณารัน deploy.sh ก่อน"
  exit 1
fi

# Set the namespace context
print_status "กำลังตั้งค่า namespace เป็น replica-demo..."
echo ""
kubectl config set-context --current --namespace=replica-demo
check_error "ไม่สามารถตั้งค่า namespace ได้"
print_success "ตั้งค่า namespace สำเร็จ"

# Display header
echo "
=======================================================
        การทดสอบพฤติกรรมของ Replicas ใน Kubernetes
=======================================================
"

# Test 1: Check the current state of replicas
print_test "Test 1: ตรวจสอบสถานะปัจจุบันของ replicas"
echo "กำลังตรวจสอบจำนวน pods ทั้งหมด..."
echo ""
kubectl get pods -o wide
check_error "ไม่สามารถดึงข้อมูล pods ได้"

echo ""
kubectl get deployment nginx-deployment -o jsonpath='{.spec.replicas}' | xargs -I{} echo "จำนวน replicas ที่กำหนดไว้ในปัจจุบัน: {}"
check_error "ไม่สามารถดึงข้อมูล replicas ได้"
echo ""

# Provide information about auto-healing
print_status "ข้อมูล: Kubernetes จะรักษาจำนวน replicas ให้ตรงตามที่กำหนดไว้เสมอ"
pause

# Test 2: Delete a pod and observe auto-healing
print_test "Test 2: ทดสอบการทำงานของ auto-healing"
echo "กำลังเลือก pod ตัวแรกเพื่อลบ..."
echo ""
POD_NAME=$(kubectl get pods -l app=nginx -o jsonpath='{.items[0].metadata.name}')
check_error "ไม่สามารถเลือก pod ได้"

echo "กำลังลบ pod: $POD_NAME"
echo ""
kubectl delete pod $POD_NAME
check_error "ไม่สามารถลบ pod ได้"
print_success "ลบ pod สำเร็จ"

echo ""
print_status "รอ Kubernetes สร้าง pod ใหม่ทดแทน..."
sleep 5

echo "ตรวจสอบสถานะ pods หลังจากลบ pod ไป:"
echo ""
kubectl get pods -o wide
check_error "ไม่สามารถดึงข้อมูล pods ได้"

# Explain what happened
echo ""
print_status "อธิบาย: Kubernetes สังเกตเห็นว่าจำนวน pods น้อยกว่าที่กำหนดไว้ จึงสร้าง pod ใหม่โดยอัตโนมัติ"
echo "สังเกตว่ามี pod ใหม่ถูกสร้างขึ้นมาแทนที่ pod ที่ถูกลบไป และมีชื่อแตกต่างจากเดิม"
pause

# Test 3: Scale up replicas
print_test "Test 3: ทดสอบการเพิ่มจำนวน replicas (Scale Up)"
echo "กำลังเพิ่มจำนวน replicas เป็น 5..."
echo ""
kubectl scale deployment nginx-deployment --replicas=5
check_error "ไม่สามารถ scale replicas ได้"
print_success "สั่ง scale up สำเร็จ"

echo ""
print_status "รอให้ pods ใหม่ถูกสร้าง..."
echo ""
kubectl rollout status deployment/nginx-deployment
sleep 5

echo "ตรวจสอบสถานะ pods หลังจาก scale up:"
echo ""
kubectl get pods -o wide
check_error "ไม่สามารถดึงข้อมูล pods ได้"

echo ""
print_status "อธิบาย: Kubernetes สร้าง pods เพิ่มเติมให้ครบตามจำนวน replicas ที่กำหนดใหม่"
pause

# Test 4: Scale down replicas
print_test "Test 4: ทดสอบการลดจำนวน replicas (Scale Down)"
echo "กำลังลดจำนวน replicas เป็น 2..."
echo ""
kubectl scale deployment nginx-deployment --replicas=2
check_error "ไม่สามารถ scale replicas ได้"
print_success "สั่ง scale down สำเร็จ"

echo ""
print_status "รอให้ pods ถูกลบ..."
echo ""
kubectl rollout status deployment/nginx-deployment
sleep 5

echo "ตรวจสอบสถานะ pods หลังจาก scale down:"
echo ""
kubectl get pods -o wide
check_error "ไม่สามารถดึงข้อมูล pods ได้"

echo ""
print_status "อธิบาย: Kubernetes ลบ pods ที่เกินจำนวน replicas ที่กำหนดใหม่"
pause

# Test 5: Check service load balancing
print_test "Test 5: ทดสอบการกระจาย traffic ไปยัง pods ต่างๆ"
echo "กำลังตรวจสอบ endpoints ของ service:"
echo ""
kubectl describe service nginx-service | grep -A 10 "Endpoints"
check_error "ไม่สามารถดึงข้อมูล service endpoints ได้"

echo ""
print_status "อธิบาย: Service จะกระจาย traffic ไปยัง pods ทุกตัวที่มี label ตรงกัน"
print_status "คุณสามารถทดสอบการทำงานนี้โดยการ port-forward และเรียกใช้งานหลายๆ ครั้ง"
echo ""
echo "คำสั่งตัวอย่าง:"
echo "  kubectl port-forward service/nginx-service 8080:80"
echo "  curl http://localhost:8080"
pause

# Test 6: Reset replicas to original count
print_test "Test 6: คืนค่า replicas กลับไปที่จำนวนเดิม (3)"
echo "กำลังคืนค่าจำนวน replicas เป็น 3..."
echo ""
kubectl scale deployment nginx-deployment --replicas=3
check_error "ไม่สามารถ scale replicas ได้"
print_success "คืนค่า replicas สำเร็จ"

echo ""
print_status "รอให้มีการปรับจำนวน pods..."
echo ""
kubectl rollout status deployment/nginx-deployment
sleep 5

echo "ตรวจสอบสถานะสุดท้ายของ pods:"
echo ""
kubectl get pods -o wide
check_error "ไม่สามารถดึงข้อมูล pods ได้"

echo ""
print_success "การทดสอบพฤติกรรมของ replicas เสร็จสมบูรณ์"

# Show summary
echo "
=======================================================
                 สรุปการทดสอบ Replicas
=======================================================
1. Auto-healing: Kubernetes จะสร้าง pod ใหม่ทดแทนทันทีเมื่อ pod เดิมล้มหรือถูกลบ
2. Scaling: สามารถเพิ่มหรือลดจำนวน replicas ได้ตามต้องการ (manual scaling)
3. Load Balancing: Service จะกระจาย traffic ไปยัง pods ทุกตัวโดยอัตโนมัติ

ข้อสังเกต:
- ชื่อของ pods จะมีการสุ่มเพื่อป้องกันปัญหาการซ้ำกัน
- การ scale up/down สามารถทำได้ทั้งจากคำสั่งหรือการแก้ไขไฟล์ YAML
- ถึงแม้ pods จะถูกสร้าง/ลบ แต่ service ยังคงทำงานได้ตลอด

ลองใช้คำสั่งนี้เพื่อทดสอบการเข้าถึง NGINX จากภายนอก:
  kubectl port-forward service/nginx-service 8080:80

และเปิดเบราว์เซอร์ไปที่ http://localhost:8080
"

# Reset namespace to default
print_status "กำลังคืนค่า namespace เป็น default..."
echo ""
kubectl config set-context --current --namespace=default
check_error "ไม่สามารถคืนค่า namespace ได้"
print_success "คืนค่า namespace สำเร็จ"
