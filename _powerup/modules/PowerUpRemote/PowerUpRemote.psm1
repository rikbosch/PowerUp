function invoke-remotetask($servers, $tasks, $deploymentEnvironment, $packageName )
{	
	foreach ($server in $servers)
	{			
		$fullLocalReleaseWorkingFolder = $server['local.temp.working.folder'] + '\' + $packageName
		$batchFile = $fullLocalReleaseWorkingFolder + '\' + 'deploy.bat'

		if ($server.ContainsKey('username'))
		{
			cmd /c cscript.exe $PSScriptRoot\cmd.js $PSScriptRoot\psexec.exe $server['server.name'] /accepteula -u $server['username'] -p $server['password'] -w $fullLocalReleaseWorkingFolder $batchFile $deploymentEnvironment $tasks
		}
		else
		{
			cmd /c cscript.exe $PSScriptRoot\cmd.js $PSScriptRoot\psexec.exe $server['server.name'] /accepteula -w $fullLocalReleaseWorkingFolder $batchFile $deploymentEnvironment $tasks		
		}
	}
}

function copy-packages($servers, $packageName)
{		
	$packageFolder = get-location
	import-module powerupfilesystem

	foreach ($server in $servers)
	{			
		$remotePath = $server['remote.temp.working.folder'] + '\' + $packageName
		echo "Copying deployment package to $remotePath"
		Copy-MirroredDirectory $packageFolder $remotePath
	}
}	

function get-serverSettings($settingsFile, $serverList)
{
	$serverNames = $serverList.split(';')
	$servers = @()
	
	foreach($serverName in $serverNames)
	{
		$serverSettings = get-parsedsettings $settingsFile $servername
		$servers += $serverSettings
	}
	
	$servers
}
				
export-modulemember -function invoke-remotetask, copy-packages, get-serverSettings