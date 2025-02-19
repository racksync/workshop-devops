import { Button } from "@/components/ui/button";
import { Link } from "react-router-dom";
import { PlusCircle } from "lucide-react";

const Index = () => {
  return (
    <div className="min-h-screen bg-background">
      <div className="container mx-auto py-10">
        <div className="flex flex-col items-center justify-center space-y-8">
          <div className="text-center space-y-4">
            <h1 className="text-4xl font-bold">ระบบ STTC Activation</h1>
            <p className="text-xl text-muted-foreground">
              ระบบสำหรับร้องขอ Activation Code ผ่านการกรอก Local Code
            </p>
          </div>

          <div className="flex flex-col items-center space-y-4">
            <Link to="/request/new">
              <Button size="lg" className="space-x-2">
                <PlusCircle className="w-5 h-5" />
                <span>สร้างคำร้องขอใหม่</span>
              </Button>
            </Link>
          </div>

          <div className="max-w-2xl text-center space-y-2">
            <h2 className="text-2xl font-semibold">วิธีการใช้งาน</h2>
            <ul className="text-muted-foreground space-y-2 list-decimal list-inside text-left">
              <li>กดปุ่ม "สร้างคำร้องขอใหม่" เพื่อเริ่มกรอกแบบฟอร์ม</li>
              <li>กรอกข้อมูลที่จำเป็น เช่น Local Code, เวอร์ชันซอฟต์แวร์, ชื่อโครงการ</li>
              <li>แนบไฟล์เอกสารที่เกี่ยวข้อง (ถ้ามี)</li>
              <li>กดปุ่ม "บันทึกคำร้องขอ" เพื่อส่งข้อมูล</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Index;