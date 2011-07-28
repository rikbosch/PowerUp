param([string]$deploymentEnvironment)

function CopyPackage($settings)
{	

	. $currentPath\_powerup\common_deploy_functions.ps1
	$remoteReleaseWorkingFolder = $settings['remote.temp.working.folder']	
	$projectName = $settings['project.name']		
	$fullDestinationFolder = $remoteReleaseWorkingFolder + '\' + $projectName
			
	echo "Copying deployment package to $fullDestinationFolder"
	RobocopyMirrorDirectory $currentPath $fullDestinationFolder
}

function RunRemoteRelease($settings)
{
	$localReleaseWorkingFolder = $settings['local.temp.working.folder']
	$deployServer = $settings['deployment.server']
	$projectName = $settings['project.name']
	
	$fullLocalReleaseWorkingFolder = $localReleaseWorkingFolder + '\' + $projectName
	$batchFile = $fullLocalReleaseWorkingFolder + '\' + 'deploy.bat'
	
	echo "Executing package deployment on remote server $deployServer"
	cmd /c cscript.exe _powerup\cmd.js _powerup\psexec.exe $deployServer /accepteula -w $fullLocalReleaseWorkingFolder $batchFile $deploymentEnvironment
}

try {
	$ErrorActionPreference='Stop'
	$currentPath = Get-Location

	echo "DeploymentEnvironment: $deploymentEnvironment"	
	echo "SettingsFile: $currentPath\settings.txt"	
	
	$env:PSModulePath = $env:PSModulePath + ";$currentPath\_powerup\_PowershellExtensions\"
	
	if ($psversiontable.clrversion.major -lt 4)
	{
		Copy-Item $currentPath\_powerup\powershell.exe.config -destination C:\Windows\System32\WindowsPowerShell\v1.0 -force 
		
		#upgrading 
		throw "Powershell CLR runtime version detected as not being .Net 4. This has been upgraded, but cannot take effect immediately. Please rerun deployment."
	}
	
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