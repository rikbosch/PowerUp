param([string]$deployFile = ".\deploy.ps1", [string]$deploymentEnvironment, [bool]$onlyFinalisePackage=$false, $tasks="default")


try {
	$ErrorActionPreference='Stop'
	$currentPath = Get-Location

	echo "Deploying package onto environment $deploymentEnvironment"	
	echo "Deployment being run under account $env:username"
	echo "Importing basic modules required by PowerUp"
	$env:PSModulePath = $env:PSModulePath + ";$currentPath\_powerup\modules\"
	import-module psake.psm1
	import-module AffinityId\Id.PowershellExtensions.dll
	import-module powerupremote
	import-module poweruptemplates
	import-module powerupsettings
	
		
	if (!$onlyFinalisePackage)
	{		
		echo "Calling psake package deployment script"
		$psake.use_exit_on_error = $true
		invoke-psake $deployFile $tasks -parameters @{"deployment.environment"=$deploymentEnvironment} 
	}
}
finally {
try{
		remove-module psake
		remove-module Id.PowershellExtensions
		}
catch{}
}
