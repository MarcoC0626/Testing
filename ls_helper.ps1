Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class L {
 [DllImport("kernel32.dll", SetLastError=true)] public static extern IntPtr OpenProcess(int a, bool b, int c);
 [DllImport("kernel32.dll", SetLastError=true)] public static extern bool ReadProcessMemory(IntPtr h, IntPtr a, byte[] b, int s, out int r);
 [DllImport("kernel32.dll", SetLastError=true)] public static extern bool CloseHandle(IntPtr h);
}
"@

$p = Get-Process lsass
Write-Host "LSASS PID: $($p.Id)"
$h = [L]::OpenProcess(0x10, $false, $p.Id)

if ($h -eq [IntPtr]::Zero) {
    $errCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
    Write-Host "[-] OpenProcess failed: $errCode"
    if ($errCode -eq 5) {
        Write-Host "[!] Access Denied"
    } else {
        Write-Host "[!] Other errors"
    }
    exit
} else {
    Write-Host "[+] OpenProcess: $h"
    
    $buf = New-Object byte[] 1
    $read = 0
    $success = [L]::ReadProcessMemory($h, [IntPtr]$p.MainModule.BaseAddress, $buf, 1, [ref]$read)
    
    if ($success) {
        Write-Host "[+] Read Success: $($buf[0])"
    } else {
        Write-Host "[-] ReadProcessMemory Failed。"
    }
    [L]::CloseHandle($h) | Out-Null
    Write-Host "[*] Handler Closed。"
}
