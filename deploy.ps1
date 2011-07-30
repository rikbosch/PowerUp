properties{
	$packageFolder = Get-Location
}


task default -depends importmodules, deployfiles, recreatesite

task importmodules {
	Import-Module PowerUpFileSystem
	Import-Module PowerUpWeb
}

task deployfiles {
	copy-mirroreddirectory $packageFolder\SimpleWebsite ${deployment.root}\${package.name} 
}

task recreatesite {
	set-webapppool ${website.name} "Integrated" "v4.0"
	set-website ${website.name} ${website.name} ${deployment.root}\${package.name} "" "http" "*" ${http.port} 	
	set-selfsignedsslcertificate ${website.name}
	set-sslbinding ${website.name} "*" ${https.port} 
	new-websitebinding ${website.name} ""  "https" "*" ${https.port} 
}
