<#
.SYNOPSIS
    This is a wrapprer script that updates Zimmermantools, KAPE, KAPE Targets, Modules, Module binaries 
    and EvtxEcmd maps.  
    The script was written to help SANS DFIR students to keep KAPE binaries in sync with the updates made
    by Get-ZimmermanTools.ps1 and Get-KAPEUpdate.ps1.
.NOTES
    Author: Mark Hallman
            2019-07-01
#>

$ZimmermanToolsLocation = "C:\Forensic Program Files\Zimmerman"  # Location of Zimmermantools
$KapeLocation           = "C:\Forensic Program Files\KAPE"       # Location of KARE
$BinaryListPath         = "KAPE-Default-Binaries.txt"            

$BinUpdateCommand = ".\Get-KapeModuleBinaries.ps1 -ModulePath .\Modules -UseBinaryList -BinaryListPath .\$BinaryListPath -dest .\Modules\bin"

Write-Host "`nUpdating Zimmerman Tools in Folder $ZimmermanToolsLocation`n" -ForegroundColor Green
Set-Location -Path $ZimmermanToolsLocation            # cd to Zimmermantools folder
Invoke-Expression -Command .\Get-ZimmermanTools.ps1   # run EZ's tool update script

Write-Host "`nUpdating KAPE in Folder $KapeLocation`n" -ForegroundColor Green
Set-Location -Path $KapeLocation                      # cd to KAPE folder
Invoke-Expression -Command .\Get-KAPEUpdate.ps1       # run EZ's KAPE update script

Write-Host "`nUpdating KAPE Targets and Modules in Folder $KapeLocation`n" -ForegroundColor Green
Invoke-Command -ScriptBlock {kape --sync}             # run KAPE --sync to get new Targets & Modules

Write-Host "`nUpdating  EvtxECmd maps in Folder $ZimmermanToolsLocation\evtxecmd`n" -ForegroundColor Green
Invoke-Command -ScriptBlock {evtxecmd --sync}         # run EvtxECmd --sync to get new Maps

Write-Host "`nUpdating KAPE Modules Binaries needed for Modules in $KapeLocation\Modules`n" -ForegroundColor Green
Invoke-Expression -Command $BinUpdateCommand          # run command to update KAPE binaries.  See script for more details
Write-Host "`EZ Update Complete ...`n" -ForegroundColor Green