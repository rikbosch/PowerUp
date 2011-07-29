param([string]$deploymentEnvironment, [string]$settingsFile, [string]$destination, [string]$templatesFolder)
try {
	$ErrorActionPreference='Stop'
	$currentPath = Get-Location
	
	$env:PSModulePath = $env:PSModulePath + ";$currentPath\_powerup\modules\"
	import-module AffinityId\Id.PowershellExtensions.dll

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