# Kubernetes Custom Operators Workshop

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | การสร้างและใช้งาน Kubernetes Custom Operators |
| **วัตถุประสงค์** | เรียนรู้การขยายความสามารถของ Kubernetes ด้วย Custom Resource Definitions (CRDs) และ Operators |
| **ระดับความยาก** | ยาก |

ในเวิร์คช็อปนี้ เราจะเรียนรู้เกี่ยวกับการพัฒนา Kubernetes Operators ซึ่งเป็นวิธีการขยายความสามารถของ Kubernetes เพื่อให้สามารถจัดการแอปพลิเคชันที่มีความซับซ้อนได้อย่างอัตโนมัติ โดยใช้แนวคิดของ GitOps และการเขียนโค้ดควบคุมการทำงานของระบบ

## สิ่งที่จะได้เรียนรู้

- ความเข้าใจพื้นฐานเกี่ยวกับ Custom Resource Definitions (CRDs) และ Operators
- การสร้างและใช้งาน CRDs ใน Kubernetes
- การพัฒนา Controller ด้วย Operator SDK (Go)
- การสร้าง Reconciliation Loop และ Control Logic
- การทดสอบ Operator ในสภาพแวดล้อม Minikube หรือ Kind
- การทำ Versioning และ Conversion Webhooks สำหรับ CRDs
- แนวทางการทำ Backup, Scaling และ Upgrades อัตโนมัติผ่าน Operators

## ความเข้าใจเกี่ยวกับ Operators

Kubernetes Operators เป็นวิธีการขยายความสามารถของ Kubernetes ด้วยการนำเอาความรู้ของผู้เชี่ยวชาญมาเขียนเป็นโค้ด เพื่อให้ระบบสามารถจัดการแอปพลิเคชันที่มีความซับซ้อนได้อย่างอัตโนมัติ โดยใช้แนวคิดของ GitOps ซึ่งประกอบด้วย:

1. **Custom Resource Definitions (CRDs)**: การนิยามทรัพยากรใหม่ให้กับ Kubernetes API
2. **Controllers**: โค้ดที่ควบคุมการทำงานของ Custom Resources และจัดการวงจรชีวิตของแอปพลิเคชัน

Operators ช่วยให้เราสามารถระบุสถานะที่ต้องการของระบบในรูปแบบของ Kubernetes manifests และให้ Controller คอยตรวจสอบและปรับให้ระบบเข้าสู่สถานะนั้นได้โดยอัตโนมัติ

## ขั้นตอนการทำงาน

### 1. สร้าง Namespace

สร้าง Namespace เพื่อแยกทรัพยากรที่ใช้ในบทเรียนนี้:

```bash
kubectl create namespace operator-demo
kubectl config set-context --current --namespace=operator-demo
```

### 2. ติดตั้ง Operator SDK และเตรียมสภาพแวดล้อม

Operator SDK เป็นเครื่องมือที่ช่วยให้การพัฒนา Operators ง่ายขึ้น:

```bash
# ติดตั้ง Operator SDK บน macOS ด้วย Homebrew
brew install operator-sdk

# หรือดาวน์โหลดไบนารี
curl -LO https://github.com/operator-framework/operator-sdk/releases/download/v1.25.0/operator-sdk_linux_amd64
chmod +x operator-sdk_linux_amd64
sudo mv operator-sdk_linux_amd64 /usr/local/bin/operator-sdk

# ตรวจสอบการติดตั้ง
operator-sdk version
```

### 3. สร้าง CRD โดยใช้ Operator SDK

เราจะสร้าง CRD สำหรับจัดการ Web Application:

```bash
# สร้างโปรเจ็คใหม่
mkdir -p webapp-operator
cd webapp-operator

# Initialize โปรเจ็ค Operator ด้วย Go
operator-sdk init --domain example.com --repo github.com/example/webapp-operator

# สร้าง API และ Controller
operator-sdk create api --group apps --version v1alpha1 --kind WebApp --resource --controller
```

### 4. กำหนดโครงสร้าง CRD

แก้ไขไฟล์ `api/v1alpha1/webapp_types.go` เพื่อกำหนด spec และ status ของ CRD:

```go
// WebAppSpec defines the desired state of WebApp
type WebAppSpec struct {
	// Size is the number of replicas for the web application
	// +kubebuilder:validation:Minimum=1
	// +kubebuilder:validation:Maximum=10
	Size int32 `json:"size"`
	
	// Image is the container image of the web application
	Image string `json:"image"`
	
	// Port is the container port of the web application
	Port int32 `json:"port"`
}

// WebAppStatus defines the observed state of WebApp
type WebAppStatus struct {
	// Nodes are the names of the web application pods
	Nodes []string `json:"nodes"`
	
	// AvailableReplicas is the number of available replicas
	AvailableReplicas int32 `json:"availableReplicas"`
}
```

### 5. จัดทำ Controller Logic

แก้ไขไฟล์ `controllers/webapp_controller.go` เพื่อกำหนด reconciliation logic:

```go
func (r *WebAppReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
	log := r.Log.WithValues("webapp", req.NamespacedName)
	
	// ดึง WebApp resource
	webapp := &appsv1alpha1.WebApp{}
	err := r.Get(ctx, req.NamespacedName, webapp)
	if err != nil {
		if errors.IsNotFound(err) {
			return ctrl.Result{}, nil
		}
		return ctrl.Result{}, err
	}
	
	// สร้าง Deployment หากไม่มี
	// ...
	
	// สร้าง Service หากไม่มี
	// ...
	
	// อัพเดต Status
	// ...
	
	return ctrl.Result{}, nil
}
```

### 6. สร้าง Custom Resource

