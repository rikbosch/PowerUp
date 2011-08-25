function invoke-remotetask($servers, $tasks, $deploymentEnvironment, $fullLocalReleaseWorkingFolder )
{	
	foreach ($server in $servers)
	{			
		$batchFile = $fullLocalReleaseWorkingFolder + '\' + 'deploy.bat'

		cmd /c cscript.exe _powerup\cmd.js _powerup\psexec.exe $server /accepteula -w $fullLocalReleaseWorkingFolder $batchFile $deploymentEnvironment $tasks
	}
}

function copy-package($remotePath)
{		
	$packageFolder = get-location
	import-module powerupfilesystem

	if (!${remotePath})
		{throw "The setting 'remotePath' is not set for this environment."}
				
	echo "Copying deployment package to $remotePath"
	Copy-MirroredDirectory $packageFolder $remotePath
}

export-modulemember -function invoke-remotetask, copy-package