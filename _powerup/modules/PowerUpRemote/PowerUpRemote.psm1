function invoke-remotetasks( $tasks, $serverNames, $deploymentEnvironment, $packageName )
{	
	$currentLocation = get-location
	$servers = get-serversettings $currentLocation\servers.txt $serverNames

	foreach ($server in $servers)
	{			
		$serverName = $server['server.name']
		echo "===== Beginning execution of tasks $tasks on server $serverName ====="
	
		$fullLocalReleaseWorkingFolder = $server['local.temp.working.folder'] + '\' + $packageName
		$batchFile = $fullLocalReleaseWorkingFolder + '\' + 'deploy.bat'

		if ($server.ContainsKey('username'))
		{
			cmd /c cscript.exe $PSScriptRoot\cmd.js $PSScriptRoot\psexec.exe $serverName /accepteula -u $server['username'] -p $server['password'] -w $fullLocalReleaseWorkingFolder $batchFile $deploymentEnvironment $tasks
		}
		else
		{
			cmd /c cscript.exe $PSScriptRoot\cmd.js $PSScriptRoot\psexec.exe $serverName /accepteula -w $fullLocalReleaseWorkingFolder $batchFile $deploymentEnvironment $tasks		
		}
		
		echo "========= Finished execution of tasks $tasks on server $serverName ====="

	}
}

function copy-packages($serverNames, $packageName)
{		
	$currentLocation = get-location
	$servers = get-serversettings $currentLocation\servers.txt $serverNames
	import-module powerupfilesystem

	foreach ($server in $servers)
	{			
		$remotePath = $server['remote.temp.working.folder'] + '\' + $packageName
		echo "Copying deployment package to $remotePath"
		Copy-MirroredDirectory $currentLocation $remotePath
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
				
export-modulemember -function invoke-remotetasks, copy-packages, get-serverSettings