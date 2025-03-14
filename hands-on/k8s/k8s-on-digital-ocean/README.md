# k8s บน digital-ocean

สร้างคลัสเตอร์ Kubernetes [ที่นี่](https://cloud.digitalocean.com/kubernetes/clusters)

เพิ่มคลัสเตอร์เข้าไปใน Kubeconfig ของคุณ
```
doctl kubernetes cluster list
doctl kubernetes cluster kubeconfig save 78287d0e-a0c4-4a9a-9dd5-a2cafc793ac7
```

ติดตั้ง ingress-nginx controller
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx --create-namespace --set controller.publishService.enabled=true
```

สร้าง CSI token secret ใน kube-system

ติดตั้ง CSI controller และ sidecar
```
kubectl apply -fhttps://raw.githubusercontent.com/digitalocean/csi-digitalocean/master/deploy/kubernetes/releases/csi-digitalocean-v4.9.0/{crds.yaml,driver.yaml,snapshot-controller.yaml}
```

เพิ่ม chart ของ postgres (bitnami)
```
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

สร้าง PVCs

ติดตั้ง postgres ผ่าน helm chart
```
helm install postgresdb bitnami/postgresql --set persistence.existingClaim=postgresql-pv-claim --set volumePermissions.enabled=true
```

ดึงรหัสผ่านของ postgres
```
export POSTGRES_PASSWORD=$(kubectl get secret --namespace default postgresdb-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
echo POSTGRES_PASSWORD
```

สร้าง secret สำหรับ connection string ของ postgres

ติดตั้งแอปพลิเคชัน

ตรวจสอบว่าแอปพลิเคชันทำงานได้
```
kubectl port-forward svc/do-sample-app-service 8080:8080
```

ติดตั้ง ingress

ชี้ DNS CNAME ไปที่ IP address ของ ingress

สำเร็จ :)


ขั้นตอนต่อไป:
- ติดตั้ง Cert Manager
- ติดตั้งระบบ Monitoring
- ติดตั้งระบบ Logging
- ปรับปรุงความปลอดภัย
- ตั้งค่า CI/CD, Helm chart และอื่นๆ