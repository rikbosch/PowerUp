param([string]$deploymentEnvironment)

function CopyPackage($settings)
{	

	. $currentPath\_powerup\common_deploy_functions.ps1
	$remoteReleaseWorkingFolder = $settings['remote.temp.working.folder']	
	$packageName = $settings['package.name']		
	$fullDestinationFolder = $remoteReleaseWorkingFolder + '\' + $packageName
			
	echo "Copying deployment package to $fullDestinationFolder"
	RobocopyMirrorDirectory $currentPath $fullDestinationFolder
}

function RunRemoteRelease($settings)
{
	$localReleaseWorkingFolder = $settings['local.temp.working.folder']
	$deployServer = $settings['deployment.server']
	$packageName = $settings['package.name']
	
	$fullLocalReleaseWorkingFolder = $localReleaseWorkingFolder + '\' + $packageName
	$batchFile = $fullLocalReleaseWorkingFolder + '\' + 'deploy.bat'
	
	echo "Executing package deployment on remote server $deployServer"
	cmd /c cscript.exe _powerup\cmd.js _powerup\psexec.exe $deployServer /accepteula -w $fullLocalReleaseWorkingFolder $batchFile $deploymentEnvironment
}

try {
	$ErrorActionPreference='Stop'
	$currentPath = Get-Location

	echo "DeploymentEnvironment: $deploymentEnvironment"	
	echo "SettingsFile: $currentPath\settings.txt"	
	
	$env:PSModulePath = $env:PSModulePath + ";$currentPath\_powerup\PowershellExtensions\"	
	import-module AffinityId\Id.PowershellExtensions.dll
		
	$settings = get-parsedsettings $currentPath\settings.txt $deploymentEnvironment 	
		
	CopyPackage($settings)
	RunRemoteRelease($settings)
}
finally {
	try{
		remove-module Id.PowershellExtensions
	}
	catch{}
}