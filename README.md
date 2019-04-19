# Get-KapeModuleBinaries
Downloads binaries used by KAPE

This script will discover and download all available EXE, ZIP, and PS1 files referenced in KAPE Module files and download them to $Dest

This was created from Eric Zimmerman's Get-ZimmermanTools script. I just modified a few things to have it parse the KAPE module (mkape) files and download binaries.  

Rerunning the script will download a new copy of Eric's tools only if a newer version exists. All other tools will be download again even if a newer version is not available. To force Eric's tools to download a new copy, delete the line for that tool in the "!!!RemoteFileDetails.csv" file from the directory specified in the -Dest parameter.

## Prerequisites
* KAPE must be installed prior to running this script - https://binaryforay.blogspot.com/2019/02/introducing-kape.html
* PowerShell 3 or later required

## Installation


Download and extract zip. Set PowerShell execution policy to allow execution of scripts by launching PowerShell as an administrator and running the following: 

PS C:\Tools> Set-ExecutionPolicy -executionpolicy bypass

## Example
Downloads/extracts and saves details about programs to c:\tools directory.

PS C:\Tools> .\Get-KapeModuleBinaries.ps1 -Dest c:\tools -ModulesPath "C:\Forensic Program Files\Zimmerman\Kape\Modules"

