<#
.SYNOPSIS
    Ths script will discover and download all available EXE, ZIP, and PS1 files referenced in KAPE Module files and download them to $Dest
.DESCRIPTION
    A file will also be created in $Dest that tracks the SHA-1 of each file, so rerunning the script will only download new versions. 
    To redownload, remove lines from or delete the CSV file created under $Dest and rerun. Note this only works for Eric Zimmerman's tools. All others will be donwloaded each time.
.PARAMETER Dest
    The path you want to save the programs to.
.PARAMETER ModulePath
    The path containing KAPE module files.   
.EXAMPLE
    PS C:\Tools> Get-KapeModuleBinaries.ps1 -Dest c:\tools -ModulePath "C:\Forensic Program Files\Zimmerman\Kape\Modules"
    Downloads/extracts and saves details about programs to c:\tools directory.
.NOTES
    This script was created from Eric Zimmerman's Get-ZimmermanTools script. I just modified a few things to have it parse the mkape files and download binaries
#>

[Cmdletbinding()]
# Where to extract the files to
Param
(
    [Parameter()]
    [string]$Dest= (Resolve-Path "."), #Where to save programs to
    [Parameter()]
    [string]$ModulePath # Path to Kape Modules directory	
)

# Some download sources require TLS 1.2 which PowerShell doesn't support out of the box so we are adding that here
function Enable-SSLRequirements
{
    add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
    $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
    [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
}
Enable-SSLRequirements

Write-Host "`nThs script will discover and download all ZIP,EXE,and PS1 files referenced in Kape Module files and download them to $Dest" -BackgroundColor Blue

$newInstall = $false

if(!(Test-Path -Path $Dest ))
{
    write-host $Dest " does not exist. Creating..."
    New-Item -ItemType directory -Path $Dest > $null

    $newInstall = $true
}


$WebKeyCollection = @()

$localDetailsFile = Join-Path $Dest -ChildPath "!!!RemoteFileDetails.csv"

if (Test-Path -Path $localDetailsFile)
{
    write-host "Loading local details from '$Dest'..."
    $LocalKeyCollection = Import-Csv -Path $localDetailsFile
}

$toDownload = @()

#Get zips
$progressPreference = 'silentlyContinue'
$mkapeContent = Get-Content $modulePath\*.mkape 
$progressPreference = 'Continue'

$regex = [regex] '(?i)\b(http.)://[-A-Z0-9+&@#/%?=~_|$!:,.;]*[A-Z0-9+&@#/%=~_|$].(zip|txt|ps1|exe)'
$matchdetails = $regex.Match($mkapeContent) 

write-host "Getting available programs..."
$progressPreference = 'silentlyContinue'
while ($matchdetails.Success) {
    $headers = (Invoke-WebRequest -Uri $matchdetails.Value -UseBasicParsing -Method Head).Headers

    # Eric's tools have the hash available in the header so we can check these to see if we have the current version already
    if($matchdetails.Value -like '*EricZimmermanTools*') {
        $getUrl = $matchdetails.Value
        $sha = $headers["x-bz-content-sha1"]
        $name = $headers["x-bz-file-name"]
        $size = $headers["Content-Length"]

        $details = @{            
            Name     = $name            
            SHA1     = $sha                 
            URL     = $getUrl
            Size    = $size
            }                           
    }
    # Downloading 
    else
    {
        $getUrl = $matchdetails.Value
        $sha = "N/A"
        $name = $matchdetails.Value | Split-Path -Leaf
        $size = $headers["Content-Length"]


        $details = @{            
            Name     = $name            
            SHA1     = $sha                 
            URL     = $getUrl
            Size    = $size
            }   
    }
    $webKeyCollection += New-Object PSObject -Property $details  

    $matchdetails = $matchdetails.NextMatch()
} 
$progressPreference = 'Continue'

$WebKeyCollection = $WebKeyCollection | Select-Object * -Unique

Foreach ($webKey in $webKeyCollection)
{
    if ($newInstall)
    {
        $toDownload+= $webKey
        continue    
    }

    $localFile = $LocalKeyCollection | Where-Object {$_.Name -eq $webKey.Name}

    if ($null -eq $localFile -or $localFile.SHA1 -ne $webKey.SHA1 -or $localFile.SHA1 -eq "N/A")
    {
        #Needs to be downloaded since file doesn't exist, SHA is different, or SHA is not in header to compare
        $toDownload+= $webKey
    }
}

if ($toDownload.Count -eq 0)
{
    write-host "`nAll files current. Exiting.`n" -BackgroundColor Blue
    return
}

$downloadedOK = @()

foreach($td in $toDownload)
{
    try 
    {
        $dUrl = $td.URL
        $size = $td.Size
        $name = $td.Name
        write-host "Downloading $name (Size: $size)" -ForegroundColor Green
        $destFile = Join-Path -Path . -ChildPath $td.Name
        $progressPreference = 'silentlyContinue'
        Invoke-WebRequest -Uri $dUrl -OutFile $destFile -ErrorAction:Stop -UseBasicParsing
    
        $downloadedOK += $td

    if ( $name.endswith("zip") )  
    {
         Expand-Archive -Path $destFile -DestinationPath "." -Force
    }       
    }
    catch 
    {
        $ErrorMessage = $_.Exception.Message
        write-host "Error downloading $name ($ErrorMessage). Wait for the run to finish and try again by repeating the command"
    }
    finally 
    {
        $progressPreference = 'Continue'
	if ( $name.endswith("zip") )  
	{
	    remove-item -Path $destFile
	} 
        
    }
}

#Downloaded ok contains new stuff, but we need to account for existing stuff too
foreach($webItems in $webKeyCollection)
{
    #Check what we have locally to see if it also contains what is in the web collection
    $localFile = $LocalKeyCollection | Where-Object {$_.SHA1 -eq $webItems.SHA1}

    #if its not null, we have a local file match against what is on the website, so its ok
    
    if ($null -ne $localFile)
    {
        #consider it downloaded since SHAs match
        $downloadedOK+=$webItems
    }
}

Write-host "`nSaving downloaded version information to $localDetailsFile`n" -ForegroundColor Red
$downloadedOK | export-csv -Path  $localDetailsFile
