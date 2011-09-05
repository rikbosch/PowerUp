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

function invoke-remotetasks-ps( $tasks, $serverNames, $deploymentEnvironment, $packageName )
{	
	$currentLocation = get-location
	$servers = get-serversettings $currentLocation\servers.txt $serverNames

	foreach ($server in $servers)
	{			
		$serverName = $server['server.name']
		echo "===== Beginning execution of tasks $tasks on server $serverName ====="
	
		$fullLocalReleaseWorkingFolder = $server['local.temp.working.folder'] + '\' + $packageName
		$psakeFile = $fullLocalReleaseWorkingFolder + '\' + 'deploy_with_psake.ps1'

		Invoke-Command { powershell -inputformat none -command "$psakeFile -buildFile .\deploy.ps1 -deploymentEnvironment $deploymentEnvironment -tasks $tasks"} -computername $serverName
		
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
		$remoteDir = $server['remote.temp.working.folder']
		$serverName = $server['server.name']
		
		if(!$remoteDir)
		{
			throw "Setting remote.temp.working.folder not set for server $serverName"
		}
	
		$remotePath = $remoteDir + '\' + $packageName
		echo "Copying deployment package to $remotePath"
		Copy-MirroredDirectory $currentLocation $remotePath
	}
}	

function get-serverSettings($settingsFile, $serverList)
{
	$serverNames = $serverList.split(';')
	
	if (!$serverNames)
	{
		$serverNames = @($serverList)
	}
		
	$servers = @()
	
	foreach($serverName in $serverNames)
	{
		$serverSettings = get-parsedsettings $settingsFile $serverName		
		$servers += $serverSettings
	}
	
	$servers
}

function enable-psremotingforpowerup
{
	$nlm = [Activator]::CreateInstance([Type]::GetTypeFromCLSID([Guid]"{DCB00C01-570F-4A9B-8D69-199FDBA5723B}"))
	$connections = $nlm.getnetworkconnections()
	
	$connections |foreach {
		if ($_.getnetwork().getcategory() -eq 0)
		{
			$_.getnetwork().setcategory(1)
		}
	}

	Enable-PSRemoting -Force 

	$currentPath = get-location
	Copy-Item $currentPath\_powerup\powershell.exe.config -destination C:\Windows\System32\wsmprovhost.exe.config -force
}


				
export-modulemember -function invoke-remotetasks, invoke-remotetasks-ps, copy-packages, get-serverSettings, enable-psremotingforpowerup