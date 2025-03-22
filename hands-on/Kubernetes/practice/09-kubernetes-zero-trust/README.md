# Kubernetes Zero-Trust Security Architecture

| รายละเอียด | คำอธิบาย |
|----------|---------|
| **ชื่อเนื้อหา** | การออกแบบและนำไปใช้ของสถาปัตยกรรมความปลอดภัยแบบ Zero-Trust บน Kubernetes |
| **วัตถุประสงค์** | เรียนรู้การสร้างระบบรักษาความปลอดภัยแบบ Zero-Trust บน Kubernetes ด้วยการใช้เครื่องมือและเทคนิคขั้นสูง |
| **ระดับความยาก** | ยากมาก |

ในเวิร์คช็อปนี้ เราจะสำรวจแนวคิดและการนำไปใช้ของสถาปัตยกรรมความปลอดภัยแบบ Zero-Trust บน Kubernetes ซึ่งเป็นแนวทางที่กำลังได้รับความนิยมเพิ่มขึ้นสำหรับการรักษาความปลอดภัยในสภาพแวดล้อมคลาวด์เนทีฟ โดยแนวคิด Zero-Trust ตั้งอยู่บนหลักการ "ไม่เชื่อใจใครทั้งสิ้น ตรวจสอบทุกอย่างอย่างต่อเนื่อง" ซึ่งแตกต่างจากโมเดลความปลอดภัยแบบดั้งเดิมที่เน้นเฉพาะการป้องกันขอบเขตภายนอก

## สิ่งที่จะได้เรียนรู้

- หลักการและแนวคิดพื้นฐานของความปลอดภัยแบบ Zero-Trust
- การสร้างและกำหนดค่า Service Mesh (Istio) สำหรับการรักษาความปลอดภัยระหว่างไมโครเซอร์วิส
- การใช้งาน mTLS ในทุกการสื่อสารภายใน cluster
- การกำหนดนโยบายความปลอดภัยแบบละเอียดด้วย Open Policy Agent (OPA) Gatekeeper
- การใช้ Kubernetes NetworkPolicies สำหรับการควบคุมการไหลของเครือข่าย
- การนำ SPIFFE/SPIRE มาใช้สำหรับการจัดการเอกลักษณ์ที่ปลอดภัย
- การใช้ Vault สำหรับการจัดการ secrets แบบปลอดภัย
- การทำ Runtime Security และตรวจจับภัยคุกคามด้วย Falco
- การจัดตั้งระบบการตรวจสอบ (Auditing) และการบันทึกเหตุการณ์ (Logging) แบบครอบคลุม
- การสร้างกระบวนการ CI/CD ที่มีความปลอดภัยสูงด้วย Supply Chain Security

## สถาปัตยกรรมของระบบ

สถาปัตยกรรม Zero-Trust ที่เราจะสร้างประกอบด้วยองค์ประกอบหลายส่วน:

1. **การพิสูจน์ตัวตนและการอนุญาต** - การตรวจสอบว่าทุกการร้องขอมาจากแหล่งที่น่าเชื่อถือ
2. **การเข้ารหัสการสื่อสาร** - mTLS สำหรับทุกการสื่อสารภายใน cluster
3. **การแบ่งส่วนเครือข่ายแบบละเอียด** - การใช้ NetworkPolicies เพื่อจำกัดการสื่อสาร
4. **นโยบายความปลอดภัยที่บังคับใช้ระหว่างการทำงาน** - ใช้ OPA Gatekeeper และ Istio Authorization Policies
5. **การจัดการ Secrets ที่ปลอดภัย** - ใช้ Vault สำหรับการจัดการและการหมุนเวียน secrets
6. **การป้องกันภัยคุกคามแบบ Runtime** - ใช้ Falco สำหรับการตรวจจับพฤติกรรมที่น่าสงสัย
7. **การตรวจสอบความปลอดภัยของรูปภาพ Container** - การสแกน vulnerabilities ด้วย Trivy/Clair
8. **การรับรองความถูกต้องของ Supply Chain** - ใช้ Sigstore/Cosign สำหรับการลงนามและตรวจสอบภาพ container

## องค์ประกอบที่ใช้ในโปรเจ็คนี้

- **Istio** - Service mesh สำหรับการรักษาความปลอดภัยระหว่างไมโครเซอร์วิส, mTLS, และนโยบายการอนุญาต
- **Open Policy Agent (OPA) Gatekeeper** - สำหรับนโยบายการรักษาความปลอดภัยแบบประกาศ
- **Vault** - สำหรับการจัดการ secrets แบบปลอดภัย 
- **SPIFFE/SPIRE** - สำหรับการจัดการเอกลักษณ์ที่ปลอดภัย
- **Falco** - สำหรับการตรวจจับภัยคุกคามที่ runtime
- **Kyverno** - สำหรับนโยบายการรักษาความปลอดภัยและการปฏิบัติตามข้อกำหนด
- **Trivy** - สำหรับการสแกน vulnerabilities ของรูปภาพ container
- **Cert-Manager** - สำหรับการจัดการใบรับรองอัตโนมัติ
- **Prometheus/Grafana** - สำหรับการตรวจสอบและการแจ้งเตือน
- **Loki/FluentBit** - สำหรับการรวบรวมและการวิเคราะห์ logs
- **Sigstore/Cosign** - สำหรับการลงนามและตรวจสอบรูปภาพ container

