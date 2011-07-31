properties{
	$packageFolder = get-location
}

task default -depends importmodules, deployfiles, recreatesite

task importmodules {
	import-module powerupfilesystem
	import-module powerupweb
}

task deployfiles {
	copy-mirroreddirectory $packageFolder\simplewebsite ${deployment.root}\${website.name} 
}

task recreatesite {
	set-webapppool ${website.name} "Integrated" "v4.0"
	set-website ${website.name} ${website.name} ${deployment.root}\${website.name} "" "http" "*" ${http.port} 	
	set-selfsignedsslcertificate ${website.name}
	set-sslbinding ${website.name} "*" ${https.port} 
	new-websitebinding ${website.name} ""  "https" "*" ${https.port} 
}
