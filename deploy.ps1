properties{
	$packageFolder = get-location
}

task default -depends deploy

task importmodules {
	import-module powerupfilesystem
	import-module powerupweb
}

task deploy -depends importmodules, distributepackages {
	invoke-remotetask @(${deployment.server}, ${deployment.server}) web-deploy
}

task distributepackages {
	copy-package ${remote.temp.working.folder}
}

task web-deploy -depends importmodules, deployfiles, recreatesite

task deployfiles  {
	copy-mirroreddirectory $packageFolder\simplewebsite ${deployment.root}\${website.name} 
}

task recreatesite {
	set-webapppool ${website.name} "Integrated" "v4.0"
	set-website ${website.name} ${website.name} ${deployment.root}\${website.name} "" "http" "*" ${http.port} 	
	set-selfsignedsslcertificate ${website.name}
	set-sslbinding ${website.name} "*" ${https.port} 
	new-websitebinding ${website.name} ""  "https" "*" ${https.port} 
}

function invoke-remotetask($servers, $tasks)
{	
	foreach ($server in $servers)
	{
		if (!${local.temp.working.folder})
			{throw "The setting 'local.temp.working.folder' is not set for this environment."}
			
		$fullLocalReleaseWorkingFolder = ${local.temp.working.folder} + '\' + ${package.name}
		$batchFile = $fullLocalReleaseWorkingFolder + '\' + 'deploy.bat'

		cmd /c cscript.exe _powerup\cmd.js _powerup\psexec.exe $server /accepteula -w $fullLocalReleaseWorkingFolder $batchFile ${deployment.environment} $tasks
	}
}

function copy-package($remotePath)
{		
	if (!${remote.temp.working.folder})
		{throw "The setting 'remote.temp.working.folder' is not set for this environment."}
	
	$fullDestinationFolder = $remotePath  + '\' + ${package.name}
			
	echo "Copying deployment package to $fullDestinationFolder"
	Copy-MirroredDirectory $packageFolder $fullDestinationFolder
}