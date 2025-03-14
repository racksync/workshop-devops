# การซ่อมแซมโหนดอัตโนมัติบน DigitalOcean Kubernetes

## บทนำ

เมื่อโหนดในคลัสเตอร์ DigitalOcean Kubernetes ไม่สมบูรณ์หรือไม่พร้อมใช้งาน การเปลี่ยนโหนดนั้นจะต้องทำด้วยตนเองและยุ่งยาก คลัสเตอร์จะทำงานได้ที่ความจุต่ำลงหากไม่มีการเปลี่ยนโหนด เพราะโหนดที่ไม่สมบูรณ์จะไม่สามารถรันพอดใด ๆ ได้

โหนดในคลัสเตอร์อาจกลายเป็นไม่สมบูรณ์เมื่อ `kubelet service` ตายหรือไม่ตอบสนอง ซึ่งอาจเกิดขึ้นได้จากหลายสาเหตุ

- โหนดเวิร์กเกอร์ *ทำงานเกินกำลัง*
- *ปัญหาเครือข่าย*: อาจเกิดขึ้นหากโหนดสูญเสียการเชื่อมต่อกับ Kubernetes API server หรือมีปัญหากับเครือข่ายโอเวอร์เลย์ที่คลัสเตอร์ใช้
- *ข้อจำกัดทรัพยากร*: หากโหนดไม่มีทรัพยากรเพียงพอ (เช่น CPU, หน่วยความจำ หรือดิสก์) ในการดำเนินการพอดที่กำหนดไว้ มันอาจกลายเป็นสถานะ "NotReady" ซึ่งอาจเกิดขึ้นหากการร้องขอทรัพยากรของพอดมีขนาดใหญ่กว่าทรัพยากรที่โหนดมีอยู่
- *การล้มเหลวของฮาร์ดแวร์*: หากเกิดความล้มเหลวของฮาร์ดแวร์บนโหนด (เช่น ดิสก์หรืออินเทอร์เฟซเครือข่ายล้มเหลว) โหนดอาจกลายเป็นสถานะ "NotReady"

