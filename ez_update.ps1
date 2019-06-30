Set-Location -Path "G:\test\ZimmermanTools\"
Invoke-Expression -Command .\Get-ZimmermanTools.ps1"
Set-Location -Path "G:\test\kape"
Invoke-Expression -Command .\Get-KAPEUpdate.ps1"
$command = ".\Get-KapeModuleBinaries-DEV.ps1 -ModulePath G:\test\KAPE\Modules -UseBinaryList -BinaryListPath .\KAPE-Default-Binaries.txt -dest G:\test\KAPE\Modules\bin"
Set-Location -Path "G:\test\kape"
Invoke-Expression -Command $command