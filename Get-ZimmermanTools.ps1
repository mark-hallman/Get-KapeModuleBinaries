<#
.SYNOPSIS
    Ths script will discover and download all available programs from https://ericzimmerman.github.io and download them to $Dest
.DESCRIPTION
    A file will also be created in $Dest that tracks the SHA-1 of each file, so rerunning the script will only download new versions. To redownload, remove lines from or delete the CSV file created under $Dest and rerun.
.PARAMETER Dest
    The path you want to save the programs to.
.EXAMPLE
    C:\PS> Get-ZimmermanTools.ps1 -Dest c:\tools
    Downloads/extracts and saves details about programs to c:\tools directory.
.NOTES
    Author: Eric Zimmerman
    Date:   January 22, 2019    
#>

[Cmdletbinding()]
# Where to extract the files to
Param
(
    [Parameter(Mandatory=$true)]
    $Dest #Where to save programs to	
)

Write-Host "`nThs script will discover and download all available programs from https://ericzimmerman.github.io and download them to $Dest" -BackgroundColor Blue
Write-Host "A file will also be created in $Dest that tracks the SHA-1 of each file, so rerunning the script will only download new versions"
Write-Host "To redownload, remove lines from or delete the CSV file created under $Dest and rerun. Enjoy!`n"

$newInstall = $false

if(!(Test-Path -Path $Dest ))
{
    write-host $Dest + " does not exist. Creating..."
    New-Item -ItemType directory -Path $Dest > $null

    $newInstall = $true
}

$URL = "https://raw.githubusercontent.com/EricZimmerman/ericzimmerman.github.io/master/index.md"

$WebKeyCollection = @()

$localDetailsFile = Join-Path $Dest -ChildPath "!!!RemoteFileDetails.csv"

if (Test-Path -Path $localDetailsFile)
{
    write-host "Loading local details..."
    $LocalKeyCollection = Import-Csv -Path $localDetailsFile
}

$toDownload = @()

#Get zips
$progressPreference = 'silentlyContinue'
$PageContent = (Invoke-WebRequest -Uri $URL).Content
$progressPreference = 'Continue'

$regex = [regex] '(?i)\b(https)://[-A-Z0-9+&@#/%?=~_|$!:,.;]*[A-Z0-9+&@#/%=~_|$].zip'
$matchdetails = $regex.Match($PageContent)

write-host "Getting available programs..."
$progressPreference = 'silentlyContinue'
while ($matchdetails.Success) {
    $headers = (Invoke-WebRequest -Uri $matchdetails.Value -Method Head).Headers

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

    $webKeyCollection += New-Object PSObject -Property $details  

    $matchdetails = $matchdetails.NextMatch()
} 
$progressPreference = 'Continue'

Foreach ($webKey in $webKeyCollection)
{
    if ($newInstall)
    {
        $toDownload+= $webKey
        continue    
    }

    $localFile = $LocalKeyCollection | Where-Object {$_.Name -eq $webKey.Name}

    if ($null -eq $localFile -or $localFile.SHA1 -ne $webKey.SHA1)
    {
        $toDownload+= $webKey
    }
}

if ($toDownload.Count -eq 0)
{
    write-host "`nAll files current. Exiting.`n" -BackgroundColor Blue
    return
}

if (-not (test-path ".\7z\7za.exe")) 
{
    Write-Host "`n.\7z\7za.exe needed! Exiting`n" -BackgroundColor Red
    return
} 
set-alias sz ".\7z\7za.exe"  

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

        #write-host "`tUnzipping to $Dest..."
        sz x $destFile -o"$Dest" -y > $null
    }
    catch 
    {
        $ErrorMessage = $_.Exception.Message
        write-host "Error downloading $name ($ErrorMessage). Wait for the run to finish and try again by repeating the command"
    }
    finally 
    {
        $progressPreference = 'Continue'
        remove-item -Path $destFile
    }
}

#Downloaded ok contains new stuff, but $LocalKeyCollection contains existing stuff, so combine
foreach($local in $LocalKeyCollection)
{
    $downloadedOK+=$local
}

Write-host "`nSaving downloaded version information to $localDetailsFile`n" -ForegroundColor Red
$downloadedOK | export-csv -Path  $localDetailsFile