หลังจากติดตั้ง CRD แล้ว เราสามารถสร้าง Custom Resource ได้:

```yaml
apiVersion: apps.example.com/v1alpha1
kind: WebApp
metadata:
  name: sample-webapp
spec:
  size: 3
  image: nginx:latest
  port: 80
```

### 7. การ Deploy Operator

```bash
# สร้าง CRD ใน Kubernetes cluster
make install

# Build และ Run Operator
make run
```

หรือ Deploy ลงใน Cluster:

```bash
# Build Docker image
make docker-build docker-push IMG=<your-registry>/webapp-operator:v0.1.0

# Deploy Operator
make deploy IMG=<your-registry>/webapp-operator:v0.1.0
```

### 8. ทดสอบ Operator

```bash
# สร้าง WebApp resource
kubectl apply -f config/samples/apps_v1alpha1_webapp.yaml

# ตรวจสอบผลลัพธ์
kubectl get webapp
kubectl get deployments
kubectl get services
kubectl get pods
```

### 9. การพัฒนา Webhooks

สร้าง Validation และ Defaulting Webhooks สำหรับ WebApp CRD:

```bash
# สร้าง Webhook
operator-sdk create webhook --group apps --version v1alpha1 --kind WebApp --defaulting --programmatic-validation
```

### 10. การอัพเกรด CRD (Versioning และ Conversion)

```bash
# สร้าง Version ใหม่
operator-sdk create api --group apps --version v1alpha2 --kind WebApp --resource
```

## การใช้ Shell Script สำหรับการจัดการทรัพยากร

เพื่อความสะดวกในการติดตั้งและทดสอบ workshop นี้ เราได้เตรียม shell script สำหรับการจัดการทรัพยากรทั้งหมด:

### 1. การติดตั้งทรัพยากรทั้งหมด (deploy.sh)

Script นี้จะสร้าง namespace และทรัพยากรทั้งหมดที่จำเป็นสำหรับ workshop นี้:

```bash
chmod +x deploy.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./deploy.sh
```

เมื่อรัน script นี้แล้ว จะมีการดำเนินการดังนี้:
- สร้าง namespace `operator-demo`
- ตั้งค่า context ให้ใช้งาน namespace `operator-demo`
- ติดตั้ง Custom Resource Definitions
- Deploy Operator และทรัพยากรที่เกี่ยวข้อง
- สร้าง Custom Resource เพื่อทดสอบ

### 2. การทดสอบทรัพยากร (test.sh)

Script นี้จะทดสอบการทำงานของ Operator:

```bash
chmod +x test.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./test.sh
```

การทดสอบประกอบด้วย:
- ตรวจสอบว่า Operator ทำงานได้ปกติ
- สร้าง Custom Resource และตรวจสอบผลลัพธ์
- ทดสอบการปรับเปลี่ยนค่าใน Custom Resource
- ตรวจสอบการตอบสนองของ Operator

### 3. การลบทรัพยากรทั้งหมด (cleanup.sh)

เมื่อต้องการลบทรัพยากรทั้งหมดที่สร้างขึ้นในบทเรียนนี้:

```bash
chmod +x cleanup.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./cleanup.sh
```

Script นี้จะดำเนินการ:
- ลบ Custom Resources ทั้งหมด
- ลบ Operator และทรัพยากรที่เกี่ยวข้อง
- ลบ Custom Resource Definitions
- ลบ namespace `operator-demo`
- ตั้งค่า context กลับไปที่ namespace `default`

## ข้อควรระวังในการพัฒนา Operators

1. **การออกแบบ API ที่ดี**: CRD ควรมีการออกแบบที่ดีตั้งแต่แรก เพราะการเปลี่ยนแปลงในภายหลังอาจทำได้ยาก
2. **การจัดการ Versioning**: เตรียมวางแผนรองรับ versioning ของ CRDs ตั้งแต่เริ่มต้น
3. **การรักษาความปลอดภัย**: ให้ความสำคัญกับการกำหนดสิทธิ์ RBAC ที่เหมาะสม
4. **การทดสอบ**: เขียน unit tests และ integration tests ให้ครอบคลุม
5. **การจัดการ Errors**: มีระบบจัดการ errors และ retry logic ที่เหมาะสม

## แนวทางปฏิบัติที่ดีในการพัฒนา Operator

1. **ทำให้ Idempotent**: Controller ควรทำงานได้อย่างถูกต้องไม่ว่าจะถูกเรียกกี่ครั้ง
2. **ความอดทนต่อความล้มเหลว**: มีกลไกการรับมือกับความล้มเหลวและการ retry
3. **ใช้ Owner References**: เพื่อให้ทรัพยากรลูกถูกลบเมื่อทรัพยากรแม่ถูกลบ
4. **Finalizers**: ใช้ในการทำ clean-up logic ก่อนที่ทรัพยากรจะถูกลบจริง
5. **Status Updates**: อัพเดต status ให้สะท้อนสถานะจริงของระบบเสมอ

## สรุป

ในเวิร์คช็อปนี้ เราได้เรียนรู้:

1. แนวคิดพื้นฐานเกี่ยวกับ Kubernetes Operators
2. วิธีการสร้าง Custom Resource Definitions (CRDs)
3. การพัฒนา Controllers ด้วย Operator SDK
4. การสร้างและติดตั้ง Operators บน Kubernetes cluster
5. แนวทางปฏิบัติที่ดีในการพัฒนา Operators

การพัฒนา Operators เป็นทักษะขั้นสูงสำหรับผู้ที่ต้องการขยายความสามารถของ Kubernetes เพื่อรองรับแอปพลิเคชันที่มีความซับซ้อน และต้องการระบบอัตโนมัติในการจัดการวงจรชีวิตของแอปพลิเคชัน
