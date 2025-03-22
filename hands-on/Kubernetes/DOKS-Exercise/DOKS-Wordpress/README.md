## ภาพรวม

[WordPress](https://wordpress.org/about/) เป็นซอฟต์แวร์โอเพนซอร์สที่ออกแบบมาสำหรับทุกคน เน้นการเข้าถึงง่าย ประสิทธิภาพ ความปลอดภัย และความง่ายในการใช้งานเพื่อสร้างเว็บไซต์ บล็อก หรือแอปพลิเคชัน [WordPress](https://en.wikipedia.org/wiki/WordPress) เป็นระบบจัดการเนื้อหา (CMS) ที่สร้างขึ้นบน PHP และใช้ MySQL เป็นที่เก็บข้อมูล ให้บริการเว็บไซต์มากกว่า 30% ของอินเทอร์เน็ตในปัจจุบัน

ในบทเรียนนี้ คุณจะใช้ Helm ในการติดตั้ง [WordPress](https://wordpress.com/) บนคลัสเตอร์ Kubernetes เพื่อสร้างเว็บไซต์ที่มีความพร้อมใช้งานสูง นอกเหนือจากการใช้ประโยชน์จากความสามารถในการขยายและความพร้อมใช้งานสูงของ Kubernetes การตั้งค่านี้จะช่วยรักษาความปลอดภัยของ WordPress โดยการให้ขั้นตอนการอัพเกรดและการย้อนกลับที่ง่ายขึ้นผ่าน Helm

คุณจะได้กำหนดค่า [NitroPack](https://wordpress.org/plugins/nitropack/) ซึ่งเป็นปลั๊กอินที่ใช้สำหรับการบีบอัดโค้ด การแคช CDN และการโหลดแบบ lazy

คุณจะใช้เซิร์ฟเวอร์ MySQL ภายนอกเพื่อแยกส่วนประกอบฐานข้อมูล เนื่องจากมันสามารถเป็นส่วนหนึ่งของคลัสเตอร์แยกหรือบริการที่มีการจัดการเพื่อความพร้อมใช้งานที่เพิ่มขึ้น หลังจากทำตามขั้นตอนที่อธิบายในบทเรียนนี้ คุณจะมีการติดตั้ง WordPress ที่ใช้งานได้อย่างเต็มรูปแบบภายในสภาพแวดล้อมคลัสเตอร์แบบคอนเทนเนอร์ที่จัดการโดย Kubernetes

## แผนภาพการติดตั้ง WordPress

![ภาพรวมการติดตั้ง WordPress](assets/images/arch_wordpress.png)

## สารบัญ

- [ภาพรวม](#ภาพรวม)
- [แผนภาพการติดตั้ง WordPress](#แผนภาพการติดตั้ง-wordpress)
- [สารบัญ](#สารบัญ)
- [ข้อกำหนดเบื้องต้น](#ข้อกำหนดเบื้องต้น)
- [การตั้งค่า DigitalOcean Managed Kubernetes Cluster (DOKS)](#การตั้งค่า-digitalocean-managed-kubernetes-cluster-doks)
- [การติดตั้งและกำหนดค่า OpenEBS Dynamic NFS Provisioner](#การติดตั้งและกำหนดค่า-openebs-dynamic-nfs-provisioner)
- [การกำหนดค่า WordPress MySQL DO Managed Database](#การกำหนดค่า-wordpress-mysql-do-managed-database)
- [การกำหนดค่าฐานข้อมูล Redis](#การกำหนดค่าฐานข้อมูล-redis)
  - [การกำหนดค่า Redis DO Managed Database](#การกำหนดค่า-redis-do-managed-database)
  - [การกำหนดค่า Redis helm chart](#การกำหนดค่า-redis-helm-chart)
- [การติดตั้ง WordPress](#การติดตั้ง-wordpress)
  - [การเดพลอย Helm Chart](#การเดพลอย-helm-chart)
  - [การรักษาความปลอดภัยของ Traffic ด้วยใบรับรอง Let's Encrypt](#การรักษาความปลอดภัยของ-traffic-ด้วยใบรับรอง-lets-encrypt)
    - [การติดตั้ง Nginx Ingress Controller](#การติดตั้ง-nginx-ingress-controller)
  - [การกำหนดค่า DNS สำหรับ Nginx Ingress Controller](#การกำหนดค่า-dns-สำหรับ-nginx-ingress-controller)
    - [การติดตั้ง Cert-Manager](#การติดตั้ง-cert-manager)
    - [การกำหนดค่าใบรับรอง TLS สำหรับ WordPress ที่พร้อมใช้งานจริง](#การกำหนดค่าใบรับรอง-tls-สำหรับ-wordpress-ที่พร้อมใช้งานจริง)
- [การเปิดใช้งาน WordPress Monitoring Metrics](#การเปิดใช้งาน-wordpress-monitoring-metrics)
- [การกำหนดค่าปลั๊กอิน WordPress](#การกำหนดค่าปลั๊กอิน-wordpress)
- [การปรับปรุงประสิทธิภาพ Wordpress](#การปรับปรุงประสิทธิภาพ-wordpress)
  - [การกำหนดค่าปลั๊กอิน NitroPack](#การกำหนดค่าปลั๊กอิน-nitropack)
  - [การกำหนดค่า Cloudflare](#การกำหนดค่า-cloudflare)
  - [การกำหนดค่า Redis Object Cache](#การกำหนดค่า-redis-object-cache)
- [การอัพเกรด WordPress](#การอัพเกรด-wordpress)
- [บทสรุป](#บทสรุป)

## ข้อกำหนดเบื้องต้น

สิ่งที่คุณต้องมีเพื่อทำบทเรียนนี้ให้สำเร็จ:

1. [Helm](https://www.helm.sh/) สำหรับจัดการการเปิดตัวและการอัพเกรดของ WordPress, Nginx Ingress Controller และ Cert-Manager
2. [Doctl](https://github.com/digitalocean/doctl/releases) CLI สำหรับการโต้ตอบกับ API ของ `DigitalOcean`
3. [Kubectl](https://kubernetes.io/docs/tasks/tools) CLI สำหรับการโต้ตอบกับ `Kubernetes`
4. ความรู้พื้นฐานในการรันและดำเนินการคลัสเตอร์ `DOKS` คุณสามารถเรียนรู้เพิ่มเติมได้[ที่นี่](https://docs.digitalocean.com/products/kubernetes)
5. ชื่อโดเมนจาก [GoDaddy](https://uk.godaddy.com), [Cloudflare](https://uk.godaddy.com) ฯลฯ เพื่อกำหนดค่า `DNS` ในบัญชี `DigitalOcean` ของคุณ

## การตั้งค่า DigitalOcean Managed Kubernetes Cluster (DOKS)

ก่อนที่จะดำเนินการตามขั้นตอนของบทเรียน คุณต้องมี DigitalOcean Managed Kubernetes Cluster (DOKS) ที่พร้อมใช้งาน ถ้าคุณมีอยู่แล้ว คุณสามารถข้ามไปยังส่วนถัดไป - [การกำหนดค่า WordPress MySQL DO Managed Database](#การกำหนดค่า-wordpress-mysql-do-managed-database)

คุณสามารถใช้คำสั่งด้านล่างเพื่อสร้างคลัสเตอร์ DOKS ใหม่:

```console
doctl k8s cluster create <YOUR_CLUSTER_NAME> \
  --auto-upgrade=false \
  --maintenance-window "saturday=21:00" \
  --node-pool "name=basicnp;size=s-4vcpu-8gb-amd;count=3;tag=cluster2;label=type=basic;auto-scale=true;min-nodes=2;max-nodes=4" \
  --region nyc1
```

**หมายเหตุ:**

- เราแนะนำให้ใช้คลัสเตอร์ DOKS กับ worker node อย่างน้อย 2 โหนดเพื่อลดผลกระทบต่อแอปพลิเคชันในกรณีที่โหนดล้มเหลว ตัวอย่างจากบทเรียนนี้ใช้ worker node 3 โหนด แต่ละโหนดมี 4cpu/8gb (`$48/เดือน`) และมีการกำหนดค่า autoscaler ระหว่าง 2 ถึง 4 โหนด ดังนั้นค่าใช้จ่ายสำหรับคลัสเตอร์ของคุณคือระหว่าง `$96-$192/เดือน` ด้วยการเรียกเก็บเงินแบบ `รายชั่วโมง` หากต้องการเลือกประเภทโหนดที่แตกต่างกัน คุณสามารถเลือก slug อื่นได้จาก `doctl compute size list`

- โปรดเยี่ยมชม [วิธีการตั้งค่า DigitalOcean Managed Kubernetes Cluster (DOKS)](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/01-setup-DOKS) สำหรับรายละเอียดเพิ่มเติม

## การติดตั้งและกำหนดค่า OpenEBS Dynamic NFS Provisioner

**ส่วนนี้อธิบายวิธีการติดตั้ง NFS provisioner โดยใช้ helm หากคุณต้องการใช้ Digitalocean Kubernetes 1-click แทน ให้ข้ามส่วนนี้และใช้ [วิธีนี้ในการติดตั้ง NFS provisioner](https://marketplace.digitalocean.com/apps/openebs-nfs-provisioner) บนคลัสเตอร์ของคุณ**

[DigitalOcean Block Storage](https://docs.digitalocean.com/products/volumes/) โวลุ่มใหม่จะถูกจัดเตรียมทุกครั้งที่คุณใช้ [PersistentVolume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) เป็นส่วนหนึ่งของแอปพลิเคชัน Kubernetes ที่มีสถานะ [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/) จะบอก Kubernetes เกี่ยวกับประเภทการเก็บข้อมูลพื้นฐานที่มีอยู่ DigitalOcean ใช้ [do-block-storage](https://github.com/digitalocean/csi-digitalocean) เป็นค่าเริ่มต้น

คำสั่งด้านล่างแสดงรายการคลาสการจัดเก็บที่มีอยู่สำหรับคลัสเตอร์ Kubernetes ของคุณ:

```console
kubectl get sc
```

ผลลัพธ์จะมีลักษณะคล้ายกับ:

```text
NAME                         PROVISIONER                 RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
do-block-storage (default)   dobs.csi.digitalocean.com   Delete          Immediate           true                   24h
```

DigitalOcean Block Storage Volumes จะถูกเมาต์แบบอ่าน-เขียนโดยโหนดเดียว (RWO) โหนดเพิ่มเติมไม่สามารถเมาต์โวลุ่มเดียวกันได้ Pod หลาย ๆ Pod ไม่สามารถเข้าถึงข้อมูลในเนื้อหาของ PersistentVolume พร้อมกันได้

Horizontal pod autoscaling (HPA) ใช้เพื่อปรับขนาด WordPress Pods ในชุด StatefulSet แบบไดนามิก ดังนั้น WordPress จึงต้องการ [volume](https://kubernetes.io/docs/concepts/storage/volumes/) ที่เมาต์แบบอ่าน-เขียนโดยหลายโหนด (RWX)

NFS (Network File System) เป็นโซลูชันที่ใช้กันทั่วไปเพื่อให้โวลุ่ม RWX บน block storage เซิร์ฟเวอร์นี้จัดเตรียม PersistentVolumeClaim (PVC) ในโหมด RWX เพื่อให้เว็บแอปพลิเคชันหลายตัวสามารถเข้าถึงข้อมูลในรูปแบบที่แชร์กันได้

OpenEBS Dynamic NFS Provisioner ช่วยให้ผู้ใช้สร้าง NFS PV ที่ตั้งค่าอินสแตนซ์ Kernel NFS ใหม่สำหรับแต่ละ PV บนทับการจัดเก็บข้อมูลพื้นหลังที่ผู้ใช้เลือก

**หมายเหตุ:**

โปรดเยี่ยมชม [OpenEBS](https://openebs.io/) สำหรับรายละเอียดเพิ่มเติม

ต่อไป คุณจะติดตั้ง OpenEBS Dynamic NFS Provisioner บนคลัสเตอร์ Kubernetes ของคุณโดยใช้ [OpenEBS Helm Chart](https://github.com/openebs/dynamic-nfs-provisioner) คุณจะติดตั้งและกำหนดค่าเฉพาะ dynamic nfs provisioner เนื่องจาก Wordpress ต้องใช้งานมัน

ก่อนอื่น ให้โคลนที่เก็บ `container-blueprints` จากนั้นเปลี่ยนไดเรกทอรีไปยังสำเนาในเครื่องของคุณและไปยังโฟลเดอร์ย่อย `DOKS-wordpress`:

```shell
git clone https://github.com/digitalocean/container-blueprints.git
cd container-blueprints/DOKS-wordpress
```

จากนั้น เพิ่มที่เก็บ `Helm`:

```console
helm repo add openebs-nfs https://openebs.github.io/dynamic-nfs-provisioner

helm repo update
```

จากนั้น เปิดและตรวจสอบไฟล์ `assets/manifests/openEBS-nfs-provisioner-values.yaml` ที่มีให้ในที่เก็บ:

```yaml
nfsStorageClass:
  backendStorageClass: "do-block-storage"
```

**หมายเหตุ:**

การแทนที่ข้างต้นจะเปลี่ยนค่าเริ่มต้นสำหรับ `backendStorageClass` เป็น [do-block-storage](https://www.digitalocean.com/products/block-storage) โปรดเยี่ยมชม [openebs nfs provisioner helm values](https://github.com/openebs/dynamic-nfs-provisioner/blob/develop/deploy/helm/charts/values.yaml) สำหรับไฟล์ `values.yaml` ฉบับเต็มและรายละเอียดเพิ่มเติม

สุดท้าย ติดตั้งชาร์ตโดยใช้ Helm:

```console
helm install openebs-nfs openebs-nfs/nfs-provisioner --version 0.9.0 \
  --namespace openebs \
  --create-namespace \
  -f "assets/manifests/openEBS-nfs-provisioner-values.yaml"
```

**หมายเหตุ:**
เวอร์ชันเฉพาะสำหรับชาร์ต Helm ถูกใช้ ในกรณีนี้ 0.9.0 ถูกเลือก ซึ่งตรงกับเวอร์ชัน 0.9.0 ของแอปพลิเคชัน เป็นแนวปฏิบัติที่ดีโดยทั่วไปที่จะล็อกเวอร์ชันเฉพาะ ซึ่งช่วยให้มีผลลัพธ์ที่คาดการณ์ได้ และอนุญาตการควบคุมเวอร์ชันผ่าน Git

คุณสามารถตรวจสอบสถานะการเดพลอย openEBS ได้ผ่าน:

```console
helm ls -n openebs
```

ผลลัพธ์จะมีลักษณะคล้ายกับ (สังเกตว่าค่าในคอลัมน์ STATUS คือ deployed):

```text
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
openebs-nfs     openebs         1               2022-05-09 10:58:14.388721 +0300 EEST   deployed        nfs-provisioner-0.9.0   0.9.0  
```

NFS provisioner ต้องการอุปกรณ์ block storage เพื่อสร้างความจุดิสก์ที่ต้องการสำหรับเซิร์ฟเวอร์ NFS ต่อไป คุณจะกำหนดค่า Storage Class เริ่มต้นของ Kubernetes (do-block-storage) ที่ DigitalOcean จัดเตรียมให้เป็นที่เก็บข้อมูลพื้นหลังสำหรับ NFS provisioner ในกรณีนั้น แอปพลิเคชันใดก็ตามที่ใช้ Storage Class ที่สร้างขึ้นใหม่ต่อไปนี้ สามารถใช้พื้นที่จัดเก็บที่แชร์ (NFS) บนโวลุ่ม DigitalOcean โดยใช้ OpenEBS NFS provisioner

ต่อไป เปิดและตรวจสอบไฟล์ `sc-rwx-values.yaml` ที่มีให้ในที่เก็บ:

```yaml
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: rwx-storage
  annotations: 
    openebs.io/cas-type: nsfrwx
    cas.openebs.io/config: |
      - name: NSFServerType
        value: "kernel"
      - name: BackendStorageClass
        value: "do-block-storage"
provisioner: openebs.io/nfsrwx
reclaimPolicy: Delete
```

คำอธิบายสำหรับการกำหนดค่าข้างต้น:

- `provisioner` - กำหนดว่า storage class ใดที่ใช้สำหรับการจัดเตรียม PVs (เช่น openebs.io/nfsrwx)
- `reclaimPolicy` - โวลุ่มที่จัดเตรียมแบบไดนามิกจะถูกลบโดยอัตโนมัติเมื่อผู้ใช้ลบ PersistentVolumeClaim ที่เกี่ยวข้อง

สำหรับข้อมูลเพิ่มเติมเกี่ยวกับ openEBS โปรดเยี่ยมชม [OpenEBS Documentation](https://openebs.io/docs)

นำไปใช้ผ่าน kubectl:

```console
kubectl apply -f assets/manifests/sc-rwx-values.yaml
```

ตรวจสอบว่า StorageClass ถูกสร้างขึ้นโดยการเรียกใช้คำสั่งด้านล่าง:

```console
kubectl get sc
```

ผลลัพธ์จะมีลักษณะคล้ายกับ:

```text
NAME                         PROVISIONER                 RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
do-block-storage (default)   dobs.csi.digitalocean.com   Delete          Immediate           true                   107m
openebs-kernel-nfs           openebs.io/nfsrwx           Delete          Immediate           false                  84m
rwx-storage                  openebs.io/nfsrwx           Delete          Immediate           false                  84m
```

ตอนนี้คุณมี StorageClass ใหม่ชื่อ rwx-storage เพื่อจัดเตรียมโวลุ่มที่แชร์กันบน DigitalOcean Block Storage แบบไดนามิก

## การกำหนดค่า WordPress MySQL DO Managed Database

ในส่วนนี้ คุณจะสร้างฐานข้อมูล MySQL เฉพาะ เช่น [DigitalOcean's Managed Databases](https://docs.digitalocean.com/products/databases/mysql/) สำหรับ WordPress นี่เป็นสิ่งจำเป็นเพราะการติดตั้ง WordPress ของคุณจะอยู่บนเซิร์ฟเวอร์แยกต่างหากภายในคลัสเตอร์ Kubernetes

**หมายเหตุ:**

- โดยค่าเริ่มต้น WordPress Helm chart จะติดตั้ง MariaDB บน pod แยกต่างหากภายในคลัสเตอร์และกำหนดค่าให้เป็นฐานข้อมูลเริ่มต้น ก่อนที่จะตัดสินใจใช้ฐานข้อมูลที่มีการจัดการเทียบกับฐานข้อมูลเริ่มต้น (MariaDB) คุณควรพิจารณาแง่มุมต่อไปนี้:
  - ด้วยบริการฐานข้อมูลที่มีการจัดการ คุณเพียงแค่ต้องตัดสินใจเกี่ยวกับขนาดเริ่มต้นของเซิร์ฟเวอร์ฐานข้อมูลและคุณก็พร้อมที่จะใช้งาน อีกจุดหนึ่งที่น่าสนใจคือด้านการทำงานอัตโนมัติ การอัปเดต การย้าย และการสร้างข้อมูลสำรองจะถูกดำเนินการโดยอัตโนมัติ โปรดดู[บทความ](https://www.digitalocean.com/community/tutorials/understanding-managed-databases)นี้สำหรับข้อมูลเพิ่มเติมเกี่ยวกับฐานข้อมูลที่มีการจัดการ การใช้ฐานข้อมูลที่มีการจัดการมีค่าใช้จ่ายเพิ่มเติม
  - ด้วยการติดตั้ง MariaDB ค่าเริ่มต้นของ Helm chart สิ่งสำคัญที่ต้องทราบคือ DB pods (คอนเทนเนอร์แอปพลิเคชันฐานข้อมูล) มีลักษณะชั่วคราว ดังนั้นพวกมันอาจรีสตาร์ทหรือล้มเหลวได้บ่อยกว่า งานบริหารจัดการเฉพาะเช่นการสำรองข้อมูลหรือการปรับขนาดต้องใช้งานและการตั้งค่าด้วยตนเองมากขึ้นเพื่อให้บรรลุเป้าหมายเหล่านั้น การใช้การติดตั้ง MariaDB จะไม่สร้างค่าใช้จ่ายเพิ่มเติม

หากคุณไม่ต้องการใช้ฐานข้อมูลภายนอก โปรดข้ามไปยังบทต่อไป - [การกำหนดค่าฐานข้อมูล Redis](#การกำหนดค่าฐานข้อมูล-redis)

ก่อนอื่น สร้างฐานข้อมูล MySQL ที่มีการจัดการ:

```console
doctl databases create wordpress-mysql --engine mysql --region nyc1 --num-nodes 2 --size db-s-2vcpu-4gb
```

**หมายเหตุ:**

ตัวอย่างจากบทเรียนนี้ใช้โหนดมาสเตอร์หนึ่งโหนดและโหนดสเลฟหนึ่งโหนด 2cpu/4gb (`$100 เรียกเก็บเงินรายเดือน`) สำหรับรายการขนาดที่มีอยู่ เยี่ยมชม: <https://docs.digitalocean.com/reference/api/api-reference/#tag/Databases>

ผลลัพธ์จะมีลักษณะคล้ายกับ (คอลัมน์ `STATE` ควรแสดง `online`):

``` text
ID                                      Name                    Engine    Version    Number of Nodes    Region    Status      Size
2f0d0969-a8e1-4f94-8b73-2d43c68f8e72    wordpress-mysql-test    mysql     8          1                  nyc1      online    db-s-1vcpu-1gb
```

**หมายเหตุ:**

- ในการตั้งค่า MySQL ให้เสร็จสมบูรณ์ จำเป็นต้องมี ID ของฐานข้อมูล คุณสามารถเรียกใช้คำสั่งด้านล่างเพื่อพิมพ์ ID ของฐานข้อมูล MySQL ของคุณ:

  ```console
  doctl databases list
  ```

ต่อไป สร้างผู้ใช้ฐานข้อมูล WordPress:

```console
doctl databases user create 2f0d0969-a8e1-4f94-8b73-2d43c68f8e72 wordpress_user
```

ผลลัพธ์จะมีลักษณะคล้ายกับต่อไปนี้ (รหัสผ่านจะถูกสร้างโดยอัตโนมัติ):

```text
Name              Role      Password
wordpress_user    normal    *******
```

**หมายเหตุ:**

โดยค่าเริ่มต้น ผู้ใช้ใหม่จะได้รับสิทธิ์เต็มรูปแบบสำหรับฐานข้อมูลทั้งหมด โดยทั่วไปแล้ว การปฏิบัติด้านความปลอดภัยที่ดีที่สุดคือการจำกัดสิทธิ์ของผู้ใช้ใหม่ให้กับฐานข้อมูล wordpress เท่านั้น คุณสามารถทำตาม [วิธีการแก้ไขสิทธิ์ของผู้ใช้ในฐานข้อมูล MySQL](https://docs.digitalocean.com/products/databases/mysql/how-to/modify-user-privileges/) ที่ DigitalOcean ให้ไว้เพื่อทำงานนี้ให้สำเร็จ

ต่อไป สร้างฐานข้อมูล WordPress หลัก:

```console
doctl databases db create 2f0d0969-a8e1-4f94-8b73-2d43c68f8e72 wordpress
```

ผลลัพธ์จะมีลักษณะคล้ายกับต่อไปนี้ (รหัสผ่านจะถูกสร้างโดยอัตโนมัติ):

```text
Name
wordpress
```

สุดท้าย คุณต้องตั้งค่าแหล่งที่เชื่อถือได้ระหว่างฐานข้อมูล MySQL ของคุณและ Kubernetes Cluster (DOKS):

 1. ก่อนอื่นให้ดึง ID ของ Kubernetes Cluster:

    ```console
    doctl kubernetes cluster list
    ```

    ผลลัพธ์จะมีลักษณะคล้ายกับต่อไปนี้:

    ```text
    ID                                      Name                       Region    Version         Auto Upgrade    Status     Node Pools
    c278b4a3-19f0-4de6-b1b2-6d90d94faa3b    k8s-cluster   nyc1      1.21.10-do.0    false           running    basic
    ```

 2. สุดท้าย จำกัดการเชื่อมต่อขาเข้า:

    ```console
    doctl databases firewalls append 2f0d0969-a8e1-4f94-8b73-2d43c68f8e72 --rule k8s:c278b4a3-19f0-4de6-b1b2-6d90d94faa3b
    ````

    **หมายเหตุ:**

    - 2f0d0969-a8e1-4f94-8b73-2d43c68f8e72: แทน ID ของฐานข้อมูล
    - c278b4a3-19f0-4de6-b1b2-6d90d94faa3b: แทน ID ของ kubernetes

**หมายเหตุ:**

โปรดเยี่ยมชม [วิธีการรักษาความปลอดภัย MySQL Managed Database Clusters](https://docs.digitalocean.com/products/databases/mysql/how-to/secure/) สำหรับรายละเอียดเพิ่มเติม

## การกำหนดค่าฐานข้อมูล Redis

Remote Dictionary Server (Redis) เป็นฐานข้อมูล key-value ที่อยู่ในหน่วยความจำและมีความคงทน ซึ่งเรียกอีกอย่างว่าเซิร์ฟเวอร์โครงสร้างข้อมูล กลไกการแคชของ Redis เมื่อรวมกับ MySQL หรือ MariaDB จะช่วยเร่งการสืบค้นฐานข้อมูล WordPress Redis ช่วยให้คุณสามารถแคชและจัดเก็บข้อมูลในหน่วยความจำเพื่อการดึงข้อมูลและการจัดเก็บข้อมูลที่มีประสิทธิภาพสูง ด้วย Redis เป็นไปได้ที่จะจัดเก็บข้อมูลที่ประมวลผลโดยการสืบค้นฐานข้อมูล MySQL ภายในอินสแตนซ์แคช Redis เพื่อการดึงข้อมูลที่รวดเร็ว

การติดตั้งและกำหนดค่าอินสแตนซ์ Redis สามารถทำได้สองวิธี โดยใช้ [DigitalOcean's Managed Databases](https://docs.digitalocean.com/products/databases/redis/) สำหรับ Redis หรือการติดตั้งผ่าน [helm chart](https://github.com/bitnami/charts/tree/master/bitnami/redis) ทั้งสองตัวเลือกจะถูกสำรวจด้านล่าง

### การกำหนดค่า Redis DO Managed Database

ในส่วนนี้คุณจะสร้างฐานข้อมูล Redis โดยใช้ DigitalOcean หากคุณไม่ต้องการใช้ฐานข้อมูลที่มีการจัดการ โปรดข้ามไปยังส่วนถัดไป - [การกำหนดค่า Redis helm chart](configuring-the-redis-helm-chart)

**หมายเหตุ:**
ก่อนที่จะตัดสินใจใช้ฐานข้อมูลที่มีการจัดการเทียบกับฐานข้อมูลที่ติดตั้งด้วย helm คุณควรพิจารณาแง่มุมต่อไปนี้:
ด้วยบริการฐานข้อมูลที่มีการจัดการ คุณเพียงแค่ต้องตัดสินใจเกี่ยวกับขนาดเริ่มต้นของเซิร์ฟเวอร์ฐานข้อมูลและคุณก็พร้อมที่จะใช้งาน อีกจุดหนึ่งที่น่าสนใจคือด้านการทำงานอัตโนมัติ การอัปเดต การย้าย และการสร้างข้อมูลสำรองจะถูกดำเนินการโดยอัตโนมัติ โปรดดู[บทความ](https://www.digitalocean.com/community/tutorials/understanding-managed-databases)นี้สำหรับข้อมูลเพิ่มเติมเกี่ยวกับฐานข้อมูลที่มีการจัดการ การใช้ฐานข้อมูลที่มีการจัดการมีค่าใช้จ่ายเพิ่มเติม
ด้วยการติดตั้ง Redis Helm chart สิ่งสำคัญที่ต้องทราบคือ DB pods (คอนเทนเนอร์แอปพลิเคชันฐานข้อมูล) มีลักษณะชั่วคราว ดังนั้นพวกมันอาจรีสตาร์ทหรือล้มเหลวได้บ่อยกว่า งานบริหารจัดการเฉพาะเช่นการสำรองข้อมูลหรือการปรับขนาดต้องใช้งานและการตั้งค่าด้วยตนเองมากขึ้นเพื่อให้บรรลุเป้าหมายเหล่านั้น การใช้การติดตั้ง Redis จะไม่สร้างค่าใช้จ่ายเพิ่มเติม

ก่อนอื่น สร้างฐานข้อมูล Redis ที่มีการจัดการ:

```console

doctl databases create wordpress-redis --engine redis --region nyc1 --num-nodes 1 --size db-s-1vcpu-1gb

```

**หมายเหตุ:**

ตัวอย่างจากบทเรียนนี้ใช้โหนดเดียว 1cpu/1gb ($10 เรียกเก็บเงินรายเดือน) สำหรับรายการขนาดที่มีอยู่ โปรดเยี่ยมชม [API doc](https://docs.digitalocean.com/reference/api/api-reference/#tag/Databases)

ผลลัพธ์จะมีลักษณะคล้ายกับต่อไปนี้ (คอลัมน์ `STATE` ควรแสดง `online`):

```text

ID                                      Name               Engine    Version    Number of Nodes    Region    Status      Size
91180998-7fe2-450c-b353-492d8abcddad    wordpress-redis    redis     6          1                  nyc1      creating    db-s-1vcpu-1gb

```

ต่อไป คุณต้องตั้งค่าแหล่งที่เชื่อถือได้ระหว่างฐานข้อมูล Redis ของคุณและ Kubernetes Cluster (DOKS):

 1. ก่อนอื่นให้ดึง ID ของ Kubernetes Cluster:

    ```console
    doctl kubernetes cluster list
    ```

    ผลลัพธ์จะมีลักษณะคล้ายกับต่อไปนี้:

    ```text
    ID                                      Name                       Region    Version         Auto Upgrade    Status     Node Pools
    c278b4a3-19f0-4de6-b1b2-6d90d94faa3b    k8s-cluster   nyc1      1.21.10-do.0    false           running    basic
    ```

 2. สุดท้าย จำกัดการเชื่อมต่อขาเข้า:

    ```console
    doctl databases firewalls append 2f0d0969-a8e1-4f94-8b73-2d43c68f8e72 --rule k8s:c278b4a3-19f0-4de6-b1b2-6d90d94faa3b
    ````

    **หมายเหตุ:**

    - 2f0d0969-a8e1-4f94-8b73-2d43c68f8e72: แทน ID ของฐานข้อมูล
    - c278b4a3-19f0-4de6-b1b2-6d90d94faa3b: แทน ID ของ kubernetes

**หมายเหตุ:**

โปรดเยี่ยมชม [วิธีการรักษาความปลอดภัย Redis Managed Database Clusters](https://docs.digitalocean.com/products/databases/redis/how-to/secure/) สำหรับรายละเอียดเพิ่มเติม

### การกำหนดค่า Redis helm chart

ในส่วนนี้คุณจะสร้างฐานข้อมูล Redis ในคลัสเตอร์ Kubernetes ของคุณโดยใช้ [Bitnami Redis Helm Chart](https://github.com/bitnami/charts/tree/master/bitnami/redis)

ก่อนอื่น เพิ่มที่เก็บ `Helm` และแสดงรายการ `charts` ที่มีอยู่:

```console
helm repo add bitnami https://charts.bitnami.com/bitnami

helm repo update bitnami
```

จากนั้น เปิดและตรวจสอบไฟล์ `assets/manifests/redis-values.yaml` ที่มีให้ในที่เก็บ:

```yaml

master:
  persistence:
    enabled: true
    storageClass: rwx-storage
    accessModes: ["ReadWriteMany"]
    size: 5Gi

auth:
  enabled: true
  password: <YOUR_REDIS_PASSWORD_HERE>
  
architecture: standalone

```

คำอธิบายสำหรับการกำหนดค่าข้างต้น:

- บล็อก `master.persistance` - เปิดใช้งาน persistance บนโหนดมาสเตอร์ Redis โดยใช้ PVC และตั้งค่า PV storage class เป็นคลาสที่สร้างขึ้นก่อนหน้านี้
- บล็อก `auth` - เปิดใช้งานและตั้งค่าการตรวจสอบรหัสผ่านสำหรับรหัสผ่านที่ผู้ใช้ตั้งค่า
- `architecture` - สถาปัตยกรรม Redis StatefulSet redis แบบสแตนด์อโลน บริการ Redis Master ชี้ไปที่มาสเตอร์ที่สามารถทำการดำเนินการอ่าน-เขียนได้

**หมายเหตุ:**

การแทนที่ส่วนใหญ่สามารถปรับแต่งได้ โปรดเยี่ยมชม [redis helm values](https://github.com/bitnami/charts/blob/master/bitnami/redis/values.yaml) สำหรับรายละเอียดเพิ่มเติม

สุดท้าย ติดตั้งชาร์ตโดยใช้ Helm:

```console
helm upgrade redis bitnami/redis \
    --atomic \
    --create-namespace \
    --install \
    --namespace redis \
    --version 17.0.5 \
    --values assets/manifests/redis-values.yaml
```

**หมายเหตุ:**

เวอร์ชันเฉพาะสำหรับ redis `Helm` chart ถูกใช้ ในกรณีนี้ `17.0.5` ถูกเลือก ซึ่งตรงกับการเปิดตัว `7.0.4` ของ Redis เป็นแนวปฏิบัติที่ดีโดยทั่วไปที่จะล็อกเวอร์ชันเฉพาะ ซึ่งช่วยให้มีผลลัพธ์ที่คาดการณ์ได้ และอนุญาตการควบคุมเวอร์ชันผ่าน Git

ตรวจสอบสถานะการปล่อย Helm:

```console
helm ls -n redis
```

ผลลัพธ์จะมีลักษณะคล้ายกับ (สังเกตว่าคอลัมน์ `STATUS` มีค่า `deployed`):

```text
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
redis   redis           1               2022-06-02 08:45:38.617726 +0300 EEST   deployed        redis-17.0.5    7.0.4
```

ตรวจสอบว่า Redis ทำงานอยู่หรือไม่:

```console
kubectl get all -n redis
```

ผลลัพธ์จะมีลักษณะคล้ายกับ (pod `redis` ทั้งหมดควร UP และ RUNNING):

```text
NAME                 READY   STATUS    RESTARTS   AGE
pod/redis-master-0   1/1     Running   0          2m24s

NAME                     TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
service/redis-headless   ClusterIP   None           <none>        6379/TCP   2m25s
service/redis-master     ClusterIP   10.245.14.50   <none>        6379/TCP   2m25s

NAME                            READY   AGE
statefulset.apps/redis-master   1/1     2m26s
```

## การติดตั้ง WordPress

### การเดพลอย Helm Chart

ในส่วนนี้ คุณจะติดตั้ง WordPress ในคลัสเตอร์ Kubernetes ของคุณโดยใช้ [Bitnami WordPress Helm Chart](https://github.com/bitnami/charts/tree/master/bitnami/wordpress/)

ค่าที่สำคัญที่สุดของ Helm chart คือ:

- `externalDatabase`- กำหนดค่า WordPress ให้ใช้ฐานข้อมูลภายนอก (เช่น ฐานข้อมูล MySQL ที่มีการจัดการ DO)
- `mariadb.enabled` - กำหนดค่า WordPress ให้ใช้ฐานข้อมูลในคลัสเตอร์ (เช่น MariaDB)

ก่อนอื่น เพิ่มที่เก็บ `Helm` และแสดงรายการ `charts` ที่มีอยู่:

```console
helm repo add bitnami https://charts.bitnami.com/bitnami

helm repo update bitnami
```

จากนั้น เปิดและตรวจสอบไฟล์ `assets/manifests/wordpress-values.yaml` ที่มีให้ในที่เก็บ:

```yaml
# WordPress service type
service:
  type: ClusterIP

# Enable persistence using Persistent Volume Claims
persistence:
  enabled: true
  storageClassName: rwx-storage
  accessModes: ["ReadWriteMany"]
  size: 5Gi

volumePermissions:
  enabled: true

# Prometheus Exporter / Metrics configuration
metrics:
  enabled: false

# Level of auto-updates to allow. Allowed values: major, minor or none.
wordpressAutoUpdateLevel: minor

# Scheme to use to generate WordPress URLs
wordpressScheme: https

# WordPress credentials
wordpressUsername: <YOUR_WORDPRESS_USER_NAME_HERE>
wordpressPassword: <YOUR_WORDPRESS_USER_PASSSWORD_HERE>

# External Database details
externalDatabase:
  host: <YOUR_WORDPRESS_MYSQL_DB_HOST_HERE>
  port: 25060
  user: <YOUR_WORDPRESS_MYSQL_DB_USER_NAME_HERE>
  password: <YOUR_WORDPRESS_MYSQL_DB_USER_PASSWORD_HERE>
  database: <YOUR_WORDPRESS_MYSQL_DB_NAME_HERE>

# Disabling MariaDB
mariadb:
  enabled: false

wordpressExtraConfigContent: |
    define( 'WP_REDIS_SCHEME', '<REDIS_SCHEME>' );
    define( 'WP_REDIS_HOST', '<REDIS_HOST>' );
    define( 'WP_REDIS_PORT', <REDIS_PORT> );
    define( 'WP_REDIS_PASSWORD', '<REDIS_PASSWORD>');
    define( 'WP_REDIS_DATABASE', 0 );

```

**หมายเหตุ:**

การแทนที่ส่วนใหญ่สามารถปรับแต่งได้ โปรดเยี่ยมชม [wordpress helm values](https://github.com/bitnami/charts/blob/master/bitnami/wordpress/values.yaml) สำหรับรายละเอียดเพิ่มเติม
พารามิเตอร์ `WP_REDIS_SCHEME` ต้องตั้งค่าเป็น `tls` เมื่อใช้ฐานข้อมูล Redis DO ที่มีการจัดการและ `tcp` เมื่อใช้ฐานข้อมูล Redis ที่ติดตั้งด้วย helm
ค่าพารามิเตอร์ `WP_REDIS_HOST` สำหรับฐานข้อมูล Redis ที่ติดตั้งด้วย helm สามารถรับได้ด้วยคำสั่งต่อไปนี้:

```shell
kubectl exec -i -t <REDIS_POD> --namespace redis -- hostname -i
```

สุดท้าย ติดตั้งชาร์ตโดยใช้ Helm:

```console
helm upgrade wordpress bitnami/wordpress \
    --atomic \
    --create-namespace \
    --install \
    --namespace wordpress \
    --version 15.0.11 \
    --values assets/manifests/wordpress-values.yaml
```

**หมายเหตุ:**

เวอร์ชันเฉพาะสำหรับ wordpress `Helm` chart ถูกใช้ ในกรณีนี้ `15.0.11` ถูกเลือก ซึ่งตรงกับการเปิดตัว `6.0.1` ของ WordPress เป็นแนวปฏิบัติที่ดีโดยทั่วไปที่จะล็อกเวอร์ชันเฉพาะ ซึ่งช่วยให้มีผลลัพธ์ที่คาดการณ์ได้ และอนุญาตการควบคุมเวอร์ชันผ่าน Git

ตรวจสอบสถานะการปล่อย Helm:

```console
helm ls -n wordpress
```

ผลลัพธ์จะมีลักษณะคล้ายกับ (สังเกตว่าคอลัมน์ `STATUS` มีค่า `deployed`):

```text
NAME      NAMESPACE REVISION UPDATED                              STATUS   CHART             APP VERSION
wordpress wordpress 1        2022-03-22 14:22:18.146474 +0200 EET deployed wordpress-15.0.11 6.0.1
```

ตรวจสอบว่า WordPress ทำงานอยู่หรือไม่:

```console
kubectl get all -n wordpress
```

ผลลัพธ์จะมีลักษณะคล้ายกับ (pod `wordpress` ทั้งหมดควร UP และ RUNNING):

```text
NAME                             READY   STATUS    RESTARTS   AGE
pod/wordpress-6f55c9ffbd-4frrh   1/1     Running   0          23h

NAME                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/wordpress   ClusterIP   10.245.36.237   <none>        80/TCP,443/TCP   23h

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/wordpress   1/1     1            1           23h

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/wordpress-6f55c9ffbd   1         1         1       23h
```

ตรวจสอบ PVC ที่สร้างภายใต้ namespace wordpress และ OpenEBS volume ที่เกี่ยวข้องภายใต้ namespace openebs:

```console
kubectl get pvc -A
```

ผลลัพธ์จะมีลักษณะคล้ายกับ (สังเกตโหมดการเข้าถึง `RWX` สำหรับ PVC ของ wordpress และคลาสการจัดเก็บใหม่ที่กำหนดไว้ก่อนหน้านี้ผ่าน openEBS NFS provisioner):

```text
NAMESPACE   NAME                                           STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS       AGE
openebs     nfs-pvc-2b898be6-19f4-4e52-ab9b-10e73ce7d82f   Bound    pvc-b253c0eb-b02b-46a6-ae88-9a7dd2b71377   5Gi        RWO            do-block-storage   10m
openebs     nfs-pvc-4ce1c2a8-ee65-420f-a722-50f4e50c60a7   Bound    pvc-2f2c9dd8-807d-4919-aac1-ab1af69e24c7   5Gi        RWO            do-block-storage   3m22s
redis       redis-data-redis-master-0                      Bound    pvc-2b898be6-19f4-4e52-ab9b-10e73ce7d82f   5Gi        RWX            rwx-storage        10m
wordpress   wordpress                                      Bound    pvc-4ce1c2a8-ee65-420f-a722-50f4e50c60a7   5Gi        RWX            rwx-storage        3m22s
```

ตรวจสอบ PV ที่เกี่ยวข้องที่สร้างในคลัสเตอร์:

```console
kubectl get pv
```

ผลลัพธ์จะมีลักษณะคล้ายกับ:

```text
NAME                                       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                                                  STORAGECLASS       REASON   AGE
pvc-2b898be6-19f4-4e52-ab9b-10e73ce7d82f   5Gi        RWX            Delete           Bound    redis/redis-data-redis-master-0                        rwx-storage                 12m
pvc-2f2c9dd8-807d-4919-aac1-ab1af69e24c7   5Gi        RWO            Delete           Bound    openebs/nfs-pvc-4ce1c2a8-ee65-420f-a722-50f4e50c60a7   do-block-storage            4m48s
pvc-4ce1c2a8-ee65-420f-a722-50f4e50c60a7   5Gi        RWX            Delete           Bound    wordpress/wordpress                                    rwx-storage                 4m48s
pvc-b253c0eb-b02b-46a6-ae88-9a7dd2b71377   5Gi        RWO            Delete           Bound    openebs/nfs-pvc-2b898be6-19f4-4e52-ab9b-10e73ce7d82f   do-block-storage            12m
```

คุณยังสามารถสร้างพ็อดเพิ่มเติมเพื่อแสดงความสามารถของ NFS provisioner โดยการเปิดไฟล์ `(wordpress-values.yaml)` และเพิ่มบรรทัด `replicaCount` ที่ตั้งค่าเป็นจำนวนเรพลิกาที่ต้องการ

```yaml
...
replicaCount: 3
...
```

ใช้การเปลี่ยนแปลงโดยใช้คำสั่งอัปเกรด helm:

```console
helm upgrade wordpress bitnami/wordpress \
    --atomic \
    --create-namespace \
    --install \
    --namespace wordpress \
    --version 15.0.11 \
    --values assets/manifests/wordpress-values.yaml
```

ตรวจสอบว่ามีการใช้การเปลี่ยนแปลงหรือไม่ สังเกตจำนวนเรพลิกาที่เพิ่มขึ้นและจำนวนพ็อด:

```console
kubectl get all -n wordpress
```

ผลลัพธ์จะมีลักษณะคล้ายกับ:

```text
NAME                             READY   STATUS    RESTARTS   AGE
pod/wordpress-5f5f4cf94c-d7mqb   1/1     Running   0          2m58s
pod/wordpress-5f5f4cf94c-qkxdq   1/1     Running   0          3m38s
pod/wordpress-5f5f4cf94c-zf46h   1/1     Running   0          87s

NAME                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
service/wordpress   ClusterIP   10.245.151.58   <none>        80/TCP,443/TCP   35m

NAME                        READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/wordpress   3/3     3            3           35m

NAME                                   DESIRED   CURRENT   READY   AGE
replicaset.apps/wordpress-5f5f4cf94c   3         3         3       35m
replicaset.apps/wordpress-798789f994   0         0         0       19m
```

เรายังสามารถตรวจสอบได้ว่าพ็อดถูกปรับใช้ที่ใด:

```console
kubectl get all -n wordpress -o wide
```

ผลลัพธ์จะมีลักษณะคล้ายกับ (สังเกตว่าพ็อดถูกปรับใช้บนโหนดต่างๆ):

```text
NAME                             READY   STATUS    RESTARTS   AGE     IP             NODE            NOMINATED NODE   READINESS GATES
pod/wordpress-5f5f4cf94c-d7mqb   1/1     Running   0          4m7s    10.244.0.206   basicnp-cwxop   <none>           <none>
pod/wordpress-5f5f4cf94c-qkxdq   1/1     Running   0          4m47s   10.244.1.84    basicnp-cwxol   <none>           <none>
pod/wordpress-5f5f4cf94c-zf46h   1/1     Running   0          2m36s   10.244.0.194   basicnp-cwxop   <none>           <none>
```

### การรักษาความปลอดภัยของ Traffic ด้วยใบรับรอง Let's Encrypt

Bitnami WordPress Helm chart มาพร้อมกับการรองรับ Ingress routes และการจัดการใบรับรองผ่าน [cert-manager](https://github.com/jetstack/cert-manager) ในตัว ซึ่งทำให้ง่ายต่อการกำหนดค่า TLS โดยใช้ใบรับรองจากผู้ให้บริการใบรับรองหลายราย รวมถึง [Let's Encrypt](https://letsencrypt.org/)

#### การติดตั้ง Nginx Ingress Controller

ก่อนอื่น เพิ่มที่เก็บ Helm และแสดงรายการชาร์ตที่มีอยู่:

```console
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm repo update ingress-nginx
```

จากนั้น ติดตั้ง Nginx Ingress Controller โดยใช้ Helm:

```console
helm install ingress-nginx ingress-nginx/ingress-nginx --version 4.1.3 \
  --namespace ingress-nginx \
  --create-namespace
```

จากนั้น ตรวจสอบว่าการติดตั้ง Helm สำเร็จหรือไม่โดยเรียกใช้คำสั่งด้านล่าง:

```console
helm ls -n ingress-nginx
```

ผลลัพธ์จะมีลักษณะคล้ายกับต่อไปนี้ (สังเกตว่าคอลัมน์ `STATUS` มีค่า `deployed`):

```text
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                  APP VERSION
ingress-nginx   ingress-nginx   1               2022-02-14 12:04:06.670028 +0200 EET    deployed        ingress-nginx-4.1.3    1.2.1
```

สุดท้าย แสดงรายการทรัพยากร load balancer ทั้งหมดจากบัญชี `DigitalOcean` ของคุณ และพิมพ์ `IP`, `ID`, `Name` และ `Status`:

```shell
doctl compute load-balancer list --format IP,ID,Name,Status
```

ผลลัพธ์จะมีลักษณะคล้ายกับ (ควรมีทรัพยากร `load balancer` ใหม่ที่สร้างขึ้นสำหรับ `Nginx Ingress Controller` ในสถานะที่ดี):

```text
IP                 ID                                      Name                                Status
45.55.107.209    0471a318-a98d-49e3-aaa1-ccd855831447    acdc25c5cfd404fd68cd103be95af8ae    active
```

### การกำหนดค่า DNS สำหรับ Nginx Ingress Controller

ในขั้นตอนนี้ คุณจะกำหนดค่า `DNS` ในบัญชี `DigitalOcean` ของคุณโดยใช้ `domain` ที่คุณเป็นเจ้าของ จากนั้นคุณจะสร้างระเบียน `A` ของโดเมนสำหรับ wordpress

ก่อนอื่น โปรดออกคำสั่งด้านล่างเพื่อสร้าง `domain` ใหม่ (`bond-0.co` ในตัวอย่างนี้):

```shell
doctl compute domain create bond-0.co
```

**หมายเหตุ:**

**คุณต้องแน่ใจว่าผู้รับจดทะเบียนโดเมนของคุณได้รับการกำหนดค่าให้ชี้ไปที่เซิร์ฟเวอร์ชื่อของ DIGITALOCEAN** ข้อมูลเพิ่มเติมเกี่ยวกับวิธีการทำเช่นนั้นมีอยู่ [ที่นี่](https://www.digitalocean.com/community/tutorials/how-to-point-to-digitalocean-nameservers-from-common-domain-registrars)

ต่อไป คุณจะเพิ่มระเบียน `A` ที่จำเป็นสำหรับแอปพลิเคชัน wordpress ก่อนอื่น คุณต้องระบุ `external IP` ของ load balancer ที่สร้างโดยการปรับใช้ `nginx`:

ต่อไป คุณจะเพิ่มระเบียน `A` ที่จำเป็นสำหรับ `hosts` ที่คุณสร้างขึ้นก่อนหน้านี้ ก่อนอื่น คุณต้องระบุ `external IP` ของ load balancer ที่สร้างโดยการปรับใช้ `nginx`:

```shell
kubectl get svc -n ingress-nginx
```

ผลลัพธ์จะมีลักษณะคล้ายกับ (สังเกตว่าคอลัมน์ `EXTERNAL-IP` มีค่าอะไรสำหรับบริการ `ingress-nginx-controller`):

```text
NAME                                 TYPE           CLUSTER-IP     EXTERNAL-IP       PORT(S)                      AGE
ingress-nginx-controller             LoadBalancer   10.245.109.87   45.55.107.209   80:32667/TCP,443:31663/TCP   25h
ingress-nginx-controller-admission   ClusterIP      10.245.90.207   <none>          443/TCP                      25h
```

จากนั้น เพิ่มระเบียน (โปรดแทนที่ตัวคั่น `<>` ตามความเหมาะสม) คุณสามารถเปลี่ยนค่า `TTL` ตามความต้องการของคุณ:

```shell
doctl compute domain records create bond-0.co --record-type "A" --record-name "wordpress" --record-data "<YOUR_LB_IP_ADDRESS>" --record-ttl "30"
```

**คำแนะนำ:**

หากคุณมี `load balancer` เพียงตัวเดียวในบัญชีของคุณ โปรดใช้โค้ดต่อไปนี้:

```shell
LOAD_BALANCER_IP=$(doctl compute load-balancer list --format IP --no-header)

doctl compute domain records create bond-0.co --record-type "A" --record-name "wordpress" --record-data "$LOAD_BALANCER_IP" --record-ttl "30"
```

**การสังเกตและผลลัพธ์:**

แสดงรายการระเบียนที่มีอยู่สำหรับโดเมน `bond-0.co`:

```shell
doctl compute domain records list bond-0.co
```

ผลลัพธ์จะมีลักษณะคล้ายกับต่อไปนี้:

```text
ID           Type    Name         Data                    Priority    Port    TTL     Weight
311452740    SOA     @            1800                    0           0       1800    0
311452742    NS      @            ns1.digitalocean.com    0           0       1800    0
311452743    NS      @            ns2.digitalocean.com    0           0       1800    0
311452744    NS      @            ns3.digitalocean.com    0           0       1800    0
311453305    A       wordpress    45.55.107.209           0           0       30      0
```

#### การติดตั้ง Cert-Manager

ก่อนอื่น เพิ่มที่เก็บ `jetstack` Helm และแสดงรายการชาร์ตที่มีอยู่:

```console
helm repo add jetstack https://charts.jetstack.io

helm repo update jetstack
```

จากนั้น ติดตั้ง Cert-Manager โดยใช้ Helm:

```console
helm install cert-manager jetstack/cert-manager --version 1.8.0 \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true
```

สุดท้าย ตรวจสอบว่าการติดตั้ง Cert-Manager สำเร็จหรือไม่โดยเรียกใช้คำสั่งด้านล่าง:

```console
helm ls -n cert-manager
```

ผลลัพธ์จะมีลักษณะคล้ายกับ (คอลัมน์ `STATUS` ควรพิมพ์ `deployed`):

```text
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
cert-manager    cert-manager    1               2021-10-20 12:13:05.124264 +0300 EEST   deployed        cert-manager-v1.8.0     v1.8.0
```

**หมายเหตุ:**

- สำหรับรายละเอียดเพิ่มเติมเกี่ยวกับ Nginx Ingress Controller และ Cert-Manager โปรดเยี่ยมชม Starter Kit chapter - [วิธีการกำหนดค่า Ingress โดยใช้ Nginx](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/blob/main/03-setup-ingress-controller/nginx.md)

- วิธีการติดตั้ง [NGINX Ingress Controller](https://marketplace.digitalocean.com/apps/nginx-ingress-controller) และ [Cert-Manager](https://marketplace.digitalocean.com/apps/cert-manager) ทางเลือกคือผ่านแพลตฟอร์ม DigitalOcean 1-click apps

#### การกำหนดค่าใบรับรอง TLS สำหรับ WordPress ที่พร้อมใช้งานจริง

ต้องมี cluster issuer ก่อนเพื่อขอรับใบรับรอง TLS สุดท้าย เปิดและตรวจสอบไฟล์ `assets/manifests/letsencrypt-issuer-values-values.yaml` ที่มีให้ในที่เก็บ:

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: wordpress
spec:
  acme:
    # You must replace this email address with your own.
    # Let's Encrypt will use this to contact you about expiring
    # certificates, and issues related to your account.
    email:  <YOUR-EMAIL-HERE>
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      # Secret resource used to store the account's private key.
      name: prod-issuer-account-key
    # Add a single challenge solver, HTTP01 using nginx
    solvers:
    - http01:
        ingress:
          class: nginx
```

นำไปใช้ผ่าน kubectl:

```console
kubectl apply -f assets/manifests/letsencrypt-issuer-values.yaml
```

เพื่อรักษาความปลอดภัยของ Traffic ของ WordPress ให้เปิดไฟล์ helm `(wordpress-values.yaml)` ที่สร้างขึ้นก่อนหน้านี้ และเพิ่มการตั้งค่าต่อไปนี้ที่ท้ายไฟล์:

```yaml
# Enable ingress record generation for WordPress
ingress:
  enabled: true
  certManager: true
  tls: false
  hostname: <YOUR_WORDPRESS_DOMAIN_HERE>
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  extraTls:
  - hosts:
      - <YOUR_WORDPRESS_DOMAIN_HERE>
    secretName: wordpress.local-tls
```

อัปเกรดผ่าน `helm`:

```console
helm upgrade wordpress bitnami/wordpress \
    --create-namespace \
    --namespace wordpress \
    --version 15.0.11 \
    --timeout 10m0s \
    --values assets/manifests/wordpress-values.yaml
```

สิ่งนี้จะสร้างใบรับรองโดยอัตโนมัติผ่าน cert-manager จากนั้นคุณสามารถตรวจสอบว่าคุณได้รับใบรับรองสำเร็จแล้วโดยเรียกใช้คำสั่งต่อไปนี้:

```console
kubectl get certificate -n wordpress wordpress.local-tls
```

หากสำเร็จ คอลัมน์ READY ของผลลัพธ์จะอ่านว่า True:

```text
NAME                  READY   SECRET                AGE
wordpress.local-tls   True    wordpress.local-tls   24h
```

ตอนนี้คุณสามารถเข้าถึง WordPress โดยใช้โดเมนที่กำหนดค่าไว้ก่อนหน้านี้ คุณจะได้รับคำแนะนำตลอดกระบวนการ `installation`

## การเปิดใช้งาน WordPress Monitoring Metrics

ในส่วนนี้ คุณจะได้เรียนรู้วิธีเปิดใช้งานเมตริกสำหรับการตรวจสอบอินสแตนซ์ WordPress ของคุณ

ก่อนอื่น ให้เปิด `wordpress-values.yaml` ที่สร้างขึ้นก่อนหน้านี้ในบทเรียนนี้ และตั้งค่า `metrics.enabled` เป็น `true`:

```yaml
# Prometheus Exporter / Metrics configuration
metrics:
  enabled: true
```

ใช้การเปลี่ยนแปลงโดยใช้ Helm:

```console
helm upgrade wordpress bitnami/wordpress \
    --create-namespace \
    --namespace wordpress \
    --version 15.0.11 \
    --timeout 10m0s \
    --values assets/manifests/wordpress-values.yaml
```

จากนั้น ส่งต่อพอร์ตบริการ wordpress เพื่อตรวจสอบเมตริกที่มีอยู่:

```console
kubectl port-forward --namespace wordpress svc/wordpress-metrics 9150:9150
```

ตอนนี้ เปิดเว็บเบราว์เซอร์และไปที่ [localhost:9150/metrics](http://127.0.0.1:9150/metrics) เพื่อดูเมตริก WordPress ทั้งหมด

สุดท้าย คุณต้องกำหนดค่า Grafana และ Prometheus เพื่อแสดงภาพเมตริกที่เปิดเผยโดยอินสแตนซ์ WordPress ใหม่ของคุณ โปรดเยี่ยมชม [วิธีการติดตั้ง Prometheus Monitoring Stack](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/04-setup-prometheus-stack) เพื่อเรียนรู้เพิ่มเติมเกี่ยวกับวิธีการติดตั้งและกำหนดค่า Grafana และ Prometheus

## การกำหนดค่าปลั๊กอิน WordPress

ปลั๊กอินเป็นส่วนประกอบสำคัญของเว็บไซต์ WordPress ของคุณ พวกเขานำฟังก์ชันที่สำคัญมาสู่เว็บไซต์ของคุณ ไม่ว่าคุณจะต้องการเพิ่มแบบฟอร์มติดต่อ ปรับปรุง SEO เพิ่มความเร็วของเว็บไซต์ สร้างร้านค้าออนไลน์ หรือเสนออีเมล opt-ins สิ่งที่คุณต้องการให้เว็บไซต์ของคุณทำได้สามารถทำได้ด้วยปลั๊กอิน

ด้านล่างนี้คุณสามารถค้นหารายการปลั๊กอินที่แนะนำ:

- [Contact Form by WPForms](https://wordpress.org/plugins/wpforms-lite/): ช่วยให้คุณสร้างแบบฟอร์มติดต่อที่สวยงาม แบบฟอร์มข้อเสนอแนะ แบบฟอร์มการสมัครสมาชิก แบบฟอร์มการชำระเงิน และแบบฟอร์มประเภทอื่นๆ สำหรับเว็บไซต์ของคุณ

- [MonsterInsights](https://wordpress.org/plugins/google-analytics-for-wordpress/): เป็นปลั๊กอิน Google Analytics ที่ดีที่สุดสำหรับ WordPress ช่วยให้คุณเชื่อมต่อเว็บไซต์ของคุณกับ Google Analytics ได้อย่างถูกต้อง เพื่อให้คุณเห็นได้อย่างชัดเจนว่าผู้คนค้นหาและใช้เว็บไซต์ของคุณอย่างไร

- [All in One SEO](https://wordpress.org/plugins/all-in-one-seo-pack/): ช่วยให้คุณได้รับผู้เข้าชมจากเครื่องมือค้นหามายังเว็บไซต์ของคุณมากขึ้น ในขณะที่ WordPress เป็นมิตรกับ SEO ตั้งแต่แรกเริ่ม แต่ยังมีอีกมากที่คุณสามารถทำได้เพื่อเพิ่มปริมาณการเข้าชมเว็บไซต์ของคุณโดยใช้แนวทางปฏิบัติที่ดีที่สุดของ SEO

- [SeedProd](https://wordpress.org/plugins/coming-soon/): เป็นเครื่องมือสร้างเพจแบบลากและวางที่ดีที่สุดสำหรับ WordPress ช่วยให้คุณปรับแต่งการออกแบบเว็บไซต์ของคุณได้อย่างง่ายดายและสร้างเลย์เอาต์เพจที่กำหนดเองโดยไม่ต้องเขียนโค้ดใดๆ

- [LiteSpeed Cache](https://wordpress.org/plugins/litespeed-cache/): เป็นปลั๊กอินการเร่งความเร็วของไซต์แบบครบวงจร มีแคชระดับเซิร์ฟเวอร์สุดพิเศษและคอลเลกชันของฟีเจอร์การเพิ่มประสิทธิภาพ

- [UpdraftPlus](https://wordpress.org/plugins/updraftplus/): ช่วยให้การสำรองข้อมูลและการกู้คืนง่ายขึ้น สำรองไฟล์และฐานข้อมูลของคุณไปยังคลาวด์และกู้คืนด้วยการคลิกเพียงครั้งเดียว

- [Query Monitor](https://wordpress.org/plugins/query-monitor/): แผงเครื่องมือสำหรับนักพัฒนาสำหรับ WordPress ช่วยให้การดีบักการสืบค้นฐานข้อมูล ข้อผิดพลาดของ PHP ฮุกและการกระทำ

โปรดเยี่ยมชม <https://wordpress.org/plugins/> สำหรับปลั๊กอินเพิ่มเติม

## การปรับปรุงประสิทธิภาพ Wordpress

CDN หรือ Content Delivery Network เป็นวิธีง่ายๆ ในการเพิ่มความเร็วให้กับเว็บไซต์ WordPress CDN เป็นการตั้งค่าเซิร์ฟเวอร์ที่ช่วยเพิ่มความเร็วในการโหลดหน้าเว็บโดยการเพิ่มประสิทธิภาพการส่งคำขอของไฟล์มีเดีย เว็บไซต์ส่วนใหญ่ประสบปัญหาความล่าช้าเมื่อผู้เยี่ยมชมอยู่ห่างจากตำแหน่งเซิร์ฟเวอร์ การใช้ CDN สามารถเพิ่มความเร็วในการส่งเนื้อหาโดยการลดภาระของเว็บเซิร์ฟเวอร์ของคุณเมื่อให้บริการเนื้อหาคงที่ เช่น รูปภาพ CSS JavaScript และสตรีมวิดีโอ ข้อดีอีกประการของการแคชเนื้อหาคงที่คือความล่าช้าน้อยที่สุด CDN เป็นโซลูชันที่ยอดเยี่ยมและเชื่อถือได้ในการเพิ่มประสิทธิภาพเว็บไซต์ของคุณและปรับปรุงประสบการณ์ของผู้ใช้ทั่วโลก

### การกำหนดค่าปลั๊กอิน NitroPack

NitroPack เป็นปลั๊กอินสำหรับเพิ่มประสิทธิภาพความเร็วและประสิทธิภาพของเว็บไซต์ของคุณ

ต่อไป คุณจะกำหนดค่าปลั๊กอิน [Nitropack](https://wordpress.org/plugins/nitropack/) สำหรับอินสแตนซ์ Wordpress ของคุณ

**หมายเหตุ:**

รหัสผ่านผู้ดูแลระบบที่กำหนดผ่านค่า Wordpress Helm chart `file` (wordpress-values.yaml) ล้มเหลวเมื่อพยายามเข้าสู่ระบบคอนโซลผู้ดูแลระบบ Wordpress ในการเปลี่ยนรหัสผ่าน คุณต้องเชื่อมต่อกับฐานข้อมูลและรีเซ็ต ก่อนอื่น หากคุณไม่คุ้นเคยกับฐานข้อมูลที่มีการจัดการของ DigitalOcean โปรดอ่านคู่มือ [วิธีการเชื่อมต่อกับคลัสเตอร์ฐานข้อมูล MySQL](https://docs.digitalocean.com/products/databases/mysql/how-to/connect/) จากนั้นทำตามบทความ [การรีเซ็ตรหัสผ่านผู้ใช้ Wordpress ของคุณ](https://wordpress.org/support/article/resetting-your-password/) จากเว็บไซต์สนับสนุนของ Wordpress

โปรดทำตามขั้นตอนด้านล่างเพื่อกำหนดค่าปลั๊กอิน NitroPack สำหรับอินสแตนซ์ WordPress ของคุณ:

1. เปิดคอนโซลผู้ดูแลระบบของการติดตั้ง WordPress ของคุณผ่านลิงก์ต่อไปนี้ในเว็บเบราว์เซอร์ของคุณ (อย่าลืมแทนที่ตัวคั่น <> ตามความเหมาะสม):

      ```shell
      https://<YOUR_WORDPRESS_DOMAIN_HERE>/wp-admin
      ```

    เมื่อถูกถาม โปรดเข้าสู่ระบบด้วยข้อมูลประจำตัวของผู้ดูแลระบบ WordPress ของคุณ
2. คลิกที่เมนู `Plugins` จากนั้นเปิดเมนูย่อย `Add New`
3. ค้นหาปลั๊กอิน `Nitropack` และจากหน้าผลลัพธ์ให้คลิกที่ปุ่ม `Install Now` หลังจากการติดตั้งเสร็จสิ้น ให้คลิกที่ปุ่ม `Activate` คุณควรเห็นปลั๊กอินที่เพิ่มในรายการปลั๊กอินของคุณ
4. คลิกที่ลิงก์ `Settings` ใต้ชื่อปลั๊กอิน ในหน้าถัดไป ให้คลิกที่ปุ่ม `Connect to NitroPack` จากนั้นคุณจะถูกเปลี่ยนเส้นทางไปยังการเข้าสู่ระบบหรือสร้างบัญชีใหม่กับ NitroPack
5. หน้าควรเปิดด้วยข้อมูลที่เกี่ยวข้องกับแผน หน้าที่ปรับให้เหมาะสม ฯลฯ

ต่อไป โปรดทำตามขั้นตอนด้านล่างเพื่อเชื่อมต่อเว็บไซต์ของคุณกับ NitroPack:

1. ไปที่ [NitroPack](https://nitropack.io/) และเข้าสู่ระบบโดยใช้บัญชีที่คุณสร้างขึ้นเมื่อกำหนดค่าปลั๊กอิน
2. คลิกที่เมนู `Add new website` จากนั้นกรอก `Website URL` และ `Website name` ด้วยข้อมูลของคุณ ตอนนี้คลิกที่ตัวเลือก `Free subscription` จากนั้นคลิกปุ่ม `Proceed`
3. หากโดเมนของคุณโฮสต์บน Clouflare คุณจะได้รับแจ้งให้เชื่อมต่อบัญชี `Cloudflare` ของคุณกับบัญชี `NitroPack`
4. คุณควรจะสามารถดู `Dashboard` พร้อมข้อมูลแคชสำหรับการติดตั้ง WordPress ของคุณ

**หมายเหตุ:**
มีปัญหาที่ทราบกันดีว่าคุณจะเห็นข้อความนี้หลังจากติดตั้ง `Nitropack`: `Could not turn on the WP_CACHE constant in wp-config.php.` นี่เป็นเพราะสิทธิ์ที่จำกัดในไฟล์ `wp-config.php` ในการแก้ไขปัญหานี้ คุณจะต้อง ssh เข้าไปในคอนเทนเนอร์ wordpress ด้วย kubectl โดยใช้สิ่งนี้:

```shell
kubectl exec --stdin --tty <your_wordpress_pod> -n wordpress -- /bin/bash
```

ไปที่ `/bitnami/wordpress` ภายในคอนเทนเนอร์และเรียกใช้ `chmod 0644 wp-config.php` เพื่อเปลี่ยนสิทธิ์ การรีสตาร์ทหน้าแรกของปลั๊กอินควรส่งผลให้ข้อผิดพลาดนั้นได้รับการแก้ไข

คุณยังสามารถตรวจสอบบทความนี้ [วิธีตรวจสอบว่า NitroPack กำลังให้บริการหน้าเว็บที่ปรับให้เหมาะสมแก่ผู้เยี่ยมชมหรือไม่](https://support.nitropack.io/hc/en-us/articles/1500002328941-How-to-Check-if-NitroPack-is-Serving-Optimized-Pages-to-Visitors)

### การกำหนดค่า Cloudflare

[Cloudflare](https://www.cloudflare.com/en-gb/) เป็นบริษัทที่ให้บริการเครือข่ายการจัดส่งเนื้อหา (CDN) DNS การป้องกัน DDoS และบริการรักษาความปลอดภัย Cloudflare เป็นโซลูชันที่ดีในการเพิ่มความเร็วและเพิ่มความปลอดภัยให้กับเว็บไซต์ WordPress ของคุณ

**หมายเหตุ:**
จำเป็นต้องมีบัญชี Cloudflare สำหรับการกำหนดค่านี้ หากคุณไม่มี โปรดไปที่ [เว็บไซต์ Cloudflare](https://www.cloudflare.com/en-gb/) และสมัครบัญชีฟรี
หากการติดตั้ง Wordpress ถูกกำหนดค่าด้วยโดเมนที่ซื้อจากผู้รับจดทะเบียนรายอื่น (เช่น GoDaddy) คุณจะต้องเปลี่ยนเซิร์ฟเวอร์ชื่อที่กำหนดเองให้ชี้ไปที่เซิร์ฟเวอร์ชื่อ Cloudflare

โปรดทำตามขั้นตอนด้านล่างเพื่อกำหนดค่า Cloudlare ให้ทำงานกับเว็บไซต์ WordPress ของคุณ:

1. เข้าสู่ระบบแดชบอร์ด Cloudflare ด้วยบัญชีของคุณและคลิกที่ `+ Add Site`
2. ป้อนโดเมนของเว็บไซต์ WordPress ของคุณและคลิกที่ปุ่ม `Add Site`
3. จากหน้าการเลือกแผน ให้คลิกที่ปุ่ม `Get Started` ภายใต้แผน `Free`
4. จากหน้าการตรวจสอบระเบียน DNS ให้คลิกที่ปุ่ม `Add record` และเพิ่มระเบียน `A`
5. เลือกชื่อสำหรับระเบียน ตรวจสอบให้แน่ใจว่าที่อยู่ `IPv4` ที่ป้อนเป็นที่อยู่ของ DigitalOcean load balancer และคลิกที่ปุ่ม `Continue`
6. ในหน้าถัดไป คุณจะถูกขอให้ลบเซิร์ฟเวอร์ชื่อที่กำหนดเองในผู้รับจดทะเบียนโดเมนของคุณและเพิ่มเซิร์ฟเวอร์ชื่อของ Cloudflare เข้าสู่ระบบผู้รับจดทะเบียนโดเมนของคุณด้วยบัญชี `administrator` และเปลี่ยนเซิร์ฟเวอร์ชื่อที่กำหนดเอง
7. คลิกที่ปุ่ม `Done, check nameservers`
8. ในหน้าถัดไป Cloudlare เสนอคำแนะนำการกำหนดค่าบางอย่าง ซึ่งสามารถข้ามได้และแก้ไขในภายหลัง คลิกที่ลิงก์ `Skip recommendations`

จะมีการส่งอีเมลเมื่อไซต์ใช้งานอยู่บน Cloudflare
จากบัญชี Cloudflare ของคุณ คุณสามารถตรวจสอบหน้า `Analytics` เพื่อดูข้อมูลเพิ่มเติมเกี่ยวกับการเข้าชมเว็บบนเว็บไซต์ WordPress ของคุณ

**หมายเหตุ:**
การประมวลผลการอัปเดตเซิร์ฟเวอร์ชื่ออาจใช้เวลาถึง 24 ชั่วโมงจึงจะเสร็จสมบูรณ์

### การกำหนดค่า Redis Object Cache

WordPress ทำการค้นหา MySQL หลายครั้งและ Redis Object Cache จะเพิ่มประสิทธิภาพการใช้งานฐานข้อมูล Wordpress Redis object สามารถใช้เพื่อจัดเก็บแคชของผลลัพธ์คำขอสำหรับการสืบค้นเฉพาะที่ส่งไปยังเซิร์ฟเวอร์ MySQL

ต่อไป คุณจะกำหนดค่าปลั๊กอิน [Redis Object Cache](https://wordpress.org/plugins/nitropack/) สำหรับอินสแตนซ์ WordPress ของคุณ

โปรดทำตามขั้นตอนด้านล่างเพื่อกำหนดค่า Redis Object Cache ให้ทำงานกับเว็บไซต์ WordPress ของคุณ:

1. เปิดคอนโซลผู้ดูแลระบบของการติดตั้ง WordPress ของคุณผ่านลิงก์ต่อไปนี้ในเว็บเบราว์เซอร์ของคุณ (อย่าลืมแทนที่ตัวคั่น <> ตามความเหมาะสม):

      ```shell
      https://<YOUR_WORDPRESS_DOMAIN_HERE>/wp-admin
      ```

    เมื่อถูกถาม โปรดเข้าสู่ระบบด้วยข้อมูลประจำตัวของผู้ดูแลระบบ WordPress ของคุณ
2. คลิกที่เมนู `Plugins` จากนั้นเปิดเมนูย่อย `Add New`
3. ค้นหาปลั๊กอิน `Redis Object Cache` และจากหน้าผลลัพธ์ให้คลิกที่ปุ่ม `Install Now` หลังจากการติดตั้งเสร็จสิ้น ให้คลิกที่ปุ่ม `Activate` คุณควรเห็นหน้า概述ของปลั๊กอิน
4. คลิกที่ปุ่ม `Enable Object Cache` ปลั๊กอินควรจะสามารถเชื่อมต่อกับ Redis Cluster และแสดงสถานะ `Connected`

## การอัพเกรด WordPress

เนื่องจากเป็นที่นิยมมาก WordPress จึงมักตกเป็นเป้าหมายของการแสวงหาผลประโยชน์ที่เป็นอันตราย ดังนั้นจึงเป็นเรื่องสำคัญที่จะต้องอัปเดตให้ทันสมัยอยู่เสมอ คุณสามารถอัปเกรด WordPress ผ่านคำสั่ง `helm upgrade`

ก่อนอื่น อัปเดตที่เก็บ helm:

```console
helm repo update
```

ต่อไป อัปเกรด WordPress เป็นเวอร์ชันใหม่:

```console
helm upgrade wordpress bitnami/wordpress \
    --atomic \
    --create-namespace \
    --install \
    --namespace wordpress \
    --version <WORDPRESS_NEW_VERSION> \
    --timeout 10m0s \
    --values assets/manifests/wordpress-values.yaml
```

**หมายเหตุ:**

แทนที่ `WORDPRESS_NEW_VERSION` ด้วยเวอร์ชันใหม่

## บทสรุป

ในคู่มือนี้ คุณได้เรียนรู้วิธีติดตั้ง WordPress ในแบบ Kubernetes โดยใช้ Helm และฐานข้อมูล MySQL ภายนอก คุณยังได้เรียนรู้วิธีอัปเกรด WordPress เป็นเวอร์ชันใหม่ และวิธีย้อนกลับไปยังเวอร์ชันก่อนหน้าในกรณีที่เกิดข้อผิดพลาด

หากคุณต้องการเรียนรู้เพิ่มเติมเกี่ยวกับ Kubernetes และ Helm โปรดตรวจสอบส่วน [DO Kubernetes](https://www.digitalocean.com/community/tags/kubernetes) ของหน้า community ของเรา