## ขั้นตอนการทำงาน

### 1. การตั้งค่าสภาพแวดล้อม

สร้าง Namespace เพื่อแยกทรัพยากรสำหรับ workshop นี้:

```bash
kubectl create namespace zero-trust-demo
kubectl config set-context --current --namespace=zero-trust-demo
```

### 2. การติดตั้งและกำหนดค่า Istio พร้อม mTLS เข้มงวด

ติดตั้ง Istio และกำหนดค่าให้บังคับใช้ mTLS สำหรับทุกการสื่อสาร:

```bash
# รายละเอียดการติดตั้ง Istio จะอยู่ในไฟล์ install-istio.sh
istioctl install -f istio-config.yaml
```

**istio-config.yaml** (ตัวอย่างบางส่วน):
```yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  meshConfig:
    enableAutoMtls: true
  values:
    global:
      pilotCertProvider: istiod
      controlPlaneSecurityEnabled: true
      mtls:
        enabled: true
  components:
    ingressGateways:
    - name: istio-ingressgateway
      enabled: true
```

### 3. การนำ NetworkPolicies มาใช้เพื่อแบ่งส่วนเครือข่ายอย่างละเอียด

```bash
kubectl apply -f network-policies.yaml
```

**network-policies.yaml** (ตัวอย่างบางส่วน):
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-app-to-db
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: database
    ports:
    - protocol: TCP
      port: 3306
```

### 4. การติดตั้งและกำหนดค่า OPA Gatekeeper สำหรับการบังคับใช้นโยบาย

```bash
kubectl apply -f gatekeeper.yaml
```

**gatekeeper-policies.yaml** (ตัวอย่างบางส่วน):
```yaml
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: require-security-context
spec:
  match:
    kinds:
      - apiGroups: [""]
        kinds: ["Pod"]
  parameters:
    requiredSecurityContext: true
```

### 5. การติดตั้ง Vault สำหรับการจัดการ Secrets อย่างปลอดภัย

```bash
helm install vault hashicorp/vault \
  --namespace zero-trust-demo \
  --set "server.dev.enabled=false" \
  --set "server.ha.enabled=true"
```

### 6. การติดตั้ง SPIFFE/SPIRE สำหรับการจัดการเอกลักษณ์

```bash
kubectl apply -f spire-server.yaml
kubectl apply -f spire-agent.yaml
```

### 7. การกำหนดค่า Falco สำหรับการตรวจจับภัยคุกคามแบบ Runtime

```bash
helm install falco falcosecurity/falco \
  --namespace zero-trust-demo \
  --set falco.jsonOutput=true
