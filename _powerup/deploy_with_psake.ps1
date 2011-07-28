# Helper script for those who want to run
# psake without importing the module.
param([string]$depoyFile = ".\deploy.ps1", [string]$deploymentEnvironment, [bool]$onlyFinalisePackage=$false)
# use the following for mandatory settings: 
# [string]$depoyFile = $(throw "-depoyFile is required.")
try {
	$ErrorActionPreference='Stop'
	$currentPath = Get-Location

	Write-Host "Deploy File: $depoyFile"
	Write-Host "Deployment Environment: $deploymentEnvironment"
	Write-Host "Settings File: $currentPath\settings.txt"
	Write-Host "Templates Directory: $currentPath\_templates"
	Write-Host "Environments Directory: $currentPath\_environments"
	
	$env:PSModulePath = $env:PSModulePath + ";$currentPath\_powerup\_PowershellExtensions\"
		
	import-module .\_powerup\psake.psm1
	import-module Pscx
	import-module AffinityId\Id.PowershellExtensions.dll
	import-module .\_powerup\LoadWebAdministration.psm1

	$settings = get-parsedsettings $currentPath\settings.txt $deploymentEnvironment 
	
	echo "Settings are:"
	$settings | Format-Table -property *

	if ((Test-Path $currentPath\_environments\$deploymentEnvironment -PathType Container) -eq $true)
	{
		Copy-Item $currentPath\_environments\$deploymentEnvironment\* -destination $currentPath\ -recurse -force   
	}	

	copy-substitutedsettingfiles -templatesDirectory $currentPath\_templates -targetDirectory $currentPath\_templatesoutput -deploymentEnvironment $deploymentEnvironment -settings $settings
	
	if ((Test-Path $currentPath\_templatesoutput\$deploymentEnvironment -PathType Container) -eq $true)
	{
	Copy-Item $currentPath\_templatesoutput\$deploymentEnvironment\* -destination $currentPath\ -recurse -force    
	}
		
	if (!$onlyFinalisePackage)
	{
		$currentComputerName = gc env:computername
		$expectedComputerName = $settings['deployment.server']
		
		echo "Expected computer is $expectedComputerName"
		echo "Current computer is $currentComputerName"
								
		if (!($expectedComputerName.ToLower().Contains("localhost")) -and !($expectedComputerName.ToLower().Contains($currentComputerName.ToLower())))
		{
			throw "Release halted, as being run against incorrect deployment server"
		}
	
		$psake.use_exit_on_error = $true
		invoke-psake $depoyFile –parameters $settings
	}
	
}
finally {
try{
		remove-module psake
		remove-module pscx
		remove-module Id.PowershellExtensions
		remove-module WebAdministration
		}
		catch{}
}
