properties{
	$packageFolder = Get-Location
}


task default -depends importmodules, deployfiles, createsite

task importmodules {
	Import-Module PowerUpFileSystem
	Import-Module PowerUpWeb
	Import-Module WebAdministration
}

task deployfiles {
	copy-mirroreddirectory $packageFolder\${package.name} ${deployment.root}\${package.name} 
}

task createsite {
	set-webapppool "simplewebsite" "Integrated" "v4.0"
	set-website "simplewebsite" "simplewebsite" ${deployment.root}\${package.name} "" "http" "*" 9000 	
	new-websitebinding "simplewebsite" "www.sample.com"
}