บทช่วยสอนนี้นำเสนอวิธีการอัตโนมัติในการรีไซเคิลโหนดที่ไม่สมบูรณ์ในคลัสเตอร์ DigitalOcean Kubernetes (DOKS) โดยใช้ [Digital Mobius](https://github.com/Qovery/digital-mobius)

<img src="./content/img/digital-mobius-install.png?raw=true" alt="mobius-install" style="display:block; margin:auto; width:50%">

### สิ่งที่ต้องมีก่อน

- [โทเค็นการเข้าถึง DigitalOcean](https://docs.digitalocean.com/reference/api/create-personal-access-token) สำหรับจัดการคลัสเตอร์ DOKS ตรวจสอบให้แน่ใจว่าโทเค็นการเข้าถึงมีขอบเขต *อ่าน-เขียน*

    ```bash
    export DIGITAL_OCEAN_TOKEN="<your_do_personal_access_token>"
    # คัดลอกค่าโทเค็นและบันทึกในตัวแปรสภาพแวดล้อมเฉพาะที่เพื่อใช้ในภายหลัง
    ```

- [doctl CLI](https://docs.digitalocean.com/reference/doctl/how-to/install)

     ```bash
     # เริ่มต้น doctl
     doctl auth init --access-token "$DIGITAL_OCEAN_TOKEN"
     ```

- [Helm CLI](https://helm.sh/docs/intro/install/)

## การตั้งค่า Digital Mobius

Digital Mobius เป็นแอปพลิเคชันโอเพนซอร์สที่เขียนด้วย Go โดยเฉพาะสำหรับการรีไซเคิลโหนดคลัสเตอร์ DOKS แอปพลิเคชันนี้จะติดตามโหนดคลัสเตอร์ DOKS ที่อยู่ในสถานะไม่สมบูรณ์ตามช่วงเวลาที่กำหนดไว้

Digital Mobius ต้องการชุดของตัวแปรสภาพแวดล้อมที่ต้องกำหนดค่าและพร้อมใช้งาน คุณสามารถดูตัวแปรเหล่านี้ได้ใน [values.yaml](https://github.com/Qovery/digital-mobius/blob/main/charts/Digital-Mobius/values.yaml):

```yaml
LOG_LEVEL: "info"
DELAY_NODE_CREATION: "10m"                                  # ช่วงเวลารีไซเคิลโหนด
DIGITAL_OCEAN_TOKEN: "<your_digitalocean_api_token>"       # ค่าโทเค็น DO API ส่วนตัว
DIGITAL_OCEAN_CLUSTER_ID: "<your_digitalocean_cluster_id>" # ID ของคลัสเตอร์ DOKS ที่ต้องการตรวจสอบ
```

**หมายเหตุ:**

เลือกค่าที่เหมาะสมสำหรับ `DELAY_NODE_CREATION` ค่าที่ต่ำเกินไปจะรบกวนช่วงเวลาที่จำเป็นสำหรับโหนดที่จะพร้อมใช้งานหลังจากที่ถูกรีไซเคิล ในสถานการณ์จริง อาจใช้เวลาหลายนาทีหรือมากกว่านั้นเพื่อให้เสร็จสมบูรณ์ จุดเริ่มต้นที่ดีคือ `10m` ซึ่งเป็นค่าที่ใช้ในบทช่วยสอนนี้

### การกำหนดค่าและการติดตั้ง

Digital Mobius สามารถติดตั้งได้ง่ายโดยใช้ [Helm chart](https://github.com/Qovery/digital-mobius/tree/main/charts/Digital-Mobius) (หรือ [artifacthub.io](https://artifacthub.io/packages/helm/digital-mobius/digital-mobius))

1. เพิ่ม Helm repository ที่จำเป็น:

    ```bash
    helm repo add digital-mobius https://qovery.github.io/digital-mobius
    ```

2. ดึงข้อมูล cluster-ID ที่คุณต้องการตรวจสอบการล้มเหลวของโหนด:

    ```bash
    doctl k8s cluster list
    export DIGITAL_OCEAN_CLUSTER_ID="<your_cluster_id_here>"
    ```

3. ตั้งค่าโทเค็นการเข้าถึง DigitalOcean:

    ```bash
    export DIGITAL_OCEAN_TOKEN="<your_do_personal_access_token>"
    echo "$DIGITAL_OCEAN_TOKEN"
    ```

4. เริ่มการติดตั้งในเนมสเปซเฉพาะ ตัวอย่างนี้ใช้ `maintenance` เป็นเนมสเปซ:

    ```bash
    helm install digital-mobius digital-mobius/digital-mobius --version 0.1.4 \
      --set environmentVariables.DIGITAL_OCEAN_TOKEN="$DIGITAL_OCEAN_TOKEN" \
      --set environmentVariables.DIGITAL_OCEAN_CLUSTER_ID="$DIGITAL_OCEAN_CLUSTER_ID" \
      --set enabledFeatures.disableDryRun=true \
      --namespace maintenance --create-namespace
    ```

    **หมายเหตุ:**

    ตัวเลือก `enabledFeatures.disableDryRun` เปิดหรือปิดโหมด `DRY RUN` ของเครื่องมือ การตั้งค่าเป็น `true` หมายความว่าโหมดทดลองรันถูกปิดใช้งาน และโหนดคลัสเตอร์จะถูกรีไซเคิล การเปิดใช้งานโหมดทดลองรันมีประโยชน์หากคุณต้องการทดสอบก่อนโดยไม่ทำการเปลี่ยนแปลงใด ๆ กับโหนดคลัสเตอร์จริง

5. ตรวจสอบการติดตั้งเมื่อเสร็จสมบูรณ์

    ```bash
    # แสดงรายการการติดตั้ง
    helm ls -n maintenance
    ```

    ผลลัพธ์จะมีลักษณะคล้ายกับต่อไปนี้:

    ```bash
    NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
    digital-mobius  maintenance     1               2023-03-04 11:24:10.131055 +0300 EEST   deployed        digital-mobius-0.1.4    0.1.4 
    ```

    ตรวจสอบพอดที่กำลังทำงาน:

    ```bash
    kubectl get pods -n maintenance
    ```

    ผลลัพธ์จะมีลักษณะคล้ายกับต่อไปนี้:

    ```bash
    NAME                             READY   STATUS    RESTARTS   AGE
    digital-mobius-55fbc9fdd-dzxbh   1/1     Running   0          8s
    ```

    ตรวจสอบบันทึก (logs):

    ```bash
    kubectl logs -l app.kubernetes.io/name=digital-mobius -n maintenance
    ```

    ผลลัพธ์จะมีลักษณะคล้ายกับต่อไปนี้:

    ```bash
        _ _       _ _        _                      _     _           
     __| (_) __ _(_) |_ __ _| |     _ __ ___   ___ | |__ (_)_   _ ___ 
    / _` | |/ _` | | __/ _` | |    | '_ ` _ \ / _ \| '_ \| | | | / __|
    | (_|| | (_| | | || (_| | |    | | | | | | (_) | |_) | | |_| \__ \
    \__,_|_|\__, |_|\__\__,_|_|    |_| |_| |_|\___/|_.__/|_|\__,_|___/
            |___/                                                     
    time="2023-03-04T08:29:52Z" level=info msg="Starting Digital Mobius 0.1.4
    ```

ตอนนี้เราได้ติดตั้ง `Digital Mobius` สำเร็จแล้ว เรามาดูตรรกะพื้นฐานในการทำงานของมันกัน

## ตรรกะการซ่อมแซมโหนดอัตโนมัติ

โหนดถือว่าไม่สมบูรณ์หากสถานะ [node condition](https://kubernetes.io/docs/concepts/architecture/nodes/#condition) เป็น `Ready` และสถานะเป็น `False` หรือ `Unknown` จากนั้นแอปพลิเคชันจะสร้างโหนดที่ได้รับผลกระทบใหม่โดยใช้ DigitalOcean [Delete Kubernetes Node API](https://docs.digitalocean.com/reference/api/api-reference/#operation/kubernetes_delete_node)

แผนภาพต่อไปนี้แสดงวิธีที่ Digital Mobius ตรวจสอบสถานะของโหนดเวิร์กเกอร์:

<img src="./content/img/digital-mobius-flow.png?raw=true" alt="mobius-flow" style="display:block; margin:auto; width:50%">

## จำลองปัญหาโหนดเวิร์กเกอร์

เราต้องตัดการเชื่อมต่อโหนดหนึ่งหรือหลายโหนดจากคลัสเตอร์ DOKS เพื่อทดสอบการตั้งค่า Digital Mobius เพื่อทำเช่นนี้ เราจะใช้เครื่องมือ [doks-debug](https://github.com/digitalocean/doks-debug) เพื่อสร้างพอดดีบักบางตัวที่รันคอนเทนเนอร์ด้วยสิทธิ์ที่สูงขึ้น เพื่อเข้าถึงคอนเทนเนอร์ที่กำลังทำงานในพอดดีบัก เราจะใช้ `kubectl exec` คำสั่งนี้จะอนุญาตให้เราดำเนินการคำสั่งภายในคอนเทนเนอร์และเข้าถึงบริการระบบของโหนดเวิร์กเกอร์

- สร้างพอดดีบัก DOKS:

    ```bash
    # สิ่งนี้จะเริ่มพอดดีบักในเนมสเปซ `kube-system`:
    kubectl apply -f https://raw.githubusercontent.com/digitalocean/doks-debug/master/k8s/daemonset.yaml
    ```

    ตรวจสอบ DaemonSet:

    ```bash
    kubectl get ds -n kube-system
    ```

    ผลลัพธ์จะมีลักษณะคล้ายกับต่อไปนี้ (สังเกตรายการ `doks-debug`):

    ```bash
    NAME                 DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
    cilium               3         3         3       3            3           kubernetes.io/os=linux   4d1h
    cpc-bridge-proxy     3         3         3       3            3           <none>                   4d1h
    csi-do-node          3         3         3       3            3           <none>                   4d1h
    do-node-agent        3         3         3       3            3           kubernetes.io/os=linux   4d1h
    doks-debug           3         3         3       3            3           <none>                   3d22h
    konnectivity-agent   3         3         3       3            3           <none>                   4d1h
    kube-proxy           3         3         3       3            3           <none>                   4d1h
    ```

    ตรวจสอบพอดดีบัก:

    ```bash
    kubectl get pods -l name=doks-debug -n kube-system
    ```

    ผลลัพธ์จะมีลักษณะคล้ายกับต่อไปนี้:

    ```bash
    NAME               READY   STATUS    RESTARTS   AGE
    doks-debug-dckbv   1/1     Running   0          3d22h
    doks-debug-rwzgm   1/1     Running   0          3d22h
    doks-debug-s9cbp   1/1     Running   0          3d22h
    ```

- หยุดบริการ `kubelet`

    ใช้ `kubectl exec` ในหนึ่งในพอดดีบักและเข้าถึงบริการระบบของโหนดเวิร์กเกอร์ จากนั้น หยุดบริการ kubelet ซึ่งส่งผลให้โหนดหายไปจากผลลัพธ์คำสั่ง `kubectl get nodes`

    เปิดหน้าต่างเทอร์มินัลใหม่และดูโหนดเวิร์กเกอร์:

     ```bash
    watch "kubectl get nodes"
    ```

    เลือกพอดดีบักตัวแรกและเข้าถึงเชลล์:

    ```bash
    kubectl exec -it <debug-pod-name> -n kube-system -- bash
    ```

    พรอมท์ที่มีลักษณะคล้ายกับต่อไปนี้จะปรากฏ:

     ```bash
    root@doks-debug-dckbv:~#
    ```

    ตรวจสอบบริการระบบ:

    ```bash
    chroot /host /bin/bash
    systemctl status kubelet
    ```

    ผลลัพธ์จะมีลักษณะคล้ายกับต่อไปนี้:

    ```shell
    ● kubelet.service - Kubernetes Kubelet Server
    Loaded: loaded (/etc/systemd/system/kubelet.service; enabled; vendor preset: enabled)
    Active: active (running) since Fri 2023-03-04 08:48:42 UTC; 2h 18min ago
    Docs: https://kubernetes.io/docs/concepts/overview/components/#kubelet
    Main PID: 1053 (kubelet)
        Tasks: 17 (limit: 4701)
    Memory: 69.3M
    CGroup: /system.slice/kubelet.service
            └─1053 /usr/bin/kubelet --config=/etc/kubernetes/kubelet.conf --logtostderr=true --image-pull-progress-deadline=5m
    ...
    ```

    หยุด kubelet:

     ```bash
    systemctl stop kubelet
    ```

<img src="./content/img/simulate-node-failure.png?raw=true" alt="simulate-node-failure" style="display:block; margin:auto; width:50%">

### สังเกตโหนดเวิร์กเกอร์

หลังจากที่คุณหยุดบริการ kubelet คุณจะถูกเตะออกจากเซสชันเชลล์ นี่หมายความว่าตัวควบคุมโหนดสูญเสียการเชื่อมต่อกับโหนดที่ได้รับผลกระทบซึ่งบริการ kubelet ถูกฆ่า

คุณสามารถเห็นสถานะ `NotReady` ของโหนดที่ได้รับผลกระทบในหน้าต่างเทอร์มินัลอื่นที่คุณตั้งค่า watch:

```bash
NAME         STATUS    ROLES   AGE     VERSION
game-q44rc   Ready    <none>   3d22h   v1.26.3
game-q4507   Ready    <none>   4d1h    v1.26.3
game-q450c   NotReady <none>   4d1h    v1.26.3
```

หลังจากช่วงเวลาที่คุณระบุใน `DELAY_NODE_CREATION` หมดอายุ โหนดจะหายไปตามที่คาดไว้:

```bash
NAME            STATUS   ROLES    AGE   VERSION
game-q44rc   Ready    <none>   3d22h   v1.26.3
game-q4507   Ready    <none>   4d1h    v1.26.3
```

ต่อไป ตรวจสอบว่า Digital Mobius ติดตามคลัสเตอร์ DOKS อย่างไร เปิดหน้าต่างเทอร์มินัลและตรวจสอบบันทึกก่อน:

```bash
kubectl logs -l app.kubernetes.io/name=digital-mobius -n maintenance
```

ผลลัพธ์มีลักษณะเช่นด้านล่างนี้ (ดูบรรทัด `Recycling node {...}`):

```bash
     _ _       _ _        _                      _     _           
  __| (_) __ _(_) |_ __ _| |     _ __ ___   ___ | |__ (_)_   _ ___ 
 / _` | |/ _` | | __/ _` | |    | '_ ` _ \ / _ \| '_ \| | | | / __|
| (_| | | (_| | | || (_| | |    | | | | | | (_) | |_) | | |_| \__ \
 \__,_|_|\__, |_|\__\__,_|_|    |_| |_| |_|\___/|_.__/|_|\__,_|___/
         |___/                                                     
time="2023-03-04T08:29:52Z" level=info msg="Starting Digital Mobius 0.1.4 \n"
time="2023-03-04T11:13:09Z" level=info msg="Recyling node {11bdd0f1-8bd0-42dc-a3af-7a83bc319295 f8d76723-2b0e-474d-9465-d9da7817a639 379826e4-8d1b-4ba4-97dd-739bbfa69023}"
...
```

ในหน้าต่างเทอร์มินัลที่คุณตั้งค่า watch สำหรับ `kubectl get nodes` โหนดใหม่จะปรากฏหลังจากผ่านไปหนึ่งนาที แทนที่โหนดเก่า โหนดใหม่มี ID และค่า `AGE` ใหม่:

```bash
NAME         STATUS   ROLES    AGE     VERSION
game-q44rc   Ready    <none>   3d22h   v1.26.3
game-q4507   Ready    <none>   4d1h    v1.26.3
game-q450d   Ready    <none>   22s     v1.26.3
```

ตามที่คุณเห็น โหนดได้รับการรีไซเคิลโดยอัตโนมัติ

## สรุป

โดยสรุป แม้ว่าการกู้คืนโหนดคลัสเตอร์โดยอัตโนมัติจะเป็นคุณสมบัติที่มีคุณค่า แต่สิ่งสำคัญคือต้องให้ความสำคัญกับการตรวจสอบสุขภาพของโหนดและการจัดการการโหลดเพื่อป้องกันความล้มเหลวของโหนดที่เกิดขึ้นบ่อย นอกจากนี้ การตั้งค่าขีดจำกัดทรัพยากรของพอดอย่างเหมาะสม เช่น การตั้งค่าและใช้ค่าที่เหมาะสม ก็สามารถช่วยป้องกันการโอเวอร์โหลดโหนดได้เช่นกัน โดยการใช้แนวทางปฏิบัติที่ดีที่สุดเหล่านี้ คุณสามารถรับประกันความเสถียรและความน่าเชื่อถือของคลัสเตอร์ Kubernetes ของคุณ หลีกเลี่ยงการหยุดทำงานที่มีค่าใช้จ่ายสูงและการหยุดชะงักของบริการ

### อ้างอิง

- [GitHub](https://github.com/digitalocean/container-blueprints/tree/main/DOKS-automatic-node-repair)
- [Digital Mobius](https://github.com/Qovery/digital-mobius)
