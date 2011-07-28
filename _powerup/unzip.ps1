param([string]$buildNumber)
$currentPath = Get-Location


$zipFile = "$currentPath\package_$buildNumber.zip"
_powerup\unzip.exe -o -q $zipFile 

Remove-Item $currentPath\package_$buildNumber.zip

