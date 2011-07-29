param([string]$deploymentEnvironment)

function CopyPackage($settings)
{	

	$remoteReleaseWorkingFolder = $settings['remote.temp.working.folder']	
	$packageName = $settings['package.name']		
	$fullDestinationFolder = $remoteReleaseWorkingFolder + '\' + $packageName
			
	echo "Copying deployment package to $fullDestinationFolder"
	Copy-MirroredDirectory $currentPath $fullDestinationFolder
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
	
	$env:PSModulePath = $env:PSModulePath + ";$currentPath\_powerup\modules\"	
	echo $env:PSModulePath
	import-module AffinityId\Id.PowershellExtensions.dll
	import-module PowerUpFileSystem
		
	$settings = get-parsedsettings $currentPath\settings.txt $deploymentEnvironment 	
		
	CopyPackage($settings)
	RunRemoteRelease($settings)
}
finally {
	try{
		remove-module Id.PowershellExtensions
		remove-module PowerUpFileSystem
	}
	catch{}
}