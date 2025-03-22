#!/bin/bash

# Script to troubleshoot Ingress issues in the replica-demo workshop

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

# Function for displaying check messages
print_check() {
  echo -e "${BLUE}$1${NC}"
}

# Check if namespace exists
if ! kubectl get namespace replica-demo &> /dev/null; then
  print_error "Namespace 'replica-demo' ไม่พบ กรุณารัน deploy.sh ก่อน"
  exit 1
fi

print_status "เริ่มการวิเคราะห์ปัญหา Ingress..."

# Set the namespace context
print_status "กำลังตั้งค่า namespace เป็น replica-demo..."
echo ""
kubectl config set-context --current --namespace=replica-demo

# Check 1: Verify Ingress resource
print_check "ตรวจสอบ Ingress resource..."
echo ""
if kubectl get ingress nginx-ingress &> /dev/null; then
  print_success "Ingress resource พบแล้ว"
  echo ""
  kubectl get ingress nginx-ingress -o wide
else
  print_error "Ingress resource ไม่พบ กรุณาตรวจสอบการติดตั้ง"
  exit 1
fi

# Check 2: Verify Ingress Controller
print_check "กำลังตรวจสอบ Ingress Controller..."
INGRESS_NS=("ingress-nginx" "kube-system" "default")
INGRESS_FOUND=false

for ns in "${INGRESS_NS[@]}"; do
  if kubectl get pods -n $ns -l app.kubernetes.io/name=ingress-nginx 2>/dev/null | grep -q Running; then
    print_success "Ingress Controller พบใน namespace '$ns'"
    echo ""
    kubectl get pods -n $ns -l app.kubernetes.io/name=ingress-nginx
    INGRESS_FOUND=true
    break
  fi
done

if [ "$INGRESS_FOUND" = false ]; then
  print_error "ไม่พบ Ingress Controller ในคลัสเตอร์"
  print_status "สำหรับ Minikube ให้รันคำสั่ง: minikube addons enable ingress"
  print_status "สำหรับคลัสเตอร์อื่น ให้ติดตั้ง NGINX Ingress Controller ตามคำแนะนำ"
  print_status "https://kubernetes.github.io/ingress-nginx/deploy/"
fi

# Check 3: Verify Service and Endpoints
print_check "กำลังตรวจสอบ Service และ Endpoints..."
echo ""
if kubectl get service nginx-service &> /dev/null; then
  print_success "Service 'nginx-service' พบแล้ว"
  echo ""
  kubectl get service nginx-service
  
  print_check "กำลังตรวจสอบ Endpoints..."
  echo ""
  ENDPOINTS=$(kubectl get endpoints nginx-service -o jsonpath='{.subsets[0].addresses}')
  if [ -z "$ENDPOINTS" ]; then
    print_error "ไม่พบ Endpoints สำหรับ Service นี้ แสดงว่า Service ไม่สามารถเชื่อมต่อกับ Pod ใดๆ ได้"
    print_status "ตรวจสอบว่า Selector ของ Service ตรงกับ Labels ของ Pod หรือไม่"
  else
    print_success "Endpoints พบแล้ว"
    echo ""
    kubectl get endpoints nginx-service
  fi
else
  print_error "ไม่พบ Service 'nginx-service'"
fi

# Check for ConfigMap
print_check "กำลังตรวจสอบ ConfigMap สำหรับ custom HTML content..."
echo ""
if kubectl get configmap nginx-html-content &> /dev/null; then
  print_success "ConfigMap 'nginx-html-content' พบแล้ว"
  echo ""
  kubectl describe configmap nginx-html-content | grep -A 1 "Data"
else
  print_error "ไม่พบ ConfigMap 'nginx-html-content'"
  print_status "สร้าง ConfigMap ด้วยคำสั่ง: kubectl apply -f nginx-configmap.yaml"
fi

# Check 4: Verify Pods
print_check "กำลังตรวจสอบ Pods..."
echo ""
if kubectl get pods -l app=nginx &> /dev/null; then
  RUNNING_PODS=$(kubectl get pods -l app=nginx -o jsonpath='{.items[?(@.status.phase=="Running")].metadata.name}')
  if [ -z "$RUNNING_PODS" ]; then
    print_error "ไม่พบ Pods ที่กำลังทำงาน"
  else
    print_success "Pods กำลังทำงาน:"
    echo ""
    kubectl get pods -l app=nginx
  fi
else
  print_error "ไม่พบ Pods ที่มี label app=nginx"
fi

# Check 5: Test DNS resolution
print_check "กำลังทดสอบ DNS resolution สำหรับ nginx.k8s.local..."
echo ""
if host nginx.k8s.local &>/dev/null; then
  print_success "DNS resolution ทำงานได้"
else
  print_error "DNS resolution ไม่ทำงาน"
  print_status "เพิ่มบรรทัดต่อไปนี้ใน /etc/hosts:"
  echo "127.0.0.1 nginx.k8s.local"
fi

# Check 6: Test direct service access
print_check "กำลังทดสอบการเข้าถึง Service โดยตรง..."
print_status "กำลังตั้งค่า port-forward ไปยัง Service..."
echo ""
kubectl port-forward service/nginx-service 8080:80 &
PF_PID=$!
sleep 3

if curl -s http://localhost:8080 &>/dev/null; then
  print_success "สามารถเข้าถึง Service โดยตรงได้"
  print_status "ลองเปิด http://localhost:8080 ในเบราว์เซอร์"
else
  print_error "ไม่สามารถเข้าถึง Service โดยตรงได้"
fi
kill $PF_PID 2>/dev/null

# Fix suggestions
echo ""
print_status "=== คำแนะนำในการแก้ไขปัญหา ==="

print_status "1. ตรวจสอบว่า Ingress Controller ทำงานอยู่"
print_status "2. ตรวจสอบว่าได้เพิ่ม nginx.k8s.local ใน /etc/hosts ของคุณแล้ว"
print_status "3. ลองแก้ไข Ingress ด้วยคำสั่งต่อไปนี้:"
echo "kubectl patch ingress nginx-ingress -p '{\"metadata\":{\"annotations\":{\"kubernetes.io/ingress.class\":\"nginx\",\"nginx.ingress.kubernetes.io/ssl-redirect\":\"false\"}}}'"

print_status "4. ตรวจสอบ logs ของ Ingress Controller เพื่อดูข้อผิดพลาด"
print_status "5. ทดสอบการเชื่อมต่อผ่าน port-forward ถ้าทำงานได้ แสดงว่าปัญหาอยู่ที่ Ingress ไม่ใช่ Service หรือ Pods"

echo ""
print_status "การวิเคราะห์เสร็จสมบูรณ์"
