<#
.SYNOPSIS
    This is a wrapprer script that updates Zimmermantools, KAPE, KAPE Targets, Modules, and Module binaries.  
    The script was written to help SANS DFIR students to keep KAPE binaries in sync with the updates made
    by Get-ZimmermanTools.ps1 and Get-KAPEUpdate.ps1.
.NOTES
    Author: Mark Hallman
            2019-07-01
#>

$ZimmermanToolsLocation = "C:\Tools\ZimmermanTools"
$KapeLocation           = "C:\Tools\KAPE"
$BinaryListPath         = "KAPE-Default-Binaries.txt"
$BinUpdateCommand = ".\Get-KapeModuleBinaries-DEV.ps1 -ModulePath $KapeLocation\Modules -UseBinaryList -BinaryListPath $KapeLocation\$BinaryListPath -dest '$KapeLocation\Modules\bin'"

Write-Host "`nUpdating Zimmerman Tools in Folder $ZimmermanToolsLocation`n" -ForegroundColor Green
Set-Location -Path $ZimmermanToolsLocation            # cd to Zimmermantools folder
Invoke-Expression -Command .\Get-ZimmermanTools.ps1   # run EZ's tool update script

Write-Host "`nUpdating KAPE in Folder $KapeLocation`n" -ForegroundColor Green
Set-Location -Path $KapeLocation                      # cd to KAPE folder
Invoke-Expression -Command .\Get-KAPEUpdate.ps1       # run EZ's KAPE update script

Write-Host "`nUpdating KAPE Targets and Modules in Folder $KapeLocation`n" -ForegroundColor Green
Invoke-Command -ScriptBlock {kape --sync}             # run KAPE --sync to get new Targets & Modules

Write-Host "`nUpdating KAPE Modules Binaries in Folder $KapeLocation`n" -ForegroundColor Green
Invoke-Expression -Command $BinUpdateCommand          # run command to update KAPE binaries.  See script for more details
Write-Host "`EZ Update Complete ...`n" -ForegroundColor Green