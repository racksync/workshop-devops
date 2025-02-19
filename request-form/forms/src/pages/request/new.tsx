import { zodResolver } from "@hookform/resolvers/zod"
import { useForm } from "react-hook-form"
import * as z from "zod"
import { Button } from "@/components/ui/button"
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import { Input } from "@/components/ui/input"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { FileUpload } from "@/components/ui/file-upload"
import { toast } from "sonner"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { ArrowLeft } from "lucide-react"
import { Link } from "react-router-dom"

const formSchema = z.object({
  localCode: z.string().min(1, "กรุณากรอก Local Code"),
  softwareVersion: z.string().min(1, "กรุณาเลือกเวอร์ชันซอฟต์แวร์"),
  projectName: z.string().min(1, "กรุณากรอกชื่อโครงการ"),
  organization: z.string().min(1, "กรุณาเลือกหน่วยงาน"),
  adminHierarchy: z.string().min(1, "กรุณาเลือกระดับการบริหาร"),
  staffCode: z.string().min(1, "กรุณากรอกรหัสพนักงาน"),
  docNo: z.string().min(1, "กรุณากรอกหมายเลขหนังสือ"),
  reason: z.string().min(1, "กรุณาเลือกเหตุผลการร้องขอ"),
  attachedFiles: z.any().optional(),
})

export default function NewRequestPage() {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      localCode: "",
      softwareVersion: "",
      projectName: "",
      organization: "",
      adminHierarchy: "",
      staffCode: "",
      docNo: "",
      reason: "",
    },
  })

  async function onSubmit(values: z.infer<typeof formSchema>) {
    try {
      console.log(values)
      toast.success("บันทึกคำร้องขอสำเร็จ")
    } catch (error) {
      toast.error("เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง")
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-background to-muted/50 py-10">
      <div className="container max-w-3xl mx-auto px-4">
        <div className="mb-8">
          <Link to="/" className="inline-flex items-center text-muted-foreground hover:text-primary transition-colors">
            <ArrowLeft className="w-4 h-4 mr-2" />
            กลับหน้าหลัก
          </Link>
        </div>
        
        <Card className="backdrop-blur-sm bg-card/95 border-accent">
          <CardHeader className="space-y-2 text-center">
            <CardTitle className="text-2xl font-bold bg-gradient-to-r from-primary to-primary/80 bg-clip-text text-transparent">
              สร้างคำร้องขอ Activation Code
            </CardTitle>
            <CardDescription>
              กรุณากรอกข้อมูลให้ครบถ้วนเพื่อขอรับ Activation Code
            </CardDescription>
          </CardHeader>
          
          <CardContent>
            <Form {...form}>
              <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
                <div className="grid gap-6 md:grid-cols-2">
                  <FormField
                    control={form.control}
                    name="localCode"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Local Code</FormLabel>
                        <FormControl>
                          <Input placeholder="กรอก Local Code" className="bg-background/50" {...field} />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="softwareVersion"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>เวอร์ชันซอฟต์แวร์</FormLabel>
                        <Select onValueChange={field.onChange} defaultValue={field.value}>
                          <FormControl>
                            <SelectTrigger className="bg-background/50">
                              <SelectValue placeholder="เลือกเวอร์ชันซอฟต์แวร์" />
                            </SelectTrigger>
                          </FormControl>
                          <SelectContent>
                            <SelectItem value="1.0.0">1.0.0</SelectItem>
                            <SelectItem value="1.1.0">1.1.0</SelectItem>
                            <SelectItem value="2.0.0">2.0.0</SelectItem>
                          </SelectContent>
                        </Select>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>

                <FormField
                  control={form.control}
                  name="projectName"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>ชื่อโครงการ</FormLabel>
                      <FormControl>
                        <Input placeholder="กรอกชื่อโครงการ" className="bg-background/50" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <div className="grid gap-6 md:grid-cols-2">
                  <FormField
                    control={form.control}
                    name="organization"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>หน่วยงาน/องค์กร</FormLabel>
                        <Select onValueChange={field.onChange} defaultValue={field.value}>
                          <FormControl>
                            <SelectTrigger className="bg-background/50">
                              <SelectValue placeholder="เลือกหน่วยงาน" />
                            </SelectTrigger>
                          </FormControl>
                          <SelectContent>
                            <SelectItem value="org1">หน่วยงาน 1</SelectItem>
                            <SelectItem value="org2">หน่วยงาน 2</SelectItem>
                            <SelectItem value="org3">หน่วยงาน 3</SelectItem>
                          </SelectContent>
                        </Select>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="adminHierarchy"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>ระดับการบริหาร</FormLabel>
                        <Select onValueChange={field.onChange} defaultValue={field.value}>
                          <FormControl>
                            <SelectTrigger className="bg-background/50">
                              <SelectValue placeholder="เลือกระดับการบริหาร" />
                            </SelectTrigger>
                          </FormControl>
                          <SelectContent>
                            <SelectItem value="district">ไฟฟ้าตำบล</SelectItem>
                            <SelectItem value="site">ไฟฟ้าหน้างาน</SelectItem>
                          </SelectContent>
                        </Select>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>

                <div className="grid gap-6 md:grid-cols-2">
                  <FormField
                    control={form.control}
                    name="staffCode"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>รหัสพนักงาน</FormLabel>
                        <FormControl>
                          <Input placeholder="กรอกรหัสพนักงาน" className="bg-background/50" {...field} />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />

                  <FormField
                    control={form.control}
                    name="docNo"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>หมายเลขหนังสือ</FormLabel>
                        <FormControl>
                          <Input placeholder="กรอกหมายเลขหนังสือ (ม.ท. XXXX)" className="bg-background/50" {...field} />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                </div>

                <FormField
                  control={form.control}
                  name="reason"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>เหตุผลการร้องขอ</FormLabel>
                      <Select onValueChange={field.onChange} defaultValue={field.value}>
                        <FormControl>
                          <SelectTrigger className="bg-background/50">
                            <SelectValue placeholder="เลือกเหตุผลการร้องขอ" />
                          </SelectTrigger>
                        </FormControl>
                        <SelectContent>
                          <SelectItem value="new">New install</SelectItem>
                          <SelectItem value="reinstall">Re-install</SelectItem>
                        </SelectContent>
                      </Select>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="attachedFiles"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>ไฟล์แนบ (ถ้ามี)</FormLabel>
                      <FormControl>
                        <FileUpload
                          accept=".pdf,.doc,.docx"
                          onFileSelect={(files) => {
                            field.onChange(files)
                          }}
                        />
                      </FormControl>
                      <FormDescription className="text-xs">
                        รองรับไฟล์ PDF และ Word เท่านั้น
                      </FormDescription>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <Button type="submit" className="w-full bg-gradient-to-r from-primary to-primary/80 hover:from-primary/90 hover:to-primary/70">
                  บันทึกคำร้องขอ
                </Button>
              </form>
            </Form>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
