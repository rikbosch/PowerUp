include .\_powerup\commontasks.ps1

task deploy {
	run web-deploy ${web.servers} 
}

task web-deploy  {
	import-module powerupfilesystem
	import-module powerupweb

	$packageFolder = get-location
	copy-mirroreddirectory $packageFolder\simplewebsite ${deployment.root}\${website.name} 

	set-webapppool ${website.name} "Integrated" "v4.0"
	set-website ${website.name} ${website.name} ${deployment.root}\${website.name} "" "http" "*" ${http.port} 	
}
