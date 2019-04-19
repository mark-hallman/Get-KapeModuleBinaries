# Get-KapeModuleBinaries
Downloads binaries used by KAPE

This script will discover and download all available EXE, ZIP, and PS1 files referenced in KAPE Module files and download them to $Dest

This was created from Eric Zimmerman's Get-ZimmermanTools script. I just modified a few things to have it parse the KAPE module (mkape) files and download binaries.


## Example
Downloads/extracts and saves details about programs to c:\tools directory.

PS C:\Tools> .\Get-KapeModuleBinaries.ps1 -Dest c:\tools -ModulesPath "C:\Forensic Program Files\Zimmerman\Kape\Modules"

