properties{
	$packageFolder = get-location
}

task default -depends deploy

task importmodules {
	import-module powerupfilesystem
	import-module powerupweb
}

task deploy -depends importmodules, distributepackages {
	$webservers = get-serversettings $packageFolder\servers.txt ${web.servers}
	invoke-remotetask $webservers web-deploy ${deployment.environment} ${package.name}
}

task distributepackages {
	$servers = get-serversettings $packageFolder\servers.txt ${all.servers}
	copy-packages $servers ${package.name}
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

