properties{
}

include .\_powerup\commontasks.ps1

task default -depends deploy

task deploy -depends importsettings, importmodules, distributepackages {
	invoke-remotetasks web-deploy ${web.servers} ${deployment.environment} ${package.name}
}

task importmodules {
	import-module powerupfilesystem
	import-module powerupweb
}

task distributepackages {
	copy-packages ${all.servers} ${package.name}
}

task web-deploy -depends importsettings, importmodules {
	$packageFolder = get-location
	copy-mirroreddirectory $packageFolder\simplewebsite ${deployment.root}\${website.name} 

	set-webapppool ${website.name} "Integrated" "v4.0"
	set-website ${website.name} ${website.name} ${deployment.root}\${website.name} "" "http" "*" ${http.port} 	
	set-selfsignedsslcertificate ${website.name}
	set-sslbinding ${website.name} "*" ${https.port} 
	new-websitebinding ${website.name} ""  "https" "*" ${https.port} 
}

