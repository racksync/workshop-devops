import * as React from "react"
import { cn } from "@/lib/utils"
import { Button } from "./button"
import { Upload } from "lucide-react"

interface FileUploadProps extends React.InputHTMLAttributes<HTMLInputElement> {
  onFileSelect?: (files: FileList | null) => void
}

const FileUpload = React.forwardRef<HTMLInputElement, FileUploadProps>(
  ({ className, onFileSelect, ...props }, ref) => {
    const handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
      if (onFileSelect) {
        onFileSelect(event.target.files)
      }
    }

    return (
      <div className={cn("grid w-full gap-1.5", className)}>
        <Button
          variant="outline"
          className="w-full"
          onClick={() => {
            const input = document.createElement("input")
            input.type = "file"
            input.multiple = true
            input.accept = props.accept
            input.click()
            input.onchange = (e) => {
              const target = e.target as HTMLInputElement
              if (onFileSelect) {
                onFileSelect(target.files)
              }
            }
          }}
        >
          <Upload className="mr-2 h-4 w-4" />
          อัปโหลดไฟล์
        </Button>
        <input
          type="file"
          className="hidden"
          onChange={handleChange}
          ref={ref}
          {...props}
        />
      </div>
    )
  }
)
FileUpload.displayName = "FileUpload"

export { FileUpload }