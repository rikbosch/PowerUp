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
	
	echo "Copying files specific to this environment to necessary folders within the package"
	merge-environmentspecificfiles $deploymentEnvironment

	echo "Reading settings"		
	$settings = get-parsedsettings $currentPath\settings.txt $deploymentEnvironment 
	
	echo "Package settings for this environment are:"
	$settings | Format-Table -property *
	
	echo "Substituting and copying templated files"	
	merge-templates $settings $deploymentEnvironment
		
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
