import Image from "next/image";

export default function Home() {
  return (
    <div className="bg-black grid grid-rows-[20px_1fr_20px] items-center justify-items-center min-h-screen p-8 pb-20 gap-16 sm:p-20 font-[family-name:var(--font-geist-sans)]">
      <main className="flex flex-col gap-8 row-start-2 items-center sm:items-start">
        {/* Removed free icon so that only "RACKSYNC" text is displayed */}
        <div>
          <span className="text-3xl font-bold">RACKSYNC</span>
        </div>
        {/* Removed DevOps picture */}
        {/* Removed previous list and inserted new training text */}
        <p>
          เทรนนิ่งคอร์สอบรม DevOps กึ่งปฏิบัติการแบบออนไลน์ถ่ายทอดตัวต่อตัว สำหรับผู้ที่สนใจปรับทักษะเพื่อปูพื้นฐานสู่การเป็น DevOps โดยหลักสูตร เน้นให้ผู้เข้าร่วมเข้าใจโครงสร้างพื้นฐานของระบบปฏิบัติการ Linux ซึ่งเป็นระบบปฏิบัติการที่ Cloud Provider ทั่วโลกตั้งแต่ขนาดเล็กจนถึงขนาดใหญ่เลือกใช้ ซึ่งมีความยืดหยุ่นสูงเหมาะสำหรับการนำมาให้บริการในเชิงพาณิชย์และเป็นโครงสร้างพื้นฐานของ service ขนาดใหญ่ทั่วโลก โดยหลักสูตรเริ่มตั้งแต่แนะนำโครงสร้างพื้นฐานไปจนถึงสามารถ spin-up service เพื่อ deploy iot infrastructure จริงสำหรับใช้ในองค์กรได้ โดยการเทรนเป็นแบบ Video Conferrence มีการบันทึกวีดีโอสำหรับผู้เข้าร่วมสามารถดูย้อนหลังเพื่อทบทวนได้ (Lifetime Access)
        </p>

        <div className="flex gap-4 items-center flex-col sm:flex-row">
          {/* Updated "Deploy now" anchor to "GitHub" with new link */}
          <a
            className="rounded-full border border-solid border-transparent transition-colors flex items-center justify-center bg-foreground text-background gap-2 hover:bg-[#383838] dark:hover:bg-[#ccc] text-sm sm:text-base h-10 sm:h-12 px-4 sm:px-5"
            href="https://github.com/racksync/devops-workshop"
            target="_blank"
            rel="noopener noreferrer"
          >
            <Image
              className="dark:invert"
              src="/vercel.svg"
              alt="Vercel logomark"
              width={20}
              height={20}
            />
            GitHub
          </a>
        </div>
      </main>
      <footer className="row-start-3 flex flex-col gap-4 items-center justify-center">
        <div className="flex gap-6">
          <a
            className="flex items-center gap-2 hover:underline hover:underline-offset-4"
            href="https://racksync.com"
            target="_blank"
            rel="noopener noreferrer"
          >
            <Image
              aria-hidden
              src="/globe.svg"
              alt="Globe icon"
              width={16}
              height={16}
            />
            Go to DevOps Workshop →
          </a>
        </div>
        <p className="text-xs">&copy; RACKSYNC CO., LTD.</p>
      </footer>
    </div>
  );
}
