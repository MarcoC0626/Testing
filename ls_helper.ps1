Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class L {
 [DllImport("kernel32.dll")] public static extern IntPtr OpenProcess(int a, bool b, int c);
 [DllImport("kernel32.dll")] public static extern bool ReadProcessMemory(IntPtr h, IntPtr a, byte[] b, int s, out int r);
 [DllImport("kernel32.dll")] public static extern bool CloseHandle(IntPtr h);
}
"@
$p = Get-Process lsass
$h = [L]::OpenProcess(0x10, $false, $p.Id)  # PROCESS_VM_READ
$buf = New-Object byte[] 1
$read = 0
[L]::ReadProcessMemory($h, $p.MainModule.BaseAddress, $buf, 1, [ref]$read)
[L]::CloseHandle($h)
