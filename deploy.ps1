properties{
}

task default -depends deploy

task importmodules {
	import-module powerupfilesystem
	import-module powerupweb
}

task deploy -depends importmodules, distributepackages {
	$remoteFolder = ${local.temp.working.folder} + '\' + ${package.name}
	invoke-remotetask @(${deployment.server}, ${deployment.server}) web-deploy ${deployment.environment} $remoteFolder 
}

task distributepackages 
{
	$remotePath = ${remote.temp.working.folder} + '\' + ${package.name}
	copy-package $remotePath
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