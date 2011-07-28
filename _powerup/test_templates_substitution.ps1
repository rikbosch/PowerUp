# Helper script for those who want to run
# psake without importing the module.
param([string]$deploymentEnvironment, [string]$settingsFile, [string]$destination, [string]$templatesFolder)
# use the following for mandatory params: 
# [string]$buildFile = $(throw "-buildFile is required.")
try {
	$ErrorActionPreference='Stop'
	$currentPath = Get-Location
	
	try{
		Copy-Item $currentPath\_PowershellExtensions\* -destination C:\Windows\System32\WindowsPowerShell\v1.0\Modules -force -recurse
		}
	catch{}
	
	import-module C:\Windows\System32\WindowsPowerShell\v1.0\Modules\AffinityId\Id.PowershellExtensions.dll

	Write-Host "DeploymentEnvironment: $deploymentEnvironment"
	Write-Host "Destination: $destination"

	
	$params = get-parsedsettings $currentPath\$settingsFile $deploymentEnvironment 
	copy-substitutedsettingfiles -templatesDirectory $currentPath\$templatesFolder -targetDirectory $destination -deploymentEnvironment $deploymentEnvironment -settings $params		
}
finally {
try{
		remove-module Id.PowershellExtensions
		}
		catch{}
}