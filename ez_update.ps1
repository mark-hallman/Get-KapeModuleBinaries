<#
.SYNOPSIS
    This is a wrapprer script that updates Zimmermantools, KAPE, KAPE Targets, Modules, and Module binaries
#>

$zimmerman_tools_loc = "C:\Forensic Program Files\ZimmermanTools"
$kape_loc            = "C:\Forensic Program Files\KAPE"
$command = ".\Get-KapeModuleBinaries-DEV.ps1 -ModulePath $kape_loc\Modules -UseBinaryList -BinaryListPath .\KAPE-Default-Binaries.txt -dest 'C:\Forensic Program Files\ZimmermanTools\bin'"

Write-Host "`nUpdating Zimmerman Tools in Folder, $zimmerman_tools_loc`n" -ForegroundColor Green
Set-Location -Path $zimmerman_tools_loc               # cd to Zimmermantools folder
Invoke-Expression -Command .\Get-ZimmermanTools.ps1   # run EZ's tool update script
Write-Host "`nUpdating KAPE in Folder, $kape_loc`n" -ForegroundColor Green
Set-Location -Path $kape_loc                          # cd to KAPE folder
Invoke-Expression -Command .\Get-KAPEUpdate.ps1       # run EZ's KAPE update script
Write-Host "`nUpdating KAPE Targets and Modules in Folder`n, $kape_loc`n" -ForegroundColor Green
Invoke-Command -ScriptBlock {kape --sync}             # run KAPE --sync to get new Targets & Modules
Set-Location -Path $kape_loc                          # cd to KAPE folder (should still be there)
Write-Host "`nUpdating KAPE Modules Binaries in Folder`n, $kape_loc`n" -ForegroundColor Green
Invoke-Expression -Command $command                   # run command to update KAPE binaries.  See script for more details
Write-Host "`nUpdating KAPE Modules Binaries in Folder`n, $kape_loc`n" -ForegroundColor Green