```

### 8. การสร้างแพลตฟอร์มตรวจสอบและบันทึกเหตุการณ์

```bash
kubectl apply -f monitoring-logging.yaml
```

### 9. การพัฒนาแอปพลิเคชันตัวอย่างที่มีความปลอดภัยสูง

สร้างและ deploy แอปพลิเคชันตัวอย่างที่ใช้ประโยชน์จากโครงสร้างพื้นฐานความปลอดภัย Zero-Trust:

```bash
kubectl apply -f secure-app-deployment.yaml
```

### 10. การทดสอบและยืนยันความถูกต้องของสถาปัตยกรรมความปลอดภัย

ทดสอบสถาปัตยกรรม Zero-Trust โดยการจำลองสถานการณ์การโจมตีต่าง ๆ:

```bash
./run-security-tests.sh
```

## การใช้ Shell Script สำหรับการจัดการทรัพยากร

เพื่อความสะดวกในการติดตั้งและทดสอบ workshop นี้ เราได้เตรียม shell script สำหรับการจัดการทรัพยากรทั้งหมด:

### 1. การติดตั้งทรัพยากรทั้งหมด (deploy.sh)

Script นี้จะติดตั้งองค์ประกอบทั้งหมดของสถาปัตยกรรม Zero-Trust:

```bash
chmod +x deploy.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./deploy.sh
```

เมื่อรัน script นี้แล้ว จะมีการดำเนินการดังนี้:
- สร้าง namespace `zero-trust-demo`
- ติดตั้งและกำหนดค่า Istio พร้อม mTLS
- ติดตั้ง OPA Gatekeeper และกำหนดค่านโยบายความปลอดภัย
- ติดตั้ง Vault สำหรับการจัดการ secrets
- ติดตั้ง SPIFFE/SPIRE สำหรับการจัดการเอกลักษณ์
- ติดตั้ง Falco สำหรับการตรวจจับภัยคุกคามแบบ runtime
- สร้างระบบตรวจสอบและบันทึกเหตุการณ์
- Deploy แอปพลิเคชันตัวอย่างที่มีการปฏิบัติตามหลัก Zero-Trust

### 2. การทดสอบทรัพยากร (test.sh)

Script นี้จะทดสอบความปลอดภัยของสถาปัตยกรรม:

```bash
chmod +x test.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./test.sh
```

การทดสอบประกอบด้วย:
- ทดสอบการบังคับใช้ mTLS
- ทดสอบนโยบาย NetworkPolicy
- ทดสอบนโยบาย OPA Gatekeeper
- ทดสอบการจัดการ secrets ด้วย Vault
- ทดสอบการตรวจจับภัยคุกคามด้วย Falco
- ทดสอบการสื่อสารระหว่างไมโครเซอร์วิสที่มีความปลอดภัย
- จำลองการโจมตีและตรวจสอบการตอบสนอง

### 3. การลบทรัพยากรทั้งหมด (cleanup.sh)

เมื่อต้องการลบทรัพยากรทั้งหมดที่สร้างขึ้นในบทเรียนนี้:

```bash
chmod +x cleanup.sh  # ให้สิทธิ์การเรียกใช้งาน script (ครั้งแรกเท่านั้น)
./cleanup.sh
```

Script นี้จะดำเนินการ:
- ลบแอปพลิเคชันตัวอย่าง
- ลบองค์ประกอบทั้งหมดของระบบรักษาความปลอดภัย
- ลบ namespace `zero-trust-demo`
- ตั้งค่า context กลับไปที่ namespace `default`

## แนวทางปฏิบัติที่ดีในการรักษาความปลอดภัยแบบ Zero-Trust

1. **การแบ่งส่วนแบบละเอียด (Micro-Segmentation)**: ใช้ NetworkPolicies เพื่อควบคุมการสื่อสารระหว่าง services อย่างเข้มงวด
2. **การพิสูจน์ตัวตนสำหรับทุกการร้องขอ**: ใช้ mTLS และระบบการจัดการเอกลักษณ์ที่ปลอดภัย
3. **การใช้สิทธิ์น้อยที่สุด (Least Privilege)**: ให้สิทธิ์แก่ services เฉพาะเท่าที่จำเป็นสำหรับการทำงาน
4. **การตรวจสอบอย่างต่อเนื่อง**: ใช้ระบบตรวจสอบและบันทึกเหตุการณ์เพื่อตรวจจับความผิดปกติ
5. **การลดพื้นที่เสี่ยง (Attack Surface)**: ลดจำนวน ingress/egress points และปรับแต่งรูปภาพ container ให้มีขนาดเล็กที่สุด

## ความท้าทายและแนวทางแก้ไข

1. **ความซับซ้อนในการบริหารจัดการ**: ใช้ operator และการทำ automation มากขึ้น
2. **Performance Overhead**: ปรับแต่งการตั้งค่าให้สมดุลระหว่างความปลอดภัยและประสิทธิภาพ
3. **การเรียนรู้ที่ชัน**: แบ่งการนำไปใช้เป็นขั้นตอน ทำทีละส่วนแทนที่จะทำทั้งหมดในคราวเดียว
4. **การบูรณาการกับระบบที่มีอยู่**: ใช้เครื่องมือและ API ที่รองรับมาตรฐานที่ใช้กันอย่างแพร่หลาย

## สรุป

ในเวิร์คช็อปนี้ เราได้เรียนรู้การสร้างสถาปัตยกรรมความปลอดภัยแบบ Zero-Trust บน Kubernetes โดยใช้เครื่องมือและเทคนิคขั้นสูงต่างๆ ซึ่งประกอบด้วย:

1. การติดตั้งและกำหนดค่า Service Mesh พร้อม mTLS
2. การนำ NetworkPolicies มาใช้เพื่อแบ่งส่วนเครือข่าย
3. การใช้ OPA Gatekeeper สำหรับการบังคับใช้นโยบายความปลอดภัย
4. การใช้ Vault สำหรับการจัดการ secrets
5. การตรวจจับภัยคุกคามแบบ Runtime ด้วย Falco
6. การสร้างระบบตรวจสอบและบันทึกเหตุการณ์ที่ครอบคลุม

การนำแนวคิด Zero-Trust มาใช้ใน Kubernetes ไม่ใช่เพียงการเพิ่มความปลอดภัยให้กับแอปพลิเคชัน แต่ยังเป็นการเปลี่ยนกระบวนทัศน์ในการออกแบบระบบ โดยมุ่งเน้นที่การไม่เชื่อใจใครทั้งสิ้นและการตรวจสอบอย่างต่อเนื่อง ซึ่งเป็นพื้นฐานสำคัญสำหรับระบบความปลอดภัยในยุคปัจจุบัน
