include .\_powerup\commontasks.ps1

task deploy {
	run web-deploy-declarative ${web.servers}
}

task web-deploy-declarative  {
	import-module websiterecipes

	$websiteOptions = @{
		websitename = ${website.name};
		webroot = ${deployment.root};
		bindings = @(
					@{port = ${http.port};}
					@{port = ${https.port};protocol='https';}
					);
	}	
				
	set-website($websiteOptions)
}

task web-deploy-explicit  {
	import-module powerupfilesystem
	import-module powerupweb

	$packageFolder = get-location
	copy-mirroreddirectory $packageFolder\simplewebsite ${deployment.root}\${website.name} 

	set-webapppool ${website.name} "Integrated" "v4.0"
	set-website ${website.name} ${website.name} ${deployment.root}\${website.name} "" "http" "*" ${http.port} 	
}