<#
.SYNOPSIS
    This script is to assist in resetting the KAPE folder back to a known state for testing.
    It will delete the KAPE folder defined in $test_kape_dir test with the contents of the 
    $old_kape folder.
#>

$old_kape = "G:\test\kape-0.7.0.0\kape"
$test_kape_dir = "G:\test\KAPE"
$dest = "G:\test"

if (Test-Path -Path $test_kape_dir  ) {
        Remove-Item $test_kape_dir -Recurse -Force | Out-Null
} 
Copy-Item $old_kape -Recurse -Force -Destination $dest | Out-Null
Write-Host "`n$dest\kape reset to $old_kape`n" -ForegroundColor Green
