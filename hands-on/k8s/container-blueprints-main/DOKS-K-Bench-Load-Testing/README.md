## ภาพรวม

การทดสอบโหลด (Load Testing) เป็นกระบวนการทดสอบซอฟต์แวร์แบบนอนฟังก์ชันที่ทดสอบประสิทธิภาพของระบบภายใต้โหลดที่คาดการณ์ไว้ ซึ่งจะกำหนดว่าระบบทำงานอย่างไรในขณะที่ถูกใช้งานภายใต้โหลด เป้าหมายของการทดสอบโหลดคือการปรับปรุงคอขวดประสิทธิภาพและเพื่อให้แน่ใจว่ามีความเสถียรและการทำงานที่ราบรื่นของระบบ การทดสอบโหลดช่วยสร้างความมั่นใจในระบบ ความน่าเชื่อถือและประสิทธิภาพ

[K-bench](https://github.com/vmware-tanzu/k-bench) เป็นเฟรมเวิร์กสำหรับการเทียบสมรรถนะด้านคอนโทรลเพลนและดาต้าเพลนของโครงสร้างพื้นฐาน Kubernetes K-Bench ให้วิธีที่สามารถกำหนดค่าได้เพื่อสร้างและจัดการทรัพยากร Kubernetes ในขนาดใหญ่อย่างเป็นระบบ และในที่สุดก็ให้เมทริกประสิทธิภาพคอนโทรลเพลนและดาต้าเพลนที่เกี่ยวข้องสำหรับโครงสร้างพื้นฐานเป้าหมาย
K-bench อนุญาตให้ผู้ใช้ควบคุมการทำงานพร้อมกันฝั่งไคลเอนต์ การดำเนินการ และวิธีการดำเนินการประเภทต่างๆ เหล่านี้ตามลำดับหรือแบบขนาน โดยเฉพาะอย่างยิ่ง ผู้ใช้สามารถกำหนดเวิร์กโฟลว์ของการดำเนินการสำหรับทรัพยากรที่รองรับผ่านไฟล์คอนฟิก
หลังจากการทำงานสำเร็จ เบนช์มาร์กจะรายงานเมทริก (เช่น จำนวนคำขอ, เวลาแฝงในการเรียก API, ปริมาณงาน ฯลฯ) สำหรับการดำเนินการที่ทำกับประเภททรัพยากรต่างๆ

ในบทช่วยสอนนี้ คุณจะกำหนดค่า K-bench เครื่องมือนี้ต้องติดตั้งบน droplet โดยควรมีสิทธิ์เข้าถึงคลัสเตอร์เป้าหมายสำหรับการทดสอบ
คุณจะกำหนดค่า (หากยังไม่มี) prometheus stack สำหรับคลัสเตอร์ของคุณเพื่อสังเกตผลลัพธ์ของการทดสอบ

## แผนภาพสถาปัตยกรรม K-bench

![แผนภาพสถาปัตยกรรม K-bench](assets/images/kbench-overview.png)

## สารบัญ

- [ภาพรวม](#overview)
- [แผนภาพสถาปัตยกรรม K-bench](#k-bench-architecture-diagram)
- [สิ่งที่ต้องมีก่อน](#prerequisites)
- [การสร้าง DO droplet สำหรับ K-bench](#creating-a-DO-droplet-for-K-bench)
- [ตัวอย่างผลลัพธ์เบนช์มาร์ก K-bench](#k-bench-benchmark-results-sample)
- [การแสดงผลเมทริกด้วย Grafana](#grafana-metric-visualization)
- [ตัวอย่างแดชบอร์ด API Server บน Grafana](#grafana-api-server-dashboard-sample)
- [ตัวอย่างแดชบอร์ดโหนดบน Grafana](#grafana-node-dashboard-sample)
- [ตัวอย่างการนับจำนวน Pod บน Grafana](#grafana-pod-count-sample)

## สิ่งที่ต้องมีก่อน

ในการทำบทช่วยสอนนี้ให้เสร็จสมบูรณ์ คุณจะต้องมี:

1. คลัสเตอร์ DOKS, อ้างอิงที่: [Kubernetes-Starter-Kit-Developers](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/01-setup-DOKS) หากต้องสร้างใหม่
2. ติดตั้ง Prometheus stack บนคลัสเตอร์, อ้างอิงที่: [Kubernetes-Starter-Kit-Developers](https://github.com/digitalocean/Kubernetes-Starter-Kit-Developers/tree/main/04-setup-prometheus-stack) หากยังไม่ได้ติดตั้ง
3. Droplet ที่จะทำหน้าที่เป็น K-bench `master`

## การสร้าง DO droplet สำหรับ K-bench

ในส่วนนี้คุณจะสร้าง droplet ที่จะทำหน้าที่เป็น K-bench master ของคุณ บน droplet นี้คุณจะโคลน K-bench repo ทำการติดตั้ง รันการทดสอบ และ/หรือเพิ่มการทดสอบใหม่ที่เหมาะกับกรณีการใช้งานของคุณ เหตุผลในการใช้ droplet คือการมีทรัพยากรที่แยกออกจากคลัสเตอร์ซึ่งเราสามารถใช้เพื่อจุดประสงค์เฉพาะอย่างเดียวคือการทำการทดสอบโหลดและแสดงผลลัพธ์ของเบนช์มาร์ก

โปรดทำตามขั้นตอนด้านล่างเพื่อสร้าง droplet ติดตั้งและกำหนดค่า K-bench:

1. นำทางไปยัง [DO cloud account](https://cloud.digitalocean.com/) ของคุณ
2. จากแดชบอร์ด คลิกที่ปุ่ม `Create` และเลือกตัวเลือก `Droplets`
3. เลือกดิสทริบิวชัน Ubuntu, แผนพื้นฐาน, ตัวเลือก CPU แบบ Regular with SSD, ภูมิภาค และใน `Authentication` เลือกตัวเลือก SSH keys หากไม่มี SSH key [บทความนี้](https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/) อธิบายวิธีการสร้างและเพิ่มเข้าบัญชี DO
4. จากแดชบอร์ด droplet คลิกที่ปุ่ม `Console` หลังจากนี้คุณจะเห็นหน้าจอแจ้งให้ `Update Droplet Console` ทำตามขั้นตอนเพื่อเข้าถึง SSH ไปยัง droplet
5. เมื่อการเข้าถึง SSH พร้อมใช้งาน คลิกที่ปุ่ม `Console` อีกครั้ง คุณจะล็อกอินเป็น root เข้าสู่ droplet
6. โคลนรีโพสิทอรี [K-bench](https://github.com/vmware-tanzu/k-bench) ผ่าน HTTPS โดยใช้คำสั่งนี้:

    ```console
    git clone https://github.com/vmware-tanzu/k-bench.git
    ```

7. นำทางไปยังไดเร็กทอรีรีโพสิทอรีที่โคลน

    ```console
    cd k-bench/
    ```

8. รันสคริปต์ติดตั้งเพื่อติดตั้ง `GO` และไลบรารีที่ต้องการอื่นๆ ของ `K-Bench`

    ```console
    ./install.sh
    ```

9. จากแดชบอร์ดคลัสเตอร์ DOKS คลิกที่ `Download Config File` และคัดลอกเนื้อหาของไฟล์คอนฟิก `K-bench` ต้องการข้อมูลนี้เพื่อเชื่อมต่อกับคลัสเตอร์
10. สร้างโฟลเดอร์ kube ที่จะเพิ่มคอนฟิกคูเบอเนตีส วางเนื้อหาที่คัดลอกจากขั้นตอนที่ 9 และบันทึกไฟล์

    ```console
    mkdir ~/.kube
    vim ~/.kube/config
    ```

11. เป็นขั้นตอนตรวจสอบ รันคำสั่งเริ่มทดสอบซึ่งจะสร้างเบนช์มาร์กสำหรับการทดสอบ `default`

    ```console
    ./run.sh
    ```

12. หากการทดสอบสำเร็จ เครื่องมือจะแสดงว่าเริ่มต้นแล้วและกำลังเขียนล็อกไปยังโฟลเดอร์ที่มีคำนำหน้า `results_run_<date>`
13. เปิดล็อกเบนช์มาร์กและดูผลลัพธ์

    ```console
    cat results_run_29-Jun-2022-08-06-42-am/default/kbench.log
    ```

**หมายเหตุ:**

การทดสอบถูกเพิ่มภายในโฟลเดอร์ `config` ของ `k-bench` เพื่อเปลี่ยนการทดสอบที่มีอยู่ ไฟล์ `config.json` จำเป็นต้องได้รับการอัปเดต
การทดสอบถูกรันผ่านแฟล็ก `-t` ที่ให้โดย k-bench ตัวอย่างเช่นการรัน `cp_heavy_12client` ทำผ่าน: `./run.sh -t cp_heavy_12client`

## ตัวอย่างผลลัพธ์เบนช์มาร์ก K-bench

![ตัวอย่างผลลัพธ์เบนช์มาร์ก K-bench](assets/images/benchmark-results-sample.png)

## การแสดงผลเมทริกด้วย Grafana

การทดสอบ `K-bench` สามารถสังเกตได้อย่างง่ายดายโดยใช้ Grafana คุณสามารถสร้างแดชบอร์ดต่างๆ เพื่อให้มองเห็นและเข้าใจเมทริกของ Prometheus ในส่วนนี้คุณจะสำรวจเมทริกที่เป็นประโยชน์สำหรับ Kubernetes รวมถึงแดชบอร์ดซึ่งสามารถให้ข้อมูลเชิงลึกว่าเกิดอะไรขึ้นกับคลัสเตอร์ DOKS ภายใต้โหลด

**หมายเหตุ:**

ส่วนนี้สามารถทำได้หากมีการสร้าง prometheus stack ไว้แล้วในขั้นตอนที่ 2 ของส่วน [สิ่งที่ต้องมีก่อน](#prerequisites) หรือได้ติดตั้งไว้แล้วในคลัสเตอร์

โปรดทำตามขั้นตอนด้านล่าง:

1. เชื่อมต่อกับ Grafana (โดยใช้ข้อมูลเข้าสู่ระบบเริ่มต้น: `admin/prom-operator`) โดยการ port forwarding ไปยังเครื่องในเครื่อข่ายภายใน

    ```console
    kubectl --namespace monitoring port-forward svc/kube-prom-stack-grafana 3000:80
    ```

2. นำทางไปที่ `http://localhost:3000/` และล็อกอินเข้าสู่ Grafana
3. นำเข้า `Kubernetes System Api Server` โดยนำทางไปที่ `http://localhost:3000/dashboard/import` เพิ่ม ID `15761` ในช่องภายใต้ `Import via grafana.com` และเพิ่ม Load
4. จากแดชบอร์ดที่กล่าวถึงข้างต้น คุณจะสามารถเห็น API latency, HTTP requests by code, HTTPS requests by verb เป็นต้น คุณสามารถใช้แดชบอร์ดนี้เพื่อติดตาม API ภายใต้โหลด
5. จากหน้าหลัก Grafana คลิกที่เมนู `Dashboards` และคลิกที่ Node Exporter Nodes เพื่อเปิดแดชบอร์ดที่เน้นทรัพยากร `Node` คุณสามารถใช้แดชบอร์ดนี้เพื่อติดตามทรัพยากรที่มีอยู่ในโหนดของคุณระหว่างการทดสอบ
6. คุณยังสามารถใช้เมทริกต่างๆ เพื่อนับจำนวนพอดที่ถูกสร้างขึ้นระหว่างการทดสอบ เช่น จากหน้า `Explore` ใส่ข้อความต่อไปนี้ในเบราว์เซอร์เมทริก: `count(kube_pod_info{namespace="kbench-pod-namespace"})` ซึ่งจะแสดงกราฟที่มีจำนวนพอดในเวลาต่างๆ

## ตัวอย่างแดชบอร์ด API Server บน Grafana

![ตัวอย่างแดชบอร์ด API Server บน Grafana](assets/images/grafana-api-server-sample.png)

## ตัวอย่างแดชบอร์ดโหนดบน Grafana

![ตัวอย่างแดชบอร์ด API Server บน Grafana](assets/images/node-dashboard-sample.png)

## ตัวอย่างการนับจำนวน Pod บน Grafana

![ตัวอย่างการนับพอด Grafana](assets/images/pod-count-sample.png)
